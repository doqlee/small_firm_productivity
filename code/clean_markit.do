********************************************************************************

* Markit CDS Spreads

* Change in the average CDS spread of domestic banks 
* between 7 days before/after Lehman bankruptcy (september 15, 2008)

* Country-level and firm-level averages

********************************************************************************

* Firm X Bank names in amadeus bankers

use "../data/raw/orbis/Banker.dta", clear

ren idnr BvD_ID_number 

duplicates drop

gen n = _n

bys BvD_ID_number (n): gen bnk_rank = _n
	drop n

compress
save "../data/cleaned/Banker_cln.dta", replace

* Bank name X Standardized bank name

use "../data/cleaned/Banker_cln.dta", clear

keep bnk_name
duplicates drop

stnd_compname bnk_name ///
	, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name)

drop if mi(stn_name)

compress
save "../data/cleaned/Banker_bnk_2_stn_name.dta", replace

* Unique standardized bank names

use "../data/cleaned/Banker_bnk_2_stn_name.dta", clear

keep stn_name stn_dbaname stn_fkaname entitytype attn_name
duplicates drop

duplicates tag stn_name, gen(dup)
	bys stn_name (entitytype): drop if dup > 0 & _n!=_N
	drop dup
	
duplicates report stn_name 

egen bnk_id = group(stn_name)

compress
save "../data/cleaned/Banker_stn_name.dta", replace

********************************************************************************
* Raw Markit CDS data downloaded from WRDS

use "../data/raw/markit/markit.dta", clear

drop if mi(redcode)
drop if mi(spread5y)

encode sector, gen(SECTOR)
	drop sector

* Dates

format date %td

cap drop year
gen year = year(date), after(date)

cap drop nredcode
egen float nredcode = group(redcode)
	order nredcode, after(redcode)

cap drop nredcodeFull
egen float nredcodeFull = group(redcode tier docclause ccy)
	order nredcodeFull, after(redcode)
	
xtset nredcodeFull date

compress
save "../data/cleaned/markit_redcode_date.dta", replace

* Drop duplicates 

use "../data/cleaned/markit_redcode_date.dta", clear

bys nredcodeFull: egen count_spread5y = count(spread5y)
bys nredcode: egen max_count_spread5y = max(count_spread5y)

duplicates tag nredcode date, gen(dup)
	bys nredcodeFull: egen max_dup = max(dup)
	bys nredcode: drop if max_dup > 0 & count_spread5y < max_count_spread5y
		cap drop dup max_dup max_count_spread5y

duplicates tag nredcode date, gen(dup)
	bys nredcodeFull: egen max_dup = max(dup)
	bys nredcode: drop if max_dup > 0 & ccy!="EUR"
		drop dup max_dup

duplicates tag nredcode date, gen(dup)
	bys nredcodeFull: egen max_dup = max(dup)
	bys nredcode: drop if max_dup > 0 & tier!="SNRFOR"
		drop dup max_dup

duplicates tag nredcode date, gen(dup)
	bys nredcodeFull: egen max_dup = max(dup)

gen _tmp_docclause = .
	replace _tmp_docclause = 1 if docclause=="MM"
	replace _tmp_docclause = 2 if docclause=="MM14"
	replace _tmp_docclause = 3 if docclause=="MR"
	replace _tmp_docclause = 4 if docclause=="MR14"
	replace _tmp_docclause = 5 if docclause=="CR"
	replace _tmp_docclause = 6 if docclause=="CR14"
	replace _tmp_docclause = 7 if docclause=="XR"
	replace _tmp_docclause = 7 if docclause=="XR14"
	
bys nredcode: egen min_tmp_docclause = min(_tmp_docclause)
bys nredcode: drop if max_dup > 0 & _tmp_docclause > min_tmp_docclause
	drop dup max_dup _tmp_docclause min_tmp_docclause

* Use most common version of bank name

keep nredcode date country shortname spread5y*

bys nredcode: egen _mode = mode(shortname)
replace shortname = _mode
	drop _mode

bys shortname: egen _mode = mode(country)
replace country = _mode
	drop _mode

collapse (mean) spread5y, by(shortname date country)

cap drop nshortname
egen double nshortname = group(shortname)

duplicates report nshortname date
xtset nshortname date

* Fill in gaps in panel

count
tsfill
count

preserve
	
	keep nshortname country shortname
	
	drop if mi(shortname)
	
	duplicates drop
	duplicates report nshortname
	duplicates report shortname
	
	tempfile _tmp
	save `_tmp'
	
restore

cap drop country shortname
merge m:1 nshortname using `_tmp', nogen keepusing(country shortname)

xtset nshortname date

bys nshortname (date): ipolate spread5y date, gen(ispread5y)
replace spread5y = ispread5y if mi(spread5y) & !mi(ispread5y)
drop ispread5y

* Country codes

preserve
	
	keep country
	duplicates drop
	
	kountry country, from(other) stuck
		ren _ISO3N_ iso3n
		drop if mi(iso3n) 
	
	kountry iso3n, from(iso3n) to(iso2c)
		ren _ISO2C_ _iso2c_
		drop if mi(_iso2c_) 
	
	encode _iso2c_, gen(ISO2)
	
	tempfile _tmp
	save `_tmp'
	
restore

merge m:1 country using `_tmp', nogen keep(1 3)

* Winsorize

preserve
	
	keep nshortname date ISO2 spread5y
	
	drop if mi(spread5y)
	
	winsor2 spread5y, trim cuts(1 99) by(ISO2) suffix(_w)
	
	keep nshortname date spread5y_w
	
	tempfile _tmp
	save `_tmp'
	
restore

merge 1:1 nshortname date using `_tmp', nogen keep(1 3)

