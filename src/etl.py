"""Transformación (ETL): de tablas crudas a un dataset analítico.

Convierte las tablas relacionales de ``merengon_magico`` en un objeto
``Dataset`` con las vistas que necesita el dashboard: ventas por ítem con
costo y utilidad, catálogo de productos con costo, inventario de insumos,
recetas y gastos diarios.
"""
from __future__ import annotations

from dataclasses import dataclass

import numpy as np
import pandas as pd

from src.config import CATEGORIAS_PRODUCTO


@dataclass
class Dataset:
    """Contenedor de las vistas analíticas ya limpias."""

    items: pd.DataFrame          # una fila por línea de venta (sin anuladas)
    productos: pd.DataFrame      # catálogo + costo por receta y por BOM
    insumos: pd.DataFrame        # inventario de materias primas
    receta_insumo: pd.DataFrame  # id_producto, id_insumo, cantidad
    gasto_diario: float          # gastos operativos promedio por día
    nomina_diaria: float         # nómina mensual / 30
    dias_obs: int                # días con ventas observados
    fecha_min: pd.Timestamp
    fecha_max: pd.Timestamp


def _num(df: pd.DataFrame, columnas: list[str]) -> pd.DataFrame:
    """Fuerza columnas numéricas (por si el driver devuelve Decimal/str)."""
    for c in columnas:
        df[c] = pd.to_numeric(df[c], errors="coerce")
    return df


def construir_productos(t: dict[str, pd.DataFrame]) -> pd.DataFrame:
    """Catálogo de productos con dos estimaciones de costo unitario.

    * ``costo_receta``: columna ``receta.costo_insumo`` (dato del negocio).
    * ``costo_bom``: suma de ``receta_insumo.cantidad * insumo.costo_und``.
    """
    prod = _num(t["producto"].copy(), ["precio_venta"])
    rec = _num(t["receta"].copy(), ["costo_insumo"])
    rec = rec[["id_producto", "costo_insumo"]].rename(columns={"costo_insumo": "costo_receta"})

    ri = _num(t["receta_insumo"].copy(), ["cantidad"])
    ins = _num(t["insumo"].copy(), ["costo_und"])
    bom = (
        ri.merge(t["receta"][["id_receta", "id_producto"]], on="id_receta")
        .merge(ins[["id_insumo", "costo_und"]], on="id_insumo")
        .assign(costo=lambda d: d["cantidad"] * d["costo_und"])
        .groupby("id_producto", as_index=False)["costo"].sum()
        .rename(columns={"costo": "costo_bom"})
    )
    prod = prod.merge(rec, on="id_producto", how="left").merge(bom, on="id_producto", how="left")
    prod["costo_bom"] = prod["costo_bom"].fillna(prod["costo_receta"])
    prod["categoria"] = prod["id_producto"].map(CATEGORIAS_PRODUCTO).fillna("Otros")
    return prod


def construir_dataset(t: dict[str, pd.DataFrame]) -> Dataset:
    """Arma el ``Dataset`` completo a partir de las tablas crudas."""
    productos = construir_productos(t)

    ventas = t["venta"].copy()
    ventas["fecha_venta"] = pd.to_datetime(ventas["fecha_venta"])
    ventas = ventas[ventas["estado"] != "Anulada"]

    det = _num(t["detalle_venta"].copy(), ["cantidad", "precio_und", "descuento", "subtotal"])
    items = det.merge(
        ventas[["id_venta", "fecha_venta", "estado", "metodo", "id_cliente"]],
        on="id_venta", how="inner",
    ).merge(
        productos[["id_producto", "nombre_prod", "categoria", "precio_venta",
                   "costo_receta", "costo_bom"]],
        on="id_producto", how="left",
    )
    items["fecha"] = items["fecha_venta"].dt.normalize()
    items["hora"] = items["fecha_venta"].dt.hour
    items["ingreso"] = items["subtotal"]  # neto de descuento, antes de IVA

    insumos = _num(t["insumo"].copy(), ["cantidadDisp", "stock", "costo_und"])
    insumos["fecha_venc"] = pd.to_datetime(insumos["fecha_venc"])

    ri = _num(t["receta_insumo"].copy(), ["cantidad"]).merge(
        t["receta"][["id_receta", "id_producto"]], on="id_receta"
    )[["id_producto", "id_insumo", "cantidad"]]

    gastos = _num(t["gasto"].copy(), ["valor"])
    gastos["fecha"] = pd.to_datetime(gastos["fecha"])
    dias_gasto = max((gastos["fecha"].max().normalize() - gastos["fecha"].min().normalize()).days + 1, 1)
    gasto_diario = float(gastos["valor"].sum() / dias_gasto)
    nomina_diaria = float(_num(t["empleado"].copy(), ["salario"])["salario"].sum() / 30.0)

    return Dataset(
        items=items,
        productos=productos,
        insumos=insumos,
        receta_insumo=ri,
        gasto_diario=gasto_diario,
        nomina_diaria=nomina_diaria,
        dias_obs=int(items["fecha"].nunique()),
        fecha_min=items["fecha"].min(),
        fecha_max=items["fecha"].max(),
    )


def aplicar_costo(items: pd.DataFrame, fuente: str = "receta") -> pd.DataFrame:
    """Agrega ``costo`` y ``utilidad_bruta`` a cada línea de venta.

    Args:
        fuente: ``"receta"`` (costo_insumo de la receta) o ``"bom"``
            (cantidades de ``receta_insumo`` x costo del insumo).
    """
    out = items.copy()
    col = "costo_bom" if fuente == "bom" else "costo_receta"
    out["costo"] = out["cantidad"] * out[col]
    out["utilidad_bruta"] = out["ingreso"] - out["costo"]
    return out


def resumen_productos(items: pd.DataFrame) -> pd.DataFrame:
    """Agrega ventas por producto: unidades, ingreso, costo y margen."""
    cols = ["id_producto", "nombre_prod", "categoria", "unidades", "ingreso",
            "costo", "utilidad_bruta", "margen_pct"]
    if items.empty:
        return pd.DataFrame(columns=cols)
    g = items.groupby(["id_producto", "nombre_prod", "categoria"], as_index=False).agg(
        unidades=("cantidad", "sum"), ingreso=("ingreso", "sum"), costo=("costo", "sum"),
    )
    g["utilidad_bruta"] = g["ingreso"] - g["costo"]
    g["margen_pct"] = np.where(g["ingreso"] > 0, g["utilidad_bruta"] / g["ingreso"], 0.0)
    return g[cols]


def ventas_por_dia(items: pd.DataFrame) -> pd.DataFrame:
    """Ingresos y unidades por día."""
    return (
        items.groupby("fecha", as_index=False)
        .agg(ingreso=("ingreso", "sum"), unidades=("cantidad", "sum"))
        .sort_values("fecha")
    )
