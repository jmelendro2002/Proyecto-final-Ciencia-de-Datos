# ──────────────────────────────────────────────── 
# Taller Final Ciencia de datos y econometría aplicada

# Autores: Juan Pablo Melendro, Sebastián Muñoz, Marcelo Yepes, Santiago Cobos
# ──────────────────────────────────────────────── 


# 1. PREPARACIÓN DEL ENTORNO Y CARGA DE DATOS --------------------------------

rm(list = ls())   # limpiar objetos
graphics.off()    # cerrar ventanas de gráficos
cat("\014")       # limpiar consola

if (!require("pacman")) install.packages("pacman")

p_load("tidyverse",
      "janitor",
       "sf",
       "tmap",
       "spatialreg",
       "sp",
       "lmtest",
       "stargazer",
       "mapview",
       "dplyr",
       "jsonlite",
       "textreg",
      "rnaturalearth", 
      "rnaturalearthdata")

setwd('/Users/juanpablomelendro/Library/CloudStorage/GoogleDrive-juanpablomelendro@hotmail.com/My Drive/Semestre 9/Ciencia de datos/Talleres/Final')

# Usamos el paquete 'rnaturalearth' para obtener los datos espaciales
mundo <- ne_countries(scale = "medium", returnclass = "sf")

latam <- mundo %>%
  filter(
    subregion %in% c("South America", "Central America"),
    !name %in% c("Suriname", "Guyana", "Falkland Is.")
  ) %>%
  select(
    country = name,
    iso_a3,
    population = pop_est,
    pop_year,
    subregion,
    geometry) %>%
  st_transform(10603) # Utilizamos esta proyección como recomendación del World Geodenic System para proyecciones en Latinoamérica

# Utilizamos esta base de datos construida a partir de datos del Banco Mundial y el FMI.
dta_raw <- read.csv("Data.csv", sep = ";")

dta <- dta_raw %>%
  clean_names() %>%
  mutate(across(
    c(
    imf_loans_2023, 
    primary_balance, 
    overall_balance, 
    ratio_of_reserve_ara_metric_unit, 
    exports_gdp, 
    imports_gdp, 
    embi_2023, 
    current_acount_balance_gdp, 
    inflation_annual
  ),
  ~as.numeric(gsub(",", ".", .))
  )) 

# Unimos las dos bases de datos
union <- left_join(latam, dta, join_by(iso_a3 == country_code)) %>%
  select(-countries) %>%
  mutate(
    imf_loans_bil = imf_loans_2023 / 1e9
  ) %>%
  filter(!is.na(embi_2023))


# 2. ANALISIS PRELIMINAR --------------------------------------------------

df_desc <- union %>%
  st_drop_geometry() %>% 
  select(
    -country,
    -iso_a3,
    -pop_year,
    -subregion
  ) %>%
  select(where(is.numeric)) %>%     
  as.data.frame()                                   

stargazer(df_desc, type = "text")


# Correlaciones 
cor(
  dta[, c(
    "imf_loans_2023",
    "primary_balance",
    "overall_balance",
    "ratio_of_reserve_ara_metric_unit",
    "exports_gdp",
    "imports_gdp",
    "embi_2023",
    "current_acount_balance_gdp",
    "inflation_annual"
  )],
  use = "complete.obs"
)

# Vamos a crear mapas para visualizar las variables con correlaciones más importantes

tmap_mode("plot")

map_theme <- tm_style("white") + 
  tm_layout(
    frame = TRUE,
    title.size = 1.4,
    legend.position = c("left", "bottom"),
    legend.bg.color = "white",
    legend.bg.alpha = 0.9,
    legend.text.size = 0.8,
    legend.title.size = 0.9,
    inner.margins = c(0.03, 0.05, 0.03, 0.05)
  )

