* Table 4: Credit market vulnerability

use "../data/cleaned/sample_did.dta", clear

qui {

ds ///
	std_delta_cds_country ///
	tmp_spread /// 
	tmp_tier1 /// 
	tmp_cds /// 
	shr_relationship
	
global credits "`r(varlist)'"

eststo clear

gen _X = .
lab var _X "$ \text{Credit} $"

foreach ctrl in ///
	D_tfp1_pre4yrBal ///
	size_EURO_pre4yrBal_1 ///
	size_EURO_pre4yrBal_2 ///
	size_EURO_pre4yrBal_3 ///
	age_pre1yr age2_pre1yr $controls {
	
	gen `ctrl'_X = .
	loc lbl_ctrl: variable label `ctrl'
	lab var `ctrl'_X "`lbl_ctrl' $\times$ $\text{Credit}$"
	
} // end ctrl loop

foreach credit in $credits {
    
    replace _X = `credit'
    
    foreach ctrl in ///
    	D_tfp1_pre4yrBal ///
    	size_EURO_pre4yrBal_1 ///
    	size_EURO_pre4yrBal_2 ///
    	size_EURO_pre4yrBal_3 ///
    	age_pre1yr age2_pre1yr $controls {
    	
    	replace `ctrl'_X = `ctrl' * `credit'
    	
    } // end ctrl loop
    
    if "`credit'"=="delta_cds_country" {
    	loc credit0 
    }
    else if "`credit'"=="shr_relationship" {
    	loc credit0 
    }
    else {
    	loc credit0 _X
    }
    
    if "`credit'"=="shr_relationship" {
    	loc cnd ""
    }
    else {
    	loc cnd "if cds_presence!=."
    }
    di "`cnd'"
    
    * Fix the sample to firms with all controls available 
    
    reghdfe DiD_D_tfp1_4yrBal ///
    	D_tfp1_pre4yrBal D_tfp1_pre4yrBal_X ///
    	size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
    	size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
    	size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
    	age_pre1yr age_pre1yr_X ///
    	age2_pre1yr age2_pre1yr_X /// 
    	leverage_pre4yrBal leverage_pre4yrBal_X /// 
    	CULI_OPRE_pre4yrBal CULI_OPRE_pre4yrBal_X /// 
    	CS_TA_pre4yrBal CS_TA_pre4yrBal_X /// 
    	CUAS_CULI_pre4yrBal CUAS_CULI_pre4yrBal_X /// 
    	ln_EBITDA_pre4yrBal ln_EBITDA_pre4yrBal_X /// 
    	`credit0' ///
    	`cnd' ///
    	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
    
    cap drop tmp_esample
    gen byte tmp_esample = e(sample)
    
    eststo: reghdfe DiD_D_tfp1_4yrBal ///
    	D_tfp1_pre4yrBal D_tfp1_pre4yrBal_X /// 
    	size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
    	size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
    	size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
    	age_pre1yr age_pre1yr_X ///
    	age2_pre1yr age2_pre1yr_X /// 
    	leverage_pre4yrBal leverage_pre4yrBal_X /// 
    	CULI_OPRE_pre4yrBal CULI_OPRE_pre4yrBal_X /// 
    	CS_TA_pre4yrBal CS_TA_pre4yrBal_X /// 
    	CUAS_CULI_pre4yrBal CUAS_CULI_pre4yrBal_X /// 
    	ln_EBITDA_pre4yrBal ln_EBITDA_pre4yrBal_X /// 
    	`credit0' ///
    	if tmp_esample ///
    	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
    	
    	su `e(depvar)' if e(sample)
    	estadd scalar mdv `r(mean)', replace
    	estadd local ldv "Yes", replace
    	estadd local controls "Yes", replace
    	estadd local ICFE "Yes", replace
		
} // end credit loop

} // end qui

esttab, label keep( ///
		size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
		_X ///
	) order( ///
		size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
		_X ///
	) coeflabels() star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2 ldv controls ICFE, fmt(%9.0fc %9.2fc %9s %9s %9s) ///
		labels( ///
			"Observations" "$ R^{2}$" ///
			"Lag TFP control" ///
			"Balance sheet controls" ///
			"Industry $\times$ Country FEs")) 
/*
esttab using "../tables/table_4.tex" ///
	, booktabs replace label fragment substitute(\_ _) ///
	nocon nonotes b(%9.4f) se(%9.4f) keep( ///
		size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
		_X ///
	) order( ///
		size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
		_X ///
	) coeflabels() star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2 mdv ldv controls ICFE, fmt(%9.0fc %9.2fc %9.2fc %9s %9s %9s) ///
		labels( ///
			"Observations" "$ R^{2}$" ///
			"Mean dep var" ///
			"Lag TFP control" ///
			"Balance sheet controls" ///
			"Industry $\times$ Country FEs")) ///
	mtitles( ///
		" \shortstack{$\Delta CDS$ \\ (Country-level)} " ///
		" \shortstack{$\Delta CDS$ \\ (Firm-level)} " ///
		" \shortstack{Bank \\ Capital} " ///
		" \shortstack{CDS \\ Presence} " ///
		" \shortstack{Relationship \\ Bank Share} ") 
*/