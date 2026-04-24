/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Regressions with Nature Exclusive Measures (REPLICATION) — aes_z variant
DATE:

NOTES: Mirrors regressions_envmeasures_aes_natureonly_replication.do but the
       three swindex robustness blocks are replaced with an "aes_z" outcome
       defined as the rowmean of in-sample standardized
       {bii, sh_treecover, changewater}.

       Robustness variants for the aes_z outcome:
         (1) reghdfe + 1-way cluster (eafolk_id)
         (2) reghdfe + 2-way cluster (eafolk_id, country_code)
         (3) acreg   + Conley spatial SE, 500 km cutoff

       Per-spec sample is identified via missing_values==0 over outcomes +
       treatment + per-spec controls. Standardization happens INSIDE
       preserve/restore so the column-specific sample doesn't leak across
       specifications.
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
gl plots "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\plots"
gl tables "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\tables"

cd "${data}"

*Setting a pre-scheme for plots
set scheme s2mono
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray

*-------------------------------------------------------------------------------
* Load pre-prepared data
*-------------------------------------------------------------------------------
use "${data}/final/folklore_envmeasures.dta", clear

*-------------------------------------------------------------------------------
* Standardize dependent variables (initial pass for full sample)
*-------------------------------------------------------------------------------
gl depvar "bii sh_treecover changewater hii"

foreach yvar of global depvar {
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
}

replace std_hii=-std_hii

*-------------------------------------------------------------------------------
* Create country & climatic-zone fixed-effects dummies
*-------------------------------------------------------------------------------
cap drop country_code_*
tab country_code, g(country_code_)

cap drop dom_climzone_*
tab dom_climzone, gen(dom_climzone_)

*Valid country codes (based on available data)
gl countrycodes "country_code_1 country_code_2 country_code_3 country_code_6 country_code_9 country_code_10 country_code_12 country_code_13 country_code_14 country_code_16 country_code_17 country_code_20 country_code_21 country_code_22 country_code_24 country_code_25 country_code_26 country_code_27 country_code_28 country_code_30 country_code_31 country_code_32 country_code_34 country_code_35 country_code_36 country_code_39 country_code_40 country_code_41 country_code_42 country_code_43 country_code_44 country_code_45 country_code_46 country_code_47 country_code_48 country_code_51 country_code_52 country_code_53 country_code_55 country_code_56 country_code_57 country_code_58 country_code_59 country_code_60 country_code_61 country_code_62 country_code_63 country_code_65 country_code_67 country_code_68 country_code_70 country_code_71 country_code_72 country_code_73 country_code_74 country_code_75 country_code_76 country_code_83 country_code_84 country_code_85 country_code_86 country_code_88 country_code_89 country_code_91 country_code_92 country_code_93 country_code_94 country_code_96 country_code_97 country_code_99 country_code_100 country_code_101 country_code_102 country_code_106 country_code_107 country_code_108 country_code_109 country_code_111 country_code_112 country_code_113 country_code_115 country_code_118 country_code_119 country_code_120 country_code_122 country_code_126 country_code_129 country_code_130 country_code_131 country_code_133 country_code_136 country_code_137 country_code_138 country_code_139 country_code_141 country_code_142 country_code_143 country_code_144 country_code_146 country_code_147 country_code_148 country_code_151 country_code_152 country_code_153 country_code_154 country_code_155 country_code_157 country_code_158 country_code_159 country_code_160 country_code_161 country_code_163 country_code_164 country_code_168 country_code_169 country_code_178 country_code_179 country_code_180 country_code_181 country_code_183 country_code_184 country_code_185 country_code_187 country_code_188 country_code_189 country_code_191 country_code_192 country_code_193 country_code_195 country_code_196 country_code_197 country_code_198 country_code_199 country_code_200 country_code_201 country_code_202 country_code_204 country_code_205 country_code_206 country_code_207 country_code_208 country_code_210 country_code_211 country_code_212 country_code_213 country_code_214 country_code_215 country_code_218 country_code_219 country_code_220 country_code_221 country_code_222 country_code_223 country_code_224 country_code_225 country_code_226"

gl domclimezone "dom_climzone_1 dom_climzone_2 dom_climzone_3 dom_climzone_4 dom_climzone_5 dom_climzone_6 dom_climzone_7 dom_climzone_8 dom_climzone_9 dom_climzone_10 dom_climzone_11 dom_climzone_12 dom_climzone_13 dom_climzone_14 dom_climzone_15 dom_climzone_16 dom_climzone_17 dom_climzone_18 dom_climzone_19 dom_climzone_20 dom_climzone_21 dom_climzone_22 dom_climzone_23 dom_climzone_24"

