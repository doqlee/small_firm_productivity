* Patent data

* Firm X patent application X year level

use "../data/raw/patstat/patent_app.dta", clear

* Country of firm

destring year, replace

* Country of application

gen iso2app = substr(app_num, 1, 2)

* Count # applications domestic

cap drop patent_app
gen byte patent_app = 0

foreach cc in $clist {
    
	replace patent_app = 1 if iso2app=="`cc'"
}

* Aggregate to annual sums for each firm

collapse (sum) patent_app, by(BvD_ID_number iso2 year)

* Want to aggregate panel data to Diff-in-diff form

cap drop numid
egen double numid = group(BvD_ID_number)
order numid, after(BvD_ID_number)
xtset numid year

* Impute gap years with 0 applications

count
tsfill
count

preserve
    
	keep numid BvD_ID_number iso2
	
	drop if mi(BvD_ID_number)
	duplicates drop
	
	tempfile _tmp
	save `_tmp'
	
restore

cap drop BvD_ID_number iso2
merge m:1 numid using `_tmp', nogen keepusing(BvD_ID_number iso2)

replace patent_app = 0 if mi(patent_app) // gap years mean 0 applications

* Dummy = 1 post crisis 2008-2011, = 0 pre-crisis; 4 year window
	
gen byte post = .
replace post = 0 if year>=(2008 - 4) & year<=(2008 - 1)
replace post = 1 if year>=(2008) & year<=(2008 + 4 - 1)

* Restrict sample to 4 year window	

drop if mi(post)

* patent_app = Pre/post crisis average # of annual applications for each firm

collapse (mean) patent_app, by(BvD_ID_number post)

reshape wide patent_app, i(BvD_ID_number) j(post)

ren patent_app0 patent_app_pre4yrBal
ren patent_app1 patent_app_post4yrBal

* Assign missing with 0 applications

replace patent_app_pre4yrBal = 0 if mi(patent_app_pre4yrBal)
replace patent_app_post4yrBal = 0 if mi(patent_app_post4yrBal)

* Post - pre crisis difference

gen DiD_patent_app_4yrBal = patent_app_post4yrBal - patent_app_pre4yrBal

keep BvD_ID_number DiD_patent_app_4yrBal patent_app_pre4yrBal

compress
save "../data/cleaned/patstat_patent_app.dta", replace