compress
save "../data/cleaned/markit_shortname_date.dta", replace 

********************************************************************************
* Country-level CDS spreads

use "../data/cleaned/markit_shortname_date.dta", clear

keep nshortname _iso2c_ date spread*

* Aggregate to country X date level

collapse (mean) spread*, by(_iso2c_ date)

* Keep countries in Orbis sample

cap drop ckeep
gen byte ckeep = 0
foreach cc in $clist {
	replace ckeep = 1 if _iso2c_=="`cc'"
}
keep if ckeep==1
drop ckeep

encode _iso2c_, gen(ISO2)
xtset ISO2 date

* Post-crisis dummy; 2-week time window around Lehman collapse

gen byte post_lehman = 0 if tin(08sep2008, 22sep2008)
replace post_lehman = 1 if tin(15sep2008, 22sep2008)
	
keep if !mi(post_lehman)

* Average CDS spreads 1 week pre and post Lehman bankruptcy

collapse (mean) spread5y*, by(_iso2c_ post_lehman)

ren spread5y* spread5y*_post
	
reshape wide spread5y*_post, i(_iso2c_) j(post_lehman)

* Change in the 1-week average CDS spreads pre and post Lehman bankruptcy

gen delta_cds_country = spread5y_w_post1 - spread5y_w_post0

compress
save "../data/cleaned/markit_delta_cds_country.dta", replace

********************************************************************************
* Preprocess bank names from Markit

use "../data/cleaned/markit_shortname_date.dta", clear

gen year = year(date), after(date)

* CDS presence dummy

gen byte nmi_pre = !mi(spread5y) & year>=(2008 - 4) & year<=(2008 - 1)
bys nshortname (date): egen bank_cds_presence = max(nmi_pre)
drop nmi_pre

bys nshortname: egen _count = count(spread5y)

* Post GFC dummy with 1 week window around Lehman collapse

gen byte post_lehman = 0 if tin(08sep2008, 22sep2008)
replace post_lehman = 1 if tin(15sep2008, 22sep2008)
	
keep if !mi(post_lehman)

* Average CDS spreads 1 week pre and post Lehman bankruptcy

collapse (mean) spread5y ///
	, by(nshortname shortname _iso2c_ _count bank_cds_presence post_lehman)

ren spread5y spread5y_post
	
reshape wide spread5y_post ///
	, i(nshortname shortname _iso2c_ _count bank_cds_presence) j(post_lehman)

* Change in the 1-week average CDS spreads pre and post Lehman bankruptcy

gen delta_cds_bank = spread5y_post1 - spread5y_post0

* Collapse to bank level

keep nshortname shortname _iso2c_ _count bank_cds_presence delta_cds_bank

duplicates drop
duplicates report shortname

* Standardize bank name

stnd_compname shortname ///
	, gen(stn_name stn_dbaname stn_fkaname entitytype attn_name)

duplicates tag stn_name, gen(dup)
	bys stn_name (_count): drop if dup > 0 & _n!=_N
	drop dup

* Check

duplicates report stn_name
duplicates report nshortname

keep nshortname shortname _iso2c_ bank_cds_presence delta_cds_bank ///
	stn_name stn_dbaname stn_fkaname entitytype attn_name

compress
save "../data/cleaned/markit_stn_name.dta", replace

********************************************************************************
* Match with Amadeus Bankers by bank name

* Reclink amadeus-banker names to markit bank names

use "../data/cleaned/Banker_stn_name.dta", clear

duplicates report bnk_id

reclink2 stn_name using ///
	"../data/cleaned/markit_stn_name.dta" ///
	, idm(bnk_id) idu(nshortname) wmatch(1) gen(rlsc) manytoone npairs(5)

* Select fuzzy match candidates with highest score

keep if _merge==3
drop _merge

ren rlsc markit_rlsc

bys bnk_id: egen _max = max(markit_rlsc)

keep if markit_rlsc==_max
	drop _max

duplicates tag bnk_id, gen(_dup)
	bys bnk_id (delta_cds_bank): drop if _dup > 0 & _n!=_N
	drop _dup

compress
save "../data/cleaned/banker_markit_matched.dta", replace

********************************************************************************
* Merge everything: Amadeus firm X bank X financials

use BvD_ID_number bnk_name bnk_rank using ///
    "../data/cleaned/Banker_cln.dta", clear

* Keep firms that are going to be in the regression sample

merge m:1 BvD_ID_number using ///
    "../data/cleaned/orbis_firms_2008.dta" ///
	, nogen keep(3) keepusing(BvD_ID_number)
	
* Amadeus banker name to standardized bank name
	
merge m:1 bnk_name using ///
    "../data/cleaned/Banker_bnk_2_stn_name.dta" ///
	, nogen keepusing(stn_name)

drop bnk_name

* Standardized bank name to Markit bank name and CDS spreads

merge m:1 stn_name using ///
    "../data/cleaned/banker_markit_matched.dta" ///
	, nogen keepusing(markit_rlsc delta_cds_bank bank_cds_presence)

drop stn_name 

* CDS presence of the firm's creditor banks

replace bank_cds_presence = 0 if mi(bank_cds_presence)
gen _pre = bank_cds_presence==1 & markit_rlsc > 0.90
bys BvD_ID_number: egen cds_presence = max(_pre)
drop _pre

gen _temp = delta_cds_bank if markit_rlsc > 0.90
bys BvD_ID_number: egen delta_cds_firm = max(_temp)
drop _temp

compress

keep BvD_ID_number cds_presence delta_cds_firm

* Collapse all firm X bank to firm-level 

collapse (mean) cds_presence delta_cds_firm, by(BvD_ID_number)

compress
save "../data/cleaned/markit_delta_cds_firm.dta", replace

