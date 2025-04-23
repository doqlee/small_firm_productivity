* Figure 1: TFP level path for SMEs and large firms

use BvD_ID_number firm_id year ISO2 nace2_2 tfp1 /// 
    using "../data/cleaned/sample_tfp_2008.dta", clear 

keep if year>=2003 & year<=2014

* Firm size pre crisis

foreach vv in EMPL eur_TOAS eur_OPRE {
    
	merge m:1 BvD_ID_number using "../data/cleaned/prePost_`vv'.dta" ///
		, nogen keep(1 3) keepusing(*_p*1yr* *_p*4yr*)
	
}

* Size bins: 1 = Micro, 2 = Small, 3 = Medium, 4 = Large (Euro definition)

* Based on Employees

gen byte size_EMPL_pre4yrBal_1 = ///
	(EMPL_pre4yrBal < 10) ///
		if !mi(EMPL_pre4yrBal)
lab var size_EMPL_pre4yrBal_1 "Micro"
gen byte size_EMPL_pre4yrBal_2 = ///
	(EMPL_pre4yrBal >= 10) ///
	& (EMPL_pre4yrBal < 50) ///
		if !mi(EMPL_pre4yrBal)
lab var size_EMPL_pre4yrBal_2 "Small"
gen byte size_EMPL_pre4yrBal_3 = ///
	(EMPL_pre4yrBal >= 50) ///
	& (EMPL_pre4yrBal < 250) ///
		if !mi(EMPL_pre4yrBal)
lab var size_EMPL_pre4yrBal_3 "Medium"

gen size_EMPL_pre4yrBal = ""
replace size_EMPL_pre4yrBal = "Micro" ///
	if (EMPL_pre4yrBal < 10) ///
		& !mi(EMPL_pre4yrBal)
replace size_EMPL_pre4yrBal = "Small" ///
	if (EMPL_pre4yrBal >= 10) ///
		& (EMPL_pre4yrBal < 50) ///
		& !mi(EMPL_pre4yrBal)
replace size_EMPL_pre4yrBal = "Medium" ///
	if (EMPL_pre4yrBal >= 50) ///
		& (EMPL_pre4yrBal < 250) ///
		& !mi(EMPL_pre4yrBal)
replace size_EMPL_pre4yrBal = "Large" ///
	if (EMPL_pre4yrBal >= 250) ///
		& !mi(EMPL_pre4yrBal)

gen SME_EMPL_pre4yrBal = "Large" ///
	if size_EMPL_pre4yrBal=="Large"
replace SME_EMPL_pre4yrBal = "SME" ///
	if size_EMPL_pre4yrBal=="Micro"
replace SME_EMPL_pre4yrBal = "SME" ///
	if size_EMPL_pre4yrBal=="Small"
replace SME_EMPL_pre4yrBal = "SME" ///
	if size_EMPL_pre4yrBal=="Medium"

gen size_EMPL_post4yrBal = ""
replace size_EMPL_post4yrBal = "Micro" ///
	if (EMPL_post4yrBal < 10) ///
		& !mi(EMPL_post4yrBal)
replace size_EMPL_post4yrBal = "Small" ///
	if (EMPL_post4yrBal >= 10) ///
		& (EMPL_post4yrBal < 50) ///
		& !mi(EMPL_post4yrBal)
replace size_EMPL_post4yrBal = "Medium" ///
	if (EMPL_post4yrBal >= 50) ///
		& (EMPL_post4yrBal < 250) ///
		& !mi(EMPL_post4yrBal)
replace size_EMPL_post4yrBal = "Large" ///
	if (EMPL_post4yrBal >= 250) ///
		& !mi(EMPL_post4yrBal)

gen SME_EMPL_post4yrBal = "Large" ///
	if size_EMPL_post4yrBal=="Large"
replace SME_EMPL_post4yrBal = "SME" ///
	if size_EMPL_post4yrBal=="Micro"
