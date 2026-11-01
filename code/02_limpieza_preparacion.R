# =========================================================
# SCRIPT 02: LIMPIEZA Y PREPARACIÓN DE DATOS
# Proyecto: Cohorte ERC — Seminario de Epiclínica II
# Autor: Pieralessandro Lasalvia
# Fecha: 2026-10-30
# Descripción: Transforma la base de datos cruda en la base
#              analítica lista para análisis estadísticos.
# =========================================================

library(tidyverse)
library(here)
library(skimr)
library(naniar)

# Cargar datos crudos
base_raw <- read.csv(
  here("data", "raw", "base_erc_cohorte.csv"),
  encoding = "UTF-8"
)

cat("Base cargada:", nrow(base_raw), "participantes,",
    ncol(base_raw), "variables\n")

# ── CORRECCIÓN DE TIPOS ──────────────────────────────────────────────
base <- base_raw %>%
  mutate(
    # Variables categóricas ordinales (con orden definido)
    estadio_basal = factor(estadio_basal,
                           levels  = c("G2", "G3a", "G3b", "G4"),
                           ordered = TRUE),

    nivel_educativo = factor(nivel_educativo,
                             levels  = c("Ninguno", "Primaria", "Secundaria",
                                         "Tecnico", "Universitario"),
                             ordered = TRUE),

    # Variables categóricas nominales
    sexo          = factor(sexo),
    etnia         = factor(etnia),
    procedencia   = factor(procedencia),
    etiologia_erc = factor(etiologia_erc),

    # Variables lógicas (0/1)
    diabetes              = as.logical(diabetes),
    hipertension          = as.logical(hipertension),
    cardiopatia_isquemica = as.logical(cardiopatia_isquemica),
    tabaquismo_actual     = as.logical(tabaquismo_actual),
    tabaquismo_previo     = as.logical(tabaquismo_previo),
    ieca_o_ara2           = as.logical(ieca_o_ara2),
    estatinas             = as.logical(estatinas),
    perdida_seguimiento_m12 = as.logical(perdida_seguimiento_m12),
    perdida_seguimiento_m24 = as.logical(perdida_seguimiento_m24),
    progresion_g5_o_trr   = as.logical(progresion_g5_o_trr)
  )

# Verificar
cat("\nTipos de variables después de la corrección:\n")
sapply(base, class) %>% print()

# ── IDENTIFICACIÓN DE VARIABLES POTENCIALMENTE IDENTIFICADORAS ────────

# Variables directamente identificadoras en esta base
# - id_estudio: es el identificador del estudio (seudónimo), no identifica directamente
# - fecha_reclutamiento: puede ser identificadora si se combina con otras variables

# Estrategia para esta base:
# El id_estudio (ERC-XXXX) ya es un seudónimo - se conserva para el análisis
# La fecha de reclutamiento se convierte a tiempo desde inicio del estudio

base <- base %>%
  mutate(
    # Calcular días desde inicio del reclutamiento (menos identificador que fecha exacta)
    dias_desde_inicio = as.numeric(
      as.Date(fecha_reclutamiento, format = "%d/%m/%Y") - as.Date("2022-01-15")
    )
  ) %>%
  # Para el análisis, podemos prescindir de la fecha exacta
  select(-fecha_reclutamiento)

# ── FALTANTES CODIFICADOS COMO TEXTO ─────────────────────────────────
# Sección agregada: read.csv() lee el motivo de pérdida vacío como ""
# (participantes sin pérdida). Se recodifica a NA antes del análisis.
base <- base %>%
  mutate(
    across(c(motivo_perdida_m12, motivo_perdida_m24),
           ~ factor(na_if(.x, "")))
  )

# Verificar: el motivo solo está presente en los participantes perdidos
stopifnot(
  all(is.na(base$motivo_perdida_m12) == !base$perdida_seguimiento_m12),
  all(is.na(base$motivo_perdida_m24) == !base$perdida_seguimiento_m24)
)

# ── IDENTIFICACIÓN DE VALORES FUERA DE RANGO ─────────────────────────

