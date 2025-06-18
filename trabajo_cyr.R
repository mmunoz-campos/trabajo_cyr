setwd("/Users/mmunozcampos/Documents/Comp y reg/trabajo_cyr")

#install.packages("zoo")

library(dplyr)
library(zoo)

base1 <- readxl::read_excel("base_1_caracteristicas.xlsx")
base2 <- readxl::read_excel("base_2_opcion_alternativa.xlsx")
fonasa_df <- readxl::read_excel("Códigos Fonasa.xlsx")


summary(as.factor(fonasa_df$grupo))

# Creamos Year y realizamos merge
base2$year <- 2001
base1 <- base1 %>%
  left_join(base2, by = c("year", "ciudad"))

rm(base2)

# Llenamos NA de tasas de crecimiento y poblacion inicial
summary(as.factor(base1$ciudad))
for (city in 1:20) {
  #crecimiento
  rate = base1$crecimiento_anual[base1$year == 2001 & base1$ciudad == city][1]
  base1$crecimiento_anual[base1$ciudad == city] <- rate
  #poblacion inicial
  pob_in = base1$poblacion_inicial[base1$year == 2001 & base1$ciudad == city][1]
  base1$poblacion_inicial[base1$ciudad == city] <- pob_in
}

# Calculamos la población aproximada
summary(as.factor(base1$year))
for (i in 0:9) {
  yr = 2001+i
  base1$poblacion_aprox[base1$year == yr] <- base1$poblacion_inicial*(1+base1$crecimiento_anual)^i
}

# cambiamos el nombre a crecimiento anual para no confundirnos
base1$pop_growth_rate_yr <- base1$crecimiento_anual
base1 <- base1 %>%
  select(-crecimiento_anual)