replace SME_EMPL_post4yrBal = "SME" ///
	if size_EMPL_post4yrBal=="Small"
replace SME_EMPL_post4yrBal = "SME" ///
	if size_EMPL_post4yrBal=="Medium"

* Based on annual turnover (operating revenue turnover)

gen byte size_OPRE_pre4yrBal_1 = ///
	(eur_OPRE_pre4yrBal <= 2 * 10^6) ///
		if !mi(eur_OPRE_pre4yrBal)
lab var size_OPRE_pre4yrBal_1 "Micro"
gen byte size_OPRE_pre4yrBal_2 = ///
	(eur_OPRE_pre4yrBal > 2 * 10^6) ///
	& (eur_OPRE_pre4yrBal <= 10 * 10^6) ///
		if !mi(eur_OPRE_pre4yrBal)
lab var size_OPRE_pre4yrBal_2 "Small"
gen byte size_OPRE_pre4yrBal_3 = ///
	(eur_OPRE_pre4yrBal > 10 * 10^6) ///
	& (eur_OPRE_pre4yrBal <= 50 * 10^6) ///
		if !mi(eur_OPRE_pre4yrBal)
lab var size_OPRE_pre4yrBal_3 "Medium"

gen size_OPRE_pre4yrBal = ""
replace size_OPRE_pre4yrBal = "Micro" ///
	if (eur_OPRE_pre4yrBal <= 2 * 10^6) ///
	& !mi(eur_OPRE_pre4yrBal)
replace size_OPRE_pre4yrBal = "Small" ///
	if (eur_OPRE_pre4yrBal > 2 * 10^6) ///
	& (eur_OPRE_pre4yrBal <= 10 * 10^6) ///
		& !mi(eur_OPRE_pre4yrBal)
replace size_OPRE_pre4yrBal = "Medium" ///
	if (eur_OPRE_pre4yrBal > 10 * 10^6) ///
	& (eur_OPRE_pre4yrBal <= 50 * 10^6) ///
		& !mi(eur_OPRE_pre4yrBal)
replace size_OPRE_pre4yrBal = "Large" ///
	if (eur_OPRE_pre4yrBal > 50 * 10^6) ///
		& !mi(eur_OPRE_pre4yrBal)

gen SME_OPRE_pre4yrBal = "Large" ///
	if size_OPRE_pre4yrBal=="Large"
replace SME_OPRE_pre4yrBal = "SME" ///
	if size_OPRE_pre4yrBal=="Micro"
replace SME_OPRE_pre4yrBal = "SME" ///
	if size_OPRE_pre4yrBal=="Small"
replace SME_OPRE_pre4yrBal = "SME" ///
	if size_OPRE_pre4yrBal=="Medium"

gen size_OPRE_post4yrBal = ""
replace size_OPRE_post4yrBal = "Micro" ///
	if (eur_OPRE_post4yrBal <= 2 * 10^6) ///
	& !mi(eur_OPRE_post4yrBal)
replace size_OPRE_post4yrBal = "Small" ///
	if (eur_OPRE_post4yrBal > 2 * 10^6) ///
	& (eur_OPRE_post4yrBal <= 10 * 10^6) ///
		& !mi(eur_OPRE_post4yrBal)
replace size_OPRE_post4yrBal = "Medium" ///
	if (eur_OPRE_post4yrBal > 10 * 10^6) ///
	& (eur_OPRE_post4yrBal <= 50 * 10^6) ///
		& !mi(eur_OPRE_post4yrBal)
replace size_OPRE_post4yrBal = "Large" ///
	if (eur_OPRE_post4yrBal > 50 * 10^6) ///
		& !mi(eur_OPRE_post4yrBal)

gen SME_OPRE_post4yrBal = "Large" ///
	if size_OPRE_post4yrBal=="Large"
replace SME_OPRE_post4yrBal = "SME" ///
	if size_OPRE_post4yrBal=="Micro"
