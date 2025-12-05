
## Análisis Espacial de Indicadores Económicos en Latinoamérica

**Autores:** Juan Pablo Melendro, Sebastián Muñoz, Marcelo Yepes, Santiago Cobos

---

## Descripción del Proyecto

Este proyecto realiza un análisis econométrico espacial de indicadores económicos clave en países de Latinoamérica, incluyendo:
- Análisis preliminar de variables macro-económicas
- Modelado OLS (Mínimos Cuadrados Ordinarios)
- Análisis de dependencia espacial
- Modelos espaciales SARAR (Spatial Autoregressive Autoregressive)
- Visualización geoespacial de indicadores

Las variables principales analizadas incluyen:
- EMBI soberano 2023
- Préstamos del FMI
- Balance primario
- Balance de cuenta corriente
- Inflación anual
- Y otras variables macroeconómicas

---

## Ejecutar todo con un comando - Instrucciones Detalladas

**Requisitos Previos**

### 1. **Instalar R**
   - Descarga R desde [https://cran.r-project.org/](https://cran.r-project.org/)
   - Versión recomendada: R 4.0 o superior

### 2. **Paquetes requeridos**
El script instalará automáticamente los paquetes necesarios usando `pacman`:
- `tidyverse` - Manipulación y visualización de datos
- `janitor` - Limpieza de nombres de variables
- `sf` - Manejo de datos espaciales
- `tmap` - Visualización de mapas temáticos
- `spatialreg` - Análisis de econometría espacial
- `sp` - Clases espaciales
- `lmtest` - Tests para modelos lineales
- `stargazer` - Tablas de regresión
- `mapview` - Visualización interactiva de mapas
- `dplyr` - Manipulación de datos
- `jsonlite` - Procesamiento JSON
- `textreg` - Regresiones con variables de texto
- `rnaturalearth` - Datos geoespaciales mundiales
- `rnaturalearthdata` - Datos complementarios

**El script instalará automáticamente estos paquetes si no los tienes instalados.**

### 3. **Correr el código**
   1. Abrir el enlace del repositorio en el navegador: `https://github.com/jmelendro2002/Proyecto-final-Ciencia-de-Datos`
   2. Pulsar **Code → Download ZIP** y descomprimir el ZIP.
   3. Abrir RStudio
   4. Ir a File → Open File
   5. Seleccionar `script/código_FINAL.R`
   6. Presionar `Ctrl+Shift+Enter` (o `Cmd+Shift+Enter` en macOS) para ejecutar todo el script
   7. O usar `Ctrl+A` → `Ctrl+Enter` para seleccionar y ejecutar

### 4. **Alternativa con un solo código**

   1. Abrir el enlace del repositorio en el navegador: `https://github.com/jmelendro2002/Proyecto-final-Ciencia-de-Datos`
   2. Pulsar **Code → Download ZIP** y descomprimir el ZIP.
   3. Abrir RStudio
   4. Copiar y pegar el siguiente código:

```r
tmp <- tempdir()
zipfile <- file.path(tmp, "repo.zip")
download.file("https://github.com/jmelendro2002/Proyecto-final-Ciencia-de-Datos/archive/refs/heads/main.zip", zipfile, mode = "wb")
unzip(zipfile, exdir = tmp)
dirs <- list.dirs(tmp, recursive = FALSE)
dir <- dirs[grepl("Proyecto-final-Ciencia-de-Datos", dirs)][1]
setwd(dir)
source("script/código_FINAL.R")
```
   5. Presionar `Ctrl+Shift+Enter` (o `Cmd+Shift+Enter` en macOS) para ejecutar todo el script
   6. O usar `Ctrl+A` → `Ctrl+Enter` para seleccionar y ejecutar

---

## Estructura del Análisis

### 1. **Preparación del Entorno y Carga de Datos**
   - Limpieza del espacio de trabajo
   - Instalación y carga de paquetes
   - Obtención de datos geoespaciales de Latinoamérica
   - Importación y limpieza de datos económicos

### 2. **Análisis Preliminar**
   - Estadísticas descriptivas
   - Matriz de correlaciones
   - Mapas temáticos de variables clave:
     - EMBI soberano 2023
     - Préstamos del FMI
     - Balance primario
     - Cobertura de reservas ARA
     - Balance en cuenta corriente
     - Inflación anual

### 3. **Modelo Base OLS**
   - Regresión lineal simple
   - Variable dependiente: EMBI 2023
   - Variables independientes: Indicadores económicos

### 4. **Análisis de Dependencia Espacial**
   - Construcción de matrices de pesos espaciales:
     - Matriz de contigüidad (Queen)
     - Matriz de regiones económicas
   - Test de Lagrange Multiplier (LM)

### 5. **Modelos Espaciales**
   - Modelo SARAR (Spatial Autoregressive Autoregressive)
   - Cálculo de efectos directos, indirectos y totales
   - Análisis de residuales espaciales

---

## Salidas Esperadas

Al ejecutar el script, obtendrás:

1. **Tablas de Estadísticas Descriptivas**
   - Resumen estadístico de variables numéricas
   - Matriz de correlaciones

2. **Mapas Geoespaciales** (se mostrarán en la ventana gráfica de R)
   - Visualización de EMBI por país
   - Distribución de préstamos del FMI
   - Indicadores de balance y reservas
   - Tasas de inflación

3. **Resultados de Modelos Econométricos**
   - Parámetros y significancia del modelo OLS
   - Tests de dependencia espacial
   - Resultados del modelo SARAR
   - Efectos espaciales (directos e indirectos)

4. **Gráficos de Diagnóstico**
   - Mapa de residuales del modelo SARAR

---

## Variables Principales en el Análisis

| Variable | Descripción | Fuente |
|----------|-------------|--------|
| `EMBI_2023` | Emerging Markets Bond Index | Banco Mundial |
| `imf_loans_2023` | Préstamos del FMI | FMI |
| `primary_balance` | Balance primario como % del PIB | FMI |
| `overall_balance` | Balance general como % del PIB | FMI |
| `ratio_of_reserve_ara_metric_unit` | Índice de cobertura de reservas ARA | FMI |
| `exports_gdp` | Exportaciones como % del PIB | Banco Mundial |
| `imports_gdp` | Importaciones como % del PIB | Banco Mundial |
| `current_acount_balance_gdp` | Balance de cuenta corriente como % del PIB | FMI |
| `inflation_annual` | Inflación anual (%) | FMI |

---

## Notas Técnicas

- **Proyección Espacial:** Se utiliza la proyección EPSG:10603 (recomendada por el World Geodetic System para Latinoamérica)
- **Matrices de Pesos Espaciales:** 
  - Queen: Basada en contigüidad de polígonos
  - Regiones Económicas: Conexiones basadas en regiones geográficas económicas
- **Modelos Espaciales:** SARAR permite autorregresión tanto en la variable dependiente como en los errores

---

## Solución de Problemas

### Error: "Package not found"
- El script usa `pacman::p_load()` que instala automáticamente paquetes faltantes
- Si persiste el error, instala manualmente:
```r
install.packages(c("tidyverse", "sf", "tmap", "spatialreg", ...))
```

### Los mapas no aparecen
- Asegúrate de que tienes una ventana gráfica activa en RStudio
- Usa `X11()` o similar para abrir una ventana gráfica en sistemas Unix/Linux

### Error de datos en URL
- El script intenta descargar datos desde GitHub
- Verifica tu conexión a internet
- Si GitHub está inaccesible, asegúrate de tener `data/Data.csv` en el directorio local

---

## Referencias

- Natural Earth: https://www.naturalearthdata.com/
- R-spatial: https://r-spatial.org/
- Econometría Espacial: https://cran.r-project.org/web/packages/spatialreg/

---

## Licencia

Proyecto académico - Taller Final Ciencia de Datos y Econometría Aplicada
