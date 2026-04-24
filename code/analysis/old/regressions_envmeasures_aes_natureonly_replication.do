/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Regressions with Nature Exclusive Measures (REPLICATION)
DATE:

NOTES: This do-file replicates the results from regressions_envmeasures_aes_natureonly.do
       using the pre-prepared dataset created by create_data_natureonly.do
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
* Standardize dependent variables
*-------------------------------------------------------------------------------
gl depvar "bii sh_treecover changewater hii"

foreach yvar of global depvar {
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
}

replace std_hii=-std_hii

*-------------------------------------------------------------------------------
* Create country fixed effects dummies
*-------------------------------------------------------------------------------
cap drop country_code_*
tab country_code, g(country_code_)

cap drop dom_climzone_*
tab dom_climzone, gen(dom_climzone_)

*Valid country codes (based on available data)
gl countrycodes "country_code_1 country_code_2 country_code_3 country_code_6 country_code_9 country_code_10 country_code_12 country_code_13 country_code_14 country_code_16 country_code_17 country_code_20 country_code_21 country_code_22 country_code_24 country_code_25 country_code_26 country_code_27 country_code_28 country_code_30 country_code_31 country_code_32 country_code_34 country_code_35 country_code_36 country_code_39 country_code_40 country_code_41 country_code_42 country_code_43 country_code_44 country_code_45 country_code_46 country_code_47 country_code_48 country_code_51 country_code_52 country_code_53 country_code_55 country_code_56 country_code_57 country_code_58 country_code_59 country_code_60 country_code_61 country_code_62 country_code_63 country_code_65 country_code_67 country_code_68 country_code_70 country_code_71 country_code_72 country_code_73 country_code_74 country_code_75 country_code_76 country_code_83 country_code_84 country_code_85 country_code_86 country_code_88 country_code_89 country_code_91 country_code_92 country_code_93 country_code_94 country_code_96 country_code_97 country_code_99 country_code_100 country_code_101 country_code_102 country_code_106 country_code_107 country_code_108 country_code_109 country_code_111 country_code_112 country_code_113 country_code_115 country_code_118 country_code_119 country_code_120 country_code_122 country_code_126 country_code_129 country_code_130 country_code_131 country_code_133 country_code_136 country_code_137 country_code_138 country_code_139 country_code_141 country_code_142 country_code_143 country_code_144 country_code_146 country_code_147 country_code_148 country_code_151 country_code_152 country_code_153 country_code_154 country_code_155 country_code_157 country_code_158 country_code_159 country_code_160 country_code_161 country_code_163 country_code_164 country_code_168 country_code_169 country_code_178 country_code_179 country_code_180 country_code_181 country_code_183 country_code_184 country_code_185 country_code_187 country_code_188 country_code_189 country_code_191 country_code_192 country_code_193 country_code_195 country_code_196 country_code_197 country_code_198 country_code_199 country_code_200 country_code_201 country_code_202 country_code_204 country_code_205 country_code_206 country_code_207 country_code_208 country_code_210 country_code_211 country_code_212 country_code_213 country_code_214 country_code_215 country_code_218 country_code_219 country_code_220 country_code_221 country_code_222 country_code_223 country_code_224 country_code_225 country_code_226"

gl domclimzone "dom_climzone_1 dom_climzone_2 dom_climzone_3 dom_climzone_4 dom_climzone_5 dom_climzone_6 dom_climzone_7 dom_climzone_8 dom_climzone_9 dom_climzone_10 dom_climzone_11 dom_climzone_12 dom_climzone_13 dom_climzone_14 dom_climzone_15 dom_climzone_16 dom_climzone_17 dom_climzone_18 dom_climzone_19 dom_climzone_20 dom_climzone_21 dom_climzone_22 dom_climzone_23 dom_climzone_24"

*gl dom_climzone "share_gc_1 share_gc_2 share_gc_3 share_gc_4 share_gc_5 share_gc_6 share_gc_7 share_gc_8 share_gc_9 share_gc_10 share_gc_11 share_gc_12 share_gc_13 share_gc_14 share_gc_15 share_gc_16 share_gc_17 share_gc_18 share_gc_19 share_gc_20 share_gc_21 share_gc_22 share_gc_23 share_gc_24 share_gc_25 share_gc_26 share_gc_27 share_gc_28 share_gc_29 share_gc_30"

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
* Estimations + capture R2/mean/SD per model
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

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl1="`r(ndistinct)'"

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
	gl meany1 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd1    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 3
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl hii)