replace SME_OPRE_post4yrBal = "SME" ///
	if size_OPRE_post4yrBal=="Small"
replace SME_OPRE_post4yrBal = "SME" ///
	if size_OPRE_post4yrBal=="Medium"

* Based on balance sheet total (total assets)

gen byte size_TOAS_pre4yrBal_1 = ///
	(eur_TOAS_pre4yrBal <= 2 * 10^6) ///
		if !mi(eur_TOAS_pre4yrBal)
lab var size_TOAS_pre4yrBal_1 "Micro"
gen byte size_TOAS_pre4yrBal_2 = ///
	(eur_TOAS_pre4yrBal > 2 * 10^6) ///
	& (eur_TOAS_pre4yrBal <= 10 * 10^6) ///
		if !mi(eur_TOAS_pre4yrBal)
lab var size_TOAS_pre4yrBal_2 "Small"
gen byte size_TOAS_pre4yrBal_3 = ///
	(eur_TOAS_pre4yrBal > 10 * 10^6) ///
	& (eur_TOAS_pre4yrBal <= 43 * 10^6) ///
		if !mi(eur_TOAS_pre4yrBal)
lab var size_TOAS_pre4yrBal_3 "Medium"

gen size_TOAS_pre4yrBal = ""
replace size_TOAS_pre4yrBal = "Micro" ///
	if (eur_TOAS_pre4yrBal <= 2 * 10^6) ///
	& !mi(eur_TOAS_pre4yrBal)
replace size_TOAS_pre4yrBal = "Small" ///
	if (eur_TOAS_pre4yrBal > 2 * 10^6) ///
	& (eur_TOAS_pre4yrBal <= 10 * 10^6) ///
		& !mi(eur_TOAS_pre4yrBal)
replace size_TOAS_pre4yrBal = "Medium" ///
	if (eur_TOAS_pre4yrBal > 10 * 10^6) ///
	& (eur_TOAS_pre4yrBal <= 43 * 10^6) ///
		& !mi(eur_TOAS_pre4yrBal)
replace size_TOAS_pre4yrBal = "Large" ///
	if (eur_TOAS_pre4yrBal > 43 * 10^6) ///
		& !mi(eur_TOAS_pre4yrBal)

gen SME_TOAS_pre4yrBal = "Large" ///
	if size_TOAS_pre4yrBal=="Large"
replace SME_TOAS_pre4yrBal = "SME" ///
	if size_TOAS_pre4yrBal=="Micro"
replace SME_TOAS_pre4yrBal = "SME" ///
	if size_TOAS_pre4yrBal=="Small"
replace SME_TOAS_pre4yrBal = "SME" ///
	if size_TOAS_pre4yrBal=="Medium"

gen size_TOAS_post4yrBal = ""
replace size_TOAS_post4yrBal = "Micro" ///
	if (eur_TOAS_post4yrBal <= 2 * 10^6) ///
	& !mi(eur_TOAS_post4yrBal)
replace size_TOAS_post4yrBal = "Small" ///
	if (eur_TOAS_post4yrBal > 2 * 10^6) ///
	& (eur_TOAS_post4yrBal <= 10 * 10^6) ///
		& !mi(eur_TOAS_post4yrBal)
replace size_TOAS_post4yrBal = "Medium" ///
	if (eur_TOAS_post4yrBal > 10 * 10^6) ///
	& (eur_TOAS_post4yrBal <= 43 * 10^6) ///
		& !mi(eur_TOAS_post4yrBal)
replace size_TOAS_post4yrBal = "Large" ///
	if (eur_TOAS_post4yrBal > 43 * 10^6) ///
		& !mi(eur_TOAS_post4yrBal)

gen SME_TOAS_post4yrBal = "Large" ///
	if size_TOAS_post4yrBal=="Large"
replace SME_TOAS_post4yrBal = "SME" ///
	if size_TOAS_post4yrBal=="Micro"