# Definir rangos esperados según el diccionario de variables
rangos <- list(
  edad                   = c(30, 85),
  peso_kg_basal          = c(35, 180),
  talla_cm               = c(145, 185),
  imc_basal              = c(15, 50),
  pas_mmhg_basal         = c(80, 220),
  pad_mmhg_basal         = c(40, 120),
  tfg_ml_min_basal       = c(10, 89),
  creatinina_mg_dl_basal = c(0.4, 15),
  hemoglobina_g_dl_basal = c(5, 18),
  albumina_g_dl_basal    = c(1.5, 5.5),
  proteinuria_mg_g_basal = c(20, 5500)
)

# Identificar y mostrar los valores fuera de rango
cat("=== VALORES FUERA DE RANGO IDENTIFICADOS ===\n")
atipicos_encontrados <- list()

for (var in names(rangos)) {
  fuera <- base %>%
    filter(!is.na(.data[[var]])) %>%
    filter(.data[[var]] < rangos[[var]][1] |
           .data[[var]] > rangos[[var]][2]) %>%
    select(id_estudio, all_of(var))

  if (nrow(fuera) > 0) {
    cat("\n[!]", var, ":\n")
    print(fuera)
    atipicos_encontrados[[var]] <- fuera
  }
}

if (length(atipicos_encontrados) == 0) {
  cat("No se encontraron valores fuera de rango.\n")
}

# ── CORRECCIÓN DE VALORES ATÍPICOS ───────────────────────────────────
# Documentación detallada en: docs/memo_preparacion_datos.txt
#
# CREATININA BASAL:
# ERC-0058 valor 0.08 → 0.84 mg/dL: error de punto decimal
# ERC-0064 valor 142 → 1.61 mg/dL: unidades µmol/L → mg/dL
# ERC-0122 valor 18.5 → 2.86 mg/dL: incoherente con su TFG de 25; se
#   recalcula desde la TFG con la ecuación CKD-EPI 2021 (revisión manual)
#
# PESO BASAL:
# ERC-0234 valor 8.5 → 49.9 kg: imposible para un adulto; se recalcula
#   como IMC registrado × talla² (revisión manual)
# ERC-0152 valor 198 → 52.2 kg: incoherente con su IMC registrado (22.9);
#   se recalcula igual (revisión manual)

# Creatinina que corresponde a una TFG dada, despejada de CKD-EPI 2021
# (válida para creatinina por encima de 0.7 mg/dL en mujeres y 0.9 en hombres):
# Cr = k × (TFG / (142 × 0.9938^edad × f))^(-1 / 1.2)
# con k = 0.7 y f = 1.012 en mujeres, k = 0.9 y f = 1 en hombres
creatinina_desde_tfg <- function(tfg, edad, sexo) {
  k <- ifelse(sexo == "Femenino", 0.7, 0.9)
  f <- ifelse(sexo == "Femenino", 1.012, 1)
  k * (tfg / (142 * 0.9938^edad * f))^(-1 / 1.2)
}

base <- base %>%
  mutate(

    # Correcciones en creatinina basal
    creatinina_mg_dl_basal = case_when(
      id_estudio == "ERC-0058" ~ 0.84,          # error punto decimal: 0.08 → 0.84
      id_estudio == "ERC-0064" ~ 142.0 / 88.4,  # unidades µmol/L → mg/dL
      id_estudio == "ERC-0122" ~ round(         # recalculada desde la TFG
        creatinina_desde_tfg(tfg_ml_min_basal, edad, sexo), 2),
      TRUE ~ creatinina_mg_dl_basal
    ),

    # Correcciones en peso basal (recalculado como IMC × talla²)
    peso_kg_basal = case_when(
      id_estudio %in% c("ERC-0234", "ERC-0152") ~
        round(imc_basal * (talla_cm / 100)^2, 1),
      TRUE ~ peso_kg_basal
    )
  )

# Verificar que las correcciones fueron aplicadas
cat("Creatinina después de correcciones:\n")
summary(base$creatinina_mg_dl_basal)

cat("\nPeso después de correcciones:\n")
summary(base$peso_kg_basal)

# ── VERIFICACIONES DE CONSISTENCIA ───────────────────────────────────

# 1. PAD debe ser menor que PAS
inconsistencia_pa <- base %>%
  filter(!is.na(pas_mmhg_basal) & !is.na(pad_mmhg_basal)) %>%
  filter(pad_mmhg_basal >= pas_mmhg_basal)

cat("Inconsistencia PA (PAD >= PAS):", nrow(inconsistencia_pa), "casos\n")

