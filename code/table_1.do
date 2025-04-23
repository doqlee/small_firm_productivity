* Table 1: Summary Statistics on firms

use "../data/cleaned/sample_did.dta", clear

qui {

* Baseline TFP, size, employees

ds ///
	DiD_D_tfp1_4yrBal ///
	D_tfp1_pre4yrBal ///
	size_EURO_pre4yrBal_1 ///
	size_EURO_pre4yrBal_2 ///
	size_EURO_pre4yrBal_3 
	
foreach vv in `r(varlist)' {

	cap drop t_`vv'
	gen t_`vv' = `vv' if esample==1
	loc lbl: var label `vv'
	lab var t_`vv' "`lbl'"
}

* Balance sheet controls

ds ///
	age_pre1yr ///
	leverage_pre4yrBal ///
	CULI_OPRE_pre4yrBal ///
	CS_TA_pre4yrBal ///
	CUAS_CULI_pre4yrBal ///
	ln_EBITDA_pre4yrBal
	
foreach vv in `r(varlist)' {

	cap drop t_`vv'
	gen t_`vv' = `vv' if esample1==1
	loc lbl: var label `vv'
	lab var t_`vv' "`lbl'"
}

* Credit

ds raw_spread raw_tier1 tmp_cds

foreach vv in `r(varlist)' {
	
	reghdfe DiD_D_tfp1_4yrBal D_tfp1_pre4yrBal ///
		size_EURO_pre4yrBal_* age_pre1yr $controls `vv' ///
		if cds_presence!=. ///
		, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	cap drop t_`vv'
	gen t_`vv' = `vv' if e(sample)
	loc lbl: var label `vv'
	lab var t_`vv' "`lbl'"
}

ds delta_cds_country shr_relationship

foreach vv in `r(varlist)' {
	
	reghdfe DiD_D_tfp1_4yrBal D_tfp1_pre4yrBal ///
		size_EURO_pre4yrBal_* age_pre1yr $controls `vv' ///
		, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	cap drop t_`vv'
	gen t_`vv' = `vv' if e(sample)
	loc lbl: var label `vv'
	lab var t_`vv' "`lbl'"
}

replace t_delta_cds_country = t_delta_cds_country * 100
replace t_raw_spread = t_raw_spread * 100

ds t_delta_cds_country t_shr_relationship

foreach vv in `r(varlist)' {
	
	gen byte _nmi = !mi(`vv')
	bys ISO2 _nmi: replace `vv' = . if _n > 1
		drop _nmi
}

* Intangible investment share

ds ///
	DiD_shr_D_ik_4yr /// 
	shr_D_ik_pre4yr //
	
foreach vv in `r(varlist)' {
	
	reghdfe DiD_shr_D_ik_4yr shr_D_ik_pre4yr ///
		size_EURO_pre4yrBal_* age_pre1yr $controls /// 
		if esample1==1, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	cap drop t_`vv'
	gen t_`vv' = `vv' if e(sample)
	loc lbl: var label `vv'
	lab var t_`vv' "`lbl'"
}

* Patent applications

ds ///
	DiD_patent_app_4yrBal ///
	patent_app_pre4yrBal //

foreach vv in `r(varlist)' {
	
	reghdfe DiD_patent_app_4yrBal patent_app_pre4yrBal ///
		size_EURO_pre4yrBal_* age_pre1yr $controls /// 
		if esample1==1, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	cap drop t_`vv'
	gen t_`vv' = `vv' if e(sample)
	loc lbl: var label `vv'
	lab var t_`vv' "`lbl'"
}

lab var t_DiD_D_tfp1_4yrBal "$\Delta TFP\text{ growth (Baseline)}$"
lab var t_D_tfp1_pre4yrBal "$ TFP $"
lab var t_size_EURO_pre4yrBal_1 "$\text{Micro}$"
lab var t_size_EURO_pre4yrBal_2 "$\text{Small}$"
lab var t_size_EURO_pre4yrBal_3 "$\text{Medium}$"
lab var t_age_pre1yr "$\text{Age}$"
lab var t_leverage_pre4yrBal "$\text{Leverage}$"
lab var t_CULI_OPRE_pre4yrBal "$\text{Debt Maturity}$"
lab var t_CS_TA_pre4yrBal "$\text{Cash Flow}$"
lab var t_CUAS_CULI_pre4yrBal "$\text{Liquidity}$"
lab var t_ln_EBITDA_pre4yrBal "$\text{Profitability}$"
lab var t_DiD_shr_D_ik_4yr "$\Delta\text{Intangible investment share}$"
lab var t_shr_D_ik_pre4yr "$\text{Intangible investment share}$"
lab var t_DiD_patent_app_4yrBal "$\Delta\text{Patent Applications}$"
lab var t_patent_app_pre4yrBal "$\text{Patent Applications}$"
lab var t_delta_cds_country "$\Delta\text{CDS (Country-level)}$"
lab var t_raw_spread "$\Delta\text{CDS (Firm-level)}$" // 
lab var t_raw_tier1 "$\text{Tier 1 Capital Ratio}$"
lab var t_tmp_cds "$\text{CDS Presence}$"
lab var t_shr_relationship "$\text{Relationship Bank Share}$"

} // end qui

* Summary statistics

eststo clear

estpost su ///
	t_DiD_D_tfp1_4yrBal ///
	t_D_tfp1_pre4yrBal ///
	t_size_EURO_pre4yrBal_1 ///
	t_size_EURO_pre4yrBal_2 ///
	t_size_EURO_pre4yrBal_3 ///
	t_age_pre1yr ///
	t_leverage_pre4yrBal ///
	t_CULI_OPRE_pre4yrBal ///
	t_CS_TA_pre4yrBal ///
	t_CUAS_CULI_pre4yrBal ///
	t_ln_EBITDA_pre4yrBal ///
	t_DiD_shr_D_ik_4yr ///
	t_shr_D_ik_pre4yr ///
	t_DiD_patent_app_4yrBal /// 
	t_patent_app_pre4yrBal /// 
	t_delta_cds_country ///
	t_raw_spread /// 
	t_raw_tier1 /// 
	t_tmp_cds /// 
	t_shr_relationship ///
	, d
	
est store t0a
/*
esttab t0a using "../tables/table_1.tex" ///
	, label noobs nonote nonum nomtitles ///
	type substitute(\_ _) fragment booktabs replace ///
	cells((count(fmt(%9.0gc) label(Obs)) ///
		mean(fmt(%9.2fc) label(Mean)) ///
		sd(fmt(%9.2fc) label(St. Dev.)) ///
		min(fmt(%9.2fc) label(Min)) ///
		p50(fmt(%9.2fc) label(Median)) ///
		max(fmt(%9.2fc) label(Max)) ///
		))
*/