# Merengón Mágico · Dashboard de analítica prescriptiva

Dashboard interactivo (Python + Streamlit + Plotly) para el proyecto **Sistema de análisis
prescriptivo para la gestión de ventas e inventario del local de postres “Merengón Mágico”**
(Business Analytics · Universidad de Cundinamarca).

**Pregunta de negocio / predicción:** ¿cuál será la utilidad (y la demanda de cada producto) de
Merengón Mágico en los próximos *N* días si cambiamos el precio, el descuento, el costo de los
insumos o la demanda esperada, y qué debemos comprar y priorizar en consecuencia?

## 1. Estructura del proyecto

```
merengon_dashboard/
├── app.py                  # Interfaz (Streamlit)
├── src/
│   ├── config.py           # Constantes y conexión (variables de entorno)
│   ├── data_loader.py      # Lectura de MySQL
│   ├── etl.py              # Limpieza y dataset analítico
│   ├── model.py            # Modelo predictivo (simulación Monte Carlo)
│   ├── recommender.py      # Capa prescriptiva (compras, prioridades)
│   ├── charts.py           # Gráficos Plotly
│   └── theme.py            # Paleta, CSS y formatos
├── database/merengon_magico.sql
├── tests/test_pipeline.py  # Pruebas de la lógica sin MySQL
├── .streamlit/config.toml  # Tema visual
├── .env.example            # Plantilla de credenciales
└── requirements.txt
```

## 2. Requisitos
* Python **3.10 – 3.12**
* MySQL **8.x** (Server + Workbench o cliente de línea de comandos)

## 3. Subir la base de datos a MySQL

El archivo `database/merengon_magico.sql` ya incluye `CREATE DATABASE` y `USE`, así que crea todo.

**Opción A – Línea de comandos**
```bash
# desde la carpeta del proyecto (en Windows: usa la consola "MySQL 8.0 Command Line Client"
# o agrega la carpeta bin de MySQL al PATH)
mysql -u root -p < database/merengon_magico.sql
```
Verifica:
```bash
mysql -u root -p -e "USE merengon_magico; SHOW TABLES; SELECT COUNT(*) FROM venta;"
```
Debe mostrar 13 tablas y 40 ventas.

**Opción B – MySQL Workbench**
1. Abre Workbench y conéctate a tu servidor local.
2. Menú **Server → Data Import**.
3. Elige **Import from Self-Contained File** y selecciona `merengon_magico.sql`.
4. En *Default Target Schema* déjalo vacío (el script crea el esquema) y pulsa **Start Import**.
5. Refresca el panel *Schemas*: debe aparecer `merengon_magico`.

**Opción C – Pegar el script**: abre `merengon_magico.sql` en una pestaña SQL de Workbench y
ejecútalo completo con el rayo.

## 4. Configurar y ejecutar el dashboard

```bash
# 1) Entorno virtual
python -m venv .venv
.venv\Scripts\activate            # Windows
# source .venv/bin/activate       # macOS / Linux

# 2) Dependencias
pip install -r requirements.txt

# 3) Credenciales (nunca se suben al repositorio)
copy .env.example .env            # Windows   (macOS/Linux: cp .env.example .env)
# edita .env y pon tu contraseña de MySQL en DB_PASSWORD

# 4) Probar la lógica (opcional, no necesita MySQL)
python -m tests.test_pipeline

# 5) Lanzar
streamlit run app.py
```
Se abre en http://localhost:8501.

## 5. Interacciones disponibles
| Zona | Interacción |
|---|---|
| Barra lateral | Rango de fechas · categorías · productos · estado de venta · método de pago · fuente del costo |
| Resumen ejecutivo | KPIs · tendencia diaria · ranking más/menos vendidos (por unidades o ingreso) · treemap con **drill-down** categoría → producto |
| Simulador | Escenarios predefinidos · 6 deslizadores (precio, descuento, costo, demanda, horizonte, elasticidad) · alcance por categorías · gastos/nómina · histograma P10/P50/P90 · tornado de sensibilidad · demanda por producto · comparación de 3 escenarios |
| Productos | Matriz rotación vs margen · filtro por cuadrante · recomendación por producto |
| Inventario y compras | Fecha de referencia · cobertura esperada/segura · descontar vencidos · stock mínimo · filtro por acción · descarga CSV · recomendaciones en texto |

## 6. Cómo funciona el modelo
1. Demanda base por producto = unidades vendidas ÷ días con ventas.
2. Escenario: `demanda' = base × (1 + Δdemanda) × (precio efectivo / precio base)^elasticidad`.
3. Incertidumbre: 3.000 simulaciones Monte Carlo (tasa ~ Gamma, unidades ~ Poisson).
4. Resultado: ingresos, costo de insumos, margen de contribución, utilidad operativa
   (− gastos operativos diarios × horizonte), P10/P50/P90 y probabilidad de pérdida.
5. Prescripción: unidades esperadas × receta ⇒ insumos requeridos ⇒ compras sugeridas y riesgo de vencimiento.

