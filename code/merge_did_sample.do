********************************************************************************
* Merge together all the variables we need for the DiD regressions

use BvD_ID_number NACE4 NAICS4 SIC3 listed ISO2 ///
    using "../data/cleaned/orbis_firms_2008.dta", clear

decode ISO2, gen(_iso2c_)
cap drop ckeep
gen byte ckeep = 0
foreach cc in $clist {
    replace ckeep = 1 if _iso2c_=="`cc'"
}
keep if ckeep==1
drop ckeep

foreach vv in age EMPL {
    
    merge 1:1 BvD_ID_number using ///
        "../data/cleaned/prePost_`vv'.dta", nogen keep(1 3)
}

drop if mi(age_pre1yr)
drop if mi(EMPL_pre4yr)

foreach vv in ///
    D_tfp1 shr_D_ik ///
    eur_TOAS eur_OPRE ///
    leverage CULI_OPRE CS_TA CUAS_CULI EBITDA ///
    {
    
    merge 1:1 BvD_ID_number using ///
        "../data/cleaned/prePost_`vv'.dta", nogen keep(1 3)
}

* Exclude certain industries

gen nace2_2 = floor(NACE4 / 100)
drop if nace2_2==64 // financial and insurance activities
drop if nace2_2==65 // financial and insurance activities
drop if nace2_2==66 // financial and insurance activities
drop if nace2_2==84 // public service
drop if nace2_2==94 // other service activities
drop if nace2_2==95 // other service activities
drop if nace2_2==96 // other service activities
drop if nace2_2==97 // household employers
drop if nace2_2==98 // household employers
drop if nace2_2==99 // Extraterritorial organizations

* Manufacturing dummy

gen byte mfg = nace2_2>=10 & nace2_2<=33

********************************************************************************

* Firm size bins: 1 = Micro, 2 = Small, 3 = Medium, 4 = Large (Euro definition)

