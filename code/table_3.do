* Table 3: Horseraces

use "../data/cleaned/sample_did.dta", clear

qui {

* Fix the sample to firms with all controls available 

reghdfe DiD_D_tfp1_4yrBal ///
	D_tfp1_pre4yrBal ///
	size_EURO_pre4yrBal_* /// 
	age_pre1yr age2_pre1yr /// 
	$controls /// 
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
cap drop tmp_esample
gen byte tmp_esample = e(sample)
	
eststo clear

eststo: reghdfe DiD_D_tfp1_4yrBal ///
	size_EURO_pre4yrBal_* /// 
	if tmp_esample==1 ///
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	su `e(depvar)' if e(sample)
	estadd scalar mdv `r(mean)', replace
	estadd local ldv "No", replace
	estadd local ICFE "Yes", replace
	
	test size_EURO_pre4yrBal_1==size_EURO_pre4yrBal_2
	estadd scalar test1 `r(p)', replace
	test size_EURO_pre4yrBal_2==size_EURO_pre4yrBal_3
	estadd scalar test2 `r(p)', replace

eststo: reghdfe DiD_D_tfp1_4yrBal ///
	D_tfp1_pre4yrBal /// 
	size_EURO_pre4yrBal_* /// 
	if tmp_esample==1 ///
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	su `e(depvar)' if e(sample)
	estadd scalar mdv `r(mean)', replace
	estadd local ldv "Yes", replace
	estadd local ICFE "Yes", replace
	
	test size_EURO_pre4yrBal_1==size_EURO_pre4yrBal_2
	estadd scalar test1 `r(p)', replace
	test size_EURO_pre4yrBal_2==size_EURO_pre4yrBal_3
	estadd scalar test2 `r(p)', replace
	
eststo: reghdfe DiD_D_tfp1_4yrBal ///
	size_EURO_pre4yrBal_* /// 
	age_pre1yr age2_pre1yr /// 
	if tmp_esample==1 ///
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	su `e(depvar)' if e(sample)
	estadd scalar mdv `r(mean)', replace
	estadd local ldv "No", replace
	estadd local ICFE "Yes", replace
	
	test size_EURO_pre4yrBal_1==size_EURO_pre4yrBal_2
	estadd scalar test1 `r(p)', replace
	test size_EURO_pre4yrBal_2==size_EURO_pre4yrBal_3
	estadd scalar test2 `r(p)', replace
	
foreach ctrl in $controls {
    
    eststo: reghdfe DiD_D_tfp1_4yrBal ///
    	size_EURO_pre4yrBal_* /// 
    	`ctrl' /// 
    	if tmp_esample==1 ///
    	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
    	
    	su `e(depvar)' if e(sample)
    	estadd scalar mdv `r(mean)', replace
    	estadd local ldv "No", replace
    	estadd local ICFE "Yes", replace
    	
    	test size_EURO_pre4yrBal_1==size_EURO_pre4yrBal_2
    	estadd scalar test1 `r(p)', replace
    	test size_EURO_pre4yrBal_2==size_EURO_pre4yrBal_3
    	estadd scalar test2 `r(p)', replace
    	
} // end ctrl loop

eststo: reghdfe DiD_D_tfp1_4yrBal ///
	D_tfp1_pre4yrBal /// 
	age_pre1yr age2_pre1yr /// 
	$controls /// 
	if tmp_esample==1 ///
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	su `e(depvar)' if e(sample)
	estadd scalar mdv `r(mean)', replace
	estadd local ldv "Yes", replace
	estadd local ICFE "Yes", replace
	
eststo: reghdfe DiD_D_tfp1_4yrBal ///
	D_tfp1_pre4yrBal /// 
	size_EURO_pre4yrBal_* /// 
	age_pre1yr age2_pre1yr /// 
	$controls /// 
	if tmp_esample==1 ///
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)
	
	su `e(depvar)' if e(sample)
	estadd scalar mdv `r(mean)', replace
	estadd local ldv "Yes", replace
	estadd local ICFE "Yes", replace
	
	test size_EURO_pre4yrBal_1==size_EURO_pre4yrBal_2
	estadd scalar test1 `r(p)', replace
	test size_EURO_pre4yrBal_2==size_EURO_pre4yrBal_3
	estadd scalar test2 `r(p)', replace

} // end qui
	
esttab, label star(* 0.10 ** 0.05 *** 0.01)
/*
esttab using "../tables/table_3.tex" ///
	, booktabs replace label fragment substitute(\_ _) ///
	nocon nonotes nomtitles b(%9.4f) se(%9.4f) /// 
	keep( ///
		size_EURO_pre4yrBal_* /// 
		D_tfp1_pre4yrBal /// 
		age_pre1yr /// 
		$controls /// 
	) order( ///
		size_EURO_pre4yrBal_* /// 
		D_tfp1_pre4yrBal /// 
		age_pre1yr /// 
		$controls /// 
	) coeflabels() star(* 0.10 ** 0.05 *** 0.01) ///
	stats(N r2 mdv ldv ICFE test1 test2, ///
		fmt(%9.0fc %9.2fc %9.2fc %9s %9s %9.2fc %9.2fc) ///
		labels( ///
			"Observations" "$ R^{2}$" ///
			"Mean dep var" ///
			"Lag TFP control" ///
			"Industry $\times$ Country FEs" ///
			"Micro $ =$ Small ($ p$-val)" ///
			"Small $=$ Medium ($ p$-val)"))
*/