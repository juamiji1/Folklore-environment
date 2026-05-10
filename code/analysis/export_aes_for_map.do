/*------------------------------------------------------------------------------
PROJECT: Folklore-environment
AUTHOR:  JMJR
TOPIC:   Build polygon-level AES (descriptive, NOT residualized) and export to
         CSV for mapping.
DATE:

NOTES: Standardizes each environmental outcome within the regression sample
       (${IF}) and averages the z-scores into `aes_z`. Result is one row per
       Ethnologue polygon (key: `id`) with ID + the standardized outcomes +
       aes_z, exported to ${maps}/aes_for_map.csv for use in the mapping
       notebook.

       Outcomes standardized: bii, sh_treecover, sh_seasonwater_base.
       Sample: hii!=. & missing_values==0 (same baseline IF as
       regressions_envmeasures_aes_natureonly.do).
------------------------------------------------------------------------------*/

clear all
set more off

*-------------------------------------------------------------------------------
* Directories (user switch)
*-------------------------------------------------------------------------------
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Measures_work"
	gl do "C:\Github\ethnographic-atlas\code"
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\data"
gl maps "${localpath}\maps"

cd "${data}"

*-------------------------------------------------------------------------------
* Load pre-prepared data
*-------------------------------------------------------------------------------
use "${data}/final/folklore_envmeasures.dta", clear

*-------------------------------------------------------------------------------
* Sample filter (mirrors the baseline regression IF)
*-------------------------------------------------------------------------------
gl depvars  "bii sh_treecover sh_seasonwater_base"
gl zdepvars "std_bii std_sh_treecover std_sh_seasonwater_base"

cap drop missing_values
egen missing_values = rowmiss(${depvars})

gl IF "hii!=. & missing_values==0"

*-------------------------------------------------------------------------------
* Standardize each outcome within the regression sample
*-------------------------------------------------------------------------------
foreach yvar of global depvars {
	cap drop std_`yvar'
	egen std_`yvar' = std(`yvar') if ${IF}
}

*-------------------------------------------------------------------------------
* Average effect size (z-score average across outcomes)
*-------------------------------------------------------------------------------
cap drop aes_z
egen aes_z = rowmean(${zdepvars}) if ${IF}

* Quick diagnostic
summ ${zdepvars} aes_z

*-------------------------------------------------------------------------------
* Export to CSV for mapping
*-------------------------------------------------------------------------------
keep if ${IF}
keep id std_bii std_sh_treecover std_sh_seasonwater_base aes_z
export delimited "${maps}/aes_for_map.csv", replace

di _n "Exported ${maps}/aes_for_map.csv"


*END
