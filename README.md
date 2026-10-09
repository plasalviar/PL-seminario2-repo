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
├── output/
│   ├── figures/                    # Figuras generadas por el código
│   └── tables/                     # Tablas generadas por el código
│
└── docs/
    ├── diccionario_variables.csv   # Diccionario de variables del proyecto
    └── fuentes_datos.md            # Descripción de la fuente de datos
```

## Requisitos

Este proyecto fue desarrollado con R versión 4.6.1. Los paquetes requeridos son:

- tidyverse
- rmarkdown
- here
- skimr

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

## Contacto

Pieralessandro Lasalvia — plasalviar@ideaxplore.com
