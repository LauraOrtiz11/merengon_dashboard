"""Gráficos Plotly del dashboard (solo construyen figuras; no leen datos)."""
from __future__ import annotations

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

from src.theme import COLORES, SECUENCIA, formato_cop

_COLOR_CUADRANTE = {
    "Estrella": COLORES["fresa"], "Impulsar": COLORES["maracuya"],
    "Optimizar costo/precio": COLORES["menta"], "Revisar": COLORES["gris"],
}


def _estilo(fig: go.Figure, titulo: str = "", alto: int = 360) -> go.Figure:
    """Aplica tipografía, márgenes y colores coherentes con la marca."""
    fig.update_layout(
        title_text=titulo, title_x=0.01, height=alto,
        margin=dict(l=10, r=10, t=50 if titulo else 20, b=10),
        paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
        font=dict(family="Poppins, sans-serif", color=COLORES["chocolate"]),
        colorway=SECUENCIA, legend=dict(orientation="h", y=-0.2),
    )
    fig.update_xaxes(showgrid=False)
    fig.update_yaxes(gridcolor="#EADBD0")
    return fig


def ventas_diarias(df: pd.DataFrame) -> go.Figure:
    """Ingresos por día con línea de tendencia lineal."""
    fig = go.Figure()
    fig.add_bar(x=df["fecha"], y=df["ingreso"], name="Ingresos", marker_color=COLORES["fresa"])
    if len(df) >= 3:
        x = np.arange(len(df))
        m, b = np.polyfit(x, df["ingreso"].to_numpy(), 1)
        fig.add_scatter(x=df["fecha"], y=m * x + b, mode="lines", name="Tendencia lineal",
                        line=dict(color=COLORES["chocolate"], dash="dash"))
    fig.update_xaxes(tickformat="%d %b")
    fig.update_yaxes(tickprefix="$", separatethousands=True)
    return _estilo(fig, "Ingresos diarios")


def ranking_productos(res: pd.DataFrame, columna: str, n: int, mayor: bool) -> go.Figure:
    """Barras horizontales con los productos de mayor o menor ``columna``."""
    d = res.nlargest(n, columna) if mayor else res.nsmallest(n, columna)
    d = d.sort_values(columna, ascending=mayor)
    color = COLORES["fresa"] if mayor else COLORES["maracuya"]
    fig = go.Figure(go.Bar(y=d["nombre_prod"], x=d[columna], orientation="h", marker_color=color))
    titulo = f"{'Más' if mayor else 'Menos'} vendidos por {'unidades' if columna == 'unidades' else 'ingreso'}"
    if columna == "ingreso":
        fig.update_xaxes(tickprefix="$", separatethousands=True)
    return _estilo(fig, titulo)


def treemap_categorias(res: pd.DataFrame) -> go.Figure:
    """Drill-down categoría -> producto; el color indica el margen."""
    d = res[res["ingreso"] > 0]
    fig = px.treemap(
        d, path=[px.Constant("Merengón Mágico"), "categoria", "nombre_prod"],
        values="ingreso", color="margen_pct",
        color_continuous_scale=[[0, COLORES["rosa_claro"]], [1, COLORES["fresa"]]],
    )
    fig.update_coloraxes(colorbar_title="Margen", colorbar_tickformat=".0%")
    fig.update_traces(hovertemplate="%{label}<br>Ingreso: $%{value:,.0f}<extra></extra>")
    return _estilo(fig, "Ingresos por categoría (clic para profundizar)", alto=420)


def histograma_utilidad(sim: np.ndarray, p10: float, p50: float, p90: float) -> go.Figure:
    """Distribución simulada de la utilidad con P10/P50/P90 y punto de equilibrio."""
    fig = px.histogram(x=sim, nbins=40, color_discrete_sequence=[COLORES["maracuya"]])
    for valor, nombre, pos, color in (
        (p10, "P10", "top left", COLORES["gris"]),
        (p50, "P50", "top", COLORES["fresa"]),
        (p90, "P90", "top right", COLORES["gris"]),
    ):
        fig.add_vline(x=valor, line_dash="dash", line_color=color,
                      annotation_text=f"{nombre}: {formato_cop(valor)}", annotation_position=pos)
    fig.add_vline(x=0, line_color=COLORES["chocolate"], line_width=2)
    fig.update_xaxes(title="Utilidad operativa del horizonte (COP)", tickprefix="$",
                     separatethousands=True)
    fig.update_yaxes(title="Frecuencia")
    return _estilo(fig, "Distribución de la utilidad (3.000 simulaciones)")


