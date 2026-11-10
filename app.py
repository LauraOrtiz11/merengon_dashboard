"""Dashboard de analítica prescriptiva · Merengón Mágico (Streamlit).

Punto de entrada de la interfaz. La lógica vive en ``src/``:
``data_loader`` (MySQL) -> ``etl`` (limpieza) -> ``model`` (predicción) ->
``recommender`` (prescripción) -> ``charts`` (gráficos).

Ejecutar:  ``streamlit run app.py``
"""
from __future__ import annotations

import pandas as pd
import streamlit as st

from src import charts, config, data_loader, etl, model, recommender
from src.theme import COLORES, formato_cop, formato_pct, inyectar_css

st.set_page_config(page_title="Merengón Mágico · Analítica prescriptiva",
                   page_icon="🍰", layout="wide")
inyectar_css()


@st.cache_data(ttl=600, show_spinner="Cargando datos desde MySQL…")
def cargar_dataset() -> etl.Dataset:
    """Lee MySQL y construye el dataset analítico (se cachea 10 minutos)."""
    motor = data_loader.get_engine()
    return etl.construir_dataset(data_loader.cargar_tablas(motor))


try:
    ds = cargar_dataset()
except Exception as exc:  # noqa: BLE001 - se muestra al usuario con instrucciones
    st.error("No se pudo conectar con la base de datos MySQL.")
    st.info("Revisa que MySQL esté encendido, que importaste `merengon_magico.sql` y que el "
            "archivo `.env` tenga el usuario y la contraseña correctos (ver README.md).")
    st.exception(exc)
    st.stop()

# ───────────────────────────── Barra lateral: filtros globales ─────────────────────────────
st.sidebar.title("🍰 Filtros")
fmin, fmax = ds.fecha_min.date(), ds.fecha_max.date()
rango = st.sidebar.date_input("Rango de fechas", value=(fmin, fmax), min_value=fmin, max_value=fmax)
f0, f1 = (rango if isinstance(rango, (tuple, list)) and len(rango) == 2 else (fmin, fmax))

categorias = sorted(ds.productos["categoria"].unique())
cats_sel = st.sidebar.multiselect("Categorías", categorias, default=categorias)
opciones_prod = sorted(ds.productos[ds.productos["categoria"].isin(cats_sel)]["nombre_prod"])
prods_sel = st.sidebar.multiselect("Productos", opciones_prod, default=opciones_prod)
estados = st.sidebar.multiselect("Estado de la venta", ["Pagada", "Pendiente"],
                                 default=["Pagada", "Pendiente"])
metodos = sorted(ds.items["metodo"].dropna().unique())
metodos_sel = st.sidebar.multiselect("Método de pago", metodos, default=metodos)
fuente_costo = st.sidebar.radio(
    "Fuente del costo unitario", ["receta", "bom"],
    format_func=lambda x: "Costo de la receta (BD)" if x == "receta" else "Calculado: insumos × cantidad",
    help="Las dos fuentes difieren en la base de datos; compara ambas para validar costos.",
)

items_c = etl.aplicar_costo(ds.items, fuente_costo)
mask = (
    (items_c["fecha"] >= pd.Timestamp(f0)) & (items_c["fecha"] <= pd.Timestamp(f1))
    & items_c["categoria"].isin(cats_sel) & items_c["nombre_prod"].isin(prods_sel)
    & items_c["estado"].isin(estados) & items_c["metodo"].isin(metodos_sel)
)
items_f = items_c[mask]

st.title(f"🍰 {config.NOMBRE_NEGOCIO}")
st.caption("Sistema de análisis prescriptivo para la gestión de ventas e inventario")

tab_res, tab_sim, tab_prod, tab_inv = st.tabs(
    ["📊 Resumen ejecutivo", "🔮 Simulador de escenarios", "🏆 Productos", "📦 Inventario y compras"]
)