# EMBI 2023
tm_shape(union) +
  tm_polygons(
    "embi_2023",
    palette = "Reds",
    style   = "quantile",
    n       = 5,
    border.col = "white",
    border.lwd = 0.5,
    title   = "EMBI (pbs básicos)"
  ) +
  tm_layout(
    title = "EMBI soberano 2023",
    title.position = c("center", "top")
  ) +
  map_theme

# Préstamos del FMI 2023
breaks_FMI <- c(0,
                600e6,
                1e9,
                3e9,
                10e9,
                20e9,
                50e9)   # 7 cortes -> 6 clases

labels_FMI <- c("0 – 600",
                "600 – 1,000",
                "1,000 – 3,000",
                "3,000 – 10,000",
                "10,000 – 20,000",
                "20,000 – 50,000")  # 6 etiquetas

# Préstamos del FMI 2023
tm_shape(union) +
  tm_polygons(
    "imf_loans_2023",
    palette    = "Blues",
    style      = "fixed",
    breaks     = breaks_FMI,
    labels     = labels_FMI,
    border.col = "white",
    border.lwd = 0.5,
    title      = "Préstamos FMI (millones USD)"
  ) +
  tm_layout(
    title = "Préstamos del FMI 2023",
    title.position = c("center", "top")
  ) +
  map_theme

# Balance primario
tm_shape(union) +
  tm_polygons(
    "primary_balance",
    palette = "-RdBu",
    style   = "quantile",
    n       = 5,
    border.col = "white",
    border.lwd = 0.5,
    title   = "Balance primario (% del PIB)"
  ) +
  tm_layout(
    title = "Balance primario 2023",
    title.position = c("center", "top")
  ) +
  map_theme

# Índice de reservas
tm_shape(union) +
  tm_polygons(
    "ratio_of_reserve_ara_metric_unit",
    palette = "Blues",
    style   = "quantile",
    n       = 5,
    border.col = "white",
    border.lwd = 0.5,
    title   = "Índice ARA (razón reservas/meta)"
  ) +
  tm_layout(
    title = "Cobertura de reservas ARA 2023",
    title.position = c("center", "top")
  ) +
  map_theme

# Balance cuenta corriente
tm_shape(union) +
  tm_polygons(
    "current_acount_balance_gdp",
    palette = "-RdBu",
    style   = "quantile",
    n       = 5,
    border.col = "white",
    border.lwd = 0.5,
    title   = "Cuenta corriente (% del PIB)"
  ) +
  tm_layout(
    title = "Balance en cuenta corriente 2023",
    title.position = c("center", "top")
  ) +
  map_theme

breaks_inf <- c(-2, 0, 2, 4, 8, 10, 50, 250)   # 8 cortes  -> 7 clases

labels_inf <- c(
  "< 0",
  "0 – 2",
  "2 – 4",
  "4 – 8",
  "8 – 10",
  "10 – 50",
  "≥ 50"
)

# Inflación
tm_shape(union) +
  tm_polygons(
    "inflation_annual",
    palette    = "OrRd",
    style      = "fixed",
    breaks     = breaks_inf,
    labels     = labels_inf,
    border.col = "white",
    border.lwd = 0.5,
    title      = "Inflación anual (%)"
  ) +
  tm_layout(
    title = "Inflación anual 2023",
    title.position = c("center", "top")
  ) +
  map_theme


# 3. MODELO BASE MCO ------------------------------------------------------

mapview(union, zcol = "embi_2023")

ols_embi <- lm(embi_2023 ~ imf_loans_bil +
                 primary_balance +
                 ratio_of_reserve_ara_metric_unit +
                 current_acount_balance_gdp +
                 inflation_annual, data = union)
summary(ols_embi)


# 4. ANALISIS DE DEPENDENCIA ESPACIAL -------------------------------------

# 4.1. Construimos dos vecindades

# 4.1.1. Matriz de pesos por contigüidad
queen <- spdep::poly2nb(union, queen = TRUE)
queen 

# 4.1.2. Matriz de pesos por "regiones económicas"
add_nb <- function(nb, i, j) {
  nb[[i]] <- sort(unique(as.integer(c(nb[[i]], j))))
  nb[[j]] <- sort(unique(as.integer(c(nb[[j]], i))))
  nb
}

