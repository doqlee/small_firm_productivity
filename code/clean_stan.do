* OECD STAN Database for Structural Analysis (ISIC Rev. 4 SNA08)
* Price deflators for cleaning Orbis data

insheet using "../data/raw/stan/STANI4_2020.csv", comma clear names

ren location cou

ren time year
tab year if !mi(value), m

compress

* Wide format

gen varlabel = var

preserve
	
	keep var varlabel // variable labels
	duplicates drop
	
	vallist var, local(vlist)
	foreach vv in `vlist' {
		vallist varlabel if var=="`vv'", local(lab_`vv')
	}
	
restore

keep cou ind year value var

reshape wide value, i(cou ind year) j(var) string
ren value* *

foreach vv in `vlist' {
	lab var `vv' "`lab_`vv''"
}

sort cou ind year
compress
save "../data/cleaned/STANI4_2020_WIDE.dta", replace

* ISIC Rev. 4 to NACE Rev. 2 crosswalk

insheet using "../data/raw/stan/isic_rev4_to_nace_rev2.csv", comma clear names
ren source isic4
ren target nace2
compress
save "../data/cleaned/isic_rev4_to_nace_rev2.dta", replace

* NACE Rev. 2 to ISIC Rev. 4 crosswalk

insheet using "../data/raw/stan/nace_rev2_to_isic_rev4.csv", comma clear names
ren source nace2
ren target isic4
compress
save "../data/cleaned/nace_rev2_to_isic_rev4.dta", replace

*** Construct STAN database at 2-digit ISIC Rev. 4 level

use "../data/cleaned/isic_rev4_to_nace_rev2.dta", clear

keep if length(isic4)<=2
keep if !regexm(nace2, "\.")
keep if !regexm(isic4, "[A-Z]")
count if isic4!=nace2

replace isic4 = "0" + isic4 if length(isic4)==1
replace isic4 = "D" + isic4

* ISIC Rev. 4 industries at various levels of aggregation

gen ind1 = ""
replace ind1 = "D01" if isic4=="D01"
replace ind1 = "D02" if isic4=="D02"
replace ind1 = "D03" if isic4=="D03"
replace ind1 = "D05T06" if isic4=="D05"
replace ind1 = "D05T06" if isic4=="D06"
replace ind1 = "D07T08" if isic4=="D07"
replace ind1 = "D07T08" if isic4=="D08"
replace ind1 = "D09" if isic4=="D09"
replace ind1 = "D10" if isic4=="D10"
replace ind1 = "D11" if isic4=="D11"
replace ind1 = "D12" if isic4=="D12"
replace ind1 = "D13" if isic4=="D13"
replace ind1 = "D14" if isic4=="D14"
replace ind1 = "D15" if isic4=="D15"
replace ind1 = "D16" if isic4=="D16"
replace ind1 = "D17" if isic4=="D17"
replace ind1 = "D18" if isic4=="D18"
replace ind1 = "D19" if isic4=="D19"
replace ind1 = "D20" if isic4=="D20"
replace ind1 = "D21" if isic4=="D21"
replace ind1 = "D22" if isic4=="D22"
replace ind1 = "D23" if isic4=="D23"
replace ind1 = "D24" if isic4=="D24"
replace ind1 = "D25" if isic4=="D25"
replace ind1 = "D26" if isic4=="D26"
replace ind1 = "D27" if isic4=="D27"
replace ind1 = "D28" if isic4=="D28"
replace ind1 = "D29" if isic4=="D29"
replace ind1 = "D30" if isic4=="D30"
replace ind1 = "D31T32" if isic4=="D31"
replace ind1 = "D31T32" if isic4=="D32"
replace ind1 = "D33" if isic4=="D33"
replace ind1 = "D35" if isic4=="D35"
replace ind1 = "D36" if isic4=="D36"
replace ind1 = "D37T39" if isic4=="D37"
replace ind1 = "D37T39" if isic4=="D38"
replace ind1 = "D37T39" if isic4=="D39"
replace ind1 = "D41T43" if isic4=="D41"
replace ind1 = "D41T43" if isic4=="D42"
replace ind1 = "D41T43" if isic4=="D43"
replace ind1 = "D45" if isic4=="D45"
replace ind1 = "D46" if isic4=="D46"
replace ind1 = "D47" if isic4=="D47"
replace ind1 = "D49" if isic4=="D49"
replace ind1 = "D50" if isic4=="D50"
replace ind1 = "D51" if isic4=="D51"
replace ind1 = "D52" if isic4=="D52"
replace ind1 = "D53" if isic4=="D53"
replace ind1 = "D55" if isic4=="D55"
replace ind1 = "D56" if isic4=="D56"
replace ind1 = "D58" if isic4=="D58"
replace ind1 = "D59T60" if isic4=="D59"
replace ind1 = "D59T60" if isic4=="D60"
replace ind1 = "D61" if isic4=="D61"
replace ind1 = "D62" if isic4=="D62"
replace ind1 = "D63" if isic4=="D63"
replace ind1 = "D64" if isic4=="D64"
replace ind1 = "D65" if isic4=="D65"
replace ind1 = "D66" if isic4=="D66"
replace ind1 = "D68" if isic4=="D68"
replace ind1 = "D69" if isic4=="D69"
replace ind1 = "D70" if isic4=="D70"
replace ind1 = "D71" if isic4=="D71"
replace ind1 = "D72" if isic4=="D72"
replace ind1 = "D73" if isic4=="D73"
replace ind1 = "D74" if isic4=="D74"
replace ind1 = "D75" if isic4=="D75"
replace ind1 = "D77" if isic4=="D77"
replace ind1 = "D78" if isic4=="D78"
replace ind1 = "D79" if isic4=="D79"
replace ind1 = "D80T82" if isic4=="D80"
replace ind1 = "D80T82" if isic4=="D81"
replace ind1 = "D80T82" if isic4=="D82"
replace ind1 = "D84" if isic4=="D84"
replace ind1 = "D85" if isic4=="D85"
replace ind1 = "D86" if isic4=="D86"
replace ind1 = "D87T88" if isic4=="D87"
replace ind1 = "D87T88" if isic4=="D88"
replace ind1 = "D90T92" if isic4=="D90"
replace ind1 = "D90T92" if isic4=="D91"
replace ind1 = "D90T92" if isic4=="D92"
replace ind1 = "D93" if isic4=="D93"
replace ind1 = "D94" if isic4=="D94"
replace ind1 = "D95" if isic4=="D95"
replace ind1 = "D96" if isic4=="D96"
replace ind1 = "D97" if isic4=="D97"
replace ind1 = "D98" if isic4=="D98"
replace ind1 = "D99" if isic4=="D99"