*-------------------------------------------------------------------------------
* Set up regression specifications
*-------------------------------------------------------------------------------
gl X1_int "sh_nat_socl_atl"
gl X2_int "sh_nat_scl_atl sh_nat_ocl_atl"

gl X0 "${countrycodes}"
gl X1 "hii ${countrycodes}"
gl X2 "hii ${domclimezone} ${countrycodes}"
gl X3 "hii tri_mean elev_mean ${domclimezone} ${countrycodes}"
gl X4 "hii tri_mean elev_mean sh_protected ${domclimezone} ${countrycodes}"

gl if " "

*-------------------------------------------------------------------------------
* MAIN: avg_effect — captures R2/mean/SD per model (kept identical to the
*       parent file so the AES headline table is regenerated unchanged)
*-------------------------------------------------------------------------------
eststo clear

** Column 1
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl)

eststo aes0: avg_effect bii sh_treecover changewater if missing_values==0, x(${X0} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n0 = "`e(N)'"
di $n0

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl0="`r(ndistinct)'"
di $cl0

** Now save mean and standard deviation of all dependent variables together
preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
** Standardize variables
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany0 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd0    = "`=string(round(r(sd), .0001), "%9.3f")'"
	di $meany0
	di $sd0
restore

** Column 2
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl hii)

eststo aes1: avg_effect bii sh_treecover changewater if missing_values==0, x(${X1} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n1 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl1="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany1 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd1    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 3
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl hii)

eststo aes2: avg_effect bii sh_treecover changewater if missing_values==0, x(${X2} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n2 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl2="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany2 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd2    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 4
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl)

eststo aes3: avg_effect bii sh_treecover changewater if missing_values==0, x(${X0} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n3 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl3="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany3 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd3   = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 5
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii)

eststo aes4: avg_effect bii sh_treecover changewater if missing_values==0, x(${X1} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n4 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl4="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany4 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd4  = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 6
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii)

eststo aes5: avg_effect bii sh_treecover changewater if missing_values==0, x(${X2} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n5 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl5="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany5 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd5 = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 7 — X3 + X1_int (adds tri_mean elev_mean)
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl hii tri_mean elev_mean)

eststo aes6: avg_effect bii sh_treecover changewater if missing_values==0, x(${X3} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n6 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl6="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
		egen std_`var'= std(`var')
	}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany6 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd6    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 8 — X4 + X1_int (adds sh_protected)
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl hii tri_mean elev_mean sh_protected)

eststo aes7: avg_effect bii sh_treecover changewater if missing_values==0, x(${X4} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n7 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl7="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
		egen std_`var'= std(`var')
	}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany7 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd7    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 9 — X3 + X2_int (adds tri_mean elev_mean)
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii tri_mean elev_mean)

eststo aes8: avg_effect bii sh_treecover changewater if missing_values==0, x(${X3} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n8 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl8="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
		egen std_`var'= std(`var')
	}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany8 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd8    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 10 — X4 + X2_int (adds sh_protected)
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii tri_mean elev_mean sh_protected)

eststo aes9: avg_effect bii sh_treecover changewater if missing_values==0, x(${X4} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n9 = "`e(N)'"

distinct eafolk_id if missing_values==0
gl cl9="`r(ndistinct)'"

preserve
	gen reg_sample = e(sample)
	keep if reg_sample == 1
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
		egen std_`var'= std(`var')
	}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany9 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd9    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore


*-------------------------------------------------------------------------------
* Tables — main avg_effect AES table (regenerates parent file's output)
*-------------------------------------------------------------------------------
esttab aes0 aes1 aes2 aes6 aes7 aes3 aes4 aes5 aes8 aes9 using "${tables}/Table_folklore_z_env_natureonly_replication.tex", keep(ae_sh_nat_socl_atl ae_sh_nat_scl_atl ae_sh_nat_ocl_atl) ///
	coeflabels( ///
    ae_sh_nat_socl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}" ///
    ae_sh_nat_scl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
    ae_sh_nat_ocl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}") ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
    booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{10}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{10}{c}{Environmental Measures (AES) - Nature Exclusive} \\"' ///
			`"\cmidrule(lr){2-11}"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
			`"\midrule"') ///
	postfoot(`" & & & & & & & & & & \\"' ///
			 `" HII control               & No  & Yes & Yes & Yes & Yes & No  & Yes & Yes & Yes & Yes \\"' ///
			 `" Climatic-zone FE          & No  & No  & Yes & Yes & Yes & No  & No  & Yes & Yes & Yes \\"' ///
			 `" Ruggedness \& elevation & No  & No  & No  & Yes & Yes & No  & No  & No  & Yes & Yes \\"' ///
			 `" Share of protected land   & No  & No  & No  & No  & Yes & No  & No  & No  & No  & Yes \\"' ///
			 `" Country fixed effects     & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
			 `" & & & & & & & & & & \\"' ///
			 `"Observations & ${n0} & ${n1} & ${n2} & ${n6} & ${n7} & ${n3} & ${n4} & ${n5} & ${n8} & ${n9} \\"' ///
			 `"Mean of dep. var. & ${meany0} & ${meany1} & ${meany2} & ${meany6} & ${meany7} & ${meany3} & ${meany4} & ${meany5} & ${meany8} & ${meany9} \\"' ///
			 `"Standard deviation of dep. var. & ${sd0} & ${sd1} & ${sd2} & ${sd6} & ${sd7} & ${sd3} & ${sd4} & ${sd5} & ${sd8} & ${sd9} \\"' ///
			 `"Ethnic-folklore clusters & ${cl0} & ${cl1} & ${cl2} & ${cl6} & ${cl7} & ${cl3} & ${cl4} & ${cl5} & ${cl8} & ${cl9} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "AES (avg_effect) table completed!"


*-------------------------------------------------------------------------------
* Per-spec scaffolding for the aes_z robustness blocks
*   Same column ordering as the AES table: spec 1..5 use X1_int (controls
*   X0..X4); spec 6..10 use X2_int (controls X0..X4).
*-------------------------------------------------------------------------------
* Real-controls only (no dummies) — used for rowmiss(), since dummies have
* no missing values and bloating the rowmiss() variable list is wasteful.
local C1 ""
local C2 "hii"
local C3 "hii"
local C4 "hii tri_mean elev_mean"
local C5 "hii tri_mean elev_mean sh_protected"

* Per-column FE absorb sets (only used by the reghdfe 2-way cluster block)
local F1 "country_code"
local F2 "country_code"
local F3 "country_code dom_climzone"
local F4 "country_code dom_climzone"
local F5 "country_code dom_climzone"

* Per-column controls WITH dummies — same X0..X4 globals as in the AES section.
* Used by reg (1-way cluster) and acreg (Conley), neither of which absorb FEs.
local CTRL1 "${X0}"
local CTRL2 "${X1}"
local CTRL3 "${X2}"
local CTRL4 "${X3}"
local CTRL5 "${X4}"

* Per-column treatment block (1=X1_int, 2=X2_int)
local T1 "${X1_int}"
local T2 "${X2_int}"


*-------------------------------------------------------------------------------
* ROBUSTNESS (1): aes_z + reg + 1-way cluster (eafolk_id)
*   aes_z = rowmean of in-sample standardized {bii, sh_treecover, changewater}.
*   Uses ${X0}..${X4} (same globals as the AES avg_effect section); country and
*   climzone fixed effects enter as dummies inside those globals.
*   Outputs ${tables}/Table_folklore_aesz_1wcluster.tex.
*-------------------------------------------------------------------------------
eststo clear

local spec 0
foreach treat in 1 2 {
	forvalues k = 1/5 {
		local ++spec
		local TREAT  "`T`treat''"
		local CTRLS  "`C`k''"
		local XCT    "`CTRL`k''"

		cap drop missing_values
		egen missing_values = rowmiss(bii sh_treecover changewater `TREAT' `CTRLS')

		preserve
			keep if missing_values == 0

			cap drop std_bii std_sh_treecover std_changewater
			foreach var of varlist bii sh_treecover changewater {
				egen std_`var' = std(`var')
			}
			cap drop aes_z
			egen aes_z = rowmean(std_bii std_sh_treecover std_changewater)

			eststo a1w`spec': reg aes_z `TREAT' `XCT', vce(cluster eafolk_id)

			gl an1w`spec'   = "`e(N)'"
			gl aclf1w`spec' = "`e(N_clust)'"
		restore
	}
}

