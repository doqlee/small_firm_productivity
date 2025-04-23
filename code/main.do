clear all
macro drop _all
set more off
sysdir set PLUS ./ado/
set max_memory 64g

* List of countries

global clist "BE CZ DE DK EE ES FI FR GB GR IT NL NO PL PT SE SI SK"

* List of firm-level control variables

global controls ///
	leverage_pre4yrBal /// leverage 
	CULI_OPRE_pre4yrBal /// debt maturity 
	CS_TA_pre4yrBal /// cash flow
	CUAS_CULI_pre4yrBal /// liquidity 
	ln_EBITDA_pre4yrBal // profitability

* Order of commands to replicate paper

do clean_stan // Deflators from OECD STAN (Public data)
do clean_ppp // Industry level PPP (Public data)
do clean_exchange_rates // Exchange rates (Public data)
*do clean_shr_relationship // Relationship bank share (Restricted data)

*do download_orbis // SQL query to download orbis data (Restricted data)
do clean_orbis // Clean orbis data (Restricted data)
do clean_patent_app // Patent applications (Restricted data)

do estimate_tfp // Estimate firm-level TFP
do make_did_sample // Prepare variables for DiD regressions
do clean_fitch // Tier 1 capital ratio from Fitch Connect (Restricted data)
do clean_markit // Bank CDS spreads from Markit (Restricted data)
do merge_did_sample // Combine all variables into a single data file

do figure_1
do table_1
do table_2
do table_3
do table_4
do table_5