gen ind2 = ""
replace ind2 = "D01T02" if isic4=="D01"
replace ind2 = "D01T02" if isic4=="D02"
replace ind2 = "D01T03" if isic4=="D03"
replace ind2 = "D05T09" if isic4=="D05"
replace ind2 = "D05T09" if isic4=="D06"
replace ind2 = "D05T09" if isic4=="D07"
replace ind2 = "D05T09" if isic4=="D08"
replace ind2 = "D05T09" if isic4=="D09"
replace ind2 = "D10T11" if isic4=="D10"
replace ind2 = "D10T11" if isic4=="D11"
replace ind2 = "D10T12" if isic4=="D12"
replace ind2 = "D13T14" if isic4=="D13"
replace ind2 = "D13T14" if isic4=="D14"
replace ind2 = "D13T15" if isic4=="D15"
replace ind2 = "D16T18" if isic4=="D16"
replace ind2 = "D16T18" if isic4=="D17"
replace ind2 = "D16T18" if isic4=="D18"
replace ind2 = "D19T23" if isic4=="D19"
replace ind2 = "D20T21" if isic4=="D20"
replace ind2 = "D20T21" if isic4=="D21"
replace ind2 = "D22T23" if isic4=="D22"
replace ind2 = "D22T23" if isic4=="D23"
replace ind2 = "D24T25" if isic4=="D24"
replace ind2 = "D24T25" if isic4=="D25"
replace ind2 = "D26T27" if isic4=="D26"
replace ind2 = "D26T27" if isic4=="D27"
replace ind2 = "D26T28" if isic4=="D28"
replace ind2 = "D29T30" if isic4=="D29"
replace ind2 = "D29T30" if isic4=="D30"
replace ind2 = "D31T33" if isic4=="D31"
replace ind2 = "D31T33" if isic4=="D32"
replace ind2 = "D31T33" if isic4=="D33"
replace ind2 = "D35T39" if isic4=="D35"
replace ind2 = "D36T39" if isic4=="D36"
replace ind2 = "D36T39" if isic4=="D37"
replace ind2 = "D36T39" if isic4=="D38"
replace ind2 = "D36T39" if isic4=="D39"
replace ind2 = "D05T82X" if isic4=="D41"
replace ind2 = "D05T82X" if isic4=="D42"
replace ind2 = "D05T82X" if isic4=="D43"
replace ind2 = "D45T47" if isic4=="D45"
replace ind2 = "D45T47" if isic4=="D46"
replace ind2 = "D45T47" if isic4=="D47"
replace ind2 = "D49T53" if isic4=="D49"
replace ind2 = "D49T53" if isic4=="D50"
replace ind2 = "D49T53" if isic4=="D51"
replace ind2 = "D49T53" if isic4=="D52"
replace ind2 = "D49T53" if isic4=="D53"
replace ind2 = "D55T56" if isic4=="D55"
replace ind2 = "D55T56" if isic4=="D56"
replace ind2 = "D58T60" if isic4=="D58"
replace ind2 = "D58T60" if isic4=="D59"
replace ind2 = "D58T60" if isic4=="D60"
replace ind2 = "D58T63" if isic4=="D61"
replace ind2 = "D62T63" if isic4=="D62"
replace ind2 = "D62T63" if isic4=="D63"
replace ind2 = "D64T66" if isic4=="D64"
replace ind2 = "D64T66" if isic4=="D65"
replace ind2 = "D64T66" if isic4=="D66"
replace ind2 = "D68A" if isic4=="D68"
replace ind2 = "D69T70" if isic4=="D69"
replace ind2 = "D69T70" if isic4=="D70"
replace ind2 = "D69T71" if isic4=="D71"
replace ind2 = "D69T75" if isic4=="D72"
replace ind2 = "D73T75" if isic4=="D73"
replace ind2 = "D74T75" if isic4=="D74"
replace ind2 = "D74T75" if isic4=="D75"
replace ind2 = "D77T82" if isic4=="D77"
replace ind2 = "D77T82" if isic4=="D78"
replace ind2 = "D77T82" if isic4=="D79"
replace ind2 = "D77T82" if isic4=="D80"
replace ind2 = "D77T82" if isic4=="D81"
replace ind2 = "D77T82" if isic4=="D82"
replace ind2 = "D84T88" if isic4=="D84"
replace ind2 = "D84T88" if isic4=="D85"
replace ind2 = "D86T88" if isic4=="D86"
replace ind2 = "D86T88" if isic4=="D87"
replace ind2 = "D86T88" if isic4=="D88"
replace ind2 = "D90T93" if isic4=="D90"
replace ind2 = "D90T93" if isic4=="D91"
replace ind2 = "D90T93" if isic4=="D92"
replace ind2 = "D90T93" if isic4=="D93"
replace ind2 = "D94T96" if isic4=="D94"
replace ind2 = "D94T96" if isic4=="D95"
replace ind2 = "D94T96" if isic4=="D96"
replace ind2 = "D97T98" if isic4=="D97"
replace ind2 = "D97T98" if isic4=="D98"
replace ind2 = "D90T99" if isic4=="D99"

