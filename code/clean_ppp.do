* Industry-level PPP (2005) from Inklaar and Timmer (2014)

import excel using "../data/raw/ppp/benchmark_2005.xlsx" ///
	, clear sheet("Hierarchy")
	
ren A industry_name
ren B isic3_division
ren C sector10
ren D major_sector_1
ren E major_sector_2

drop in 1/2
compress
save "../data/cleaned/benchmark_2005_hierarchy.dta", replace

import excel using "../data/raw/ppp/benchmark_2005.xlsx" ///
	, clear sheet("VA_GDP_MajorSector")
	
ren A country
ren B iso3c
ren C VA_gdp
ren E VA_sectormarket_economy
ren F VA_sectorgoods_producing
ren G VA_sectormanufacturing
ren H VA_sectorother_goods
ren I VA_sectorservices
ren J VA_sectormarket_services
ren K VA_sectornon_market_services

keep country iso3c VA_gdp VA_sector*

drop in 1/2
drop if mi(iso3c)
destring, replace

reshape long VA_sector, i(country iso3c VA_gdp) j(major_sector) string

compress
save "../data/cleaned/benchmark_2005_VA_GDP_MajorSector.dta", replace

import excel using "../data/raw/ppp/benchmark_2005.xlsx" ///
	, clear sheet("LP_GDP_MajorSector")
	
ren A country
ren B iso3c
ren C LP_gdp
ren E LP_sectormarket_economy
ren F LP_sectorgoods_producing
ren G LP_sectormanufacturing
ren H LP_sectorother_goods
ren I LP_sectorservices
ren J LP_sectormarket_services
ren K LP_sectornon_market_services

keep country iso3c LP_gdp LP_sector*

drop in 1/2
drop if mi(iso3c)

ds country iso3c, not
foreach vv in `r(varlist)' {
	replace `vv' = "" if `vv'=="n.a."
	destring `vv', replace
}

reshape long LP_sector, i(country iso3c LP_gdp) j(major_sector) string

compress
save "../data/cleaned/benchmark_2005_LP_GDP_MajorSector.dta", replace

import excel using "../data/raw/ppp/benchmark_2005.xlsx" ///
	, clear sheet("GO_GDP_MajorSector")
	
ren A country
ren B iso3c
ren C GO_gdp
ren E GO_sectormarket_economy
ren F GO_sectorgoods_producing
ren G GO_sectormanufacturing
ren H GO_sectorother_goods
ren I GO_sectorservices
ren J GO_sectormarket_services
ren K GO_sectornon_market_services

keep country iso3c GO_gdp GO_sector*

drop in 1/2
drop if mi(iso3c)
destring, replace

reshape long GO_sector, i(country iso3c GO_gdp) j(major_sector) string

compress
save "../data/cleaned/benchmark_2005_GO_GDP_MajorSector.dta", replace

import excel using "../data/raw/ppp/benchmark_2005.xlsx" ///
	, clear sheet("GO_10Sector")
	
ren A country
ren B iso3c

ds country iso3c, not
foreach vv in `r(varlist)' {
	loc _lbl = `vv'[2]
	loc _tmp = `vv'[3]
	lab var `vv' "Sector gross output relative prices for 2005: `_lbl'"
	ren `vv' GO_sector_S10`_tmp'
}

keep country iso3c GO_sector_S10*

drop in 1/3
drop if mi(iso3c)
destring, replace

reshape long GO_sector_S10, i(country iso3c) j(sector10) string

compress
save "../data/cleaned/benchmark_2005_GO_10Sector.dta", replace

import excel using "../data/raw/ppp/benchmark_2005.xlsx" ///
	, clear sheet("GO_35Industry")
	
ren A country
ren B iso3c

ds country iso3c, not
foreach vv in `r(varlist)' {
	loc _lbl = `vv'[2]
	loc _tmp = `vv'[3]
	lab var `vv' "Sector gross output relative prices for 2005: `_lbl'"
	ren `vv' GO_sector_I35`_tmp'
}

keep country iso3c GO_sector_I35*

drop in 1/3
drop if mi(iso3c)
destring, replace

reshape long GO_sector_I35, i(country iso3c) j(isic3_division) string

compress
save "../data/cleaned/benchmark_2005_GO_35Industry.dta", replace

* Combine all sheets into one file

use "../data/cleaned/benchmark_2005_GO_35Industry.dta", clear

merge m:1 isic3_division using ///
	"../data/cleaned/benchmark_2005_hierarchy.dta" ///
		, nogen keep(1 3)

replace major_sector_1 = lower(major_sector_1)
replace major_sector_1 = subinstr(major_sector_1, "-", "_", .)
replace major_sector_1 = subinstr(major_sector_1, " ", "_", .)

replace major_sector_2 = lower(major_sector_2)
replace major_sector_2 = subinstr(major_sector_2, "-", "_", .)
replace major_sector_2 = subinstr(major_sector_2, " ", "_", .)

merge m:1 iso3c sector10 using ///
	"../data/cleaned/benchmark_2005_GO_10Sector.dta" ///
		, nogen keep(1 3)

ren major_sector_1 major_sector

merge m:1 iso3c major_sector using ///
	"../data/cleaned/benchmark_2005_GO_GDP_MajorSector.dta" ///
		, nogen keep(1 3) keepusing(GO_gdp GO_sector)
ren GO_* GO_*_1

merge m:1 iso3c major_sector using ///
	"../data/cleaned/benchmark_2005_LP_GDP_MajorSector.dta" ///
		, nogen keep(1 3) keepusing(LP_gdp LP_sector)
ren LP_* LP_*_1

merge m:1 iso3c major_sector using ///
	"../data/cleaned/benchmark_2005_VA_GDP_MajorSector.dta" ///
		, nogen keep(1 3) keepusing(VA_gdp VA_sector)
ren VA_* VA_*_1

ren major_sector major_sector_1
ren major_sector_2 major_sector

merge m:1 iso3c major_sector using ///
	"../data/cleaned/benchmark_2005_GO_GDP_MajorSector.dta" ///
		, nogen keep(1 3) keepusing(GO_gdp GO_sector)
ren GO_* GO_*_2

merge m:1 iso3c major_sector using ///
	"../data/cleaned/benchmark_2005_LP_GDP_MajorSector.dta" ///
		, nogen keep(1 3) keepusing(LP_gdp LP_sector)
ren LP_* LP_*_2

merge m:1 iso3c major_sector using ///
	"../data/cleaned/benchmark_2005_VA_GDP_MajorSector.dta" ///
		, nogen keep(1 3) keepusing(VA_gdp VA_sector)
ren VA_* VA_*_2
ren *_1_2 *_1

ren major_sector major_sector_2

* Norway: Use EU-27 numbers

expand 2 if iso3c=="EU27", gen(duplicate)
replace country = "Norway" if iso3c=="EU27" & duplicate==1
replace iso3c = "NOR" if iso3c=="EU27" & duplicate==1
drop duplicate

* Switzerland: Use EU-27 numbers

expand 2 if iso3c=="EU27", gen(duplicate)
replace country = "Switzerland" if iso3c=="EU27" & duplicate==1
replace iso3c = "CHE" if iso3c=="EU27" & duplicate==1
drop duplicate

kountry iso3c, from(iso3c) to(iso2c)
ren _ISO2C_ _iso2c_
order _iso2c_, before(iso3c)
drop if mi(_iso2c_)

sort iso3c isic3_division
d
compress
save "../data/cleaned/benchmark_2005.dta", replace