# ───────────────────────────── 1. Resumen ejecutivo ─────────────────────────────
with tab_res:
    if items_f.empty:
        st.warning("No hay ventas con los filtros seleccionados.")
    else:
        res_f = etl.resumen_productos(items_f)
        n_ventas = items_f["id_venta"].nunique()
        ingreso, util = items_f["ingreso"].sum(), items_f["utilidad_bruta"].sum()
        c = st.columns(5)
        c[0].metric("Ingresos (sin IVA)", formato_cop(ingreso))
        c[1].metric("Utilidad bruta", formato_cop(util))
        c[2].metric("Margen bruto", formato_pct(util / ingreso if ingreso else 0))
        c[3].metric("Unidades vendidas", f"{int(items_f['cantidad'].sum())}")
        c[4].metric("Ticket promedio", formato_cop(ingreso / n_ventas))

        izq, der = st.columns(2)
        izq.plotly_chart(charts.ventas_diarias(etl.ventas_por_dia(items_f)), use_container_width=True)
        modo = der.radio("Ranking", ["Más vendidos", "Menos vendidos"], horizontal=True)
        metrica = der.radio("Medir por", ["unidades", "ingreso"], horizontal=True)
        der.plotly_chart(charts.ranking_productos(res_f, metrica, 8, modo == "Más vendidos"),
                         use_container_width=True)
        st.plotly_chart(charts.treemap_categorias(res_f), use_container_width=True)

# ───────────────────────────── 2. Simulador (predictivo) ─────────────────────────────
PRESETS = {
    "Personalizado": None,
    **model.escenarios_predefinidos(),
}
DEFECTOS = {"s_precio": 0, "s_desc": 0, "s_costo": 0, "s_demanda": 0, "s_horizonte": 7,
            "s_elast": config.ELASTICIDAD_DEFECTO}
for clave, valor in DEFECTOS.items():
    st.session_state.setdefault(clave, valor)


def aplicar_preset() -> None:
    """Carga en los controles los valores del escenario elegido."""
    p = PRESETS[st.session_state["preset"]]
    if p is None:
        return
    st.session_state.update(
        s_precio=round(p.delta_precio * 100), s_desc=round(p.descuento * 100),
        s_costo=round(p.delta_costo * 100), s_demanda=round(p.delta_demanda * 100),
        s_horizonte=p.horizonte_dias, s_elast=p.elasticidad,
    )


