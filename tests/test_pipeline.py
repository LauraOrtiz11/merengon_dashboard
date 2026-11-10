"""Pruebas de la lógica (ETL, modelo y recomendaciones) sin MySQL.

Carga ``database/merengon_magico.sql`` en SQLite en memoria y verifica
invariantes básicos. Ejecutar:  ``python -m tests.test_pipeline``
"""
from __future__ import annotations

import re
import sqlite3
from pathlib import Path

import pandas as pd

from src import data_loader, etl, model, recommender

SQL = Path(__file__).resolve().parent.parent / "database" / "merengon_magico.sql"


def sqlite_desde_dump() -> sqlite3.Connection:
    """Convierte el dump de MySQL en una base SQLite en memoria (solo para pruebas)."""
    txt = SQL.read_text(encoding="utf8").replace("\r", "")
    con = sqlite3.connect(":memory:")
    for m in re.finditer(r"CREATE TABLE `(\w+)` \((.*?)\) ENGINE", txt, re.S):
        cols = [re.match(r"\s*`(\w+)`", ln).group(1)
                for ln in m.group(2).split("\n") if re.match(r"\s*`\w+`", ln)]
        con.execute(f"CREATE TABLE {m.group(1)} ({','.join(cols)})")
    for m in re.finditer(r"^INSERT INTO `\w+` VALUES .*;$", txt, re.M):
        con.executescript(m.group(0))
    return con


def main() -> None:
    con = sqlite_desde_dump()
    ds = etl.construir_dataset(data_loader.cargar_tablas(con))

    # 1) El ingreso del ETL coincide con el detalle de ventas no anuladas
    esperado = pd.read_sql_query(
        "SELECT SUM(d.subtotal) s FROM detalle_venta d JOIN venta v USING(id_venta) "
        "WHERE v.estado <> 'Anulada'", con)["s"][0]
    assert abs(ds.items["ingreso"].sum() - esperado) < 1e-6

    # 2) El modelo es reproducible y coherente
    base = model.escenarios_predefinidos()
    r1, r2 = model.simular(ds, base["Base"]), model.simular(ds, base["Base"])
    assert r1.kpis["utilidad"] == r2.kpis["utilidad"]
    assert r1.kpis["ingreso"] > 0

    # 3) Subir el costo de insumos baja la utilidad
    caro = model.simular(ds, base["Alza de costos"])
    assert caro.kpis["costo"] > r1.kpis["costo"]

    # 4) El plan de compras no devuelve cantidades negativas
    plan = recommender.plan_compras(ds, r1.por_producto, 7, ds.fecha_max)
    assert (plan["comprar"] >= 0).all()

    print("OK - todas las pruebas pasaron")
    print(model.comparar(ds, base).round(0).to_string())


if __name__ == "__main__":
    main()