# 2. Tabaquismo actual y previo mutuamente excluyentes
inconsistencia_tabaco <- base %>%
  filter(tabaquismo_actual == TRUE & tabaquismo_previo == TRUE)

cat("Inconsistencia tabaquismo (actual Y previo = TRUE):",
    nrow(inconsistencia_tabaco), "casos\n")

# 3. IMC coherente con peso y talla
base <- base %>%
  mutate(
    imc_calculado   = round(peso_kg_basal / (talla_cm / 100)^2, 1),
    discrepancia_imc = abs(imc_basal - imc_calculado)
  )

inconsistencia_imc <- base %>%
  filter(!is.na(discrepancia_imc) & discrepancia_imc > 2)

cat("Discrepancia IMC > 2 kg/m²:", nrow(inconsistencia_imc), "casos\n")
if (nrow(inconsistencia_imc) > 0) print(inconsistencia_imc %>%
    select(id_estudio, peso_kg_basal, talla_cm, imc_basal, imc_calculado))

# 4. TFG basal coherente con el estadio registrado (G4: 15 a 29)
# ERC-0007, ERC-0145 y ERC-0219 tienen TFG de 13-14 con estadio G4. Se
# llevan al límite inferior del estadio (15) y se marcan para revisión.
inconsistencia_estadio <- base %>%
  filter(estadio_basal == "G4" & tfg_ml_min_basal < 15)

cat("TFG < 15 con estadio G4:", nrow(inconsistencia_estadio), "casos\n")
print(inconsistencia_estadio %>% select(id_estudio, estadio_basal, tfg_ml_min_basal))

base <- base %>%
  mutate(tfg_ml_min_basal = if_else(
    estadio_basal == "G4" & tfg_ml_min_basal < 15, 15L, tfg_ml_min_basal
  ))

# ── MARCA PARA REVISIÓN MANUAL ───────────────────────────────────────
# Los valores recalculados o ajustados quedan marcados para revisarlos
# contra la fuente.
revision <- tribble(
  ~id_estudio, ~motivo_revision,
  "ERC-0122",  "Creatinina basal 18.5 recalculada desde la TFG (2.86)",
  "ERC-0152",  "Peso basal 198 recalculado desde el IMC (52.2)",
  "ERC-0234",  "Peso basal 8.5 recalculado desde el IMC (49.9)",
  "ERC-0007",  "TFG basal 14 ajustada a 15 (límite de G4)",
  "ERC-0145",  "TFG basal 14 ajustada a 15 (límite de G4)",
  "ERC-0219",  "TFG basal 13 ajustada a 15 (límite de G4)"
)

# También se marcan los participantes que llegan a TFG < 15 en el
# seguimiento sin desenlace registrado (posible desenlace no registrado)
tfg_bajo_sin_desenlace <- base %>%
  filter(!progresion_g5_o_trr,
         pmin(tfg_ml_min_m12, tfg_ml_min_m24, na.rm = TRUE) < 15) %>%
  transmute(id_estudio,
            motivo_revision = "TFG < 15 en el seguimiento sin desenlace registrado")

revision <- bind_rows(revision, tfg_bajo_sin_desenlace) %>%
  group_by(id_estudio) %>%
  summarise(motivo_revision = paste(motivo_revision, collapse = "; "))

base <- base %>%
  left_join(revision, by = "id_estudio") %>%
  mutate(revision_manual = !is.na(motivo_revision))

cat("Participantes marcados para revisión manual:",
    sum(base$revision_manual), "\n")