gen ind3 = ""
replace ind3 = "D01T99" if isic4=="D01"
replace ind3 = "D01T99" if isic4=="D02"
replace ind3 = "D01T99" if isic4=="D03"
replace ind3 = "D05T39" if isic4=="D05"
replace ind3 = "D05T39" if isic4=="D06"
replace ind3 = "D05T39" if isic4=="D07"
replace ind3 = "D05T39" if isic4=="D08"
replace ind3 = "D05T39" if isic4=="D09"
replace ind3 = "D10T12" if isic4=="D10"
replace ind3 = "D10T12" if isic4=="D11"
replace ind3 = "D10T33" if isic4=="D12"
replace ind3 = "D13T15" if isic4=="D13"
replace ind3 = "D13T15" if isic4=="D14"
replace ind3 = "D10T33" if isic4=="D15"
replace ind3 = "D10T33" if isic4=="D16"
replace ind3 = "D10T33" if isic4=="D17"
replace ind3 = "D10T33" if isic4=="D18"
replace ind3 = "D10T33" if isic4=="D19"
replace ind3 = "D10T33" if isic4=="D20"
replace ind3 = "D10T33" if isic4=="D21"
replace ind3 = "D10T33" if isic4=="D22"
replace ind3 = "D10T33" if isic4=="D23"
replace ind3 = "D10T33" if isic4=="D24"
replace ind3 = "D10T33" if isic4=="D25"
replace ind3 = "D26T28" if isic4=="D26"
replace ind3 = "D26T28" if isic4=="D27"
replace ind3 = "D10T33" if isic4=="D28"
replace ind3 = "D10T33" if isic4=="D29"
replace ind3 = "D10T33" if isic4=="D30"
replace ind3 = "D10T33" if isic4=="D31"
replace ind3 = "D10T33" if isic4=="D32"
replace ind3 = "D10T33" if isic4=="D33"
replace ind3 = "D05T39" if isic4=="D35"
replace ind3 = "D35T39" if isic4=="D36"
replace ind3 = "D35T39" if isic4=="D37"
replace ind3 = "D35T39" if isic4=="D38"
replace ind3 = "D35T39" if isic4=="D39"
replace ind3 = "D01T99" if isic4=="D41"
replace ind3 = "D01T99" if isic4=="D42"
replace ind3 = "D01T99" if isic4=="D43"
replace ind3 = "D45T56" if isic4=="D45"
replace ind3 = "D45T56" if isic4=="D46"
replace ind3 = "D45T56" if isic4=="D47"
replace ind3 = "D45T56" if isic4=="D49"
replace ind3 = "D45T56" if isic4=="D50"
replace ind3 = "D45T56" if isic4=="D51"
replace ind3 = "D45T56" if isic4=="D52"
replace ind3 = "D45T56" if isic4=="D53"
replace ind3 = "D45T56" if isic4=="D55"
replace ind3 = "D45T56" if isic4=="D56"
replace ind3 = "D58T63" if isic4=="D58"
replace ind3 = "D58T63" if isic4=="D59"
replace ind3 = "D58T63" if isic4=="D60"
replace ind3 = "D45T82" if isic4=="D61"
replace ind3 = "D45T82" if isic4=="D62"
replace ind3 = "D45T82" if isic4=="D63"
replace ind3 = "D45T82" if isic4=="D64"
replace ind3 = "D45T82" if isic4=="D65"
replace ind3 = "D45T82" if isic4=="D66"
replace ind3 = "D68T82" if isic4=="D68"
replace ind3 = "D69T71" if isic4=="D69"
replace ind3 = "D69T71" if isic4=="D70"
replace ind3 = "D69T75" if isic4=="D71"
replace ind3 = "D69T82" if isic4=="D72"
replace ind3 = "D69T82" if isic4=="D73"
replace ind3 = "D69T82" if isic4=="D74"
replace ind3 = "D69T82" if isic4=="D75"
replace ind3 = "D69T82" if isic4=="D77"
replace ind3 = "D69T82" if isic4=="D78"
replace ind3 = "D69T82" if isic4=="D79"
replace ind3 = "D69T82" if isic4=="D80"
replace ind3 = "D69T82" if isic4=="D81"
replace ind3 = "D69T82" if isic4=="D82"
replace ind3 = "D84T99" if isic4=="D84"
replace ind3 = "D84T99" if isic4=="D85"
replace ind3 = "D84T88" if isic4=="D86"
replace ind3 = "D84T88" if isic4=="D87"
replace ind3 = "D84T88" if isic4=="D88"
replace ind3 = "D90T99" if isic4=="D90"
replace ind3 = "D90T99" if isic4=="D91"
replace ind3 = "D90T99" if isic4=="D92"
replace ind3 = "D90T99" if isic4=="D93"
replace ind3 = "D90T99" if isic4=="D94"
replace ind3 = "D90T99" if isic4=="D95"
replace ind3 = "D90T99" if isic4=="D96"
replace ind3 = "D90T99" if isic4=="D97"
replace ind3 = "D90T99" if isic4=="D98"
replace ind3 = "D84T99" if isic4=="D99"

