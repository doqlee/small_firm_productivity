* Clean Orbis data for each country

foreach country in $clist {
    
    * Financials
    
    use "../data/raw/orbis/financials_`country'.dta", clear
    
    * Industry codes
    
    merge m:1 BvD_ID_number using ///
    	"../data/raw/orbis/industry_classifications_`country'.dta" ///
    		, keep(3) nogen
    
    * Legal information
    
    merge m:1 BvD_ID_number using ///
    	"../data/raw/orbis/legal_info_`country'.dta" ///
    		, keep(3) nogen
    
    * Housekeeping
    
    ren Total_assets TOAS
    ren Operating_revenue_Turnover OPRE
    ren Number_of_employees EMPL
    ren Fixed_assets FIAS
    ren Tangible_fixed_assets TFAS
    ren Intangible_fixed_assets IFAS
    ren Other_fixed_assets OFAS 
    ren Current_assets CUAS
    ren Other_current_assets OCAS
    ren Costs_of_employees WAGE
    ren Sales SALE
    ren Material_costs MATL
    ren Loans LOAN
    ren Long_term_debt LTDB
    ren Cash_flow CSFL
    ren Shareholders_funds SHDF 
    ren Other_shareholders_funds OSHF 
    ren Added_value AV
    ren EBITDA EBITDA 
    ren Current_liabilities CULI
    ren Other_current_liabilities OCLI
    ren Non_current_liabilities NCLI
    ren Other_non_current_liabilities ONLI
    ren Total_shareh_funds_and_liab TSHF
    ren Depreciation_and_Amortization DEPR
    ren Capital CPTL
    ren Stock STCK
    ren Debtors DBTR
    ren Creditors CRED
    ren US_SIC_Core_code_3_digits SIC3
    ren NAICS_2012_Core_code_4_digits NAICS4
    ren NACE_Rev_2_Core_code_4_digits NACE4
    
    gen byte listed = .
    replace listed = 1 if Listed_Delisted_Unlisted=="Listed"
    replace listed = 0 if Listed_Delisted_Unlisted=="Unlisted"
    replace listed = -1 if Listed_Delisted_Unlisted=="Delisted"
    	drop Listed_Delisted_Unlisted
    	
    drop Historical_record_since
    
    destring Number_of_months NACE4 NAICS4 SIC3, replace
    
    encode Filing_type, gen(n_Filing_type)
    encode Original_units, gen(n_Original_units)
    encode Status, gen(n_Status)
    encode Standardised_legal_form, gen(n_Standardised_legal_form)
    encode Type_of_entity, gen(n_Type_of_entity)
    encode Category_of_the_company, gen(n_Category_of_the_company)
    
    drop Original_units Status Standardised_legal_form ///
    	Type_of_entity Category_of_the_company
    
    compress
    
    * Keep unconsolidated accounts only
    
    keep if Consolidation_code=="U1" | Consolidation_code=="U2"
    
    * Firm id
    
    cap drop firm_id
    egen double firm_id = group(BvD_ID_number)
    order firm_id, after(BvD_ID_number)
    compress
    
    * Drop duplicates in firm and year
    
    gen ndate = date(Closing_date, "YMD")
    	format ndate %td
    
    * Keep the duplicate with largest revenue
    
    bys firm_id ndate (OPRE): egen tmp_max = max(OPRE)
    bys firm_id ndate (OPRE): egen tmp_min = min(OPRE)
    bys firm_id ndate (OPRE): gen tmp_sum = _N
    bys firm_id ndate (OPRE): drop if tmp_sum > 1 & tmp_max==. & tmp_min!=. & OPRE==.
    	drop tmp_max tmp_min tmp_sum
    	
    bys firm_id ndate (OPRE): egen tmp_max = max(OPRE)
    bys firm_id ndate (OPRE): gen tmp_sum = _N
    bys firm_id ndate (OPRE): drop if OPRE < tmp_max 
    	drop tmp_max tmp_sum
    
    * Relative years
    
    gen time_month = month(ndate)
    
    gen current_year = 1 if time_month>=6
    replace current_year = 0 if time_month < 6
    	
    gen int year = year(ndate) if current_year==1
    replace year = year(ndate) - 1 if current_year==0
    
    * Keep duplicates at the end of year
    
    sort firm_id year ndate
    by firm_id year (ndate): gen tmp = _N
    by firm_id year (ndate): egen max_month = max(time_month)
    by firm_id year (ndate): drop if tmp > 1 & max_month==12 & time_month!=12
    	drop tmp max_month
    
    * Keep the duplicate with largest revenue
    
    bys firm_id year (OPRE): egen tmp_max = max(OPRE)
    bys firm_id year (OPRE): egen tmp_min = min(OPRE)
    bys firm_id year (OPRE): gen tmp_sum = _N
    bys firm_id year (OPRE): drop if tmp_sum > 1 & tmp_max==. & tmp_min!=. & OPRE==.
    	drop tmp_max tmp_min tmp_sum
    	
    bys firm_id year (OPRE): egen tmp_max = max(OPRE)
    bys firm_id year (OPRE): gen tmp_sum = _N
    bys firm_id year (OPRE): drop if OPRE < tmp_max 
    	drop tmp_max tmp_sum
    	
    bys firm_id year (OPRE): gen tmp = _n
    bys firm_id year (OPRE): gen tmp2 = _N 
    keep if tmp==tmp2
    
    drop tmp tmp2
    drop time_month current_year ndate
    
    * Drop observations if:
    * Missing total assets and operating revenues and sales and employment
    
    drop if TOAS==. & OPRE==. & SALE==. & EMPL==.
    
    * Drop the firm if: 
    * Total assets or employment or sales or tangibles negative in any year
    
    foreach var in TOAS EMPL SALE TFAS {
        
    	bys firm_id: egen `var'_min = min(`var')
    	drop if `var'_min < 0
    	drop `var'_min
    }
    
    * Drop the firm if: Employment > 2 million in any year
    
    gen byte dum_num = 0
    replace dum_num = 1 if EMPL > 2000000 & EMPL!=.
    
    by firm_id: egen maxdum_num = max(dum_num)
    drop if maxdum_num==1
    	drop dum_num maxdum_num
    
    * Drop observations with missing or <=0 operating revenue
    
    drop if OPRE==.
    drop if OPRE<=0 
    
    * Drop observations with missing or <=0 total assets
    
    drop if TOAS==.
    drop if TOAS<=0
    
    * Drop observations with missing industry code
    
    drop if mi(NACE4)
    
    * Check that the financials are consistent with each other
    
    * Fixed assets + current assets should = total assets
    
    gen check_TOAS = (FIAS + CUAS) / TOAS
    
    * Capital + other shareholder funds should = total shareholder funds
    
    gen check_SHDF = (CPTL + OSHF) / SHDF
    
    * Stocks + debtors + other current assets should = total current assets
    
    gen check_CUAS = (STCK + DBTR + OCAS) / CUAS
    
    * Tangibles + intangibles + other fixed assets should = total fixed assets
    
    gen check_FIAS = (TFAS + IFAS + OFAS) / FIAS
    
    * Non-current liabilities + current liabilities + shareholder funds should 
    * = total shareholder funds and liabilities
    
    gen check_TSHF = (NCLI + CULI + SHDF) / TSHF
    
    * Loans + creditors + other current liabilities should 
    * = total current liabilities
    
    gen check_CULI = (LOAN + CRED + OCLI) / CULI
    
    * Long term debt + other non-current liabilities should 
    * = total non-current liabilities
    
    gen check_NCLI = (LTDB + ONLI) / NCLI
    
    * Drop outliers at 0.1 percentile
    
    foreach var in ///
        check_TOAS check_SHDF check_CUAS check_FIAS ///
        check_TSHF check_CULI check_NCLI {
    	
    	_pctile `var', p(0.1 99.9)
    	
    	gen byte todrop_`var' = 1 if `var' < r(r1) 
    	replace todrop_`var' = 1 if `var' > r(r2) & r(r2)!=. & `var'!=.
    	
    	drop if todrop_`var'==1
    	
    	drop `var' todrop_`var'
    }
    
    * Drop firms that ever had age<=0
    
    gen year_of_incorporation = substr(Date_of_incorporation, 1, 4) 
    replace year_of_incorporation = "." if Date_of_incorporation=="n.a."
    replace year_of_incorporation = "." if Date_of_incorporation=="."
    replace year_of_incorporation = "." if Date_of_incorporation==""
    	destring year_of_incorporation, replace
    
    gen int age = (year - year_of_incorporation) + 1
    
    by firm_id: egen min_age = min(age)
    
    drop if min_age<=0 
    drop min_age year_of_incorporation
    
    * Drop observations with total liabilities<=0
    
    gen liabilities = TSHF - SHDF
    
    drop if liabilities<=0
    
    * Drop observation if the two measures of total liabilities are inconsistent
    
    gen check_liabilities = liabilities / (CULI + NCLI)
    drop if check_liabilities > 1.1 & check_liabilities!=.
    drop if check_liabilities < 0.9
    drop check_liabilities
    
    * Drop observation if long term debt greater than total liabilities
    
    drop if LTDB > liabilities & LTDB!=.
    drop liabilities
    
    * Drop observations with negative items
    
    drop if CUAS < 0 
    drop if CRED < 0 
    drop if CULI < 0 
    drop if LOAN < 0 
    drop if OCLI < 0 
    drop if NCLI < 0 
    drop if LTDB < 0 
    
    * Drop observations if total assets does not equal to total shareholder funds
    
    drop if TOAS!=TSHF & TOAS!=. & TSHF!=.
    
    * Drop observations with missing or <=0 wage bills
    
    drop if WAGE==. & EMPL==. 
    drop if WAGE<=0 
    
    * Drop observations with negative intangible fixed assets
    
    drop if IFAS < 0 
    
    * Drop observations with missing for zero tangible fixed assets
    
    drop if TFAS==.
    drop if TFAS==0
    
    * Drop observations with tangibles greater than total assets
    
    gen check_TFAS = TFAS / TOAS
    drop if check_TFAS > 1
    drop check_TFAS
    
    * Drop observations with negative depreciation
    
    drop if DEPR < 0
    
    * Drop firms with capital-labor ratio below 0.1 percentile
    
    gen K = TFAS + IFAS
    gen KL = K / WAGE
    _pctile KL, p(0.1)
    
    gen byte todrop = 1 if KL < r(r1) & r(r1)!=.
    replace todrop = 0 if KL>=r(r1) & r(r1)!=.
    by firm_id: egen max_todrop = max(todrop)
    drop if max_todrop==1
    drop K max_todrop todrop
    
    * Drop outlying observations in capital-labor ratio at 0.1 percentile
    
    _pctile KL, p(0.1 99.9)
    drop if KL < r(r1) & KL!=. & r(r1)!=.
    drop if KL > r(r2) & KL!=. & r(r2)!=.
    drop KL
    
    * Drop observations with negative shareholder funds
    
    drop if SHDF < 0
    
    * Drop if other shareholders funds to total assets below 0.1 percentile
    
    gen OSHF_TOAS = OSHF / TOAS
    _pctile OSHF_TOAS, p(0.1)
    drop if OSHF_TOAS < r(r1) & r(r1)!=.
    drop OSHF_TOAS
    
    * Drop outlying observations in the following ratios:
    
    * Tangible fixed assets to total shareholder funds
    
    gen TFAS_SHDF = TFAS / SHDF
    
    * Total assets to total shareholder funds
    
    gen TOAS_SHDF = TOAS / SHDF
    
    foreach var in TFAS_SHDF TOAS_SHDF {
    
    	_pctile `var', p(0.1 99.9)
    	gen byte todrop_`var' = 1 if `var' < r(r1) & r(r1)!=.
    	replace todrop_`var' = 1 if `var' > r(r2) & r(r2)!=. & `var'!=.
    	drop if todrop_`var'==1
    	drop `var' todrop_`var'
    }
    
    * Drop observations with negative Value Added
    
    gen VA = OPRE - MATL
    drop if VA < 0
    
    * Drop outlying observations in Wage bill to value added
    
    gen WAGE_VA = WAGE / VA
    _pctile WAGE_VA, p(99)
    
    if r(r1) > 1 & r(r1)!=. {
    
    	_pctile WAGE_VA, p(1 99)
    	drop if WAGE_VA < r(r1) & r(r1)!=.
    	drop if WAGE_VA > r(r2) & r(r2)!=. & WAGE_VA!=.
    }
    else {
    
    	_pctile WAGE_VA, p(0.1 99.9)
    	drop if WAGE_VA < r(r1) & r(r1)!=.
    	drop if WAGE_VA > r(r2) & r(r2)!=. & WAGE_VA!=.
    }
    
    drop if WAGE_VA > 1.1 & WAGE_VA!=.
    drop VA WAGE_VA

    compress
    
    * Map country codes to currency codes
    
    gen _iso2c_ = substr(BvD_ID_number, 1, 2)
    gen nace2_2 = floor(NACE4 / 100)
    
    do "iso2c_to_currency.do"
    
    * BIS US dollar exchange rates
    
    merge m:1 _iso2c_ year using ///
    	"../data/cleaned/WEBSTATS_XRU_CURRENT_DATAFLOW_83_16.dta" ///
    	, keep(1 3) nogen keepusing(xru_E xru_E_2005)
    
    * List of financial variables
    
    global financialvars ///
    	TOAS OPRE SALE WAGE MATL CUAS NCLI CULI TSHF SHDF CSFL AV EBITDA
    
    * List of capital variables
    
    global capitalvars ///
        FIAS TFAS IFAS DEPR
    
    * Convert to current local currency
    
    foreach y in $financialvars $capitalvars {
        
        replace `y' = `y' * xru_E
    }
    
    * Convert to 2005 units
    
    foreach y in $financialvars $capitalvars {
        
        replace `y' = `y' / xru_E_2005
    }
    
    * Map 2-digit NACE Rev 2 industry codes to ISIC3 divisions
    
    gen isic3_division = ""
    replace isic3_division = "AtB" if nace2_2>=1 & nace2_2<=3
    replace isic3_division = "C" if nace2_2>=5 & nace2_2<=9
    replace isic3_division = "15t16" if nace2_2>=10 & nace2_2<=12
    replace isic3_division = "17t18" if nace2_2>=13 & nace2_2<=14
    replace isic3_division = "19" if nace2_2>=15 & nace2_2<=15
    replace isic3_division = "20" if nace2_2>=16 & nace2_2<=16
    replace isic3_division = "21t22" if nace2_2>=17 & nace2_2<=18
    replace isic3_division = "23" if nace2_2>=19 & nace2_2<=19
    replace isic3_division = "24" if nace2_2>=20 & nace2_2<=21
    replace isic3_division = "25" if nace2_2>=22 & nace2_2<=22
    replace isic3_division = "26" if nace2_2>=23 & nace2_2<=23
    replace isic3_division = "27t28" if nace2_2>=24 & nace2_2<=25
    replace isic3_division = "29" if nace2_2>=28 & nace2_2<=28
    replace isic3_division = "30t33" if nace2_2>=26 & nace2_2<=27
    replace isic3_division = "34t35" if nace2_2>=29 & nace2_2<=30
    replace isic3_division = "36t37" if nace2_2>=31 & nace2_2<=33
    replace isic3_division = "E" if nace2_2>=35 & nace2_2<=39
    replace isic3_division = "F" if nace2_2>=41 & nace2_2<=43
    replace isic3_division = "50" if nace2_2>=45 & nace2_2<=45
    replace isic3_division = "51" if nace2_2>=46 & nace2_2<=46
    replace isic3_division = "52" if nace2_2>=47 & nace2_2<=47
    replace isic3_division = "H" if nace2_2>=55 & nace2_2<=56
    replace isic3_division = "60" if nace2_2>=49 & nace2_2<=49
    replace isic3_division = "61" if nace2_2>=50 & nace2_2<=50
    replace isic3_division = "62" if nace2_2>=51 & nace2_2<=51
    replace isic3_division = "63" if nace2_2>=52 & nace2_2<=53
    replace isic3_division = "64" if nace2_2>=58 & nace2_2<=63
    replace isic3_division = "J" if nace2_2>=64 & nace2_2<=66
    replace isic3_division = "70" if nace2_2>=68 & nace2_2<=68
    replace isic3_division = "71t74" if nace2_2>=69 & nace2_2<=82
    replace isic3_division = "L" if nace2_2>=84 & nace2_2<=84
    replace isic3_division = "M" if nace2_2>=85 & nace2_2<=85
    replace isic3_division = "N" if nace2_2>=86 & nace2_2<=88
    replace isic3_division = "O" if nace2_2>=90 & nace2_2<=96
    replace isic3_division = "P" if nace2_2>=97 & nace2_2<=98
    
    * Industry-level PPP (2005) from Inklaar and Timmer (2014)
    
    merge m:1 _iso2c_ isic3_division using ///
    	"../data/cleaned/benchmark_2005.dta" ///
    		, keep(1 3) nogen keepusing(VA_gdp_1)
    
    * Adjust for 2005 Industry-level PPP
    
    foreach y in $financialvars $capitalvars {
        
        replace `y' = `y' / VA_gdp_1
    }
    
    * Apply deflators using the OECD STAN Database
    * Gross Value Added Deflator (VALP), 2005 = 1
    * Gross Fixed Capital Formation Deflator (GFCP), 2005 = 1
    
    merge m:1 _iso2c_ year nace2_2 ///
    	using "../data/cleaned/STANI4_2020_NACE2.dta" ///
    	, keep(1 3 4 5) keepusing(unit_GFCP unit_VALP LABR EMPE) nogen 
    
    * Construct tangible capital stock using perpetual inventory method (PIM)
    
    * Fill in missing years
    
    foreach var in TFAS IFAS DEPR {
        
    	tempvar `var'_ip
    	bysort firm_id (year): ipolate `var' year, gen(``var'_ip')
    	noi replace `var' = ``var'_ip' if `var'==. & ``var'_ip' < .
    }
    	
    * Tag nonmissing observations
    
    gen touse = 1 if TFAS < .
    	
    * Real gross investment
    
    bys firm_id touse (year): gen investment = ///
    	(TFAS - TFAS[_n-1] + DEPR) / unit_GFCP ///
    		if _n>=2 & touse==1
    
    * Depreciation rates
    
    bys firm_id touse (year): gen depreciation = ///
    	DEPR / (TFAS[_n-1] + DEPR) ///
    		if _n>=2 & touse==1
    	
    * Starting value of real capital stock
    
    bys firm_id touse (year): gen K = ///
    	TFAS / unit_GFCP ///
    		if _n==1 & touse==1
    	
    * Accumulate real capital stock from real investment + depreciated lag value
    
    bys firm_id touse (year): replace K = ///
    	(1 - depreciation) * K[_n-1] + investment ///
    		if _n>=2 & touse==1
    
    * Exclude big jumps in capital stock
    
    foreach var in K {
        
    	* Exclude negative values
    	
		replace `var' = . if `var' < 0
    	
    	* Exclude large decreases upon entry
    	
		bys firm_id (touse year): ///
			drop if `var' > `var'[_n+1] * 10 ///
				& `var' > `var'[_n+2] * 10 ///
				& `var'!=. & _n==1
    	
    	* Exclude big increases
		
		bys firm_id (year): ///
			drop if `var' > `var'[_n+1] * 50 ///
				& `var' > `var'[_n-1] * 50 ///
				& `var'!=.
    	
    	* Exclude big decreases
		
		bys firm_id (year): ///
			drop if `var' < `var'[_n+1] / 50 ///
				& `var' < `var'[_n-1] / 50 ///
				& `var'[_n+1]!=. & `var'[_n-1]!=. ///
				& `var'!=.
    				
    }
    
    drop touse depreciation investment 
    
    * Deflate capital variables with Gross Fixed Capital Formation Deflator
    
    foreach var in $capitalvars {
        
    	replace `var' = `var' / unit_GFCP
    }
    drop unit_GFCP
    
    * Deflate financial variables with Gross Value Added Deflator
    
    foreach var in $financialvars {
        
    	replace `var' = `var' / unit_VALP
    }
    drop unit_VALP
    
    compress
    
    * Value added
    
    gen VA = OPRE - MATL
    
    * Drop observations with < 0 value added
    
    drop if VA < 0
    
    * Liabilities
    
    gen liabilities = TSHF - SHDF
    
    * Drop observations with <= 0 liabilities
    
    drop if liabilities<=0
    drop liabilities
    
    * Winsorize variables at 1 percentile
    
    foreach var in VA TFAS WAGE OPRE MATL TOAS FIAS {
        
    	winsor2 `var', replace cuts(1 99)
    }
    
    * Fill in gaps in panel
    
    xtset firm_id year
    
    count
    tsfill
    count
    
    preserve
        
    	keep firm_id BvD_ID_number _iso2c_ SIC* NAICS* NACE* nace2_2 listed 
    	
    	drop if mi(BvD_ID_number)
    	duplicates drop
    	
    	tempfile _tmp
    	save `_tmp'
    	
    restore
    
    drop BvD_ID_number _iso2c_ SIC* NAICS* NACE* nace2_2 listed
    
    merge m:1 firm_id using `_tmp', nogen ///
    	keepusing(BvD_ID_number _iso2c_ SIC* NAICS* NACE* nace2_2 listed)
    	
    xtset firm_id year
    bys firm_id (year): replace age = age[_n-1] + 1 if mi(age)
    
    ds TOAS OPRE EMPL WAGE SALE MATL ///
        FIAS TFAS K IFAS CUAS CULI NCLI CSFL AV EBITDA 
    loc tmpvars `r(varlist)'
    
    preserve
        
        keep firm_id year `tmpvars'
        
        foreach var in `tmpvars' {
        	
        	xtset firm_id year
        	
        	bys firm_id (year): ipolate `var' year, gen(i`var')
        	
        	replace `var' = i`var' if mi(`var') & !mi(i`var')
        	drop i`var'
        }
        
        compress
        tempfile _tmp
        save `_tmp'
        
    restore
    
    drop `tmpvars' 
    merge m:1 firm_id year using `_tmp', nogen keep(1 3) keepusing(`tmpvars') 
    
    * Externally imputed wages
    
    gen LABR_EMPE = (LABR * 10^6) / (EMPE * 10^3)
    gen WAGE_imp = LABR_EMPE * EMPL
    
    if "`country'"=="GR" {
        replace WAGE = WAGE_imp
    }
    drop LABR EMPE LABR_EMPE
    
    * Value added imputed by cost of employees + ebitda
    
    gen VA_imp = WAGE + EBITDA
    replace VA_imp = AV if !mi(AV)

    * Materials imputed by the difference between operating revenue and added value 
    
    gen MATL_imp = OPRE - VA_imp
    replace MATL_imp = MATL if !mi(MATL)

    * Fill in gaps in panel
    
    ds VA_imp MATL_imp
    
    foreach var in `r(varlist)' {
    	
    	preserve
        	
        	keep firm_id year `var'
        	xtset firm_id year
        	
        	bys firm_id (year): ipolate `var' year, gen(i`var') 
        	
        	replace `var' = i`var' if mi(`var') & !mi(i`var')
        	drop i`var'
        	
        	drop if mi(`var')
        	
        	compress
        	tempfile _tmp
        	save `_tmp'
        	
    	restore
    	
    	drop `var'
    	merge m:1 firm_id year using `_tmp', nogen keep(1 3) keepusing(`var') 
    }
    
    keep BvD_ID_number age year _iso2c_ SIC3 NAICS4 NACE4 listed ///
        TOAS OPRE SALE VA_imp EMPL WAGE FIAS TFAS K IFAS MATL_imp ///
        CUAS CULI NCLI CSFL EBITDA
    		
    compress
    save "../data/cleaned/orbis_`country'.dta", replace
    
} // end country loop