replace SME_TOAS_post4yrBal = "SME" ///
	if size_TOAS_post4yrBal=="Small"
replace SME_TOAS_post4yrBal = "SME" ///
	if size_TOAS_post4yrBal=="Medium"

* Based on Employees AND (total assets OR revenue)

gen byte _cnd = !mi(EMPL_pre4yrBal) ///
	& !mi(eur_OPRE_pre4yrBal) ///
	& !mi(eur_TOAS_pre4yrBal)

gen size_EURO_pre4yrBal = ""
replace size_EURO_pre4yrBal = "Micro" ///
	if (EMPL_pre4yrBal < 10) & ( ///
		(eur_OPRE_pre4yrBal <= 2 * 10^6) | ///
		(eur_TOAS_pre4yrBal <= 2 * 10^6) ///
		) & _cnd==1
replace size_EURO_pre4yrBal = "Small" ///
	if (EMPL_pre4yrBal < 50) & ( ///
		(eur_OPRE_pre4yrBal <= 10 * 10^6) | ///
		(eur_TOAS_pre4yrBal <= 10 * 10^6) ///
		) & _cnd==1 & size_EURO_pre4yrBal==""
replace size_EURO_pre4yrBal = "Medium" ///
	if (EMPL_pre4yrBal < 250) & ( ///
		(eur_OPRE_pre4yrBal <= 50 * 10^6) | ///
		(eur_TOAS_pre4yrBal <= 43 * 10^6) ///
		) & _cnd==1 & size_EURO_pre4yrBal==""
replace size_EURO_pre4yrBal = "Large" ///
	if _cnd==1 & size_EURO_pre4yrBal==""

gen byte size_EURO_pre4yrBal_1 = ///
	(size_EURO_pre4yrBal=="Micro") if _cnd==1
lab var size_EURO_pre4yrBal_1 "Micro"

gen byte size_EURO_pre4yrBal_2 = ///
	(size_EURO_pre4yrBal=="Small") if _cnd==1
lab var size_EURO_pre4yrBal_2 "Small"

gen byte size_EURO_pre4yrBal_3 = ///
	(size_EURO_pre4yrBal=="Medium") if _cnd==1
lab var size_EURO_pre4yrBal_3 "Medium"

gen SME_EURO_pre4yrBal = "Large" ///
	if size_EURO_pre4yrBal=="Large"
replace SME_EURO_pre4yrBal = "SME" ///
	if size_EURO_pre4yrBal=="Micro"
replace SME_EURO_pre4yrBal = "SME" ///
	if size_EURO_pre4yrBal=="Small"
replace SME_EURO_pre4yrBal = "SME" ///
	if size_EURO_pre4yrBal=="Medium"

drop _cnd

gen byte _cnd = !mi(EMPL_post4yrBal) ///
	& !mi(eur_OPRE_post4yrBal) ///
	& !mi(eur_TOAS_post4yrBal)

gen size_EURO_post4yrBal = ""
replace size_EURO_post4yrBal = "Micro" ///
	if (EMPL_post4yrBal < 10) & ( ///
		(eur_OPRE_post4yrBal <= 2 * 10^6) | ///
		(eur_TOAS_post4yrBal <= 2 * 10^6) ///
		) & _cnd==1
replace size_EURO_post4yrBal = "Small" ///
	if (EMPL_post4yrBal < 50) & ( ///
		(eur_OPRE_post4yrBal <= 10 * 10^6) | ///
		(eur_TOAS_post4yrBal <= 10 * 10^6) ///
		) & _cnd==1 & size_EURO_post4yrBal==""
replace size_EURO_post4yrBal = "Medium" ///
	if (EMPL_post4yrBal < 250) & ( ///
		(eur_OPRE_post4yrBal <= 50 * 10^6) | ///
		(eur_TOAS_post4yrBal <= 43 * 10^6) ///
		) & _cnd==1 & size_EURO_post4yrBal==""