gen ind4 = ""
replace ind4 = "D01T99" if isic4=="D01"
replace ind4 = "D01T99" if isic4=="D02"
replace ind4 = "D01T99" if isic4=="D03"
replace ind4 = "D05T82X" if isic4=="D05"
replace ind4 = "D05T82X" if isic4=="D06"
replace ind4 = "D05T82X" if isic4=="D07"
replace ind4 = "D05T82X" if isic4=="D08"
replace ind4 = "D05T82X" if isic4=="D09"
replace ind4 = "D10T33" if isic4=="D10"
replace ind4 = "D10T33" if isic4=="D11"
replace ind4 = "D05T39" if isic4=="D12"
replace ind4 = "D10T33" if isic4=="D13"
replace ind4 = "D10T33" if isic4=="D14"
replace ind4 = "D05T39" if isic4=="D15"
replace ind4 = "D05T39" if isic4=="D16"
replace ind4 = "D05T39" if isic4=="D17"
replace ind4 = "D05T39" if isic4=="D18"
replace ind4 = "D05T39" if isic4=="D19"
replace ind4 = "D05T39" if isic4=="D20"
replace ind4 = "D05T39" if isic4=="D21"
replace ind4 = "D05T39" if isic4=="D22"
replace ind4 = "D05T39" if isic4=="D23"
replace ind4 = "D05T39" if isic4=="D24"
replace ind4 = "D05T39" if isic4=="D25"
replace ind4 = "D10T33" if isic4=="D26"
replace ind4 = "D10T33" if isic4=="D27"
replace ind4 = "D05T39" if isic4=="D28"
replace ind4 = "D05T39" if isic4=="D29"
replace ind4 = "D05T39" if isic4=="D30"
replace ind4 = "D05T39" if isic4=="D31"
replace ind4 = "D05T39" if isic4=="D32"
replace ind4 = "D05T39" if isic4=="D33"
replace ind4 = "D05T82X" if isic4=="D35"
replace ind4 = "D05T39" if isic4=="D36"
replace ind4 = "D05T39" if isic4=="D37"
replace ind4 = "D05T39" if isic4=="D38"
replace ind4 = "D05T39" if isic4=="D39"
replace ind4 = "D01T99" if isic4=="D41"
replace ind4 = "D01T99" if isic4=="D42"
replace ind4 = "D01T99" if isic4=="D43"
replace ind4 = "D45T82" if isic4=="D45"
replace ind4 = "D45T82" if isic4=="D46"
replace ind4 = "D45T82" if isic4=="D47"
replace ind4 = "D45T82" if isic4=="D49"
replace ind4 = "D45T82" if isic4=="D50"
replace ind4 = "D45T82" if isic4=="D51"
replace ind4 = "D45T82" if isic4=="D52"
replace ind4 = "D45T82" if isic4=="D53"
replace ind4 = "D45T82" if isic4=="D55"
replace ind4 = "D45T82" if isic4=="D56"
replace ind4 = "D45T82" if isic4=="D58"
replace ind4 = "D45T82" if isic4=="D59"
replace ind4 = "D45T82" if isic4=="D60"
replace ind4 = "D05T82X" if isic4=="D61"
replace ind4 = "D05T82X" if isic4=="D62"
replace ind4 = "D05T82X" if isic4=="D63"
replace ind4 = "D05T82X" if isic4=="D64"
replace ind4 = "D05T82X" if isic4=="D65"
replace ind4 = "D05T82X" if isic4=="D66"
replace ind4 = "D05T82X" if isic4=="D68"
replace ind4 = "D69T75" if isic4=="D69"
replace ind4 = "D69T75" if isic4=="D70"
replace ind4 = "D69T82" if isic4=="D71"
replace ind4 = "D68T82" if isic4=="D72"
replace ind4 = "D68T82" if isic4=="D73"
replace ind4 = "D68T82" if isic4=="D74"
replace ind4 = "D68T82" if isic4=="D75"
replace ind4 = "D68T82" if isic4=="D77"
replace ind4 = "D68T82" if isic4=="D78"
replace ind4 = "D68T82" if isic4=="D79"
replace ind4 = "D68T82" if isic4=="D80"
replace ind4 = "D68T82" if isic4=="D81"
replace ind4 = "D68T82" if isic4=="D82"
replace ind4 = "D45T99" if isic4=="D84"
replace ind4 = "D45T99" if isic4=="D85"
replace ind4 = "D84T99" if isic4=="D86"
replace ind4 = "D84T99" if isic4=="D87"
replace ind4 = "D84T99" if isic4=="D88"
replace ind4 = "D84T99" if isic4=="D90"
replace ind4 = "D84T99" if isic4=="D91"
replace ind4 = "D84T99" if isic4=="D92"
replace ind4 = "D84T99" if isic4=="D93"
replace ind4 = "D84T99" if isic4=="D94"
replace ind4 = "D84T99" if isic4=="D95"
replace ind4 = "D84T99" if isic4=="D96"
replace ind4 = "D84T99" if isic4=="D97"
replace ind4 = "D84T99" if isic4=="D98"
replace ind4 = "D45T99" if isic4=="D99"