with tab_sim:
    st.subheader("¿Cuánto ganaríamos si cambiamos precio, descuento, costos o demanda?")
    ctrl, out = st.columns([1, 3])
    with ctrl:
        st.selectbox("Escenario", list(PRESETS), key="preset", on_change=aplicar_preset)
        st.slider("Cambio en precio (%)", -30, 30, key="s_precio")
        st.slider("Descuento promocional (%)", 0, 30, key="s_desc")
        st.slider("Cambio en costo de insumos (%)", -20, 50, key="s_costo")
        st.slider("Cambio en demanda esperada (%)", -50, 100, key="s_demanda")
        st.slider("Horizonte (días)", 1, 60, key="s_horizonte")
        st.slider("Elasticidad precio-demanda", -3.0, 0.0, step=0.1, key="s_elast",
                  help="Supuesto: con -1,2, subir 10 % el precio baja ~12 % la demanda.")
        alcance = st.multiselect("Aplicar precio/descuento/demanda a categorías", categorias,
                                 default=categorias)
        usar_gastos = st.checkbox("Descontar gastos operativos registrados", value=True)
        usar_nomina = st.checkbox("Incluir nómina (salarios/30 por día)", value=False)

    ids_alcance = tuple(ds.productos[ds.productos["categoria"].isin(alcance)]["id_producto"])
    esc = model.Escenario(
        nombre=st.session_state["preset"],
        delta_precio=st.session_state["s_precio"] / 100,
        descuento=st.session_state["s_desc"] / 100,
        delta_costo=st.session_state["s_costo"] / 100,
        delta_demanda=st.session_state["s_demanda"] / 100,
        horizonte_dias=st.session_state["s_horizonte"],
        elasticidad=st.session_state["s_elast"],
        productos=ids_alcance, incluir_nomina=usar_nomina, incluir_gastos=usar_gastos,
        fuente_costo=fuente_costo,
    )
    res = model.simular(ds, esc)
    ref = model.simular(ds, model.Escenario(
        nombre="Referencia", horizonte_dias=esc.horizonte_dias, elasticidad=esc.elasticidad,
        incluir_nomina=usar_nomina, incluir_gastos=usar_gastos, fuente_costo=fuente_costo))
    k, k0 = res.kpis, ref.kpis

    with out:
        m = st.columns(5)
        m[0].metric("Ingresos esperados", formato_cop(k["ingreso"]),
                    formato_cop(k["ingreso"] - k0["ingreso"]))
        m[1].metric("Costo de insumos", formato_cop(k["costo"]),
                    formato_cop(k["costo"] - k0["costo"]), delta_color="inverse")
        m[2].metric("Margen de contribución", formato_pct(k["margen_contribucion_pct"]),
                    f"{(k['margen_contribucion_pct'] - k0['margen_contribucion_pct']) * 100:+.1f} pp")
        m[3].metric("Utilidad operativa", formato_cop(k["utilidad"]),
                    formato_cop(k["utilidad"] - k0["utilidad"]))
        m[4].metric("Prob. de pérdida", f"{k['prob_perdida']:.0%}")
        st.caption("Las flechas comparan contra el mismo horizonte sin cambios (escenario base).")

        a, b = st.columns(2)
        a.plotly_chart(charts.histograma_utilidad(
            res.utilidad_sim, k["utilidad_p10"], k["utilidad_p50"], k["utilidad_p90"]),
            use_container_width=True)
        b.plotly_chart(charts.tornado(model.sensibilidad(ds, esc)), use_container_width=True)
        st.plotly_chart(charts.unidades_producto(res.por_producto), use_container_width=True)

        with st.expander("Comparar los tres escenarios de prueba (mismo horizonte)"):
            comp = model.comparar(ds, model.escenarios_predefinidos(esc.horizonte_dias))
            comp["prob_perdida"] = comp["prob_perdida"] * 100
            st.plotly_chart(charts.comparacion_escenarios(comp), use_container_width=True)
            st.dataframe(comp, hide_index=True, use_container_width=True, column_config={
                c: st.column_config.NumberColumn(format="$%.0f")
                for c in ["ingreso", "costo", "contribucion", "gastos", "utilidad_media",
                          "utilidad_p10", "utilidad_p90"]
            } | {"prob_perdida": st.column_config.NumberColumn("Prob. pérdida (%)", format="%.0f")})
        st.info(
            f"Modelo basado en {ds.dias_obs} días de ventas "
            f"({ds.fecha_min:%d/%m/%Y} – {ds.fecha_max:%d/%m/%Y}): es una simulación de escenarios; "
            "su precisión mejora al cargar más historial. La elasticidad es un supuesto ajustable.")

# ───────────────────────────── 3. Productos ─────────────────────────────
with tab_prod:
    if items_f.empty:
        st.warning("No hay ventas con los filtros seleccionados.")
    else:
        clasif = recommender.clasificar_productos(etl.resumen_productos(items_f))
        st.plotly_chart(charts.matriz_productos(clasif), use_container_width=True)
        elegido = st.selectbox("Filtrar por cuadrante", ["Todos"] + sorted(clasif["cuadrante"].unique()))
        vista = clasif if elegido == "Todos" else clasif[clasif["cuadrante"] == elegido]
        vista = vista.assign(margen_pct=vista["margen_pct"] * 100)
        st.dataframe(
            vista.sort_values("ingreso", ascending=False)[
                ["nombre_prod", "categoria", "unidades", "ingreso", "utilidad_bruta",
                 "margen_pct", "cuadrante", "recomendacion"]],
            hide_index=True, use_container_width=True,
            column_config={
                "nombre_prod": "Producto", "categoria": "Categoría", "unidades": "Unidades",
                "ingreso": st.column_config.NumberColumn("Ingreso", format="$%.0f"),
                "utilidad_bruta": st.column_config.NumberColumn("Utilidad bruta", format="$%.0f"),
                "margen_pct": st.column_config.NumberColumn("Margen (%)", format="%.1f"),
                "cuadrante": "Cuadrante", "recomendacion": "Recomendación",
            },
        )
        st.caption("Los cuadrantes se calculan con la mediana de unidades y de margen de los productos filtrados.")

