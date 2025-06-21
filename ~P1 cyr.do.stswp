cd "/Users/mmunozcampos/Documents/Comp y reg/trabajo_cyr"
clear all
macro drop _all
capture log close
log using P1cyr.log, replace

import excel using "df_p1.xlsx", firstrow clear

sort ciudad year prestador

** Vemos como evoluciona el ratio a traves del tiempo
preserve
gen mkt_relativo = mkt_operacion / mkt_total
collapse (mean) mkt_relativo, by(year)
twoway line mkt_relativo year, ///
    ytitle("Total de operados respecto al mercado total (%)") ///
	xtitle("Año")
restore

** Vemos como afectan las nuevas tecnologias
preserve 
collapse (sum) num_operados, by(year prestador)
twoway line num_operados year if prestador == "Clinica_A", ///
    xline(2008, lpattern(dash) lcolor(red)) ///
    ytitle("Número de operados") ///
    xtitle("Año") ///
    title("Evolución de Clinica A con incorporación tecnológica")
graph export newtec_CA.png, replace

twoway line num_operados year if prestador == "Clinica_B", ///
    xline(2006, lpattern(dash) lcolor(red)) ///
    ytitle("Número de operados") ///
    xtitle("Año") ///
    title("Evolución de Clinica B con incorporación tecnológica")
graph export newtec_CB.png, replace

twoway line num_operados year if prestador == "Clinica_C", ///
    ytitle("Número de operados") ///
    xtitle("Año") ///
    title("Evolución del Clínica C")
graph export newtec_CC.png, replace

twoway line num_operados year if prestador == "Publico", ///
    xline(2008, lpattern(dash) lcolor(red)) ///
    ytitle("Número de operados") ///
    xtitle("Año") ///
    title("Evolución del servicio publico con incorporación tecnológica")
graph export newtec_PB.png, replace

restore


** Vemos cuales son mas similares
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

** MODELO LOGIT

** PRIMERA REGRESION (Sin instrumentos)
gen delta = ln(mkt_share) - ln(outside_op_mktsh)

egen panel_id = group(ciudad prestador)
xtset panel_id year
xtreg delta infraestructura puntaje_doctor precio, r
outreg2 using "p1_regs.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	cttop("MCO") ///
	label replace word
xtreg delta infraestructura puntaje_doctor tecnologia_alta precio, r
outreg2 using "p1_regs.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	cttop("MCO") ///
	label append word

** SEGUNDA REGRESION (Con instrumentos)
egen infraestructura_otros = mean(infraestructura), by(ciudad year)
replace infraestructura_otros = infraestructura_otros - infraestructura

egen puntaje_otros = mean(puntaje_doctor), by(ciudad year)
replace puntaje_otros = puntaje_otros - puntaje_doctor

** Regresión primera etapa
reg precio infraestructura_otros puntaje_otros infraestructura puntaje_doctor ///
	tecnologia_alta, r
test infraestructura_otros puntaje_otros
local F1 r(F)
outreg2 using "p1_regs.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	adds("F-test excluded instrument", `F1') ///
	cttop("Primera Etapa") ///
	label append word

ivreg2 delta (precio = infraestructura_otros puntaje_otros) infraestructura ///
	puntaje_doctor, r first
outreg2 using "p1_regs.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	cttop("MC2E") ///
	label append word
ivreg2 delta (precio = infraestructura_otros puntaje_doctor) infraestructura ///
	puntaje_doctor tecnologia_alta, r first
outreg2 using "p1_regs.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	cttop("MC2E") ///
	label append word
	
	
*** NESTED LOGIT

gen grupo = .
replace grupo = 1 if prestador == "Clinica_A" | prestador == "Clinica_B"
replace grupo = 2 if prestador == "Clinica_C"
replace grupo = 3 if prestador == "Publico"

* Share del prestador dentro de su grupo
bysort grupo ciudad: egen total_grupo = total(num_operados)
gen s_jg = num_operados / total_grupo
gen ln_sjg = ln(s_jg)


** Regresión primera etapa
reg precio infraestructura_otros puntaje_otros infraestructura puntaje_doctor ///
	tecnologia_alta ln_sjg, r
test infraestructura_otros puntaje_otros
local F1 r(F)
outreg2 using "p1_regs_nested.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	adds("F-test excluded instrument", `F1') ///
	cttop("Primera Etapa") ///
	label replace word

ivreg2 delta ln_sjg infraestructura puntaje_doctor ///
    (precio = infraestructura_otros puntaje_otros), r first
outreg2 using "p1_regs_nested.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	cttop("MC2E") ///
	label append word
	
** repetimos para la otra base
import excel using "df_p1_interp.xlsx", firstrow clear

** Generamos variables de nuevo
gen delta = ln(mkt_share) - ln(outside_op_mktsh)

egen infraestructura_otros = mean(infraestructura), by(ciudad year)
replace infraestructura_otros = infraestructura_otros - infraestructura

egen puntaje_otros = mean(puntaje_doctor), by(ciudad year)
replace puntaje_otros = puntaje_otros - puntaje_doctor

gen grupo = .
replace grupo = 1 if prestador == "Clinica_A" | prestador == "Clinica_B"
replace grupo = 2 if prestador == "Clinica_C"
replace grupo = 3 if prestador == "Publico"

* Share del prestador dentro de su grupo
bysort grupo ciudad: egen total_grupo = total(num_operados)
gen s_jg = num_operados / total_grupo
gen ln_sjg = ln(s_jg)


** Regresión primera etapa
reg precio infraestructura_otros puntaje_otros infraestructura puntaje_doctor ///
	tecnologia_alta ln_sjg, r
test infraestructura_otros puntaje_otros
local F1 r(F)
outreg2 using "p1_regs_nested.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	adds("F-test excluded instrument", `F1') ///
	addtext("Base rellenada", "X") ///
	cttop("Primera Etapa") ///
	label append word

ivreg2 delta ln_sjg infraestructura puntaje_doctor ///
    (precio = infraestructura_otros puntaje_otros), r first
outreg2 using "p1_regs_nested.doc", ///
	nonotes bracket sdec(3) bdec(3) ///
	addtext("Base rellenada", "X") ///
	cttop("MC2E") ///
	label append word


	