gen ind5 = ""
replace ind5 = "D01T99" if isic4=="D01"
replace ind5 = "D01T99" if isic4=="D02"
replace ind5 = "D01T99" if isic4=="D03"
replace ind5 = "D01T99" if isic4=="D05"
replace ind5 = "D01T99" if isic4=="D06"
replace ind5 = "D01T99" if isic4=="D07"
replace ind5 = "D01T99" if isic4=="D08"
replace ind5 = "D01T99" if isic4=="D09"
replace ind5 = "D05T39" if isic4=="D10"
replace ind5 = "D05T39" if isic4=="D11"
replace ind5 = "D05T82X" if isic4=="D12"
replace ind5 = "D05T39" if isic4=="D13"
replace ind5 = "D05T39" if isic4=="D14"
replace ind5 = "D05T82X" if isic4=="D15"
replace ind5 = "D05T82X" if isic4=="D16"
replace ind5 = "D05T82X" if isic4=="D17"
replace ind5 = "D05T82X" if isic4=="D18"
replace ind5 = "D05T82X" if isic4=="D19"
replace ind5 = "D05T82X" if isic4=="D20"
replace ind5 = "D05T82X" if isic4=="D21"
replace ind5 = "D05T82X" if isic4=="D22"
replace ind5 = "D05T82X" if isic4=="D23"
replace ind5 = "D05T82X" if isic4=="D24"
replace ind5 = "D05T82X" if isic4=="D25"
replace ind5 = "D05T39" if isic4=="D26"
replace ind5 = "D05T39" if isic4=="D27"
replace ind5 = "D05T82X" if isic4=="D28"
replace ind5 = "D05T82X" if isic4=="D29"
replace ind5 = "D05T82X" if isic4=="D30"
replace ind5 = "D05T82X" if isic4=="D31"
replace ind5 = "D05T82X" if isic4=="D32"
replace ind5 = "D05T82X" if isic4=="D33"
replace ind5 = "D01T99" if isic4=="D35"
replace ind5 = "D05T82X" if isic4=="D36"
replace ind5 = "D05T82X" if isic4=="D37"
replace ind5 = "D05T82X" if isic4=="D38"
replace ind5 = "D05T82X" if isic4=="D39"
replace ind5 = "D01T99" if isic4=="D41"
replace ind5 = "D01T99" if isic4=="D42"
replace ind5 = "D01T99" if isic4=="D43"
replace ind5 = "D45T99" if isic4=="D45"
replace ind5 = "D45T99" if isic4=="D46"
replace ind5 = "D45T99" if isic4=="D47"
replace ind5 = "D45T99" if isic4=="D49"
replace ind5 = "D45T99" if isic4=="D50"
replace ind5 = "D45T99" if isic4=="D51"
replace ind5 = "D45T99" if isic4=="D52"
replace ind5 = "D45T99" if isic4=="D53"
replace ind5 = "D45T99" if isic4=="D55"
replace ind5 = "D45T99" if isic4=="D56"
replace ind5 = "D45T99" if isic4=="D58"
replace ind5 = "D45T99" if isic4=="D59"
replace ind5 = "D45T99" if isic4=="D60"
replace ind5 = "D01T99" if isic4=="D61"
replace ind5 = "D01T99" if isic4=="D62"
replace ind5 = "D01T99" if isic4=="D63"
replace ind5 = "D01T99" if isic4=="D64"
replace ind5 = "D01T99" if isic4=="D65"
replace ind5 = "D01T99" if isic4=="D66"
replace ind5 = "D01T99" if isic4=="D68"
replace ind5 = "D69T82" if isic4=="D69"
replace ind5 = "D69T82" if isic4=="D70"
replace ind5 = "D68T82" if isic4=="D71"
replace ind5 = "D45T99" if isic4=="D72"
replace ind5 = "D45T99" if isic4=="D73"
replace ind5 = "D45T99" if isic4=="D74"
replace ind5 = "D45T99" if isic4=="D75"
replace ind5 = "D45T99" if isic4=="D77"
replace ind5 = "D45T99" if isic4=="D78"
replace ind5 = "D45T99" if isic4=="D79"
replace ind5 = "D45T99" if isic4=="D80"
replace ind5 = "D45T99" if isic4=="D81"
replace ind5 = "D45T99" if isic4=="D82"
replace ind5 = "D01T99" if isic4=="D84"
replace ind5 = "D01T99" if isic4=="D85"
replace ind5 = "D01T99" if isic4=="D86"
replace ind5 = "D01T99" if isic4=="D87"
replace ind5 = "D01T99" if isic4=="D88"
replace ind5 = "D01T99" if isic4=="D90"
replace ind5 = "D01T99" if isic4=="D91"
replace ind5 = "D01T99" if isic4=="D92"
replace ind5 = "D01T99" if isic4=="D93"
replace ind5 = "D01T99" if isic4=="D94"
replace ind5 = "D01T99" if isic4=="D95"
replace ind5 = "D01T99" if isic4=="D96"
replace ind5 = "D01T99" if isic4=="D97"
replace ind5 = "D01T99" if isic4=="D98"
replace ind5 = "D84T99" if isic4=="D99"

