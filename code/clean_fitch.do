* Fitch Connect data - historical + 10yr

use "../data/raw/fitch/bnk_hist_usd.dta", clear

keep if periodlength==12 & periodtype==0
drop periodlength periodtype

* Drop duplicates in bank name

preserve
    
    keep issuername bank_iso2c_ consolidated isocurrencycode scale ///
        dateofincorporation accountingsystem foreignownedsubsidiary
    
    duplicates drop
    
    stnd_compname issuername ///
    	, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name)
    
    gen date_inc = date(dateofincorporation, "MDY")
    	bys stn_name: egen min_date_inc = min(date_inc)
    	format *date_inc %td
    
    duplicates tag stn_name, gen(dup)
    	tab dup, m
    	drop if date_inc!=min_date_inc & dup > 0
    	drop dup *date_inc
    
    duplicates tag stn_name, gen(dup)
    	tab dup, m
    	drop if trim(consolidated)!="N" & dup > 0
    	drop dup
    
    duplicates tag stn_name, gen(dup)
    	tab dup, m
    	drop if trim(isocurrencycode)!="USD" & dup > 0
    	drop dup
    
    duplicates tag stn_name, gen(dup)
    	tab dup, m
    	drop if trim(accountingsystem)!="Local GAAP" & dup > 0
    	drop dup
    
    duplicates tag stn_name, gen(dup)
    	tab dup, m
    	drop if trim(foreignownedsubsidiary)!="No" & dup > 0
    	drop dup
    
    duplicates tag stn_name, gen(dup)
    	tab dup, m
    	drop if scale!=6 & dup > 0
    	drop dup
    
    duplicates report stn_name
    
    tempfile _tmp
    save `_tmp'
    
restore

merge m:1 issuername dateofincorporation consolidated ///
	isocurrencycode accountingsystem foreignownedsubsidiary scale ///
	using `_tmp', nogen keep(3)

* Aggregate any remaining duplicates by year

gen str_date = substr(perioddate, 1, 10), after(perioddate)
gen int date = date(str_date, "YMD"), after(str_date)
	format date %td
	
gen int year = year(date), after(date)
gen byte quarter = quarter(date), after(date)

compress

duplicates report stn_name year

preserve
    
    keep issuername bank_iso2c_ consolidated isocurrencycode scale ///
        dateofincorporation accountingsystem foreignownedsubsidiary ///
    	stn_name stn_dbaname stn_fkaname entitytype attn_name
    
    duplicates drop
    duplicates report stn_name
    
    tempfile _tmp
    save `_tmp'
    	
restore

ren tier1regulatorycapitalratio bank_capital

collapse (mean) bank_capital, by(stn_name year)

merge m:1 stn_name using `_tmp', nogen keep(3)

duplicates report stn_name year

egen fitch_id = group(stn_name)
order fitch_id year, first
xtset fitch_id year

compress
save "../data/cleaned/fitch_stn_name_year.dta", replace

* fitch bank names

use "../data/cleaned/fitch_stn_name_year.dta", clear

keep fitch_id stn_name stn_dbaname stn_fkaname entitytype attn_name
duplicates drop

compress
save "../data/cleaned/fitch_stn_name.dta", replace

* Bank names in amadeus bankers

use "../data/raw/orbis/Banker.dta", clear

keep bnk_name
duplicates drop

stnd_compname bnk_name ///
	, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name)

egen bnk_id = group(bnk_name)

compress
save "../data/cleaned/banker_bnk_name.dta", replace

* Reclink fitch-amadeus banker names

use "../data/cleaned/banker_bnk_name.dta", clear

reclink2 stn_name using ///
	"../data/cleaned/fitch_stn_name.dta" ///
	, idm(bnk_id) idu(fitch_id) wmatch(10) gen(rlsc) manytoone npairs(5)

* Select candidate match with top score