replace size_EURO_post4yrBal = "Large" ///
	if _cnd==1 & size_EURO_post4yrBal==""

gen byte size_EURO_post4yrBal_1 = ///
	(size_EURO_post4yrBal=="Micro") if _cnd==1
lab var size_EURO_post4yrBal_1 "Micro"

gen byte size_EURO_post4yrBal_2 = ///
	(size_EURO_post4yrBal=="Small") if _cnd==1
lab var size_EURO_post4yrBal_2 "Small"

gen byte size_EURO_post4yrBal_3 = ///
	(size_EURO_post4yrBal=="Medium") if _cnd==1
lab var size_EURO_post4yrBal_3 "Medium"

gen SME_EURO_post4yrBal = "Large" ///
	if size_EURO_post4yrBal=="Large"
replace SME_EURO_post4yrBal = "SME" ///
	if size_EURO_post4yrBal=="Micro"
replace SME_EURO_post4yrBal = "SME" ///
	if size_EURO_post4yrBal=="Small"
replace SME_EURO_post4yrBal = "SME" ///
	if size_EURO_post4yrBal=="Medium"

* Exclude certain industries

drop if nace2_2==64 // financial and insurance activities
drop if nace2_2==65 // financial and insurance activities
drop if nace2_2==66 // financial and insurance activities
drop if nace2_2==84 // public service
drop if nace2_2==94 // other service activities
drop if nace2_2==95 // other service activities
drop if nace2_2==96 // other service activities
drop if nace2_2==97 // household employers
drop if nace2_2==98 // household employers
drop if nace2_2==99 // Extraterritorial organizations

drop if EMPL_pre4yrBal < 1

keep firm_id year ISO2 tfp1 SME_EURO_pre4yrBal SME_EURO_post4yrBal

keep if !mi(SME_EURO_pre4yrBal) & !mi(SME_EURO_post4yrBal)

winsor2 tfp1, by(ISO2 year) cuts(1 99) replace trim 

* Balanced sample for TFP

gen byte _sample = 1 if !mi(tfp1) & year>=2004 & year<=2014

bys firm_id (year): egen _tmp = total(_sample) if year>=2004 & year<=2014
bys firm_id (year): egen _cnt = min(_tmp)

qui su year if year>=2004 & year<=2014
gen byte balanced = (_cnt>=(r(max) - r(min) + 1))
	drop _sample _tmp _cnt

keep if balanced==1

drop if SME_EURO_pre4yrBal=="SME" & SME_EURO_post4yrBal=="Large"
drop if SME_EURO_pre4yrBal=="Large" & SME_EURO_post4yrBal=="SME"

keep firm_id year SME_EURO_pre4yrBal tfp1

collapse (mean) tfp1, by(year SME_EURO_pre4yrBal)

bys SME_EURO_pre4yrBal (year): gen _tmp = tfp1 if year==2006
bys SME_EURO_pre4yrBal (year): egen tfp1_2006 = min(_tmp)
gen expu_tfp1 = exp(tfp1) / exp(tfp1_2006) * 100
drop _tmp tfp1_2006

drop if year < 2004

encode SME_EURO_pre4yrBal, gen(n_SME_EURO_pre4yrBal)
xtset n_SME_EURO_pre4yrBal year

twoway ///
	(tsline expu_tfp1 if SME_EURO_pre4yrBal=="SME" ///
		, lp(solid) lc(black) lw(medium)) ///
	(tsline expu_tfp1 if SME_EURO_pre4yrBal=="Large" ///
		, lp(longdash) lc(gs5) lw(medium)) ///
	, graphregion(color(white)) plotregion(margin(zero)) ///
	xtitle("") xlabel(2005(2)2013) ///
	ytitle("") ylabel(90(5)105, angle(0)) /// 
	legend(order(1 "SME" 2 "Large") row(1))
/*
graph export "../figures/figure_1.pdf", as(pdf) replace
graph close
*/
