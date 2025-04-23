* Diff-in-Diff sample for regressions: 2008 GFC

loc cnt = 1

foreach cc in $clist {
    
    if `cnt++'==1 {
        
    	use BvD_ID_number age year _iso2c_ SIC* NAICS* NACE* listed /// 
    		TOAS EMPL OPRE FIAS K IFAS CUAS CULI NCLI CSFL EBITDA /// 
    		using "../data/cleaned/orbis_`cc'.dta", clear
    }
    else {
        
    	append using "../data/cleaned/orbis_`cc'.dta", keep( ///
    	    BvD_ID_number age year _iso2c_ SIC* NAICS* NACE* listed ///
    	    TOAS EMPL OPRE FIAS K IFAS CUAS CULI NCLI CSFL EBITDA ///
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

destring NAICS4, replace
	
cap drop firm_id
egen double firm_id = group(BvD_ID_number)
order firm_id, after(BvD_ID_number)
xtset firm_id year

* TFP estimates

merge 1:1 BvD_ID_number year using "../data/cleaned/sample_tfp_2008.dta" /// 
	, nogen keep(1 3) keepusing(D_tfp1)

* Fill in gaps in panel

compress

xtset firm_id year
count
tsfill
count

preserve
    
	keep firm_id BvD_ID_number _iso2c_ SIC* NAICS* NACE* listed
	
	drop if mi(BvD_ID_number)
	duplicates drop
	
	tempfile _tmp
	save `_tmp'
	
restore

cap drop BvD_ID_number _iso2c_ SIC* NAICS* NACE* listed
merge m:1 firm_id using `_tmp', nogen ///
	keepusing(BvD_ID_number _iso2c_ SIC* NAICS* NACE* listed)

xtset firm_id year
bys firm_id (year): replace age = age[_n-1] + 1 if mi(age)

* Country code

encode _iso2c_, gen(ISO2)

* Nace 2-digit industry code

gen nace2_2 = floor(NACE4 / 100), after(NACE4)

compress

* Interpolate

ds D_tfp1 TOAS EMPL OPRE K IFAS CUAS CULI NCLI CSFL EBITDA
loc tmpvars `r(varlist)'

preserve
    
    keep firm_id year `tmpvars'
    xtset firm_id year
    
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

* Leverage: Total liability to total assets

gen leverage = (CULI + NCLI) / TOAS

* Debt maturity: Rollover risk (Current liability to revenue)

gen CULI_OPRE = CULI / OPRE

* Cash flow / assets

gen CS_TA = CSFL / TOAS

* Current ratio

gen CUAS_CULI = CUAS / CULI

* Profitability

gen ln_EBITDA = ln(EBITDA)

* Physical and intangible capital 

gen K_v0 = K if !mi(K) & !mi(IFAS)
gen IK_v0 = IFAS if !mi(K) & !mi(IFAS)

xtset firm_id year

* Share of intangible investment
	
gen shr_D_ik = D.IK_v0 / (D.K_v0 + D.IK_v0)

* BIS US dollar exchange rates: Period-end (E)

do "iso2c_to_currency.do"

merge m:1 _iso2c_ year using ///
	"../data/cleaned/WEBSTATS_XRU_CURRENT_DATAFLOW_83_16.dta" ///
	, keep(1 3) nogen keepusing(xru_E)

* Convert to current local currency: for applying EU definition of SME

foreach y in TOAS OPRE {

    gen eur_`y' = `y' * xru_E
}

drop _iso2c_ xru_* currency

keep BvD_ID_number firm_id year NAICS4 NACE4 SIC3 listed ISO2 ///
	D_tfp1 shr_D_ik age EMPL eur_TOAS eur_OPRE ///
    leverage CULI_OPRE CS_TA CUAS_CULI EBITDA

compress

* Variables pre and post Lehman bankruptcy

ds D_tfp1 shr_D_ik age EMPL eur_TOAS eur_OPRE ///
    leverage CULI_OPRE CS_TA CUAS_CULI EBITDA
	
loc tmpvars `r(varlist)'

foreach vv in `tmpvars' {

preserve
	
	keep BvD_ID_number year `vv'
	drop if mi(`vv')
	
	* Pre & post crisis time window
	
	keep if year>=(2008 - 5) & year<=(2008 + 5)
	
	* Restrict data to pre vs. post GFC
	
	foreach yy in 1 4 {
		
		gen `vv'_pre`yy'yr = `vv' ///
			if year>=(2008 - `yy') & year<=(2008 - 1)
		gen `vv'_post`yy'yr = `vv' ///
			if year>=(2008) & year<=(2008 + `yy' - 1)
		
		egen cnt_`vv'_pre`yy'yr = total(!mi(`vv'_pre`yy'yr)) ///
			, by(BvD_ID_number)
		egen cnt_`vv'_post`yy'yr = total(!mi(`vv'_post`yy'yr)) ///
			, by(BvD_ID_number)
		
		gen `vv'_pre`yy'yrBal = `vv' ///
			if cnt_`vv'_pre`yy'yr==(`yy') & !mi(`vv'_pre`yy'yr)
		gen `vv'_post`yy'yrBal = `vv' ///
			if cnt_`vv'_post`yy'yr==(`yy') & !mi(`vv'_post`yy'yr)
		
		drop cnt_*
	}
	
	keep BvD_ID_number year *_pre*yr* *_post*yr*
	
	collapse (mean) *_pre*yr* *_post*yr*, by(BvD_ID_number)

	compress
	save "../data/cleaned/prePost_`vv'.dta", replace
	
restore
}

keep BvD_ID_number firm_id NAICS4 NACE4 SIC3 listed ISO2

drop if mi(BvD_ID_number)
duplicates drop
duplicates report firm_id

compress
save "../data/cleaned/orbis_firms_2008.dta", replace
