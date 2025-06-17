setwd("/Users/mmunozcampos/Documents/Comp y reg/trabajo_cyr")

base1 <- readxl::read_excel("base_1_caracteristicas.xlsx")
base2 <- readxl::read_excel("base_2_opcion_alternativa.xlsx")
fonasa_df <- readxl::read_excel("Códigos Fonasa.xlsx")

summary(base1)
