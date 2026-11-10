"""Identidad visual (paleta, tipografía, formatos) del dashboard.

Paleta inspirada en el producto: fresa, crema de merengue, chocolate y
maracuyá. Para cambiar la imagen corporativa basta con editar ``COLORES``
y el archivo ``.streamlit/config.toml``.
"""
from __future__ import annotations

COLORES = {
    "fresa": "#D94F7A",
    "crema": "#FFF7EE",
    "chocolate": "#4E342E",
    "maracuya": "#F2A93B",
    "menta": "#6BBF9F",
    "rosa_claro": "#F9D5E0",
    "gris": "#8D7B73",
}
SECUENCIA = [COLORES["fresa"], COLORES["maracuya"], COLORES["menta"],
             COLORES["chocolate"], "#B07AA1", "#7FB3D5"]

_CSS = f"""
<style>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
html, body, [class*="css"], .stApp {{ font-family: 'Poppins', sans-serif; }}
h1, h2, h3 {{ color: {COLORES['chocolate']}; font-weight: 700; }}
[data-testid="stMetric"] {{
    background: #FFFFFF; border-left: 6px solid {COLORES['fresa']};
    border-radius: 12px; padding: 12px 16px; box-shadow: 0 2px 8px rgba(78,52,46,.10);
}}
[data-testid="stMetricLabel"] {{ color: {COLORES['gris']}; }}
.stTabs [data-baseweb="tab"] {{ font-weight: 600; }}
.caja-reco {{
    background: #FFFFFF; border-left: 6px solid {COLORES['maracuya']};
    border-radius: 12px; padding: 12px 18px; margin-bottom: 8px;
}}
</style>
"""


def inyectar_css() -> None:
    """Aplica la hoja de estilos del dashboard."""
    import streamlit as st

    st.markdown(_CSS, unsafe_allow_html=True)


def formato_cop(valor: float) -> str:
    """Formatea pesos colombianos: 1234567 -> ``$1.234.567``."""
    signo = "-" if valor < 0 else ""
    return f"{signo}${abs(valor):,.0f}".replace(",", ".")


def formato_pct(valor: float, decimales: int = 1) -> str:
    """Formatea una fracción como porcentaje con coma decimal."""
    return f"{valor * 100:.{decimales}f}%".replace(".", ",")