foreach yr in yr yrBal {
    foreach yy in 1 4 {
        
        * Based on Employees
        
        gen byte size_EMPL_pre`yy'`yr'_1 = ///
            (EMPL_pre`yy'`yr' < 10) ///
                if !mi(EMPL_pre`yy'`yr')
        lab var size_EMPL_pre`yy'`yr'_1 "Micro"
        
        gen byte size_EMPL_pre`yy'`yr'_2 = ///
            (EMPL_pre`yy'`yr' >= 10) ///
            & (EMPL_pre`yy'`yr' < 50) ///
                if !mi(EMPL_pre`yy'`yr')
        lab var size_EMPL_pre`yy'`yr'_2 "Small"
        
        gen byte size_EMPL_pre`yy'`yr'_3 = ///
            (EMPL_pre`yy'`yr' >= 50) ///
            & (EMPL_pre`yy'`yr' < 250) ///
                if !mi(EMPL_pre`yy'`yr')
        lab var size_EMPL_pre`yy'`yr'_3 "Medium"
        
        gen size_EMPL_pre`yy'`yr' = ""
        
        replace size_EMPL_pre`yy'`yr' = "Micro" ///
            if (EMPL_pre`yy'`yr' < 10) ///
                & !mi(EMPL_pre`yy'`yr')
        replace size_EMPL_pre`yy'`yr' = "Small" ///
            if (EMPL_pre`yy'`yr' >= 10) ///
                & (EMPL_pre`yy'`yr' < 50) ///
                & !mi(EMPL_pre`yy'`yr')
        replace size_EMPL_pre`yy'`yr' = "Medium" ///
            if (EMPL_pre`yy'`yr' >= 50) ///
                & (EMPL_pre`yy'`yr' < 250) ///
                & !mi(EMPL_pre`yy'`yr')
        replace size_EMPL_pre`yy'`yr' = "Large" ///
            if (EMPL_pre`yy'`yr' >= 250) ///
                & !mi(EMPL_pre`yy'`yr')
        
        gen SME_EMPL_pre`yy'`yr' = "Large" ///
            if size_EMPL_pre`yy'`yr'=="Large"
            
        replace SME_EMPL_pre`yy'`yr' = "SME" ///
            if size_EMPL_pre`yy'`yr'=="Micro"
        replace SME_EMPL_pre`yy'`yr' = "SME" ///
            if size_EMPL_pre`yy'`yr'=="Small"
        replace SME_EMPL_pre`yy'`yr' = "SME" ///
            if size_EMPL_pre`yy'`yr'=="Medium"
        
        gen size_EMPL_post`yy'`yr' = ""
        
        replace size_EMPL_post`yy'`yr' = "Micro" ///
            if (EMPL_post`yy'`yr' < 10) ///
                & !mi(EMPL_post`yy'`yr')
        replace size_EMPL_post`yy'`yr' = "Small" ///
            if (EMPL_post`yy'`yr' >= 10) ///
                & (EMPL_post`yy'`yr' < 50) ///
                & !mi(EMPL_post`yy'`yr')
        replace size_EMPL_post`yy'`yr' = "Medium" ///
            if (EMPL_post`yy'`yr' >= 50) ///
                & (EMPL_post`yy'`yr' < 250) ///
                & !mi(EMPL_post`yy'`yr')
        replace size_EMPL_post`yy'`yr' = "Large" ///
            if (EMPL_post`yy'`yr' >= 250) ///
                & !mi(EMPL_post`yy'`yr')
        
        gen SME_EMPL_post`yy'`yr' = "Large" ///
            if size_EMPL_post`yy'`yr'=="Large"
            
        replace SME_EMPL_post`yy'`yr' = "SME" ///
            if size_EMPL_post`yy'`yr'=="Micro"
        replace SME_EMPL_post`yy'`yr' = "SME" ///
            if size_EMPL_post`yy'`yr'=="Small"
        replace SME_EMPL_post`yy'`yr' = "SME" ///
            if size_EMPL_post`yy'`yr'=="Medium"
        
        * Based on annual turnover (operating revenue turnover)
        
        gen byte size_OPRE_pre`yy'`yr'_1 = ///
            (eur_OPRE_pre`yy'`yr' <= 2 * 10^6) ///
                if !mi(eur_OPRE_pre`yy'`yr')
        lab var size_OPRE_pre`yy'`yr'_1 "Micro"
        
        gen byte size_OPRE_pre`yy'`yr'_2 = ///
            (eur_OPRE_pre`yy'`yr' > 2 * 10^6) ///
            & (eur_OPRE_pre`yy'`yr' <= 10 * 10^6) ///
                if !mi(eur_OPRE_pre`yy'`yr')
        lab var size_OPRE_pre`yy'`yr'_2 "Small"
        
        gen byte size_OPRE_pre`yy'`yr'_3 = ///
            (eur_OPRE_pre`yy'`yr' > 10 * 10^6) ///
            & (eur_OPRE_pre`yy'`yr' <= 50 * 10^6) ///
                if !mi(eur_OPRE_pre`yy'`yr')
        lab var size_OPRE_pre`yy'`yr'_3 "Medium"
        
        gen size_OPRE_pre`yy'`yr' = ""
        
        replace size_OPRE_pre`yy'`yr' = "Micro" ///
            if (eur_OPRE_pre`yy'`yr' <= 2 * 10^6) ///
                & !mi(eur_OPRE_pre`yy'`yr')
        replace size_OPRE_pre`yy'`yr' = "Small" ///
            if (eur_OPRE_pre`yy'`yr' > 2 * 10^6) ///
                & (eur_OPRE_pre`yy'`yr' <= 10 * 10^6) ///
                & !mi(eur_OPRE_pre`yy'`yr')
        replace size_OPRE_pre`yy'`yr' = "Medium" ///
            if (eur_OPRE_pre`yy'`yr' > 10 * 10^6) ///
                & (eur_OPRE_pre`yy'`yr' <= 50 * 10^6) ///
                & !mi(eur_OPRE_pre`yy'`yr')
        replace size_OPRE_pre`yy'`yr' = "Large" ///
            if (eur_OPRE_pre`yy'`yr' > 50 * 10^6) ///
                & !mi(eur_OPRE_pre`yy'`yr')
        
        gen SME_OPRE_pre`yy'`yr' = "Large" ///
            if size_OPRE_pre`yy'`yr'=="Large"
        
        replace SME_OPRE_pre`yy'`yr' = "SME" ///
            if size_OPRE_pre`yy'`yr'=="Micro"
        replace SME_OPRE_pre`yy'`yr' = "SME" ///
            if size_OPRE_pre`yy'`yr'=="Small"
        replace SME_OPRE_pre`yy'`yr' = "SME" ///
            if size_OPRE_pre`yy'`yr'=="Medium"
        
        gen size_OPRE_post`yy'`yr' = ""
        
        replace size_OPRE_post`yy'`yr' = "Micro" ///
            if (eur_OPRE_post`yy'`yr' <= 2 * 10^6) ///
                & !mi(eur_OPRE_post`yy'`yr')
        replace size_OPRE_post`yy'`yr' = "Small" ///
            if (eur_OPRE_post`yy'`yr' > 2 * 10^6) ///
                & (eur_OPRE_post`yy'`yr' <= 10 * 10^6) ///
                & !mi(eur_OPRE_post`yy'`yr')
        replace size_OPRE_post`yy'`yr' = "Medium" ///
            if (eur_OPRE_post`yy'`yr' > 10 * 10^6) ///
                & (eur_OPRE_post`yy'`yr' <= 50 * 10^6) ///
                & !mi(eur_OPRE_post`yy'`yr')
        replace size_OPRE_post`yy'`yr' = "Large" ///
            if (eur_OPRE_post`yy'`yr' > 50 * 10^6) ///
                & !mi(eur_OPRE_post`yy'`yr')
         
        gen SME_OPRE_post`yy'`yr' = "Large" ///
            if size_OPRE_post`yy'`yr'=="Large"
        
        replace SME_OPRE_post`yy'`yr' = "SME" ///
            if size_OPRE_post`yy'`yr'=="Micro"
        replace SME_OPRE_post`yy'`yr' = "SME" ///
            if size_OPRE_post`yy'`yr'=="Small"
        replace SME_OPRE_post`yy'`yr' = "SME" ///
            if size_OPRE_post`yy'`yr'=="Medium"
        
        * Based on balance sheet total (total assets)
        
        gen byte size_TOAS_pre`yy'`yr'_1 = ///
            (eur_TOAS_pre`yy'`yr' <= 2 * 10^6) ///
                if !mi(eur_TOAS_pre`yy'`yr')
        lab var size_TOAS_pre`yy'`yr'_1 "Micro"
        
        gen byte size_TOAS_pre`yy'`yr'_2 = ///
            (eur_TOAS_pre`yy'`yr' > 2 * 10^6) ///
            & (eur_TOAS_pre`yy'`yr' <= 10 * 10^6) ///
                if !mi(eur_TOAS_pre`yy'`yr')
        lab var size_TOAS_pre`yy'`yr'_2 "Small"
        
        gen byte size_TOAS_pre`yy'`yr'_3 = ///
            (eur_TOAS_pre`yy'`yr' > 10 * 10^6) ///
            & (eur_TOAS_pre`yy'`yr' <= 43 * 10^6) ///
                if !mi(eur_TOAS_pre`yy'`yr')
        lab var size_TOAS_pre`yy'`yr'_3 "Medium"
        
        gen size_TOAS_pre`yy'`yr' = ""
        
        replace size_TOAS_pre`yy'`yr' = "Micro" ///
            if (eur_TOAS_pre`yy'`yr' <= 2 * 10^6) ///
                & !mi(eur_TOAS_pre`yy'`yr')
        replace size_TOAS_pre`yy'`yr' = "Small" ///
            if (eur_TOAS_pre`yy'`yr' > 2 * 10^6) ///
                & (eur_TOAS_pre`yy'`yr' <= 10 * 10^6) ///
                & !mi(eur_TOAS_pre`yy'`yr')
        replace size_TOAS_pre`yy'`yr' = "Medium" ///
            if (eur_TOAS_pre`yy'`yr' > 10 * 10^6) ///
                & (eur_TOAS_pre`yy'`yr' <= 43 * 10^6) ///
                & !mi(eur_TOAS_pre`yy'`yr')
        replace size_TOAS_pre`yy'`yr' = "Large" ///
            if (eur_TOAS_pre`yy'`yr' > 43 * 10^6) ///
                & !mi(eur_TOAS_pre`yy'`yr')
        
        gen SME_TOAS_pre`yy'`yr' = "Large" ///
            if size_TOAS_pre`yy'`yr'=="Large"
        
        replace SME_TOAS_pre`yy'`yr' = "SME" ///
            if size_TOAS_pre`yy'`yr'=="Micro"
        replace SME_TOAS_pre`yy'`yr' = "SME" ///
            if size_TOAS_pre`yy'`yr'=="Small"
        replace SME_TOAS_pre`yy'`yr' = "SME" ///
            if size_TOAS_pre`yy'`yr'=="Medium"
        
        gen size_TOAS_post`yy'`yr' = ""
        
        replace size_TOAS_post`yy'`yr' = "Micro" ///
            if (eur_TOAS_post`yy'`yr' <= 2 * 10^6) ///
                & !mi(eur_TOAS_post`yy'`yr')
        replace size_TOAS_post`yy'`yr' = "Small" ///
            if (eur_TOAS_post`yy'`yr' > 2 * 10^6) ///
                & (eur_TOAS_post`yy'`yr' <= 10 * 10^6) ///
                & !mi(eur_TOAS_post`yy'`yr')
        replace size_TOAS_post`yy'`yr' = "Medium" ///
            if (eur_TOAS_post`yy'`yr' > 10 * 10^6) ///
                & (eur_TOAS_post`yy'`yr' <= 43 * 10^6) ///
                & !mi(eur_TOAS_post`yy'`yr')
        replace size_TOAS_post`yy'`yr' = "Large" ///
            if (eur_TOAS_post`yy'`yr' > 43 * 10^6) ///
                & !mi(eur_TOAS_post`yy'`yr')
        
        gen SME_TOAS_post`yy'`yr' = "Large" ///
            if size_TOAS_post`yy'`yr'=="Large"
        
        replace SME_TOAS_post`yy'`yr' = "SME" ///
            if size_TOAS_post`yy'`yr'=="Micro"
        replace SME_TOAS_post`yy'`yr' = "SME" ///
            if size_TOAS_post`yy'`yr'=="Small"
        replace SME_TOAS_post`yy'`yr' = "SME" ///
            if size_TOAS_post`yy'`yr'=="Medium"
        
        * Based on Employees AND (total assets OR revenue)
        
        gen byte _cnd = !mi(EMPL_pre`yy'`yr') ///
            & !mi(eur_OPRE_pre`yy'`yr') ///
            & !mi(eur_TOAS_pre`yy'`yr')
        
        gen size_EURO_pre`yy'`yr' = ""
        
        replace size_EURO_pre`yy'`yr' = "Micro" ///
            if (EMPL_pre`yy'`yr' < 10) & ( ///
                (eur_OPRE_pre`yy'`yr' <= 2 * 10^6) | ///
                (eur_TOAS_pre`yy'`yr' <= 2 * 10^6) ///
                ) & _cnd==1
        replace size_EURO_pre`yy'`yr' = "Small" ///
            if (EMPL_pre`yy'`yr' < 50) & ( ///
                (eur_OPRE_pre`yy'`yr' <= 10 * 10^6) | ///
                (eur_TOAS_pre`yy'`yr' <= 10 * 10^6) ///
                ) & _cnd==1 & size_EURO_pre`yy'`yr'==""
        replace size_EURO_pre`yy'`yr' = "Medium" ///
            if (EMPL_pre`yy'`yr' < 250) & ( ///
                (eur_OPRE_pre`yy'`yr' <= 50 * 10^6) | ///
                (eur_TOAS_pre`yy'`yr' <= 43 * 10^6) ///
                ) & _cnd==1 & size_EURO_pre`yy'`yr'==""
        replace size_EURO_pre`yy'`yr' = "Large" ///
            if _cnd==1 & size_EURO_pre`yy'`yr'==""
        
        gen byte size_EURO_pre`yy'`yr'_1 = ///
            (size_EURO_pre`yy'`yr'=="Micro") ///
            if _cnd==1
        lab var size_EURO_pre`yy'`yr'_1 "Micro"
        
        gen byte size_EURO_pre`yy'`yr'_2 = ///
            (size_EURO_pre`yy'`yr'=="Small") ///
            if _cnd==1
        lab var size_EURO_pre`yy'`yr'_2 "Small"
        
        gen byte size_EURO_pre`yy'`yr'_3 = ///
            (size_EURO_pre`yy'`yr'=="Medium") ///
            if _cnd==1
        lab var size_EURO_pre`yy'`yr'_3 "Medium"
        
        gen SME_EURO_pre`yy'`yr' = "Large" ///
            if size_EURO_pre`yy'`yr'=="Large"
        
        replace SME_EURO_pre`yy'`yr' = "SME" ///
            if size_EURO_pre`yy'`yr'=="Micro"
        replace SME_EURO_pre`yy'`yr' = "SME" ///
            if size_EURO_pre`yy'`yr'=="Small"
        replace SME_EURO_pre`yy'`yr' = "SME" ///
            if size_EURO_pre`yy'`yr'=="Medium"
        
        drop _cnd
        
        gen byte _cnd = !mi(EMPL_post`yy'`yr') ///
            & !mi(eur_OPRE_post`yy'`yr') ///
            & !mi(eur_TOAS_post`yy'`yr')
        
        gen size_EURO_post`yy'`yr' = ""
        
        replace size_EURO_post`yy'`yr' = "Micro" ///
            if (EMPL_post`yy'`yr' < 10) & ( ///
                (eur_OPRE_post`yy'`yr' <= 2 * 10^6) | ///
                (eur_TOAS_post`yy'`yr' <= 2 * 10^6) ///
                ) & _cnd==1
        replace size_EURO_post`yy'`yr' = "Small" ///
            if (EMPL_post`yy'`yr' < 50) & ( ///
                (eur_OPRE_post`yy'`yr' <= 10 * 10^6) | ///
                (eur_TOAS_post`yy'`yr' <= 10 * 10^6) ///
                ) & _cnd==1 & size_EURO_post`yy'`yr'==""
        replace size_EURO_post`yy'`yr' = "Medium" ///
            if (EMPL_post`yy'`yr' < 250) & ( ///
                (eur_OPRE_post`yy'`yr' <= 50 * 10^6) | ///
                (eur_TOAS_post`yy'`yr' <= 43 * 10^6) ///
                ) & _cnd==1 & size_EURO_post`yy'`yr'==""
        replace size_EURO_post`yy'`yr' = "Large" ///
            if _cnd==1 & size_EURO_post`yy'`yr'==""
        
        gen byte size_EURO_post`yy'`yr'_1 = ///
            (size_EURO_post`yy'`yr'=="Micro") ///
            if _cnd==1
        lab var size_EURO_post`yy'`yr'_1 "Micro"
        
        gen byte size_EURO_post`yy'`yr'_2 = ///
            (size_EURO_post`yy'`yr'=="Small") ///
            if _cnd==1
        lab var size_EURO_post`yy'`yr'_2 "Small"
        
        gen byte size_EURO_post`yy'`yr'_3 = ///
            (size_EURO_post`yy'`yr'=="Medium") ///
            if _cnd==1
        lab var size_EURO_post`yy'`yr'_3 "Medium"
        
        gen SME_EURO_post`yy'`yr' = "Large" ///
            if size_EURO_post`yy'`yr'=="Large"
        
        replace SME_EURO_post`yy'`yr' = "SME" ///
            if size_EURO_post`yy'`yr'=="Micro"
        replace SME_EURO_post`yy'`yr' = "SME" ///
            if size_EURO_post`yy'`yr'=="Small"
        replace SME_EURO_post`yy'`yr' = "SME" ///
            if size_EURO_post`yy'`yr'=="Medium"
        
        drop _cnd size_OPRE* SME_OPRE* size_TOAS* SME_TOAS*
        
    }
}

gen age2_pre1yr = age_pre1yr^2

gen ln_EBITDA_pre1yrBal = ln(EBITDA_pre1yrBal)
gen ln_EBITDA_pre4yrBal = ln(EBITDA_pre4yrBal)

foreach vv in leverage CULI_OPRE CS_TA CUAS_CULI ln_EBITDA EMPL {
	
	replace `vv'_pre4yrBal = `vv'_pre1yrBal if _iso2c_=="PT"
}

ds D_tfp1_p*4yrBal shr_D_ik_p*4yrBal
	
foreach vv in `r(varlist)' {
	
	winsor2 `vv', cuts(1 99) by(ISO2) replace
}

ds $controls

foreach vv in `r(varlist)' {
	
	winsor2 `vv', cuts(1 99) by(ISO2) replace
}

replace size_EURO_pre4yrBal_1 = size_EURO_pre1yrBal_1 if _iso2c_=="PT"
replace size_EURO_pre4yrBal_2 = size_EURO_pre1yrBal_2 if _iso2c_=="PT"
replace size_EURO_pre4yrBal_3 = size_EURO_pre1yrBal_3 if _iso2c_=="PT"
replace SME_EURO_pre4yrBal = SME_EURO_pre1yrBal if _iso2c_=="PT"

foreach vv in D_tfp1 shr_D_ik {
    
    replace `vv'_pre4yrBal = `vv'_pre1yrBal if _iso2c_=="PT" 
}

foreach vv in D_tfp1 shr_D_ik { //  
	
	gen DiD_`vv'_4yrBal = `vv'_post4yrBal - `vv'_pre4yrBal
}

replace shr_D_ik_pre4yr = . if abs(shr_D_ik_pre4yr) > 1
replace DiD_shr_D_ik_4yr = . if abs(DiD_shr_D_ik_4yr) > 1

********************************************************************************

gen byte SME = (SME_EURO_pre4yrBal=="SME") if !mi(SME_EURO_pre4yrBal)

reghdfe DiD_D_tfp1_4yrBal ///
	D_tfp1_pre4yrBal /// 
	SME /// 
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)

gen byte esample = e(sample)

reghdfe DiD_D_tfp1_4yrBal ///
	D_tfp1_pre4yrBal /// 
	SME /// 
	$controls ///
	, absorb(i.ISO2#i.NACE4) vce(cluster i.ISO2#i.NACE4)

gen byte esample1 = e(sample)

keep if !mi(D_tfp1_pre4yr)
keep if !mi(D_tfp1_post4yr)
keep if !mi(size_EURO_pre4yrBal)

bys ISO2 NACE4: egen nfirms = count(esample1)
*drop if nfirms < 10 // Note: Uncomment when running the code with real data

cap drop ckeep
gen byte ckeep = 0
foreach cc in $clis0 {
	replace ckeep = 1 if _iso2c_=="`cc'"
}

********************************************************************************

lab var D_tfp1_pre4yrBal "$ TFP $"
lab var size_EURO_pre4yrBal_1 "$\text{Micro}$"
lab var size_EURO_pre4yrBal_2 "$\text{Small}$"
lab var size_EURO_pre4yrBal_3 "$\text{Medium}$"
lab var age_pre1yr "$\text{Age}$"
lab var age2_pre1yr "$\text{Age}^2$"
lab var leverage_pre4yrBal "$\text{Leverage}$"
lab var CULI_OPRE_pre4yrBal "$\text{Debt Maturity}$"
lab var CS_TA_pre4yrBal "$\text{Cash Flow}$"
lab var CUAS_CULI_pre4yrBal "$\text{Liquidity}$"
lab var ln_EBITDA_pre4yrBal "$\text{Profitability}$"

********************************************************************************

* Credit variables

* Country-level relationship lending

merge m:1 _iso2c_ using "../data/cleaned/bepsii_shr_relationship.dta" ///
	, nogen keep(1 3) keepusing(shr_relationship)

* Country level CDS spreads

merge m:1 _iso2c_ using "../data/cleaned/markit_delta_cds_country.dta" ///
    , nogen keep(1 3) keepusing(delta_cds_country)

* Firm level CDS spreads

merge m:1 BvD_ID_number using "../data/cleaned/markit_delta_cds_firm.dta" ///
	, nogen keep(1 3) keepusing(delta_cds_firm cds_presence)

* Rescale in units of standard deviations

ds delta_cds_country delta_cds_firm

foreach vv in `r(varlist)' {

	qui su `vv', d
	gen std_`vv' = (`vv' - r(mean)) / r(sd)
}

* Fitch bank financials

merge m:1 BvD_ID_number using "../data/cleaned/fitch_bank_capital.dta" ///
    , keep(1 3) nogen keepusing(bank_capital_pre4yrBal)

ds bank_capital_pre4yrBal

foreach vv in `r(varlist)' {
    
    egen _p50 = median(`vv')
    gen byte high_`vv' = (`vv' > _p50) if !mi(`vv')
    drop _p50
}

bys ISO2 NACE4: gen _sample = 1 if esample==1 & !mi(delta_cds_firm)
bys ISO2 NACE4: egen _count = total(_sample)
gen tmp_spread = delta_cds_firm if _count > 5 & !mi(std_delta_cds_country)
drop _sample _count
gen raw_spread = delta_cds_firm if !mi(tmp_spread)

bys ISO2 NACE4: gen _sample = 1 if esample==1 & !mi(high_bank_capital_pre4yrBal)
bys ISO2 NACE4: egen _count = total(_sample)
gen tmp_tier1 = high_bank_capital_pre4yrBal if _count > 5
drop _sample _count
gen raw_tier1 = bank_capital_pre4yrBal / 100 if !mi(tmp_tier1)
winsor2 raw_tier1, cuts(1 99) replace

bys ISO2 NACE4: gen _sample = 1 if esample==1 & !mi(cds_presence)
bys ISO2 NACE4: egen _count = total(_sample)
gen tmp_cds = cds_presence if _count > 5
drop _sample _count

********************************************************************************

* Patents

merge 1:1 BvD_ID_number using "../data/cleaned/patstat_patent_app.dta" ///
    , nogen keep(1 3) keepusing(DiD_patent_app_4yrBal patent_app_pre4yrBal)

ds DiD_patent_app_4yrBal patent_app_pre4yrBal

foreach vv in `r(varlist)' {
    
    winsor2 `vv', cuts(2 98) replace
}

compress
save "../data/cleaned/sample_did.dta", replace
