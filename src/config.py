"""Configuración central del dashboard de Merengón Mágico.

Aquí viven las constantes del negocio y la construcción segura de la conexión
a MySQL. Las credenciales NUNCA se escriben en el código: se leen de variables
de entorno o del archivo ``.env`` (ver ``.env.example``).
"""
from __future__ import annotations

import os
from pathlib import Path
from urllib.parse import quote_plus

try:  # python-dotenv es opcional para poder probar la lógica sin instalarlo
    from dotenv import load_dotenv
except ImportError:  # pragma: no cover
    load_dotenv = None

BASE_DIR = Path(__file__).resolve().parent.parent
if load_dotenv is not None:
    load_dotenv(BASE_DIR / ".env")

NOMBRE_NEGOCIO = "Merengón Mágico"

#: Tablas que se leen de la base de datos ``merengon_magico``.
TABLAS = (
    "cliente", "compra", "detalle_compra", "detalle_venta", "empleado",
    "gasto", "insumo", "pago", "producto", "proveedor", "receta",
    "receta_insumo", "venta",
)

#: La base de datos no trae categoría de producto; esta clasificación es una
#: decisión del equipo (id_producto -> categoría) y puede editarse libremente.
CATEGORIAS_PRODUCTO = {
    1: "Merengones", 2: "Merengones", 3: "Merengones", 4: "Merengones",
    5: "Merengones", 7: "Merengones",
    6: "Frutas", 18: "Frutas", 19: "Frutas",
    13: "Tortas y horneados", 14: "Tortas y horneados",
    15: "Tortas y horneados", 16: "Tortas y horneados",
    8: "Postres tradicionales", 9: "Postres tradicionales",
    10: "Postres tradicionales", 11: "Postres tradicionales",
    12: "Postres tradicionales", 17: "Postres tradicionales",
    20: "Postres tradicionales",
}

#: Parámetros por defecto del modelo predictivo.
ELASTICIDAD_DEFECTO = -1.2   # supuesto: 1 % más de precio -> 1,2 % menos de demanda
SIMULACIONES = 3000          # corridas Monte Carlo
SEMILLA = 42                 # reproducibilidad


def get_database_url() -> str:
    """Devuelve la URL de conexión SQLAlchemy a partir del entorno.

    Prioridad: ``DATABASE_URL`` y, si no existe, ``DB_HOST``, ``DB_PORT``,
    ``DB_USER``, ``DB_PASSWORD`` y ``DB_NAME``.
    """
    url = os.getenv("DATABASE_URL")
    if url:
        return url
    usuario = os.getenv("DB_USER", "root")
    clave = quote_plus(os.getenv("DB_PASSWORD", ""))
    host = os.getenv("DB_HOST", "localhost")
    puerto = os.getenv("DB_PORT", "3306")
    nombre = os.getenv("DB_NAME", "merengon_magico")
    return f"mysql+pymysql://{usuario}:{clave}@{host}:{puerto}/{nombre}?charset=utf8mb4"
