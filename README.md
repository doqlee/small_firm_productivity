# Small and Vulnerable: SME Productivity in the Great Productivity Slowdown

Sophia Chen (IMF), Do Lee (New York University)  
September 11, 2022

This repository contains the replication package for the paper *“Small and Vulnerable: SME Productivity in the Great Productivity Slowdown.”* It includes Stata code, data cleaning scripts, and output files. The code is written for **Stata MP version 14**.

## Instructions for Replication

1. Place the **restricted data files** in `./data/raw/` as described in Section 3.2 below.
2. Run the master script:
   ```
   ./code/main.do
   ```
3. This will generate:
   - Figures in `./figures/`
   - Tables in `./tables/`

## Output

- **Figures**:  
  `figure 1.pdf` is produced by `figure 1.do` using `sample_tfp_2008.dta`, an annual firm-level TFP panel from Orbis.

- **Tables**:  
  `table#.tex` files are generated from `table#.do` using `sample_did.dta`, a firm-level dataset used for DiD regressions.

## Data Overview

### Publicly Available Data

1. **BIS Exchange Rates**  
   - Source: [BIS](https://www.bis.org/statistics/full_xru_csv.zip)  
   - File: `exchange_rates/WEBSTATS_XRU_CURRENT_DATAFLOW_csv_col.csv`  
   - Script: `clean_exchange_rates.do`  
   - Used to convert USD variables in Orbis to local currency

2. **OECD STAN Local Currency Deflators**  
   - Source: [OECD STAN Database](https://www.oecd.org/sti/ind/stanstructuralanalysisdatabase.htm)  
   - File: `stan/STANI4_2020.csv`  
   - Script: `clean_stan.do`  
   - Produces: `STANI4_2020_NACE2.dta`

3. **PPP Exchange Rates (2005 Benchmark)**  
   - Source: [Inklaar et al. 2005](http://onlinelibrary.wiley.com/doi/10.1111/roiw.12012/abstract)  
   - File: `ppp/benchmark_2005.xlsx`  
   - Script: `clean_ppp.do`  
   - Used to convert local currency to 2005 USD

### Restricted Data

> These datasets are not included due to copyright/confidentiality. The replication code will run with **pseudo-data**, which mimics the structure but not the values of the actual data.

1. **Orbis Historical Database** (`orbis/`)  
   - Raw firm-level data (financials, industry codes, legal info)  
   - Country-specific `.dta` files indexed by ISO code

2. **Firm-Bank Relationships** (`orbis/Banker.dta`)  
   - AMADEUS data on firms' main creditors  
   - Used to link with bank-level financials

3. **Fitch Connect** (`fitch/bnk_hist_usd.dta`)  
   - Bank-level capital data  
   - Processed by `clean_fitch.do`

4. **Markit CDS** (`markit/markit.dta`)  
   - End-of-day 5-year CDS spreads  
   - Processed by `clean_markit.do`

5. **BEPS II Survey Data** (`bepsii/`)  
   - Bank relationship classifications (from Beck et al. 2018)  
   - Used in `clean_relationship_bank_share.do`

6. **PATSTAT** (`patstat/patent_app.dta`)  
   - Firm-level patent applications  
   - Matched to Orbis and used in `table 5.do`

## Data Cleaning Procedures

1. **Orbis Data Cleaning**  
   - Script: `clean_orbis.do`  
   - Output: `cleaned_orbis_##.dta` (firm-year panel by country)

2. **Productivity Estimation**  
   - Script: `estimate_tfp.do`  
   - Output: `sample_tfp_2008.dta`

3. **Final DiD Sample Construction**  
   - Scripts: `make_did_sample.do`, `merge_did_sample.do`  
   - Output: `sample_did.dta`  
   - Aggregates firm-level data over pre- (2004–2007) and post-crisis (2008–2011) periods

## References

- Beck, Thorsten, et al. (2018). *"When arm’s length is too far: Relationship banking over the credit cycle."* *Journal of Financial Economics*, 127(1): 174–196.  
- Inklaar, Robert, et al. (2005). *"ICT and Europe’s productivity performance."* *Review of Income and Wealth*, 51(4): 505–536.

## Contact

- Sophia Chen (IMF): [ychen2@imf.org](mailto:ychen2@imf.org)  
- Do Lee (NYU): [dql204@nyu.edu](mailto:dql204@nyu.edu)