esttab a1w1 a1w2 a1w3 a1w4 a1w5 a1w6 a1w7 a1w8 a1w9 a1w10 ///
	using "${tables}/Table_folklore_aesz_1wcluster.tex", ///
	keep(${X1_int} ${X2_int}) ///
	coeflabels( ///
		sh_nat_socl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}" ///
		sh_nat_scl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
		sh_nat_ocl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}") ///
	se nocons star(* 0.10 ** 0.05 *** 0.01) ///
	label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
	booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{10}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{10}{c}{AES Z-Score - Nature Exclusive} \\"' ///
			`"\cmidrule(lr){2-11}"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
			`"\midrule"') ///
	postfoot(`" & & & & & & & & & & \\"' ///
			 `" HII control               & No  & Yes & Yes & Yes & Yes & No  & Yes & Yes & Yes & Yes \\"' ///
			 `" Climatic-zone FE          & No  & No  & Yes & Yes & Yes & No  & No  & Yes & Yes & Yes \\"' ///
			 `" Ruggedness \& elevation   & No  & No  & No  & Yes & Yes & No  & No  & No  & Yes & Yes \\"' ///
			 `" Share of protected land   & No  & No  & No  & No  & Yes & No  & No  & No  & No  & Yes \\"' ///
			 `" Country fixed effects     & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
			 `" & & & & & & & & & & \\"' ///
			 `"Observations & ${an1w1} & ${an1w2} & ${an1w3} & ${an1w4} & ${an1w5} & ${an1w6} & ${an1w7} & ${an1w8} & ${an1w9} & ${an1w10} \\"' ///
			 `"Ethnic-folklore clusters & ${aclf1w1} & ${aclf1w2} & ${aclf1w3} & ${aclf1w4} & ${aclf1w5} & ${aclf1w6} & ${aclf1w7} & ${aclf1w8} & ${aclf1w9} & ${aclf1w10} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "aes_z + 1-way cluster table completed!"


*-------------------------------------------------------------------------------
* ROBUSTNESS (2): aes_z + reghdfe + 2-way cluster (eafolk_id, country_code)
*   Outputs ${tables}/Table_folklore_aesz_2wcluster.tex.
*-------------------------------------------------------------------------------
eststo clear

local spec 0
foreach treat in 1 2 {
	forvalues k = 1/5 {
		local ++spec
		local TREAT  "`T`treat''"
		local CTRLS  "`C`k''"
		local FES    "`F`k''"

		cap drop missing_values
		egen missing_values = rowmiss(bii sh_treecover changewater `TREAT' `CTRLS')

		preserve
			keep if missing_values == 0

			cap drop std_bii std_sh_treecover std_changewater
			foreach var of varlist bii sh_treecover changewater {
				egen std_`var' = std(`var')
			}
			cap drop aes_z
			egen aes_z = rowmean(std_bii std_sh_treecover std_changewater)

			eststo a2w`spec': reghdfe aes_z `TREAT' `CTRLS', ///
				absorb(`FES') vce(cluster eafolk_id country_code)

			gl an2w`spec'   = "`e(N)'"
			gl aclf2w`spec' = "`e(N_clust1)'"
			gl aclc2w`spec' = "`e(N_clust2)'"
		restore
	}
}