gen ind6 = ""
replace ind6 = "D01T99" if isic4=="D01"
replace ind6 = "D01T99" if isic4=="D02"
replace ind6 = "D01T99" if isic4=="D03"
replace ind6 = "D01T99" if isic4=="D05"
replace ind6 = "D01T99" if isic4=="D06"
replace ind6 = "D01T99" if isic4=="D07"
replace ind6 = "D01T99" if isic4=="D08"
replace ind6 = "D01T99" if isic4=="D09"
replace ind6 = "D05T82X" if isic4=="D10"
replace ind6 = "D05T82X" if isic4=="D11"
replace ind6 = "D01T99" if isic4=="D12"
replace ind6 = "D05T82X" if isic4=="D13"
replace ind6 = "D05T82X" if isic4=="D14"
replace ind6 = "D01T99" if isic4=="D15"
replace ind6 = "D01T99" if isic4=="D16"
replace ind6 = "D01T99" if isic4=="D17"
replace ind6 = "D01T99" if isic4=="D18"
replace ind6 = "D01T99" if isic4=="D19"
replace ind6 = "D01T99" if isic4=="D20"
replace ind6 = "D01T99" if isic4=="D21"
replace ind6 = "D01T99" if isic4=="D22"
replace ind6 = "D01T99" if isic4=="D23"
replace ind6 = "D01T99" if isic4=="D24"
replace ind6 = "D01T99" if isic4=="D25"
replace ind6 = "D05T82X" if isic4=="D26"
replace ind6 = "D05T82X" if isic4=="D27"
replace ind6 = "D01T99" if isic4=="D28"
replace ind6 = "D01T99" if isic4=="D29"
replace ind6 = "D01T99" if isic4=="D30"
replace ind6 = "D01T99" if isic4=="D31"
replace ind6 = "D01T99" if isic4=="D32"
replace ind6 = "D01T99" if isic4=="D33"
replace ind6 = "D01T99" if isic4=="D35"
replace ind6 = "D01T99" if isic4=="D36"
replace ind6 = "D01T99" if isic4=="D37"
replace ind6 = "D01T99" if isic4=="D38"
replace ind6 = "D01T99" if isic4=="D39"
replace ind6 = "D01T99" if isic4=="D41"
replace ind6 = "D01T99" if isic4=="D42"
replace ind6 = "D01T99" if isic4=="D43"
replace ind6 = "D01T99" if isic4=="D45"
replace ind6 = "D01T99" if isic4=="D46"
replace ind6 = "D01T99" if isic4=="D47"
replace ind6 = "D01T99" if isic4=="D49"
replace ind6 = "D01T99" if isic4=="D50"
replace ind6 = "D01T99" if isic4=="D51"
replace ind6 = "D01T99" if isic4=="D52"
replace ind6 = "D01T99" if isic4=="D53"
replace ind6 = "D01T99" if isic4=="D55"
replace ind6 = "D01T99" if isic4=="D56"
replace ind6 = "D01T99" if isic4=="D58"
replace ind6 = "D01T99" if isic4=="D59"
replace ind6 = "D01T99" if isic4=="D60"
replace ind6 = "D01T99" if isic4=="D61"
replace ind6 = "D01T99" if isic4=="D62"
replace ind6 = "D01T99" if isic4=="D63"
replace ind6 = "D01T99" if isic4=="D64"
replace ind6 = "D01T99" if isic4=="D65"
replace ind6 = "D01T99" if isic4=="D66"
replace ind6 = "D01T99" if isic4=="D68"
replace ind6 = "D45T99" if isic4=="D69"
replace ind6 = "D45T99" if isic4=="D70"
replace ind6 = "D45T99" if isic4=="D71"
replace ind6 = "D01T99" if isic4=="D72"
replace ind6 = "D01T99" if isic4=="D73"
replace ind6 = "D01T99" if isic4=="D74"
replace ind6 = "D01T99" if isic4=="D75"
replace ind6 = "D01T99" if isic4=="D77"
replace ind6 = "D01T99" if isic4=="D78"
replace ind6 = "D01T99" if isic4=="D79"
replace ind6 = "D01T99" if isic4=="D80"
replace ind6 = "D01T99" if isic4=="D81"
replace ind6 = "D01T99" if isic4=="D82"
replace ind6 = "D01T99" if isic4=="D84"
replace ind6 = "D01T99" if isic4=="D85"
replace ind6 = "D01T99" if isic4=="D86"
replace ind6 = "D01T99" if isic4=="D87"
replace ind6 = "D01T99" if isic4=="D88"
replace ind6 = "D01T99" if isic4=="D90"
replace ind6 = "D01T99" if isic4=="D91"
replace ind6 = "D01T99" if isic4=="D92"
replace ind6 = "D01T99" if isic4=="D93"
replace ind6 = "D01T99" if isic4=="D94"
replace ind6 = "D01T99" if isic4=="D95"
replace ind6 = "D01T99" if isic4=="D96"
replace ind6 = "D01T99" if isic4=="D97"
replace ind6 = "D01T99" if isic4=="D98"
replace ind6 = "D45T99" if isic4=="D99"

