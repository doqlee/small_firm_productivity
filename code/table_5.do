* Table 5: SME intangible capital gap

use "../data/cleaned/sample_did.dta", clear

* Industry intangible intensity

gen shr_D_ik_pre4yrBal_w = shr_D_ik_pre4yrBal ///
	if abs(shr_D_ik_pre4yrBal)<=1

ds shr_D_ik_pre4yrBal_w patent_app_pre4yrBal

foreach vv in `r(varlist)' {
    
    preserve
        
        cap drop p50_* high_*
        
        bys _iso2c_ NACE4: egen _cnt = count(`vv')
        
        *drop if _cnt < 5 // Note: Uncomment when running the code with real data
        	
        bys _iso2c_ NACE4: egen mean_`vv' = mean(`vv')
        
        keep _iso2c_ NACE4 mean_`vv'
        drop if mi(mean_`vv')
        
        duplicates drop
        duplicates report _iso2c_ NACE4
        
        egen p50_`vv' = median(mean_`vv')
        gen byte high_`vv' = (mean_`vv' > p50_`vv')
        
        keep _iso2c_ NACE4 high_`vv'
        
        compress
        tempfile temp_`vv'
        save `temp_`vv''
        
    restore
    
    merge m:1 _iso2c_ NACE4 using `temp_`vv'', nogen keep(1 3)
    
}

ds high_shr_D_ik_pre4yrBal_w high_patent_app_pre4yrBal 

global iis "`r(varlist)'"

qui {

eststo clear

foreach ctrl in ///
	D_tfp1_pre4yrBal ///
	size_EURO_pre4yrBal_1 ///
	size_EURO_pre4yrBal_2 ///
	size_EURO_pre4yrBal_3 ///
	age_pre1yr age2_pre1yr $controls {
	
	gen `ctrl'_X = .
	loc lbl_ctrl: variable label `ctrl'
	lab var `ctrl'_X "`lbl_ctrl' $\times$ $\text{Industry Intensity}$"
	
} // end ctrl loop

foreach ii in $iis { // 
    
    foreach ctrl in ///
    	D_tfp1_pre4yrBal ///
    	size_EURO_pre4yrBal_1 ///
    	size_EURO_pre4yrBal_2 ///
    	size_EURO_pre4yrBal_3 ///
    	age_pre1yr age2_pre1yr $controls {
    	
    	replace `ctrl'_X = `ctrl' * `ii'
    	
    } // end ctrl loop
    
    loc ii0 `ii'
	lab var `ii0' "$\text{Industry Intensity}$"

    * Fix the sample to firms with all controls available
    
    reghdfe DiD_D_tfp1_4yrBal ///
    	D_tfp1_pre4yrBal D_tfp1_pre4yrBal_X ///
    	size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
    	size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
    	size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
    	age_pre1yr age_pre1yr_X age2_pre1yr age2_pre1yr_X /// 
    	leverage_pre4yrBal leverage_pre4yrBal_X /// 
    	CULI_OPRE_pre4yrBal CULI_OPRE_pre4yrBal_X /// 
    	CS_TA_pre4yrBal CS_TA_pre4yrBal_X /// 
    	CUAS_CULI_pre4yrBal CUAS_CULI_pre4yrBal_X /// 
    	ln_EBITDA_pre4yrBal ln_EBITDA_pre4yrBal_X /// 
    	`ii0' ///
    	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
    
    cap drop tmp_esample
    gen byte tmp_esample = e(sample)
    
    eststo: reghdfe DiD_D_tfp1_4yrBal ///
    	D_tfp1_pre4yrBal D_tfp1_pre4yrBal_X /// 
    	size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
    	size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
    	size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
    	age_pre1yr age_pre1yr_X age2_pre1yr age2_pre1yr_X /// 
    	leverage_pre4yrBal leverage_pre4yrBal_X /// 
    	CULI_OPRE_pre4yrBal CULI_OPRE_pre4yrBal_X /// 
    	CS_TA_pre4yrBal CS_TA_pre4yrBal_X /// 
    	CUAS_CULI_pre4yrBal CUAS_CULI_pre4yrBal_X /// 
    	ln_EBITDA_pre4yrBal ln_EBITDA_pre4yrBal_X /// 
    	`ii0' ///
    	if tmp_esample ///
    	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
    	
    	su `e(depvar)' if e(sample)
    	estadd scalar mdv `r(mean)', replace
    	estadd local ldv "Yes", replace
    	estadd local controls "Yes", replace
    	estadd local ICFE "Yes", replace
    
} // end ii loop

* Firm intangible share

foreach var in shr_D_ik patent_app {
    
    * Fix the sample to firms with all controls available
    
    reghdfe DiD_`var'_4yr ///
    	`var'_pre4yr ///
    	size_EURO_pre4yrBal_1 /// 
    	size_EURO_pre4yrBal_2 /// 
    	size_EURO_pre4yrBal_3 /// 
    	age_pre1yr age2_pre1yr /// 
    	$controls /// 
    	if esample1==1, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
    
    cap drop tmp_esample
    gen byte tmp_esample = e(sample)
    
    eststo: reghdfe DiD_`var'_4yr ///
    	`var'_pre4yr /// 
    	size_EURO_pre4yrBal_1 /// 
    	size_EURO_pre4yrBal_2 /// 
    	size_EURO_pre4yrBal_3 /// 
    	age_pre1yr age2_pre1yr /// 
    	$controls /// 
    	if tmp_esample ///
    	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
    	
    	su `e(depvar)' if e(sample)
    	estadd scalar mdv `r(mean)', replace
    	estadd local ldv "Yes", replace
    	estadd local controls "Yes", replace
    	estadd local ICFE "Yes", replace
    	
} // end dv loop

} // end qui

esttab, label star(* 0.10 ** 0.05 *** 0.01) keep( /// 
        size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
	) order( ///
		size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
	)
/*	
esttab using ///
	"../tables/table_5.tex" ///
	, replace label booktabs fragment substitute(\_ _) ///
	nocon nonotes nomtitles b(%9.4f) se(%9.4f) keep( /// 
		size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
	) order( ///
		size_EURO_pre4yrBal_1 size_EURO_pre4yrBal_1_X /// 
		size_EURO_pre4yrBal_2 size_EURO_pre4yrBal_2_X /// 
		size_EURO_pre4yrBal_3 size_EURO_pre4yrBal_3_X /// 
	) coeflabels() star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2 mdv ldv controls ICFE, fmt(%9.0fc %9.2fc %9.3fc %9s %9s %9s) ///
		labels( ///
			"Observations" "$ R^{2}$" ///
			"Mean dep var" ///
			"Lag dep var" ///
			"Balance sheet controls" ///
			"Industry $\times$ Country FEs"))
*/