def tornado(sens: pd.DataFrame) -> go.Figure:
    """Sensibilidad: cambio de utilidad al mover cada variable."""
    fig = go.Figure()
    fig.add_bar(y=sens["factor"], x=sens["menor"], orientation="h",
                name="Variable menor", marker_color=COLORES["menta"])
    fig.add_bar(y=sens["factor"], x=sens["mayor"], orientation="h",
                name="Variable mayor", marker_color=COLORES["fresa"])
    fig.update_layout(barmode="overlay")
    fig.update_xaxes(title="Cambio en la utilidad esperada (COP)", tickprefix="$",
                     separatethousands=True)
    return _estilo(fig, "¿Qué variable mueve más la utilidad?")


def unidades_producto(df: pd.DataFrame) -> go.Figure:
    """Unidades esperadas por producto con rango P10-P90."""
    d = df.sort_values("unidades_esp")
    mas = np.maximum(d["u_p90"].to_numpy() - d["unidades_esp"].to_numpy(), 0)
    menos = np.maximum(d["unidades_esp"].to_numpy() - d["u_p10"].to_numpy(), 0)
    fig = go.Figure(go.Bar(
        y=d["nombre_prod"], x=d["unidades_esp"], orientation="h", marker_color=COLORES["fresa"],
        error_x=dict(type="data", symmetric=False, array=mas, arrayminus=menos),
    ))
    fig.update_xaxes(title="Unidades esperadas en el horizonte (barra: rango P10-P90)")
    return _estilo(fig, "Demanda proyectada por producto", alto=520)


def comparacion_escenarios(df: pd.DataFrame) -> go.Figure:
    """Utilidad media por escenario con rango P10-P90."""
    mas = (df["utilidad_p90"] - df["utilidad_media"]).clip(lower=0).to_numpy()
    menos = (df["utilidad_media"] - df["utilidad_p10"]).clip(lower=0).to_numpy()
    fig = go.Figure(go.Bar(
        x=df["escenario"], y=df["utilidad_media"], marker_color=SECUENCIA[: len(df)],
        error_y=dict(type="data", symmetric=False, array=mas, arrayminus=menos),
    ))
    fig.update_yaxes(title="Utilidad operativa (COP)", tickprefix="$", separatethousands=True)
    return _estilo(fig, "Comparación de escenarios")


def matriz_productos(df: pd.DataFrame) -> go.Figure:
    """Rotación vs margen; el tamaño es el ingreso."""
    d = df[df["ingreso"] > 0]
    fig = px.scatter(
        d, x="unidades", y="margen_pct", size="ingreso", color="cuadrante",
        hover_name="nombre_prod", color_discrete_map=_COLOR_CUADRANTE, size_max=40,
    )
    fig.add_vline(x=d["unidades"].median(), line_dash="dot", line_color=COLORES["gris"])
    fig.add_hline(y=d["margen_pct"].median(), line_dash="dot", line_color=COLORES["gris"])
    fig.update_xaxes(title="Unidades vendidas")
    fig.update_yaxes(title="Margen bruto", tickformat=".0%")
    return _estilo(fig, "Matriz de prioridad: rotación vs margen", alto=440)


def ranking_insumos(df: pd.DataFrame, columna: str, titulo: str, color: str) -> go.Figure:
    """Top 10 de insumos por valor (compra recomendada o valor en riesgo)."""
    d = df[df[columna] > 0].nlargest(10, columna).sort_values(columna)
    fig = go.Figure(go.Bar(y=d["nombre_insumo"], x=d[columna], orientation="h", marker_color=color))
    fig.update_xaxes(tickprefix="$", separatethousands=True)
    return _estilo(fig, titulo)