esttab a2w1 a2w2 a2w3 a2w4 a2w5 a2w6 a2w7 a2w8 a2w9 a2w10 ///
	using "${tables}/Table_folklore_aesz_2wcluster.tex", ///
	keep(${X1_int} ${X2_int}) ///
	coeflabels( ///
		sh_nat_socl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}" ///
		sh_nat_scl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
		sh_nat_ocl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}") ///
	se nocons star(* 0.10 ** 0.05 *** 0.01) ///
	label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
	booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{10}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{10}{c}{AES Z-Score - Nature Exclusive (2-way clustered SEs)} \\"' ///
			`"\cmidrule(lr){2-11}"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
			`"\midrule"') ///
	postfoot(`" & & & & & & & & & & \\"' ///
			 `" HII control               & No  & Yes & Yes & Yes & Yes & No  & Yes & Yes & Yes & Yes \\"' ///
			 `" Climatic-zone FE          & No  & No  & Yes & Yes & Yes & No  & No  & Yes & Yes & Yes \\"' ///
			 `" Ruggedness \& elevation   & No  & No  & No  & Yes & Yes & No  & No  & No  & Yes & Yes \\"' ///
			 `" Share of protected land   & No  & No  & No  & No  & Yes & No  & No  & No  & No  & Yes \\"' ///
			 `" Country fixed effects     & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
			 `" & & & & & & & & & & \\"' ///
			 `"Observations & ${an2w1} & ${an2w2} & ${an2w3} & ${an2w4} & ${an2w5} & ${an2w6} & ${an2w7} & ${an2w8} & ${an2w9} & ${an2w10} \\"' ///
			 `"Ethnic-folklore clusters & ${aclf2w1} & ${aclf2w2} & ${aclf2w3} & ${aclf2w4} & ${aclf2w5} & ${aclf2w6} & ${aclf2w7} & ${aclf2w8} & ${aclf2w9} & ${aclf2w10} \\"' ///
			 `"Country clusters & ${aclc2w1} & ${aclc2w2} & ${aclc2w3} & ${aclc2w4} & ${aclc2w5} & ${aclc2w6} & ${aclc2w7} & ${aclc2w8} & ${aclc2w9} & ${aclc2w10} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "aes_z + 2-way cluster table completed!"


*-------------------------------------------------------------------------------
* ROBUSTNESS (3): aes_z + acreg + Conley spatial SE (500 km cutoff)
*   acreg has no absorb(), so the country/climzone dummies are passed via the
*   X0..X4 globals (which already include them). Per-spec controls live in the
*   CTRL1..CTRL5 locals below.
*   Outputs ${tables}/Table_folklore_aesz_conley500km.tex.
*   Requires: ssc install acreg
*-------------------------------------------------------------------------------
cap which acreg
if _rc ssc install acreg

eststo clear

local spec 0
foreach treat in 1 2 {
	forvalues k = 1/5 {
		local ++spec
		local TREAT  "`T`treat''"
		local CTRLS  "`C`k''"
		local XCT    "`CTRL`k''"

		cap drop missing_values
		egen missing_values = rowmiss(bii sh_treecover changewater `TREAT' `CTRLS')

		preserve
			keep if missing_values == 0

			cap drop std_bii std_sh_treecover std_changewater
			foreach var of varlist bii sh_treecover changewater {
				egen std_`var' = std(`var')
			}
			cap drop aes_z
			egen aes_z = rowmean(std_bii std_sh_treecover std_changewater)

			cap drop _conley_id _conley_t
			gen _conley_id = _n
			gen _conley_t  = 1

			eststo acn`spec': acreg aes_z `TREAT' `XCT', ///
				id(_conley_id) time(_conley_t) ///
				spatial latitude(lat) longitude(lon) dist(500)

			gl ancn`spec' = "`e(N)'"
		restore
	}
}

esttab acn1 acn2 acn3 acn4 acn5 acn6 acn7 acn8 acn9 acn10 ///
	using "${tables}/Table_folklore_aesz_conley500km.tex", ///
	keep(${X1_int} ${X2_int}) ///
	coeflabels( ///
		sh_nat_socl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}" ///
		sh_nat_scl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
		sh_nat_ocl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}") ///
	se nocons star(* 0.10 ** 0.05 *** 0.01) ///
	label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
	booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{10}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{10}{c}{AES Z-Score - Nature Exclusive (Conley SEs, 500 km)} \\"' ///
			`"\cmidrule(lr){2-11}"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
			`"\midrule"') ///
	postfoot(`" & & & & & & & & & & \\"' ///
			 `" HII control               & No  & Yes & Yes & Yes & Yes & No  & Yes & Yes & Yes & Yes \\"' ///
			 `" Climatic-zone FE          & No  & No  & Yes & Yes & Yes & No  & No  & Yes & Yes & Yes \\"' ///
			 `" Ruggedness \& elevation   & No  & No  & No  & Yes & Yes & No  & No  & No  & Yes & Yes \\"' ///
			 `" Share of protected land   & No  & No  & No  & No  & Yes & No  & No  & No  & No  & Yes \\"' ///
			 `" Country fixed effects     & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
			 `" Conley distance cutoff    & 500km & 500km & 500km & 500km & 500km & 500km & 500km & 500km & 500km & 500km \\"' ///
			 `" & & & & & & & & & & \\"' ///
			 `"Observations & ${ancn1} & ${ancn2} & ${ancn3} & ${ancn4} & ${ancn5} & ${ancn6} & ${ancn7} & ${ancn8} & ${ancn9} & ${ancn10} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "aes_z + Conley 500km table completed!"

di _n "Replication completed successfully!"
