# Progresión de la enfermedad renal crónica en una cohorte prospectiva

## Descripción

Proyecto analítico reproducible del Módulo 2 del Seminario de Epidemiología Clínica II. La pregunta de investigación es qué características basales se asocian con la progresión a estadio G5 o inicio de terapia de reemplazo renal (TRR) en adultos con enfermedad renal crónica (ERC) en estadios G2 a G4. El diseño es una cohorte prospectiva con medición basal y seguimiento a los 12 y 24 meses. El análisis describe la cohorte, estima la incidencia del desenlace primario y modela su asociación con las variables basales mediante regresión logística, regresión lineal y análisis de supervivencia.

## Estado del proyecto

**Versión actual:** v1.0 (análisis final)

**Resultado principal:** 33 de 300 participantes (11.0%) progresaron a G5 o TRR, 32 de ellos en G4. G2 y G3a no tuvieron eventos, así que la máxima verosimilitud no puede estimar el efecto del estadio; se estimó con regresión penalizada de Firth (G4 frente a G2: OR 239.8, IC 95% 29.1-31,761.5; HR 147.9, IC 95% 20.4-18,828.5). Ninguna otra covariable se asoció de forma estable con la progresión. Los valores salen del reporte final, que los calcula desde el código.

### Productos generados

| Archivo | Descripción |
|---------|-------------|
| `code/08_reporte_final.html` | Reporte completo del análisis |
| `output/tables/tabla_01_caracteristicas_basales.docx` | Características basales |
| `output/tables/tabla_02_or_ajustados.docx` | OR crudos y ajustados (regresión logística) |
| `output/tables/tabla_03_hr_ajustados.docx` | HR crudos y ajustados (modelo de Cox) |
| `output/tables/tabla_04_or_hr_firth.docx` | OR y HR con regularización de Firth |
| `output/tables/tabla_05_declive_tfg.docx` | Coeficientes de la regresión lineal (tasa de declive de la TFG) |
| `output/figures/figura_01_tfg_declive_estadio.png` | TFG y tasa de declive por estadio (300 DPI) |
| `output/figures/figura_02_kaplan_meier.png` | Curvas de Kaplan-Meier por estadio (300 DPI) |

Las tablas y figuras se exportan desde los mismos objetos que muestra el reporte final (sección "Exportación de tablas y figuras"), así que coinciden con lo publicado en él.

### Documentos de análisis

| Archivo | Contenido |
|---------|-----------|
| `code/04_regresion_logistica.Rmd` | Regresión logística para progresión a G5/TRR, con supuestos |
| `code/05_regresion_lineal.Rmd` | Regresión lineal para la tasa de declive de la TFG, con supuestos |
| `code/06_analisis_supervivencia.Rmd` | Kaplan-Meier y modelo de Cox, con supuestos |
| `code/07_validacion_resultados.Rmd` | Validación crítica: coherencia, supuestos y cuatro análisis de sensibilidad |
| `code/08_reporte_final.Rmd` | Reporte final integrado |

Cada documento tiene su `.html` renderizado al lado y termina con `sessioninfo::session_info()`.

### Decisiones analíticas

- [`docs/memo_preparacion_datos.txt`](docs/memo_preparacion_datos.txt): correcciones de valores atípicos, variables derivadas y faltantes.
- [`docs/memo_decisiones_analiticas.txt`](docs/memo_decisiones_analiticas.txt): covariables, casos completos, categoría de referencia, resultados de los supuestos y decisiones tras la validación (regularización de Firth y análisis de sensibilidad).

## Fuentes de datos

Base de datos sintética del curso (`base_erc_cohorte.csv`), distribuida por la plataforma del curso. Contiene 300 participantes con ERC G2 a G4 reclutados entre enero de 2022 y julio de 2023, y 47 variables: sociodemográficas, antropométricas, presión arterial, comorbilidades, laboratorio, medicamentos, mediciones de seguimiento a los meses 12 y 24, y el desenlace primario. Los datos no se incluyen en este repositorio: se descargan de la plataforma del curso y se copian sin modificar a `data/raw/`.

- Descripción de la fuente: [`docs/fuentes_datos.md`](docs/fuentes_datos.md)
- Diccionario de variables: [`docs/diccionario_variables.csv`](docs/diccionario_variables.csv)

## Estructura del repositorio

