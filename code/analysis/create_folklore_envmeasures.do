/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Create dataset for Nature Exclusive Regressions
DATE:

NOTES: This do-file creates a dataset with only the variables needed to run
       the regressions in regressions_envmeasures_aes_natureonly_replication.do
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
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
* Preparing data
*
*-------------------------------------------------------------------------------
* Country and climatic zones (from Ancestral Characteristics paper)
import delimited "${data}/raw\ancestral_characteristics\countries_iso3.csv", varnames(1) clear

ren (country iso3) (c1 isocode)

tempfile ISO3
save `ISO3', replace

use "${data}/raw\ancestral_characteristics\EA_joined_to_KG.dta", clear

import delimited "${maps}/raw\KG_climatic_zones\ethnologue_KGshares.csv", varnames(1) clear

tempfile CLIMZ
save `CLIMZ', replace

use "${data}/raw\ancestral_characteristics\EA_joined_to_KG.dta", clear

tempfile CLIMZ1
save `CLIMZ1', replace

* Satellite imagery
import delimited "${maps}/raw\protected_land\ethnologue_wdpa.csv", clear

tempfile WDPA
save `WDPA', replace 

import delimited "${maps}/raw\BII\ethnologue_bii.csv", clear

tempfile BII
save `BII', replace 

import delimited "${maps}/raw\Hansen_forest\ethnologue_treecoverloss_fixed.csv", clear

tempfile TREES
save `TREES', replace 

import delimited "${maps}/raw\NL\ethnologue_nl.csv", clear

tempfile NL
save `NL', replace 

import delimited "${maps}/raw\Water_surface\perm_loss_water.csv", clear

tempfile WATER
save `WATER', replace 

import delimited "${maps}/raw\HII\ethnologue_hii.csv", clear

tempfile HII
save `HII', replace 

import delimited "${maps}/raw\CO2\ethnologue_ghg.csv", clear

tempfile GHG
save `GHG', replace 

import delimited "${maps}/raw\MODIS\ethnologue_treecover_modis.csv", clear

tempfile TREESMODIS
save `TREESMODIS', replace 

import delimited "${maps}/raw\DEM\ethnologue_ruggedness.csv", clear

tempfile TRI
save `TRI', replace

import delimited "${maps}/raw\Geography\ethnologue_centroids.csv", clear

tempfile CENT
save `CENT', replace

* Merging the satellite imagery with folklore
use "${data}/interim\Motifs_EA_WESEE_Ethnologue_humanvsnature_all.dta", clear

drop if id=="" 

merge 1:1 id using `WDPA', keep(1 3) nogen
merge 1:1 id using `BII', keep(1 3) nogen 
merge 1:1 id using `TREES', keep(1 3) nogen
merge 1:1 id using `NL', keep(1 3) nogen 
merge 1:1 id using `WATER', keep(1 3) nogen 
merge 1:1 id using `HII', keep(1 3) nogen
merge 1:1 id using `GHG', keep(1 3) nogen 
merge m:1 id using `CLIMZ', keep(1 3) nogen 
merge 1:1 id using `TREESMODIS', keep(1 3) nogen 
merge m:1 id using `TRI', keep(1 3) nogen
merge m:1 id using `CENT', keep(1 3) nogen