# ── VARIABLES DERIVADAS ───────────────────────────────────────────────
base <- base %>%
  mutate(

    # Grupos de edad
    grupo_edad = cut(edad,
                     breaks = c(0, 45, 60, 75, Inf),
                     labels = c("<45 años", "45–59 años",
                                "60–74 años", "≥75 años"),
                     right  = FALSE) %>% factor(),

    # Estadio agrupado para análisis
    estadio_agrupado = case_when(
      estadio_basal %in% c("G2", "G3a") ~ "Leve-moderado (G2-G3a)",
      estadio_basal %in% c("G3b", "G4") ~ "Moderado-severo (G3b-G4)"
    ) %>% factor(levels = c("Leve-moderado (G2-G3a)",
                             "Moderado-severo (G3b-G4)")),

    # Etiología agrupada
    etiologia_agrupada = case_when(
      etiologia_erc == "Diabetica"    ~ "Diabética",
      etiologia_erc == "Hipertensiva" ~ "Hipertensiva",
      TRUE                            ~ "Otras / Desconocida"
    ) %>% factor(levels = c("Diabética", "Hipertensiva",
                             "Otras / Desconocida")),

    # Transformación logarítmica de proteinuria (distribución muy sesgada)
    log_proteinuria_basal = log(proteinuria_mg_g_basal),

    # Cambio en TFG entre puntos de seguimiento
    cambio_tfg_m12   = tfg_ml_min_m12 - tfg_ml_min_basal,
    cambio_tfg_m24   = tfg_ml_min_m24 - tfg_ml_min_basal,

    # Tasa anual de declive de TFG (mL/min/año)
    tasa_declive_tfg = (tfg_ml_min_m24 - tfg_ml_min_basal) / 2,

    # Indicador de anemia (Hgb < 12 g/dL en mujeres, < 13 g/dL en hombres)
    anemia_basal = case_when(
      sexo == "Femenino"  & hemoglobina_g_dl_basal < 12 ~ TRUE,
      sexo == "Masculino" & hemoglobina_g_dl_basal < 13 ~ TRUE,
      TRUE ~ FALSE
    )
  )

cat("Variables derivadas creadas correctamente.\n")
cat("Nuevas variables:", c("grupo_edad", "estadio_agrupado",
    "etiologia_agrupada", "log_proteinuria_basal",
    "cambio_tfg_m12", "cambio_tfg_m24",
    "tasa_declive_tfg", "anemia_basal"), "\n")

# ── EVALUACIÓN DE DATOS FALTANTES ────────────────────────────────────

# Resumen de faltantes por variable
faltantes_resumen <- base %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(),
               names_to  = "variable",
               values_to = "n_faltantes") %>%
  mutate(pct = round(n_faltantes / nrow(base) * 100, 1)) %>%
  filter(n_faltantes > 0) %>%
  arrange(desc(n_faltantes))

cat("=== RESUMEN DE DATOS FALTANTES ===\n")
print(faltantes_resumen)

# Visualizar patrón de faltantes en variables de seguimiento
vis_miss(base %>%
  select(tfg_ml_min_m12, hemoglobina_g_dl_m12, albumina_g_dl_m12,
         proteinuria_mg_g_m12, tfg_ml_min_m24, hemoglobina_g_dl_m24,
         albumina_g_dl_m24, proteinuria_mg_g_m24))

# Verificar si los faltantes están asociados con el estadio
# (prueba informal de MAR vs MCAR)
base %>%
  mutate(faltante_tfg_m12 = is.na(tfg_ml_min_m12)) %>%
  group_by(faltante_tfg_m12, estadio_basal) %>%
  summarise(n = n(), .groups = "drop") %>%
  pivot_wider(names_from = faltante_tfg_m12,
              values_from = n,
              names_prefix = "faltante_") %>%
  print()

# ── CONSTRUCCIÓN FINAL DE LA BASE ANALÍTICA ──────────────────────────
# Se conservan todos los participantes en la base analítica.
# Los análisis que requieren datos completos excluirán los faltantes
# según las variables de cada modelo específico.

base_analitica <- base %>%
  # Eliminar variables redundantes o reemplazadas
  select(
    -imc_basal,         # reemplazado por imc_calculado
    -discrepancia_imc   # variable de verificación, no analítica
  )

# Verificación final
cat("=== BASE ANALÍTICA FINAL ===\n")
cat("Participantes:", nrow(base_analitica), "\n")
cat("Variables:", ncol(base_analitica), "\n")
cat("Desenlace (progresión G5/TRR):", sum(base_analitica$progresion_g5_o_trr,
                                           na.rm = TRUE), "eventos\n")
cat("Con seguimiento completo (mes 24):",
    sum(!base_analitica$perdida_seguimiento_m24), "\n")

# Exportar
saveRDS(base_analitica,
        here("data", "processed", "base_analitica_v1.0.rds"))
write.csv(base_analitica,
          here("data", "processed", "base_analitica_v1.0.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

cat("\nBase analítica exportada en:\n")
cat("  data/processed/base_analitica_v1.0.rds\n")
cat("  data/processed/base_analitica_v1.0.csv\n")

# Registrar información de sesión
capture.output(sessioninfo::session_info(),
               file = here("docs", "session_info_limpieza.txt"))