gen ind7 = ""
replace ind7 = "D01T99" if isic4=="D01"
replace ind7 = "D01T99" if isic4=="D02"
replace ind7 = "D01T99" if isic4=="D03"
replace ind7 = "D01T99" if isic4=="D05"
replace ind7 = "D01T99" if isic4=="D06"
replace ind7 = "D01T99" if isic4=="D07"
replace ind7 = "D01T99" if isic4=="D08"
replace ind7 = "D01T99" if isic4=="D09"
replace ind7 = "D01T99" if isic4=="D10"
replace ind7 = "D01T99" if isic4=="D11"
replace ind7 = "D01T99" if isic4=="D12"
replace ind7 = "D01T99" if isic4=="D13"
replace ind7 = "D01T99" if isic4=="D14"
replace ind7 = "D01T99" if isic4=="D15"
replace ind7 = "D01T99" if isic4=="D16"
replace ind7 = "D01T99" if isic4=="D17"
replace ind7 = "D01T99" if isic4=="D18"
replace ind7 = "D01T99" if isic4=="D19"
replace ind7 = "D01T99" if isic4=="D20"
replace ind7 = "D01T99" if isic4=="D21"
replace ind7 = "D01T99" if isic4=="D22"
replace ind7 = "D01T99" if isic4=="D23"
replace ind7 = "D01T99" if isic4=="D24"
replace ind7 = "D01T99" if isic4=="D25"
replace ind7 = "D01T99" if isic4=="D26"
replace ind7 = "D01T99" if isic4=="D27"
replace ind7 = "D01T99" if isic4=="D28"
replace ind7 = "D01T99" if isic4=="D29"
replace ind7 = "D01T99" if isic4=="D30"
replace ind7 = "D01T99" if isic4=="D31"
replace ind7 = "D01T99" if isic4=="D32"
replace ind7 = "D01T99" if isic4=="D33"
replace ind7 = "D01T99" if isic4=="D35"
replace ind7 = "D01T99" if isic4=="D36"
replace ind7 = "D01T99" if isic4=="D37"
replace ind7 = "D01T99" if isic4=="D38"
replace ind7 = "D01T99" if isic4=="D39"
replace ind7 = "D01T99" if isic4=="D41"
replace ind7 = "D01T99" if isic4=="D42"
replace ind7 = "D01T99" if isic4=="D43"
replace ind7 = "D01T99" if isic4=="D45"
replace ind7 = "D01T99" if isic4=="D46"
replace ind7 = "D01T99" if isic4=="D47"
replace ind7 = "D01T99" if isic4=="D49"
replace ind7 = "D01T99" if isic4=="D50"
replace ind7 = "D01T99" if isic4=="D51"
replace ind7 = "D01T99" if isic4=="D52"
replace ind7 = "D01T99" if isic4=="D53"
replace ind7 = "D01T99" if isic4=="D55"
replace ind7 = "D01T99" if isic4=="D56"
replace ind7 = "D01T99" if isic4=="D58"
replace ind7 = "D01T99" if isic4=="D59"
replace ind7 = "D01T99" if isic4=="D60"
replace ind7 = "D01T99" if isic4=="D61"
replace ind7 = "D01T99" if isic4=="D62"
replace ind7 = "D01T99" if isic4=="D63"
replace ind7 = "D01T99" if isic4=="D64"
replace ind7 = "D01T99" if isic4=="D65"
replace ind7 = "D01T99" if isic4=="D66"
replace ind7 = "D01T99" if isic4=="D68"
replace ind7 = "D01T99" if isic4=="D69"
replace ind7 = "D01T99" if isic4=="D70"
replace ind7 = "D01T99" if isic4=="D71"
replace ind7 = "D01T99" if isic4=="D72"
replace ind7 = "D01T99" if isic4=="D73"
replace ind7 = "D01T99" if isic4=="D74"
replace ind7 = "D01T99" if isic4=="D75"
replace ind7 = "D01T99" if isic4=="D77"
replace ind7 = "D01T99" if isic4=="D78"
replace ind7 = "D01T99" if isic4=="D79"
replace ind7 = "D01T99" if isic4=="D80"
replace ind7 = "D01T99" if isic4=="D81"
replace ind7 = "D01T99" if isic4=="D82"
replace ind7 = "D01T99" if isic4=="D84"
replace ind7 = "D01T99" if isic4=="D85"
replace ind7 = "D01T99" if isic4=="D86"
replace ind7 = "D01T99" if isic4=="D87"
replace ind7 = "D01T99" if isic4=="D88"
replace ind7 = "D01T99" if isic4=="D90"
replace ind7 = "D01T99" if isic4=="D91"
replace ind7 = "D01T99" if isic4=="D92"
replace ind7 = "D01T99" if isic4=="D93"
replace ind7 = "D01T99" if isic4=="D94"
replace ind7 = "D01T99" if isic4=="D95"
replace ind7 = "D01T99" if isic4=="D96"
replace ind7 = "D01T99" if isic4=="D97"
replace ind7 = "D01T99" if isic4=="D98"
replace ind7 = "D01T99" if isic4=="D99"

