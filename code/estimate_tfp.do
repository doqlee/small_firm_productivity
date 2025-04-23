* Estimate TFP: GFC

loc cnt = 1

foreach cc in $clist {
    
    if `cnt++'==1 {
        
    	use BvD_ID_number age year _iso2c_ SIC3 NACE4 ///
    		TOAS OPRE VA_imp EMPL FIAS K IFAS MATL_imp ///
    		using "../data/cleaned/orbis_`cc'.dta", clear
    }
    else {
        
    	append using "../data/cleaned/orbis_`cc'.dta", keep( ///
    	    BvD_ID_number age year _iso2c_ SIC3 NACE4 ///
    		TOAS OPRE VA_imp EMPL FIAS K IFAS MATL_imp ///
    		)
    }
    
    keep if year>=2003 
    keep if year<=2015 
    keep if age>=0 
    
    drop if age > 200
    drop if EMPL<=0
    
    drop if mi(TOAS)
    drop if mi(EMPL)
    drop if mi(OPRE)
    drop if mi(FIAS) 
    
}

ren VA_imp VA
ren MATL_imp MATL

keep BvD_ID_number year _iso2c_ SIC3 NACE4 VA EMPL K IFAS MATL

cap drop firm_id
egen double firm_id = group(BvD_ID_number)
order firm_id, after(BvD_ID_number)
xtset firm_id year

compress

* Fill in gaps in panel

count
tsfill
count

preserve
    
	keep firm_id BvD_ID_number _iso2c_ SIC3 NACE4 // 
	
	drop if mi(BvD_ID_number)
	duplicates drop
	
	tempfile _tmp
	save `_tmp'
	
restore

cap drop BvD_ID_number _iso2c_ SIC3 NACE4 // 
merge m:1 firm_id using `_tmp', nogen ///
	keepusing(BvD_ID_number _iso2c_ SIC3 NACE4) // 

xtset firm_id year

* Country code

cap drop ISO2
encode _iso2c_, gen(ISO2)
drop _iso2c_

* Nace 2-digit industry code

gen nace2_2 = floor(NACE4 / 100), after(NACE4)

xtset firm_id year

* Interpolate

ds VA EMPL K IFAS MATL

loc tmpvars `r(varlist)'

preserve
    
    keep firm_id year `tmpvars'
    
    foreach vv in `tmpvars' {
    	
    	xtset firm_id year
    	
    	bys firm_id (year): ipolate `vv' year, gen(i`vv')
    	
    	replace `vv' = i`vv' if mi(`vv') & !mi(i`vv')
    	drop i`vv'
    }
    
    compress
    tempfile _tmp
    save `_tmp'
    
restore

drop `tmpvars'
merge m:1 firm_id year using `_tmp', nogen keep(1 3) keepusing(`tmpvars') 

xtset firm_id year

gen i = firm_id
noi keep if (i<. & L.i<. & F.i<.) ///
	| (i<. & L.i<. & L2.i<.) ///
	| (i<. & F.i<. & F2.i<.)
drop i

ds VA EMPL K IFAS MATL

foreach vv in `r(varlist)' {
    
	winsor2 `vv', cuts(1 99) by(nace2_2) replace
	gen ln_`vv' = log(`vv')
}

keep BvD_ID_number firm_id year ISO2 NACE4 nace2_2 ln_*

* Balanced sample

gen byte sample = 1 if !mi(ln_EMPL) & !mi(ln_MATL) & !mi(ln_K) & !mi(ln_IFAS)
bys firm_id (year): egen cnt = count(sample) if year>=2004 & year<=2011

qui su year if year>=2004 & year<=2011
gen byte balanced = (cnt>=(r(max) - r(min) + 1)) if year>=2004 & year<=2011
drop cnt

compress

* Implementing Wooldridge (2009)

xtset firm_id year

gen L1_K_M = L.ln_K * L.ln_MATL
gen L1_K_2 	= L.ln_K * L.ln_K
gen L1_M_2	= L.ln_MATL * L.ln_MATL
gen L1_K_3 	= L.ln_K * L.ln_K * L.ln_K
gen L1_M_3   = L.ln_MATL * L.ln_MATL * L.ln_MATL
gen L1_K_2_M = L.ln_K * L.ln_K * L.ln_MATL
gen L1_K_M_2 = L.ln_K * L.ln_MATL * L.ln_MATL

gl exoreg 	ln_K L.ln_K  ///
			ln_MATL	///
			L1_K_M 	///
			L1_K_2 L1_M_2	///
			L1_K_3 L1_M_3	///
			L1_K_2_M L1_K_M_2

gl endoreg 	ln_EMPL
gl instr	L.ln_EMPL

* Baseline Specification: L + K

eststo clear

gen tfp1 = .

levelsof nace2_2, clean
loc industries = r(levels)

foreach i in `industries' {
	
	preserve
    	
    	keep if nace2_2==`i'
    	
    	gl beta_ln_EMPL_`i' 
    	gl beta_ln_K_`i' 
    	
    	noi di "Industry: `i'"
    	
    	cap noi eststo: ivregress gmm ln_VA ///
    		$exoreg i.year i.ISO2 ($endoreg = $instr) ///
    			if nace2_2==`i' & balanced==1, wmatrix(robust)
    	
    	loc rc = _rc
    	
    	cap noi estadd local YFE "Yes", replace
    	cap noi estadd local CFE "Yes", replace
    	cap noi estadd local industry "`i'", replace
    		
    	cap noi gl beta_EMPL_`i' = _b[ln_EMPL]
    	cap noi gl beta_K_`i' = _b[ln_K]
    	cap noi gl N_`i' = e(N)
    	
	restore
	
	cap noi if (`rc' == 0 & ${beta_EMPL_`i'} > 0 & ${beta_K_`i'} > 0) {
		
		cap noi replace tfp1 = ln_VA ///
			- ${beta_EMPL_`i'} * ln_EMPL ///
			- ${beta_K_`i'} * ln_K ///
				if nace2_2==`i'
	}
	
	if `rc' != 0 noi di as err "Estimation could not run for industry `i'"
}

cap drop firm_id
egen double firm_id = group(BvD_ID_number)
order firm_id, after(BvD_ID_number)
xtset firm_id year

tsfill

preserve
    
	keep BvD_ID_number firm_id NACE4 nace2_2 
	
	drop if mi(BvD_ID_number)
	duplicates drop
	
	tempfile _tmp
	save `_tmp'
	
restore

merge m:1 firm_id using `_tmp', update nogen keepusing(BvD_ID_number nace2_2)

keep BvD_ID_number firm_id year ISO2 NACE4 nace2_2 balanced ln_* tfp*

xtset firm_id year

ds tfp*

foreach vv in `r(varlist)' {
    
	gen D_`vv' = `vv' - L.`vv'
}

compress
d
save "../data/cleaned/sample_tfp_2008.dta", replace

