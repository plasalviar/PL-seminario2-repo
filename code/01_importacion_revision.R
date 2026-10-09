# =========================================================
# SCRIPT 01: IMPORTACIÓN Y REVISIÓN INICIAL DE DATOS
# Proyecto: Progresión de la enfermedad renal crónica en una cohorte prospectiva
# Autor: Pieralessandro Lasalvia
# Fecha: 2026-10-09
# =========================================================

library(tidyverse)
library(here)
library(skimr)

# 1. CARGA DE DATOS -------------------------------------------------------

# Importar la base de datos del curso
base_raw <- read.csv(
  here("data", "raw", "base_erc_cohorte.csv"),
  encoding = "UTF-8"
)

# 2. REVISIÓN INICIAL -------------------------------------------------------

# Dimensiones de la base
cat("Participantes:", nrow(base_raw), "\n")
cat("Variables:", ncol(base_raw), "\n")

# Nombres de variables
names(base_raw)

# Estructura de la base
glimpse(base_raw)

# Primeras filas
head(base_raw, 10)

# 3. ESTADÍSTICAS DESCRIPTIVAS RÁPIDAS ------------------------------------

# Resumen completo por variable
skim(base_raw)

# 4. REVISIÓN DE DATOS FALTANTES ------------------------------------------

# Conteo de faltantes por variable
faltantes <- base_raw %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(),
               names_to = "variable",
               values_to = "n_faltantes") %>%
  mutate(pct_faltantes = round(n_faltantes / nrow(base_raw) * 100, 1)) %>%
  filter(n_faltantes > 0) %>%
  arrange(desc(n_faltantes))

print(faltantes)

# 5. REVISIÓN DE VARIABLES CLAVE ------------------------------------------

# Distribución de estadio basal
table(base_raw$estadio_basal)

# Distribución de sexo
table(base_raw$sexo)

# Distribución de etiología
table(base_raw$etiologia_erc)

# Rangos de variables numéricas clave
summary(base_raw[, c("edad", "tfg_ml_min_basal", "creatinina_mg_dl_basal",
                      "hemoglobina_g_dl_basal", "pas_mmhg_basal")])

# 6. NOTAS DE LA REVISIÓN INICIAL -----------------------------------------

# Después de ejecutar este script, anote en el README o en un memo
# cualquier observación importante sobre la estructura de los datos:
# - ¿Hay valores que parecen imposibles?
# - ¿La distribución de las variables es la esperada?
# - ¿El número de faltantes es coherente con lo descrito en el diccionario?