```
PL-seminario2-repo/
│
├── README.md                         # Este archivo
├── PL-seminario2-repo.Rproj          # Archivo de proyecto de RStudio
│
├── data/                             # No se incluye en el repositorio
│   ├── raw/                          # base_erc_cohorte.csv, tal como se descargó
│   └── processed/                    # base_analitica_v1.0.rds y .csv (genera el script 02)
│
├── code/
│   ├── 01_importacion_revision.R     # Importación y revisión inicial de datos
│   ├── diccionario_variables.R       # Construcción del diccionario de variables
│   ├── 02_descripcion_base.Rmd       # Descripción general de la base original
│   ├── 02_limpieza_preparacion.R     # Limpieza y construcción de la base analítica
│   ├── 03_analisis_exploratorio.Rmd  # Análisis exploratorio y calidad de datos
│   ├── 04_regresion_logistica.Rmd    # Regresión logística
│   ├── 05_regresion_lineal.Rmd       # Regresión lineal
│   ├── 06_analisis_supervivencia.Rmd # Kaplan-Meier y modelo de Cox
│   ├── 07_validacion_resultados.Rmd  # Validación crítica y sensibilidad
│   └── 08_reporte_final.Rmd          # Reporte final y exportación de productos
│
├── output/
│   ├── figures/                      # Figuras generadas por el código
│   └── tables/                       # Tablas generadas por el código (.docx)
│
└── docs/
    ├── diccionario_variables.csv     # Diccionario de variables
    ├── fuentes_datos.md              # Descripción de la fuente de datos
    ├── memo_preparacion_datos.txt    # Decisiones de limpieza
    ├── memo_decisiones_analiticas.txt # Decisiones de los modelos
    ├── session_info.txt              # Versiones de R y paquetes (script 01)
    └── session_info_limpieza.txt     # Versiones de R y paquetes (script 02)
```

Cada tipo de archivo tiene su carpeta:

- **Datos crudos** (`data/raw/`): la base del curso tal como se descargó. Es de solo lectura.
- **Datos procesados** (`data/processed/`): la base analítica que genera el código a partir de los datos crudos.
- **Código** (`code/`): scripts y documentos R Markdown numerados en orden de ejecución.
- **Productos analíticos** (`output/`): figuras y tablas generadas por el código. La carpeta está en `.gitignore`; los productos finales se agregaron al repositorio de forma explícita.
- **Documentación** (`docs/`): diccionario, fuentes, memos de decisiones y versiones de los paquetes.

Todas las rutas usan `here()`, relativas a la raíz del proyecto.

## Requisitos

Este proyecto fue desarrollado con R 4.6.1. Los paquetes requeridos son:

- Manejo de datos y reportes: tidyverse, here, rmarkdown, sessioninfo, skimr, naniar, corrplot
- Tablas: gtsummary, flextable, broom, broom.helpers, parameters
- Modelos: survival, survminer, car, lmtest, ResourceSelection, logistf, coxphf
- Figuras: patchwork, ragg

```r
install.packages(c("tidyverse", "here", "rmarkdown", "sessioninfo", "skimr",
                   "naniar", "corrplot", "gtsummary", "flextable", "broom",
                   "broom.helpers", "parameters", "survival", "survminer",
                   "car", "lmtest", "ResourceSelection", "logistf", "coxphf",
                   "patchwork", "ragg"))
```

Las versiones exactas usadas están al final de cada documento renderizado.

## Cómo reproducir el análisis

1. Clone el repositorio
2. Coloque `base_erc_cohorte.csv` en `data/raw/` (descárguelo de la plataforma del curso)
3. Abra `PL-seminario2-repo.Rproj` en RStudio
4. Ejecute los scripts en orden numérico (01 → 08):
   1. `code/01_importacion_revision.R`
   2. `code/diccionario_variables.R`
   3. `code/02_descripcion_base.Rmd` (Knit)
   4. `code/02_limpieza_preparacion.R` (crea la base analítica en `data/processed/`)
   5. `code/03_analisis_exploratorio.Rmd` a `code/08_reporte_final.Rmd`, en orden (Knit)
5. Los productos se generarán automáticamente en `output/`. `08_reporte_final.Rmd` reescribe `tabla_01_caracteristicas_basales.docx`, que también exporta el documento 03.

Desde la consola, el paso 5 equivale a:

```r
for (f in sprintf("code/%s.Rmd", c("03_analisis_exploratorio", "04_regresion_logistica",
                                    "05_regresion_lineal", "06_analisis_supervivencia",
                                    "07_validacion_resultados", "08_reporte_final"))) {
  rmarkdown::render(f)
}
```

## Notas de la revisión inicial

Observaciones al ejecutar `code/01_importacion_revision.R` (2026-10-09):

- **¿Hay valores que parecen imposibles?** Sí. Creatinina basal en 3 participantes: ERC-0058 (0.08 mg/dL), ERC-0064 (142 mg/dL, compatible con µmol/L) y ERC-0122 (18.5 mg/dL con TFG de 25). Peso basal en 2 participantes, incoherente con su IMC: ERC-0234 (8.5 kg) y ERC-0152 (198 kg).
- **¿La distribución de las variables es la esperada?** Sí, salvo esos valores. La base tiene 300 participantes y 47 variables, sin identificadores duplicados, reclutados entre el 15/01/2022 y el 08/07/2023.
- **¿El número de faltantes es coherente con lo descrito en el diccionario?** Sí. La pérdida de seguimiento es de 12.3% al mes 12 y 18.0% al mes 24. Entre los participantes no perdidos, los faltantes adicionales de laboratorio son de 4.3-5.0% al mes 12 y 4.7-7.0% al mes 24.

Estos valores se corrigieron en `code/02_limpieza_preparacion.R` sin modificar `data/raw/`; el detalle está en `docs/memo_preparacion_datos.txt`.

## Contacto

Pieralessandro Lasalvia — plasalviar@ideaxplore.com
