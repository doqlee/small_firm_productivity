* BIS US dollar exchange rates

* Period averages (A) and period-end (E)
* https://www.bis.org/statistics/full_webstats_xru_current_dataflow_csv.zip

insheet using ///
    "../data/raw/exchange_rates/WEBSTATS_XRU_CURRENT_DATAFLOW_csv_col.csv" ///
	, comma clear nonames 

ds v1-v9

foreach vv in `r(varlist)' {
    
	loc tmp = `vv'[1]
	loc tmp = subinstr("`tmp'", " ", "", .)
	ren `vv' `tmp'
}

ds v*

foreach vv in `r(varlist)' {
    
	loc tmp = `vv'[1]
	cap replace `vv' = subinstr(`vv', "E", "e", .)
	
	if regexm("`tmp'", "[0-9][0-9][0-9][0-9]-Q[1-4]") {
	    
		loc tmp = subinstr("`tmp'", "-", "_", .)
		ren `vv' tq`tmp'
	}
	else if regexm("`tmp'", "[0-9][0-9][0-9][0-9]-[0-1][0-9]") {
	    
		loc tmp = subinstr("`tmp'", "-", "_", .)
		ren `vv' tm`tmp'
	}
	else {
	    
		ren `vv' ty`tmp'
	}
}

keep if FREQ=="A"

ren REF_AREA _iso2c_
ren Referencearea name_country
ren CURRENCY currency
ren Currency name_currency
ren ty* xru_*

keep _iso2c_ name_country currency name_currency COLLECTION xru_*

destring, replace ignore(NaN)

reshape long xru_ ///
	, i(_iso2c_ name_country currency name_currency COLLECTION) j(year)

reshape wide xru_ ///
	, i(_iso2c_ name_country currency name_currency year) j(COLLECTION) string

preserve

	keep if year==2005
	
	ren xru_* xru_*_2005
	keep _iso2c_ xru_A_2005 xru_E_2005
	
	tempfile tmp
	save `tmp'
	
restore

merge m:1 _iso2c_ using `tmp', nogen keep(1 3) keepusing(xru_A_2005 xru_E_2005)

keep if year>=1983 & year<=2016

compress
save "../data/cleaned/WEBSTATS_XRU_CURRENT_DATAFLOW_83_16.dta", replace
