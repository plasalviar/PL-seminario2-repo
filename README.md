# Progresión de la enfermedad renal crónica en una cohorte prospectiva

## Descripción

Proyecto analítico reproducible del Módulo 2 del Seminario de Epidemiología Clínica II. La pregunta de investigación es qué características basales se asocian con la progresión a estadio G5 o inicio de terapia de reemplazo renal (TRR) en adultos con enfermedad renal crónica (ERC) en estadios G2 a G4. El diseño es una cohorte prospectiva con medición basal y seguimiento a los 12 y 24 meses. El objetivo principal del análisis es describir la cohorte, estimar la incidencia del desenlace primario y modelar su asociación con las variables basales mediante regresión y análisis de supervivencia.

## Fuentes de datos

Base de datos sintética del curso (`base_erc_cohorte.csv`), distribuida por la plataforma del curso. Contiene 300 participantes con ERC G2 a G4 reclutados entre enero de 2022 y julio de 2023, y 47 variables: sociodemográficas, antropométricas, presión arterial, comorbilidades, laboratorio, medicamentos, mediciones de seguimiento a los meses 12 y 24, y el desenlace primario. Los datos no se incluyen en este repositorio.

## Estructura del repositorio

```
PL-seminario2-repo/
│
├── README.md                   # Este archivo
├── PL-seminario2-repo.Rproj    # Archivo de proyecto de RStudio
│
├── data/
│   ├── raw/                    # Datos originales (no incluidos en el repositorio)
│   └── processed/              # Datos procesados (no incluidos en el repositorio)
│
├── code/
│   ├── 01_importacion.R        # Importación y revisión inicial de datos
│   ├── 02_limpieza.R           # Limpieza y preparación de datos
│   ├── 03_analisis.R           # Análisis estadísticos
│   └── 04_resultados.Rmd       # Reporte reproducible de resultados
│
├── output/
│   ├── figures/                # Figuras generadas por el código
│   └── tables/                 # Tablas generadas por el código
│
└── docs/
    └── diccionario_variables.md  # Diccionario de variables del proyecto
```

## Requisitos

Este proyecto se desarrolla con R versión 4.6.1. Los paquetes requeridos son:

- tidyverse
- rmarkdown
- here
- skimr

## Cómo reproducir el análisis

1. Clone este repositorio
2. Coloque los datos en la carpeta `data/raw/` (descargar de la plataforma del curso)
3. Abra el archivo `.Rproj` en RStudio
4. Ejecute los scripts en el orden indicado por su numeración

## Contacto

Pieralessandro Lasalvia — plasalviar@ideaxplore.com