merge m:1 c1 using `ISO3', keep(1 3) nogen

* Creating vars of interest 
gen sh_protected=protected_km2*100/area_km2
gen sh_treeloss=treeloss_km2*100/treecover_km2
gen sh_treecover=treecover_km2*100/area_km2
gen sh_treecover_modis=treecover_modis_km2*100/area_km2

gen sh_treeloss_v2=treeloss_km2*100/area_km2

replace sh_protected=100 if sh_protected>100 & sh_protected!=.
replace sh_treeloss=100 if sh_treeloss>100 & sh_treeloss!=.
replace sh_treecover=100 if sh_treecover>100 & sh_treecover!=.
replace sh_treecover_modis=100 if sh_treecover_modis>100 & sh_treecover_modis!=.

replace sh_treeloss_v2=100 if sh_treeloss_v2>100 & sh_treeloss_v2!=.

replace sh_treeloss=0 if sh_treeloss==.
replace sh_treeloss_v2=0 if sh_treeloss_v2==.

gen tot_water=permwater_km2+losswater_km2
gen sh_losswater=losswater_km2*100/permwater_km2
replace sh_losswater=0 if sh_losswater==.

*gen sh_permwater_base=permwater_baseline_km2*100/area_km2
gen sh_permwater_base=permwater_2000_km2*100/area_km2
gen sh_seasonwater_base=seasonalwater_2000_km2*100/area_km2

gen water_2000_km2=permwater_2000_km2+seasonalwater_2000_km2
gen sh_water_base=water_2000_km2*100/area_km2

* Same shares but excluding pixels inside non-natural lakes (Lake_type 2 or 3)
gen sh_permwater_base_excl_res   = permwater_2000_km2_excl_res*100/area_km2
gen sh_seasonwater_base_excl_res = seasonalwater_2000_km2_excl_res*100/area_km2

replace ghg=0 if ghg==.

gen sh_permwater=permwater_km2*100/area_km2
replace sh_permwater=0 if sh_permwater==.

replace bii=0 if bii==.

replace nl_mean=0 if nl_mean==.

encode c1, gen(country_code)
encode isocode, gen(isocode_num)

drop if area_km2==. 

*Nature exclusive variables 
gen sh_nat_socl_atl=sh_nature_scl_ocl_only_atl
gen sh_nat_scl_atl=sh_nature_scl_only_atl
gen sh_nat_ocl_atl=sh_nature_ocl_only_atl

*Labels
la var sh_nat_socl_atl `" "Share of motifs with nature-only" "subject or object" "'
la var sh_nat_scl_atl `" "Share of motifs with a" "nature-only subject" "'
la var sh_nat_ocl_atl `" "Share of motifs with a" "nature-only object" "'

*Dominant climatic zone (1–30): index of share_gc_* with the highest share
egen max_gc_share = rowmax(share_gc_1-share_gc_30)
gen dom_climzone = .
forvalues k = 1/30 {
	replace dom_climzone = `k' if share_gc_`k' == max_gc_share & dom_climzone == .
}
drop max_gc_share
la var dom_climzone "Dominant Köppen-Geiger zone (argmax of share_gc_1..30; ties → lowest index)"

*-------------------------------------------------------------------------------
* Keep only variables needed for the replication
*-------------------------------------------------------------------------------
* Identify all share_gc_* variables (climatic zones)
ds share_gc_*
local climvars `r(varlist)'

* Keep essential variables for replication
* Note: `changewater*` wildcard already covers changewater, changewater_abs,
* and their _excl_res counterparts (anything starting with "changewater").
keep id c1 isocode country_code isocode_num eafolk_id ///
     bii sh_treecover* changewater* hii ///
     sh_nat_socl_atl sh_nat_scl_atl sh_nat_ocl_atl ///
     `climvars' dom_climzone tri_mean elev_mean lat lon ///
     area_km2 sh_protected sh_treeloss* ///
     sh_permwater_base sh_permwater_base_excl_res ///
     sh_seasonwater_base sh_seasonwater_base_excl_res ///
	 sh_water_base v98

* Order variables
order id c1 isocode country_code isocode_num eafolk_id ///
      bii sh_treecover* changewater changewater_excl_res ///
      changewater_abs changewater_abs_excl_res hii ///
      sh_nat_socl_atl sh_nat_scl_atl sh_nat_ocl_atl

*-------------------------------------------------------------------------------
* Save the dataset
*-------------------------------------------------------------------------------
compress
save "${data}/final/folklore_envmeasures.dta", replace

di _n "Dataset created successfully: folklore_envmeasures.dta"
di "Number of observations: " _N
describe, short
