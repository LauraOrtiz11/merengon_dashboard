"""Modelo predictivo: simulación de escenarios de rentabilidad.

Idea del modelo (explicable en el informe)
------------------------------------------
1. **Demanda base** de cada producto: unidades vendidas / días con ventas.
2. **Efecto del escenario** (variables predictoras):
   precio, descuento, demanda esperada y elasticidad precio-demanda::

       demanda' = demanda_base * (1 + Δdemanda) * (precio_efectivo / precio_base) ** elasticidad

3. **Incertidumbre**: con pocos datos la demanda real puede alejarse de la
   observada. Se simula con Monte Carlo: la tasa diaria se muestrea de una
   Gamma (más ventas observadas = menos dispersión) y las unidades del
   horizonte de una Poisson.
4. **Resultado**: distribución de ingresos, costos y utilidad (P10/P50/P90) y
   probabilidad de pérdida.

Limitación declarada: el historial no tiene variación de precios, por eso la
elasticidad es un supuesto ajustable, no un parámetro estimado.
"""
from __future__ import annotations

from dataclasses import dataclass, field, replace

import numpy as np
import pandas as pd

from src.config import ELASTICIDAD_DEFECTO, SEMILLA, SIMULACIONES
from src.etl import Dataset


@dataclass(frozen=True)
class Escenario:
    """Valores asignados a las variables predictoras (fracciones: 0.10 = +10 %)."""

    nombre: str = "Escenario"
    delta_precio: float = 0.0
    descuento: float = 0.0
    delta_costo: float = 0.0
    delta_demanda: float = 0.0
    horizonte_dias: int = 7
    elasticidad: float = ELASTICIDAD_DEFECTO
    productos: tuple = ()          # ids a los que aplican precio/descuento/demanda; vacío = todos
    incluir_nomina: bool = False
    incluir_gastos: bool = True
    fuente_costo: str = "receta"   # "receta" | "bom"


@dataclass
class Resultado:
    """Salida de una simulación."""

    escenario: Escenario
    kpis: dict
    por_producto: pd.DataFrame
    utilidad_sim: np.ndarray = field(repr=False)


def escenarios_predefinidos(horizonte: int = 7) -> dict[str, Escenario]:
    """Los tres escenarios de prueba que se documentan en el informe."""
    return {
        "Base": Escenario(nombre="Base", horizonte_dias=horizonte),
        "Promoción": Escenario(
            nombre="Promoción", descuento=0.15, delta_demanda=0.10, horizonte_dias=horizonte),
        "Alza de costos": Escenario(
            nombre="Alza de costos", delta_costo=0.30, delta_precio=0.05,
            delta_demanda=-0.05, horizonte_dias=horizonte),
    }


def base_producto(ds: Dataset, esc: Escenario) -> pd.DataFrame:
    """Demanda histórica y costo unitario de los productos activos."""
    prod = ds.productos[ds.productos["estado"] == "Activo"].copy()
    unidades = ds.items.groupby("id_producto")["cantidad"].sum()
    prod["unidades_hist"] = prod["id_producto"].map(unidades).fillna(0.0)
    prod["lambda_dia"] = prod["unidades_hist"] / max(ds.dias_obs, 1)
    prod["costo_unit"] = prod["costo_bom" if esc.fuente_costo == "bom" else "costo_receta"]
    return prod.reset_index(drop=True)


def _vectores(base: pd.DataFrame, esc: Escenario):
    """Precio efectivo, costo unitario y demanda diaria ajustados al escenario."""
    if esc.productos:
        sel = base["id_producto"].isin(esc.productos).to_numpy()
    else:
        sel = np.ones(len(base), dtype=bool)
    ratio = np.where(sel, (1 + esc.delta_precio) * (1 - esc.descuento), 1.0)
    precio = base["precio_venta"].to_numpy() * ratio
    costo = base["costo_unit"].to_numpy() * (1 + esc.delta_costo)
    factor = np.where(sel, (1 + esc.delta_demanda) * np.power(ratio, esc.elasticidad), 1.0)
    lam = base["lambda_dia"].to_numpy() * factor
    return precio, costo, lam


def _gasto_fijo_dia(ds: Dataset, esc: Escenario) -> float:
    fijo = ds.gasto_diario if esc.incluir_gastos else 0.0
    return fijo + (ds.nomina_diaria if esc.incluir_nomina else 0.0)


def utilidad_esperada(base: pd.DataFrame, ds: Dataset, esc: Escenario) -> float:
    """Utilidad esperada determinística (sin simulación); base del tornado."""
    precio, costo, lam = _vectores(base, esc)
    contribucion = float((lam * esc.horizonte_dias * (precio - costo)).sum())
    return contribucion - _gasto_fijo_dia(ds, esc) * esc.horizonte_dias


