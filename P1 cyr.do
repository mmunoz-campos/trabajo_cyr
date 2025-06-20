cd "/Users/mmunozcampos/Documents/Comp y reg/trabajo_cyr"
clear all
macro drop _all
capture log close
log using P1cyr.log, replace

import excel using "df_p1_interp.xlsx", firstrow clear

sort ciudad year prestador

egen z_infra = std(infraestructura)
egen z_operados = std(num_operados)
egen z_doctores = std(puntaje_doctor)
egen z_precio = std(precio)

* Agrupamiento jerárquico
cluster wardslinkage z_infra z_operados z_doctores z_precio

* Dendrograma para visualizar agrupamiento
cluster dendrogram, cutnumber(4)

list prestador _clus_1_ord
drop z_infra z_operados z_doctores z_precio

** PRIMERA REGRESION
gen delta = ln(mkt_share) - ln(outside_op_mktsh)

egen panel_id = group(ciudad prestador)
xtset panel_id year
xtreg delta infraestructura puntaje_doctor precio
xtreg delta infraestructura puntaje_doctor tecnologia_alta precio

** SEGUNDA REGRESION
egen infraestructura_otros = mean(infraestructura), by(ciudad year)
replace infraestructura_otros = infraestructura_otros - infraestructura

egen puntaje_otros = mean(puntaje_doctor), by(ciudad year)
replace puntaje_otros = puntaje_otros - puntaje_doctor

ivreg2 delta (precio = infraestructura_otros puntaje_doctor) infraestructura puntaje_doctor
ivreg2 delta (precio = infraestructura_otros puntaje_doctor) infraestructura ///
	puntaje_doctor tecnologia_alta