eststo aes2: avg_effect bii sh_treecover changewater if missing_values==0, x(${X2} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n2 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl2="`r(ndistinct)'"

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
	gl meany2 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd2    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 4
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl)

eststo aes3: avg_effect bii sh_treecover changewater if missing_values==0, x(${X0} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n3 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl3="`r(ndistinct)'"

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
	gl meany3 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd3   = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 5
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii)

eststo aes4: avg_effect bii sh_treecover changewater if missing_values==0, x(${X1} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n4 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl4="`r(ndistinct)'"

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
	gl meany4 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd4  = "`=string(round(r(sd), .0001), "%9.3f")'"
restore

** Column 6
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii)

eststo aes5: avg_effect bii sh_treecover changewater if missing_values==0, x(${X2} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n5 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl5="`r(ndistinct)'"

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
* Tables
*-------------------------------------------------------------------------------
*Exporting results dummy
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

di _n "Replication completed successfully!"


*-------------------------------------------------------------------------------
* ROBUSTNESS: swindex + reghdfe with TRUE 2-way clustering
*   Builds the inverse-covariance-weighted index of {bii, sh_treecover,
*   changewater} (Anderson 2008 / Schwab et al.), then runs a single reghdfe
*   per spec with vce(cluster eafolk_id country_code). Differs from avg_effect
*   in that the outcome is collapsed into one index instead of stacked, but
*   it gives proper 2-way clustered SEs.
*   Outputs ${tables}/Table_folklore_swindex_2wcluster.tex.
*   Requires: ssc install swindex ; ssc install reghdfe ; ssc install ftools
*-------------------------------------------------------------------------------
* Per-column controls (without dummies — country/climzone go in absorb())
local C1 ""
local C2 "hii"
local C3 "hii"
local C4 "hii tri_mean elev_mean"
local C5 "hii tri_mean elev_mean sh_protected"

* Per-column FE absorb sets
local F1 "country_code"
local F2 "country_code"
local F3 "country_code dom_climzone"
local F4 "country_code dom_climzone"
local F5 "country_code dom_climzone"

* Per-column treatment block (1=X1_int, 2=X2_int)
local T1 "${X1_int}"
local T2 "${X2_int}"

*-------------------------------------------------------------------------------
* Export swindex + 1-way clustered table
*-------------------------------------------------------------------------------
eststo clear

* Loop spec_id 1..10 — same column ordering as the AES table (X1_int first 5,
* then X2_int). For each spec, regenerate swindex on the column's sample.
local spec 0
foreach treat in 1 2 {
	forvalues k = 1/5 {
		local ++spec
		local TREAT  "`T`treat''"
		local CTRLS  "`C`k''"
		local FES    "`F`k''"

		cap drop missing_values
		egen missing_values = rowmiss(bii sh_treecover changewater `TREAT' `CTRLS')

		cap drop env_idx
		swindex bii sh_treecover changewater if missing_values==0, gen(env_idx)

		eststo sw`spec': reghdfe env_idx `TREAT' `CTRLS' if missing_values==0, ///
			absorb(`FES') vce(cluster eafolk_id)

		gl sn`spec'   = "`e(N)'"
		gl sclf`spec' = "`e(N_clust1)'"
		gl sclc`spec' = "0"
	}
}

esttab sw1 sw2 sw3 sw4 sw5 sw6 sw7 sw8 sw9 sw10 ///
	using "${tables}/Table_folklore_swindex_1wcluster.tex", ///
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
			`" & \multicolumn{10}{c}{Environmental Measures (swindex)} \\"' ///
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
			 `"Observations & ${sn1} & ${sn2} & ${sn3} & ${sn4} & ${sn5} & ${sn6} & ${sn7} & ${sn8} & ${sn9} & ${sn10} \\"' ///
			 `"Ethnic-folklore clusters & ${sclf1} & ${sclf2} & ${sclf3} & ${sclf4} & ${sclf5} & ${sclf6} & ${sclf7} & ${sclf8} & ${sclf9} & ${sclf10} \\"' ///
			 `"Country clusters & ${sclc1} & ${sclc2} & ${sclc3} & ${sclc4} & ${sclc5} & ${sclc6} & ${sclc7} & ${sclc8} & ${sclc9} & ${sclc10} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')
			 
*-------------------------------------------------------------------------------
* Export swindex + 2-way clustered table
*-------------------------------------------------------------------------------
eststo clear

* Loop spec_id 1..10 — same column ordering as the AES table (X1_int first 5,
* then X2_int). For each spec, regenerate swindex on the column's sample.
local spec 0
foreach treat in 1 2 {
	forvalues k = 1/5 {
		local ++spec
		local TREAT  "`T`treat''"
		local CTRLS  "`C`k''"
		local FES    "`F`k''"

		cap drop missing_values
		egen missing_values = rowmiss(bii sh_treecover changewater `TREAT' `CTRLS')

		cap drop env_idx
		swindex bii sh_treecover changewater if missing_values==0, gen(env_idx)

		eststo sw`spec': reghdfe env_idx `TREAT' `CTRLS' if missing_values==0, ///
			absorb(`FES') vce(cluster eafolk_id country_code)

		gl sn`spec'   = "`e(N)'"
		gl sclf`spec' = "`e(N_clust1)'"
		gl sclc`spec' = "`e(N_clust2)'"
	}
}

esttab sw1 sw2 sw3 sw4 sw5 sw6 sw7 sw8 sw9 sw10 ///
	using "${tables}/Table_folklore_swindex_2wcluster.tex", ///
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
			`" & \multicolumn{10}{c}{Environmental Measures (swindex)} \\"' ///
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
			 `"Observations & ${sn1} & ${sn2} & ${sn3} & ${sn4} & ${sn5} & ${sn6} & ${sn7} & ${sn8} & ${sn9} & ${sn10} \\"' ///
			 `"Ethnic-folklore clusters & ${sclf1} & ${sclf2} & ${sclf3} & ${sclf4} & ${sclf5} & ${sclf6} & ${sclf7} & ${sclf8} & ${sclf9} & ${sclf10} \\"' ///
			 `"Country clusters & ${sclc1} & ${sclc2} & ${sclc3} & ${sclc4} & ${sclc5} & ${sclc6} & ${sclc7} & ${sclc8} & ${sclc9} & ${sclc10} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "swindex + 2-way cluster table completed!"


*-------------------------------------------------------------------------------
* ROBUSTNESS: swindex + acreg with Conley spatial SEs (500 km cutoff)
*   Same swindex outcome as the 2-way cluster block, but SEs are spatially
*   adjusted via acreg using polygon centroid lat/lon, with a 500 km distance
*   threshold (~4.5 degrees, uniform kernel).
*   Outputs ${tables}/Table_folklore_swindex_conley500km.tex.
*   Requires: ssc install acreg ; ssc install swindex
*-------------------------------------------------------------------------------
cap which acreg
if _rc ssc install acreg

* acreg requires id and time variables — for cross-sectional data set id=_n, time=1
cap drop _conley_id _conley_t
gen _conley_id = _n
gen _conley_t  = 1

* Per-column treatment block (1=X1_int, 2=X2_int) and per-column controls
local T1 "${X1_int}"
local T2 "${X2_int}"

* Match X0..X4 to spec k=1..5 (these globals already include country/climzone dummies)
local CTRL1 "${X0}"
local CTRL2 "${X1}"
local CTRL3 "${X2}"
local CTRL4 "${X3}"
local CTRL5 "${X4}"

eststo clear

local spec 0
foreach treat in 1 2 {
	forvalues k = 1/5 {
		local ++spec
		local TREAT  "`T`treat''"
		local CTRLS  "`CTRL`k''"

		cap drop missing_values
		egen missing_values = rowmiss(bii sh_treecover changewater `TREAT' `CTRLS')

		cap drop env_idx
		swindex bii sh_treecover changewater if missing_values==0, gen(env_idx)

		eststo cn`spec': acreg env_idx `TREAT' `CTRLS' if missing_values==0, ///
			id(_conley_id) time(_conley_t) ///
			spatial latitude(lat) longitude(lon) dist(500)

		gl cn_n`spec' = "`e(N)'"
	}
}

*-------------------------------------------------------------------------------
* Export swindex + Conley 500km table
*-------------------------------------------------------------------------------
esttab cn1 cn2 cn3 cn4 cn5 cn6 cn7 cn8 cn9 cn10 ///
	using "${tables}/Table_folklore_swindex_conley500km.tex", ///
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
			`" & \multicolumn{10}{c}{Env. Measures Index (swindex) - Nature Exclusive (Conley SEs, 500 km)} \\"' ///
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
			 `"Observations & ${cn_n1} & ${cn_n2} & ${cn_n3} & ${cn_n4} & ${cn_n5} & ${cn_n6} & ${cn_n7} & ${cn_n8} & ${cn_n9} & ${cn_n10} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "swindex + Conley 500km table completed!"