remove_nb <- function(nb, i, j) {
  nb[[i]] <- setdiff(nb[[i]], j)
  nb[[j]] <- setdiff(nb[[j]], i)
  nb
}

regiones <- queen # Vamos a duplicar la matriz queen y modificarla para construir los vecinos

# Región Norte: Colombia; Venezuela, Perú, Ecuador, Panamá
# Región Centro América: México; Honduras; Nicaragua; Costa Rica; El Salvador; Guatemala
# Región Sur: Brasil; Argentina; Chile; Paraguay; Uruguay; Bolivia. 

# Región Norte
# Venezuela
regiones <- add_nb(regiones, 1, 13)
regiones <- add_nb(regiones, 1, 11)
regiones <- add_nb(regiones, 1, 3)
regiones <- add_nb(regiones, 1, 5)
regiones <-  remove_nb(regiones, 1, 15)

# Colombia
regiones <-  remove_nb(regiones, 13, 15)

# Ecuador
regiones <- add_nb(regiones, 11, 5)

# Panamá
regiones <- add_nb(regiones, 5, 3)
regiones <-  remove_nb(regiones, 5, 12)

# Peru
regiones <-  remove_nb(regiones, 3, 16)
regiones <-  remove_nb(regiones, 3, 15)
regiones <-  remove_nb(regiones, 3, 14)

# Región Centro América

# México
regiones <- add_nb(regiones, 7, 8)
regiones <- add_nb(regiones, 7, 10)
regiones <- add_nb(regiones, 7, 12)

# Honduras
regiones <- add_nb(regiones, 8, 12)

# Guatemala
regiones <- add_nb(regiones, 9, 12)

# El Salvador
regiones <- add_nb(regiones, 10, 12)


# Región Sur
# Uruguay
regiones <- add_nb(regiones, 2, 4)
regiones <- add_nb(regiones, 2, 14)
regiones <- add_nb(regiones, 2, 16)

# Paraguay
regiones <- add_nb(regiones, 4, 14)

# Chile
regiones <- add_nb(regiones, 14, 15)

# 4.2. Construimos las matrices de pesos
W_region <- spdep::nb2listw(regiones, style = "W")
W_queen <- spdep::nb2listw(queen, style = "W")

# 4.3. Test de Lagrange Multiplier

# 4.3.1. Para la matriz de "regiones económicas"

lm_tests <- spdep::lm.RStests(ols_embi, W_region, 
                              test = c("LMlag", "LMerr", "RLMlag", "RLMerr"))

print(lm_tests) 

# 4.3.2. Para la matriz de distancias queen

lm_tests_queen <- spdep::lm.RStests(ols_embi, W_queen, 
                              test = c("LMlag", "LMerr", "RLMlag", "RLMerr"))

print(lm_tests_queen) # Los resultados sugieren fuertemente un rezago espacial y en los errores


# 5. MODELOS ESPACIALES ---------------------------------------------------

# 5.1. Calculamos solo un SARAR para el modelo de matriz de contigüidad
sarar_embi <- sacsarlm(embi_2023 ~ imf_loans_bil +
                 primary_balance +
                 ratio_of_reserve_ara_metric_unit +
                 current_acount_balance_gdp +
                 inflation_annual,
                      data = union,
                      listw = W_queen)
summary(sarar_embi)

# 5.2. Impactos directos/indirectos y totales
effects_embi <- impacts(
  sarar_embi,
  listw = W_queen,
  R = 5000      
)

summary(effects_embi, zstats = TRUE, short = TRUE)


# 5.3. Residuos de la regresión 

union$res_SARAR <- residuals(sarar_embi)

# 5.3.1. Mapa de residuales no observados

tm_shape(union) +
  tm_fill("res_SARAR", palette = "magma", style = "quantile", n = 5, title = "Residuales") +
  tm_borders(col = "white", lwd = 0.2) 
