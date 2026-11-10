"""Capa de acceso a datos: conexión a MySQL y lectura de tablas crudas."""
from __future__ import annotations

import pandas as pd

from src.config import TABLAS, get_database_url


def get_engine():
    """Crea el motor SQLAlchemy usando las credenciales del entorno."""
    from sqlalchemy import create_engine  # import tardío: facilita las pruebas

    return create_engine(get_database_url(), pool_pre_ping=True)


def cargar_tablas(conexion) -> dict[str, pd.DataFrame]:
    """Lee todas las tablas del esquema y las devuelve en un diccionario.

    Args:
        conexion: motor SQLAlchemy (o conexión DB-API, útil en pruebas).

    Returns:
        ``{nombre_tabla: DataFrame}``. Los DECIMAL llegan como ``float``.
    """
    return {
        tabla: pd.read_sql_query(f"SELECT * FROM {tabla}", conexion, coerce_float=True)
        for tabla in TABLAS
    }