# ───────────────────────────── 4. Inventario y compras (prescriptivo) ─────────────────────────────
with tab_inv:
    st.subheader(f"Plan de compras para el escenario «{esc.nombre}» ({esc.horizonte_dias} días)")
    p1, p2, p3, p4 = st.columns(4)
    fecha_ref = p1.date_input("Fecha de referencia", value=fmax)
    nivel = p2.radio("Nivel de cobertura", ["esperado", "seguro"],
                     format_func=lambda x: "Demanda esperada" if x == "esperado" else "Seguro (percentil 90)")
    descontar = p3.checkbox("Descontar insumos vencidos", value=False)
    minimo = p4.checkbox("Respetar stock mínimo (columna stock)", value=True)

    plan = recommender.plan_compras(ds, res.por_producto, esc.horizonte_dias,
                                    pd.Timestamp(fecha_ref), nivel, descontar, minimo)
    n_venc = int((plan["dias_venc"] < 0).sum())
    if n_venc:
        st.warning(f"{n_venc} de {len(plan)} insumos tienen fecha de vencimiento anterior a la fecha "
                   "de referencia. Si las fechas están desactualizadas, no actives «Descontar vencidos».")

    q = st.columns(3)
    q[0].metric("Insumos a comprar", int((plan["comprar"] > 0).sum()))
    q[1].metric("Inversión sugerida", formato_cop(plan["costo_compra"].sum()))
    q[2].metric("Valor en riesgo de desperdicio", formato_cop(plan["valor_riesgo"].sum()))

    g1, g2 = st.columns(2)
    g1.plotly_chart(charts.ranking_insumos(plan, "costo_compra", "Compras más costosas", COLORES["fresa"]),
                    use_container_width=True)
    g2.plotly_chart(charts.ranking_insumos(plan, "valor_riesgo", "Mayor valor en riesgo", COLORES["maracuya"]),
                    use_container_width=True)

    accion = st.selectbox("Filtrar por acción", ["Todas"] + sorted(plan["accion"].unique()))
    vista = plan if accion == "Todas" else plan[plan["accion"] == accion]
    st.dataframe(vista, hide_index=True, use_container_width=True, column_config={
        "nombre_insumo": "Insumo", "und_medida": "Unidad", "cantidadDisp": "Disponible",
        "stock": "Stock mínimo", "costo_und": st.column_config.NumberColumn("Costo/und", format="$%.2f"),
        "fecha_venc": st.column_config.DateColumn("Vence"), "dias_venc": "Días a vencer",
        "requerido": st.column_config.NumberColumn("Requerido", format="%.0f"),
        "comprar": st.column_config.NumberColumn("Comprar", format="%.0f"),
        "costo_compra": st.column_config.NumberColumn("Costo compra", format="$%.0f"),
        "valor_riesgo": st.column_config.NumberColumn("Valor en riesgo", format="$%.0f"),
        "accion": "Acción",
    })
    st.download_button("⬇️ Descargar plan de compras (CSV)", plan.to_csv(index=False).encode("utf-8-sig"),
                       file_name="plan_compras.csv", mime="text/csv")

    st.subheader("Recomendaciones")
    clasif_all = recommender.clasificar_productos(etl.resumen_productos(etl.aplicar_costo(ds.items, fuente_costo)))
    for texto in recommender.recomendaciones_texto(k, plan, clasif_all):
        st.markdown(f"<div class='caja-reco'>{texto}</div>", unsafe_allow_html=True)
