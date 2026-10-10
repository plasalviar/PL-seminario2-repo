# Progresión de la enfermedad renal crónica en una cohorte prospectiva

## Descripción

Proyecto analítico reproducible del Módulo 2 del Seminario de Epidemiología Clínica II. La pregunta de investigación es qué características basales se asocian con la progresión a estadio G5 o inicio de terapia de reemplazo renal (TRR) en adultos con enfermedad renal crónica (ERC) en estadios G2 a G4. El diseño es una cohorte prospectiva con medición basal y seguimiento a los 12 y 24 meses. El objetivo principal del análisis es describir la cohorte, estimar la incidencia del desenlace primario y modelar su asociación con las variables basales mediante regresión y análisis de supervivencia.

## Fuentes de datos

Base de datos sintética del curso (`base_erc_cohorte.csv`), distribuida por la plataforma del curso. Contiene 300 participantes con ERC G2 a G4 reclutados entre enero de 2022 y julio de 2023, y 47 variables: sociodemográficas, antropométricas, presión arterial, comorbilidades, laboratorio, medicamentos, mediciones de seguimiento a los meses 12 y 24, y el desenlace primario. Los datos no se incluyen en este repositorio: se descargan de la plataforma del curso y se copian sin modificar a `data/raw/`.

- Descripción de la fuente: [`docs/fuentes_datos.md`](docs/fuentes_datos.md)
- Diccionario de variables: [`docs/diccionario_variables.csv`](docs/diccionario_variables.csv)

## Estructura del repositorio

```
PL-seminario2-repo/
│
├── README.md                       # Este archivo
├── PL-seminario2-repo.Rproj        # Archivo de proyecto de RStudio
│
├── data/
│   ├── raw/                        # Datos originales (no incluidos en el repositorio)
│   │   └── base_erc_cohorte.csv    # Base de datos del curso
│   └── processed/                  # Datos procesados (no incluidos en el repositorio)
│
├── code/
│   ├── 01_importacion_revision.R   # Importación y revisión inicial de datos
│   └── diccionario_variables.R     # Construcción del diccionario de variables
│
├── output/                         # Productos analíticos (no incluidos en el repositorio)
│   ├── figures/                    # Figuras generadas por el código
│   └── tables/                     # Tablas generadas por el código
│
└── docs/
    ├── diccionario_variables.csv   # Diccionario de variables del proyecto
    ├── fuentes_datos.md            # Descripción de la fuente de datos
    └── session_info.txt            # Versiones de R y paquetes (generado por el script 01)
```

Cada tipo de archivo tiene su carpeta:

- **Datos crudos** (`data/raw/`): la base del curso tal como se descargó. Es de solo lectura.
- **Datos procesados** (`data/processed/`): la base analítica que genera el código a partir de los datos crudos.
- **Código** (`code/`): scripts numerados en orden de ejecución.
- **Productos analíticos** (`output/`): figuras y tablas generadas por el código.
- **Documentación** (`docs/`): diccionario de variables, fuentes de datos y versiones de los paquetes.

## Requisitos

Este proyecto fue desarrollado con R versión 4.6.1. Los paquetes requeridos son:

- tidyverse
- rmarkdown
- here
- skimr
- sessioninfo

## Cómo reproducir el análisis

1. Clone este repositorio
2. Coloque los datos en la carpeta `data/raw/` (descargar `base_erc_cohorte.csv` de la plataforma del curso)
3. Abra el archivo `.Rproj` en RStudio
4. Ejecute los scripts en este orden:
   1. `code/01_importacion_revision.R`
   2. `code/diccionario_variables.R`

## Notas de la revisión inicial

Observaciones al ejecutar `code/01_importacion_revision.R` (2026-10-09):

- **¿Hay valores que parecen imposibles?** Sí. Creatinina basal en 3 participantes: ERC-0058 (0.08 mg/dL), ERC-0064 (142 mg/dL, compatible con µmol/L) y ERC-0122 (18.5 mg/dL con TFG de 25). Peso basal en 2 participantes, incoherente con su IMC: ERC-0234 (8.5 kg) y ERC-0152 (198 kg).
- **¿La distribución de las variables es la esperada?** Sí, salvo esos valores. La base tiene 300 participantes y 47 variables, sin identificadores duplicados, reclutados entre el 15/01/2022 y el 08/07/2023.
- **¿El número de faltantes es coherente con lo descrito en el diccionario?** Sí. La pérdida de seguimiento es de 12.3% al mes 12 y 18.0% al mes 24. Entre los participantes no perdidos, los faltantes adicionales de laboratorio son de 4.3-5.0% al mes 12 y 4.7-7.0% al mes 24. Cuando no hubo pérdida, `motivo_perdida_m12` y `motivo_perdida_m24` se leen como cadena vacía (`""`), no como `NA`.

Estos valores se corregirán en la semana de limpieza de datos, sin modificar `data/raw/`.

## Transformaciones previstas para la base analítica

La base analítica se construirá con `code/02_limpieza_preparacion.R` a partir de `data/raw/base_erc_cohorte.csv`, sin modificar el archivo original. Cada decisión quedará comentada en el código y, si es compleja, en un memo en `docs/`.

1. **Valores imposibles de creatinina basal:** revisar ERC-0058, ERC-0064 y ERC-0122. El valor de ERC-0064 se convertirá de µmol/L a mg/dL (142 / 88.4 = 1.61 mg/dL). Los otros dos se corregirán si la revisión confirma un error de digitación; si no, quedarán como faltantes.
2. **Peso basal incoherente:** revisar ERC-0234 y ERC-0152 frente al IMC y la talla registrados. El peso se corregirá solo si el error es verificable; si no, quedará como faltante.
3. **Faltantes codificados como texto:** convertir la cadena vacía de `motivo_perdida_m12` y `motivo_perdida_m24` a `NA`.
4. **Tipos de variables:** convertir `fecha_reclutamiento` (DD/MM/AAAA) a fecha; las variables categóricas a factores, con orden para `estadio_basal` (G2 < G3a < G3b < G4) y `nivel_educativo`; y las variables 0/1 a factores etiquetados.
5. **Variables derivadas:** cambio de TFG entre la visita basal y los meses 12 y 24.
6. **Datos faltantes:** describir el patrón de faltantes en el laboratorio de seguimiento y documentar en un memo el método elegido (casos completos o imputación).
7. **Flujo de participantes:** registrar el número de participantes en cada etapa, incluidas las pérdidas de seguimiento a los meses 12 y 24.
8. **Exportación:** guardar la base analítica en `data/processed/base_analitica_v1.0.rds` y agregar las variables derivadas al diccionario.

## Contacto

Pieralessandro Lasalvia — plasalviar@ideaxplore.com