unique bnk_name
loc _total `r(unique)'

keep if _merge==3
drop _merge

bys bnk_name (rlsc): keep if _n==_N

keep if rlsc > 0.85

* Share of banks that are matched

unique bnk_name
loc _matched `r(unique)'

di `_matched' / `_total'

compress
save "../data/cleaned/banker_fitch_matched.dta", replace

*** Finalize bank-level panel data

use "../data/cleaned/fitch_stn_name_year.dta", clear

* Fill in gaps in panel

xtset fitch_id year

count
tsfill
count

preserve
    
    keep fitch_id issuername bank_iso2c_ consolidated isocurrencycode scale ///
        dateofincorporation accountingsystem foreignownedsubsidiary ///
    	stn_name stn_dbaname stn_fkaname entitytype attn_name
    
    drop if mi(stn_name)
    
    duplicates drop
    duplicates report fitch_id
    
    tempfile _tmp
    save `_tmp'
    
restore

merge m:1 fitch_id using `_tmp', nogen update

xtset fitch_id year

ds bank_capital

foreach vv in `r(varlist)' {

    cap drop i`vv'
    bys fitch_id (year): ipolate `vv' year, gen(i`vv')
    replace `vv' = i`vv' if mi(`vv') & !mi(i`vv')
    drop i`vv'
}

* Winsorize

ds bank_capital

foreach vv in `r(varlist)' {
    
    winsor2 `vv', trim cuts(1 99) by(bank_iso2c_) replace
}

keep fitch_id bank_iso2c_ year bank_capital

compress

*** Bank-level data for DiD

* Variables pre and post Lehman bankruptcy

ds bank_capital

foreach vv in `r(varlist)' {
    
    foreach yy in 4 {
        
        di "`vv'_pre`yy'yr, `vv'_post`yy'yr"
        
        gen `vv'_pre`yy'yr = `vv' if year>=(2008 - `yy') & year<=(2008 - 1)
        egen cnt_`vv'_pre`yy'yr = total(!mi(`vv'_pre`yy'yr)), by(fitch_id)
        gen `vv'_pre`yy'yrBal = `vv' if cnt_`vv'_pre`yy'yr==(`yy') & !mi(`vv'_pre`yy'yr)
        
        cap drop cnt_`vv'_p*`yy'yr
    }
}
 
* Collapse to pre crisis variables

keep fitch_id bank_iso2c_ bank_capital_pre4yrBal

compress

preserve
    
    keep fitch_id bank_iso2c_
    
    duplicates drop
    duplicates report fitch_id
    
    tempfile _tmp
    save `_tmp'
    
restore

collapse (mean) bank_capital_pre4yrBal, by(fitch_id)

merge 1:1 fitch_id using `_tmp', nogen

compress
save "../data/cleaned/fitch_bank_capital_pre4yrBal.dta", replace

********************************************************************************
*** Firm-level averages of Bank-firm-level 

use "../data/raw/orbis/Banker.dta", clear

ren idnr BvD_ID_number

merge m:1 BvD_ID_number using "../data/cleaned/orbis_firms_2008.dta" ///
	, keep(3) nogen keepusing(BvD_ID_number)

* Assume the first row is the firm's main bank

bys BvD_ID_number: gen banker_rank = _n

* Amadeus Bankers X fitch crosswalk file

merge m:1 bnk_name using "../data/cleaned/banker_fitch_matched.dta" ///
	, gen(_merge_crosswalk) keep(1 3) keepusing(fitch_id)

egen bank_id = group(bnk_name)
drop bnk_name consol 

* Merge bank balance sheet info from fitch

merge m:1 fitch_id using "../data/cleaned/fitch_bank_capital_pre4yrBal.dta" ///
	, gen(_merge_fitch) keep(1 3) keepusing(bank_capital_pre4yrBal)

keep BvD_ID_number bank_capital_pre4yrBal

duplicates drop
compress

collapse (mean) bank_capital_pre4yrBal, by(BvD_ID_number) 

compress
save "../data/cleaned/fitch_bank_capital.dta", replace
