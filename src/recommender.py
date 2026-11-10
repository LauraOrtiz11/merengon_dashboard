"""Capa prescriptiva: qué comprar, qué priorizar y qué hacer.

Convierte los resultados del modelo (unidades esperadas por producto) en
decisiones: plan de compras de insumos, alertas de vencimiento y clasificación
de productos para definir prioridades de venta.
"""
from __future__ import annotations

import numpy as np
import pandas as pd

from src.etl import Dataset
from src.theme import formato_cop


def plan_compras(
    ds: Dataset,
    por_producto: pd.DataFrame,
    horizonte_dias: int,
    fecha_ref: pd.Timestamp,
    nivel: str = "esperado",
    descontar_vencidos: bool = False,
    respetar_stock_minimo: bool = True,
) -> pd.DataFrame:
    """Calcula necesidades de compra y riesgo de desperdicio por insumo.

    Args:
        por_producto: salida de ``model.simular`` (``unidades_esp`` y ``u_p90``).
        nivel: ``"esperado"`` (demanda media) o ``"seguro"`` (percentil 90).
        descontar_vencidos: si es True, el stock vencido no cuenta como disponible
            (por defecto False: la mayoría de fechas de la BD parecen desactualizadas).
        respetar_stock_minimo: si es True, se exige mantener la columna ``stock``
            como inventario mínimo (supuesto a validar con el negocio).

    Returns:
        DataFrame por insumo con ``requerido``, ``comprar``, ``costo_compra``,
        ``valor_riesgo`` y la ``accion`` sugerida.
    """
    col = "u_p90" if nivel == "seguro" else "unidades_esp"
    ri = ds.receta_insumo.merge(por_producto[["id_producto", col]], on="id_producto")
    ri["req"] = ri["cantidad"] * ri[col]
    requerido = ri.groupby("id_insumo")["req"].sum()

    ins = ds.insumos.copy()
    ins["requerido"] = ins["id_insumo"].map(requerido).fillna(0.0)
    ins["dias_venc"] = (ins["fecha_venc"] - pd.Timestamp(fecha_ref)).dt.days
    ins["vencido"] = ins["dias_venc"] < 0
    ins["disp_util"] = np.where(ins["vencido"] & descontar_vencidos, 0.0, ins["cantidadDisp"])
    minimo = ins["stock"] if respetar_stock_minimo else 0.0
    ins["comprar"] = np.ceil(np.maximum(0.0, ins["requerido"] + minimo - ins["disp_util"]))
    ins["costo_compra"] = ins["comprar"] * ins["costo_und"]

    uso_dia = ins["requerido"] / max(horizonte_dias, 1)
    consumo_hasta_venc = uso_dia * ins["dias_venc"].clip(lower=0)
    ventana = max(horizonte_dias, 30)
    sobrante = np.where(
        ins["vencido"], ins["cantidadDisp"],
        np.where(ins["dias_venc"] <= ventana,
                 np.maximum(0.0, ins["cantidadDisp"] - consumo_hasta_venc), 0.0),
    )
    ins["valor_riesgo"] = sobrante * ins["costo_und"]

    def accion(r) -> str:
        if r["vencido"] and descontar_vencidos:
            return "Dar de baja y reponer" if r["requerido"] > 0 else "Dar de baja"
        if r["comprar"] > 0:
            return "Comprar"
        if r["valor_riesgo"] > 0:
            return "Usar primero / promocionar"
        if r["vencido"]:
            return "Verificar vencimiento"
        return "Suficiente"

    ins["accion"] = ins.apply(accion, axis=1)
    cols = ["id_insumo", "nombre_insumo", "und_medida", "cantidadDisp", "stock", "costo_und",
            "fecha_venc", "dias_venc", "requerido", "comprar", "costo_compra",
            "valor_riesgo", "accion"]
    return ins[cols].sort_values(["costo_compra", "valor_riesgo"], ascending=False).reset_index(drop=True)


_ACCIONES = {
    "Estrella": "Mantener disponibilidad y destacarlo en vitrina; no lo incluyas en descuentos.",
    "Impulsar": "Buen margen pero poca rotación: promocionarlo, combos o ubicación visible.",
    "Optimizar costo/precio": "Se vende mucho con margen relativo bajo: renegociar insumos o ajustar precio.",
    "Revisar": "Poca rotación y margen relativo bajo: producir bajo pedido o evaluar retirarlo.",
}


def clasificar_productos(res: pd.DataFrame) -> pd.DataFrame:
    """Clasifica productos por rotación y margen (relativos a la mediana)."""
    out = res.copy()
    if out.empty:
        out["cuadrante"] = []
        out["recomendacion"] = []
        return out
    alta_u = out["unidades"] >= out["unidades"].median()
    alto_m = out["margen_pct"] >= out["margen_pct"].median()
    out["cuadrante"] = np.select(
        [alta_u & alto_m, ~alta_u & alto_m, alta_u & ~alto_m],
        ["Estrella", "Impulsar", "Optimizar costo/precio"],
        default="Revisar",
    )
    out["recomendacion"] = out["cuadrante"].map(_ACCIONES)
    return out


def recomendaciones_texto(kpis: dict, compras: pd.DataFrame, clasif: pd.DataFrame) -> list[str]:
    """Genera las recomendaciones gerenciales en lenguaje natural."""
    msgs = [
        f"Con este escenario la utilidad esperada es {formato_cop(kpis['utilidad'])} "
        f"(rango probable {formato_cop(kpis['utilidad_p10'])} a {formato_cop(kpis['utilidad_p90'])}); "
        f"la probabilidad de pérdida es {kpis['prob_perdida']:.0%}."
    ]
    comprar = compras[compras["comprar"] > 0]
    if len(comprar):
        top = ", ".join(comprar.head(3)["nombre_insumo"])
        msgs.append(
            f"Compras: reponer {len(comprar)} insumos por {formato_cop(comprar['costo_compra'].sum())}; "
            f"prioriza {top}."
        )
    else:
        msgs.append("Compras: el inventario útil cubre la demanda proyectada; no se requieren compras.")
    venc = compras[compras["dias_venc"] < 0]
    if len(venc):
        msgs.append(
            f"Desperdicio: {len(venc)} insumos aparecen vencidos en la base de datos "
            f"({formato_cop(venc['valor_riesgo'].sum())} en inventario); confirma las fechas y retira lo que ya no sirva."
        )
    pronto = compras[compras["accion"] == "Usar primero / promocionar"]
    if len(pronto):
        msgs.append(f"Rotación: usa primero {', '.join(pronto.head(3)['nombre_insumo'])} (vencen pronto).")
    if not clasif.empty:
        est = clasif[clasif["cuadrante"] == "Estrella"].nlargest(3, "ingreso")["nombre_prod"]
        imp = clasif[clasif["cuadrante"] == "Impulsar"].nlargest(3, "margen_pct")["nombre_prod"]
        if len(est):
            msgs.append(f"Productos prioritarios: {', '.join(est)}.")
        if len(imp):
            msgs.append(f"Para impulsar con promoción o combos: {', '.join(imp)}.")
    return msgs