* Country X industry X year panel

preserve
	use "../data/cleaned/STANI4_2020_WIDE.dta", clear
	distinct cou
	loc ncou = r(ndistinct)
	vallist cou, local(clist)
restore

expand `ncou'

bys isic4: gen n = _n
loc cnt = 1

gen cou = ""
foreach cc in `clist' {
	bys isic4 (n): replace cou = "`cc'" if n==`cnt++'
}
drop n

gen ind = ind1
order cou ind isic4 nace2

expand (2019 - 1970 + 1)
bys cou isic4: gen year = _n + 1970 - 1

egen id = group(cou isic4)
xtset id year

preserve
    
	use "../data/cleaned/STANI4_2020_WIDE.dta", clear
	ds cou ind year, not
	global stanvars "`r(varlist)'"
	
restore

* Construct STAN variables at 2-digit ISIC Rev. 4 level

foreach vv in $stanvars {
    
    global vv `vv'
    
    * Start with most granular industry
    
    replace ind = ind1
    
    merge m:1 cou ind year using "../data/cleaned/STANI4_2020_WIDE.dta" ///
    	, nogen keep(1 3) keepusing(${vv})
    
    ren ${vv} ${vv}_ind1
    gen ${vv}0 = ${vv}_ind1
    
    forval ii = 2/7 {
        
        replace ind = ind`ii'
        	
        merge m:1 cou ind year using "../data/cleaned/STANI4_2020_WIDE.dta" ///
        	, nogen keep(1 3) keepusing(${vv})
        
        * If data missing, use data from the broader industry
        
        bys id (year): egen _cnt0 = count(${vv}0)
        bys id (year): egen _cnt1 = count(${vv})
        
        replace ${vv}0 = ${vv} if _cnt0 < _cnt1
        
        * If data too noisy, use data from the broader industry
        
        xtset id year
        gen _g = D.${vv}0 / L.${vv}0
        
        bys id (year): egen _max = max(_g)
        bys id (year): egen _min = min(_g)
        bys id (year): egen _mean = mean(_g)
        bys id (year): egen _sd = sd(_g)
        
        replace ${vv}0 = ${vv} if !mi(_g) & _max > _mean + 2 * _sd
        replace ${vv}0 = ${vv} if !mi(_g) & _min < _mean + 2 * _sd
        
        drop _cnt0 _cnt1 _g _max _min _mean _sd
        
        ren ${vv} ${vv}_ind`ii'
        
    } // end ii loop
    
    * Remove big jumps at the beginning of sample
    
    ren ${vv}0 ${vv}
    
    xtset id year
    gen _g = (${vv} - L.${vv}) / L.${vv}
    
    bys id (year): egen _max = max(_g)
    bys id (year): egen _min = min(_g)
    bys id (year): egen _mean = mean(_g)
    bys id (year): egen _sd = sd(_g)
    
    xtset id year
    replace ${vv} = . if mi(_g) & !mi(F._g) & _g > _mean + 2 * _sd
    replace ${vv} = . if mi(_g) & !mi(F._g) & F._g < _mean - 2 * _sd
    
    drop _g _max _min _mean _sd
    
    * Rescale variable into index (base year = 2005)
    
    gen _tmp = ${vv} if year==2005
    bys id: egen _base = min(_tmp)
    
    gen unit_${vv} = ${vv} / _base, after(${vv})
    
    drop _tmp _base
    
} // end vv loop

replace ind = isic4

preserve
    
	use "../data/cleaned/STANI4_2020_WIDE.dta", clear
	
	keep cou ind
	duplicates drop
	
	tempfile _tmp
	save `_tmp'
	
restore

merge m:1 cou ind using `_tmp', nogen keep(1 3)

destring nace2, gen(nace2_2)

kountry cou, from(iso3c) to(iso2c)
ren _ISO2C_ _iso2c_
order _iso2c_, before(cou)

sort _iso2c_ ind year
compress
save "../data/cleaned/STANI4_2020_NACE2.dta", replace
