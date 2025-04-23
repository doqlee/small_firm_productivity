* Relationship bank share from the Banking Environment and Performance Survey

* Number of branches of relationship banks in each country 
* As a share of the total number of bank branches

use "../data/raw/bepsii/BEPSII_branches_for_Chen_Lee_12Jan2022.dta", clear

kountry country, from(other) stuck
ren _ISO3N_ iso3n
kountry iso3n, from(iso3n) to(iso2c)
ren _ISO2C_ _iso2c_

replace city = lower(city)

gen byte nbranch = 1

merge m:1 q1b q1c using ///
	"../data/raw/bepsii/BEPSII_survey_for_Chen_Lee_12Jan2022.dta" ///
	, nogen keep(1 3) keepusing(q6a foreign)

gen byte relationship = q6a>=5 if !mi(q6a)

collapse (sum) nbranch relationship, by(_iso2c_ city)

gen shr_relationship = relationship / nbranch * 100

collapse (mean) shr_relationship, by(_iso2c_)

replace shr_relationship = shr_relationship / 100

compress
save "../data/cleaned/bepsii_shr_relationship.dta", replace