def simular(ds: Dataset, esc: Escenario, n_sims: int = SIMULACIONES, seed: int = SEMILLA) -> Resultado:
    """Simula ``n_sims`` futuros posibles para el escenario dado."""
    base = base_producto(ds, esc)
    precio, costo, lam = _vectores(base, esc)
    rng = np.random.default_rng(seed)

    forma = np.maximum(base["unidades_hist"].to_numpy(), 0.5)
    escala = lam / forma
    tasa = rng.gamma(forma, escala, size=(n_sims, len(base)))
    unidades = rng.poisson(tasa * esc.horizonte_dias)

    ingreso_p = unidades * precio
    costo_p = unidades * costo
    gastos = _gasto_fijo_dia(ds, esc) * esc.horizonte_dias
    ingreso = ingreso_p.sum(axis=1)
    costos = costo_p.sum(axis=1)
    utilidad = ingreso - costos - gastos

    p10, p50, p90 = np.percentile(utilidad, [10, 50, 90])
    ing_m = float(ingreso.mean())
    kpis = {
        "ingreso": ing_m,
        "costo": float(costos.mean()),
        "contribucion": ing_m - float(costos.mean()),
        "margen_contribucion_pct": (ing_m - float(costos.mean())) / ing_m if ing_m else 0.0,
        "gastos": float(gastos),
        "cobertura_gastos": (ing_m - float(costos.mean())) / float(gastos) if gastos else float("nan"),
        "utilidad": float(utilidad.mean()),
        "utilidad_p10": float(p10), "utilidad_p50": float(p50), "utilidad_p90": float(p90),
        "prob_perdida": float((utilidad < 0).mean()),
        "unidades": float(unidades.sum(axis=1).mean()),
    }

    pp = base[["id_producto", "nombre_prod", "categoria"]].copy()
    pp["precio_efectivo"] = precio
    pp["costo_unit"] = costo
    pp["margen_unit"] = precio - costo
    pp["margen_pct"] = np.where(precio > 0, (precio - costo) / precio, 0.0)
    pp["unidades_esp"] = unidades.mean(axis=0)
    pp["u_p10"], pp["u_p50"], pp["u_p90"] = np.percentile(unidades, [10, 50, 90], axis=0)
    pp["ingreso"] = ingreso_p.mean(axis=0)
    pp["contribucion"] = ingreso_p.mean(axis=0) - costo_p.mean(axis=0)
    return Resultado(escenario=esc, kpis=kpis, por_producto=pp, utilidad_sim=utilidad)


_VARIACIONES = (
    ("Precio de venta (±10 pp)", "delta_precio", 0.10, -0.5, 0.5),
    ("Descuento (±5 pp)", "descuento", 0.05, 0.0, 0.5),
    ("Costo de insumos (±20 pp)", "delta_costo", 0.20, -0.5, 1.0),
    ("Demanda esperada (±20 pp)", "delta_demanda", 0.20, -0.9, 3.0),
    ("Elasticidad (±0,5)", "elasticidad", 0.5, -4.0, 0.0),
)


def sensibilidad(ds: Dataset, esc: Escenario) -> pd.DataFrame:
    """Cambio en la utilidad esperada al mover cada variable alrededor del escenario."""
    base = base_producto(ds, esc)
    ref = utilidad_esperada(base, ds, esc)
    filas = []
    for etiqueta, campo, paso, lo, hi in _VARIACIONES:
        valor = getattr(esc, campo)
        menor = utilidad_esperada(base, ds, replace(esc, **{campo: max(lo, valor - paso)})) - ref
        mayor = utilidad_esperada(base, ds, replace(esc, **{campo: min(hi, valor + paso)})) - ref
        filas.append({"factor": etiqueta, "menor": menor, "mayor": mayor,
                      "rango": abs(mayor - menor)})
    return pd.DataFrame(filas).sort_values("rango").reset_index(drop=True)


def comparar(ds: Dataset, escenarios: dict[str, Escenario]) -> pd.DataFrame:
    """Tabla comparativa de KPIs entre varios escenarios."""
    filas = []
    for nombre, esc in escenarios.items():
        k = simular(ds, esc).kpis
        filas.append({
            "escenario": nombre, "ingreso": k["ingreso"], "costo": k["costo"],
            "contribucion": k["contribucion"], "gastos": k["gastos"],
            "utilidad_media": k["utilidad"], "utilidad_p10": k["utilidad_p10"],
            "utilidad_p90": k["utilidad_p90"], "prob_perdida": k["prob_perdida"],
            "unidades": k["unidades"],
        })
    return pd.DataFrame(filas)
