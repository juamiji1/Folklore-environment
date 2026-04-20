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
gl depvar "bii sh_treecover sh_treecover_modis changewater hii sh_treeloss"

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

*Valid country codes (based on available data)
gl countrycodes "country_code_1 country_code_2 country_code_3 country_code_6 country_code_9 country_code_10 country_code_12 country_code_13 country_code_14 country_code_16 country_code_17 country_code_20 country_code_21 country_code_22 country_code_24 country_code_25 country_code_26 country_code_27 country_code_28 country_code_30 country_code_31 country_code_32 country_code_34 country_code_35 country_code_36 country_code_39 country_code_40 country_code_41 country_code_42 country_code_43 country_code_44 country_code_45 country_code_46 country_code_47 country_code_48 country_code_51 country_code_52 country_code_53 country_code_55 country_code_56 country_code_57 country_code_58 country_code_59 country_code_60 country_code_61 country_code_62 country_code_63 country_code_65 country_code_67 country_code_68 country_code_70 country_code_71 country_code_72 country_code_73 country_code_74 country_code_75 country_code_76 country_code_83 country_code_84 country_code_85 country_code_86 country_code_88 country_code_89 country_code_91 country_code_92 country_code_93 country_code_94 country_code_96 country_code_97 country_code_99 country_code_100 country_code_101 country_code_102 country_code_106 country_code_107 country_code_108 country_code_109 country_code_111 country_code_112 country_code_113 country_code_115 country_code_118 country_code_119 country_code_120 country_code_122 country_code_126 country_code_129 country_code_130 country_code_131 country_code_133 country_code_136 country_code_137 country_code_138 country_code_139 country_code_141 country_code_142 country_code_143 country_code_144 country_code_146 country_code_147 country_code_148 country_code_151 country_code_152 country_code_153 country_code_154 country_code_155 country_code_157 country_code_158 country_code_159 country_code_160 country_code_161 country_code_163 country_code_164 country_code_168 country_code_169 country_code_178 country_code_179 country_code_180 country_code_181 country_code_183 country_code_184 country_code_185 country_code_187 country_code_188 country_code_189 country_code_191 country_code_192 country_code_193 country_code_195 country_code_196 country_code_197 country_code_198 country_code_199 country_code_200 country_code_201 country_code_202 country_code_204 country_code_205 country_code_206 country_code_207 country_code_208 country_code_210 country_code_211 country_code_212 country_code_213 country_code_214 country_code_215 country_code_218 country_code_219 country_code_220 country_code_221 country_code_222 country_code_223 country_code_224 country_code_225 country_code_226"

*-------------------------------------------------------------------------------
* Set up regression specifications
*-------------------------------------------------------------------------------
gl X1_int "sh_nat_socl_atl"
gl X2_int "sh_nat_scl_atl sh_nat_ocl_atl"

gl X0 ""
gl X1 "hii"
gl X2 "hii"
gl X3 "hii tri_mean elev_mean"
gl X4 "hii tri_mean elev_mean sh_protected"

gl FEO "i.country_code"
gl FE1 "i.country_code"
gl FE2 "i.country_code i.dom_climzone"
gl FE3 "i.country_code i.dom_climzone"
gl FE4 "i.country_code i.dom_climzone"

*-------------------------------------------------------------------------------
* Make sure outcomes have human-readable labels for the table title
*-------------------------------------------------------------------------------
la var bii                "Biodiversity Intactness Index"
la var sh_treecover       "Tree Cover Share (Hansen)"
la var sh_treecover_modis "Tree Cover Share (MODIS)"
la var changewater        "Surface Water Change"
la var hii                "Human Influence Index"
la var sh_treeloss        "Tree Loss Share (treeloss / 2000 tree cover)"

*-------------------------------------------------------------------------------
* Estimations + tables — one per outcome, 10 columns each
*   Cols: (X0/X1/X2/X3/X4) x (X1_int / X2_int)
*     X3 adds tri+elev; X4 further adds sh_protected
*-------------------------------------------------------------------------------
gl depvar "bii sh_treecover sh_treecover_modis changewater sh_treeloss"

foreach yvar of global depvar {

	local ylab : variable label `yvar'
	if "`ylab'" == "" local ylab "`yvar'"

	eststo clear

	** Column 1: X0 + X1_int
	eststo c1: reg std_`yvar' ${X1_int} ${X0} ${FEO}, vce(cluster eafolk_id)
	gl n1 = `e(N)'

	** Column 2: X1 + X1_int
	eststo c2: reg std_`yvar' ${X1_int} ${X1} ${FE1}, vce(cluster eafolk_id)
	gl n2 = `e(N)'

	** Column 3: X2 + X1_int
	eststo c3: reg std_`yvar' ${X1_int} ${X2} ${FE2}, vce(cluster eafolk_id)
	gl n3 = `e(N)'

	** Column 4: X3 + X1_int  (adds tri_mean elev_mean)
	eststo c4: reg std_`yvar' ${X1_int} ${X3} ${FE3}, vce(cluster eafolk_id)
	gl n4 = `e(N)'

	** Column 5: X4 + X1_int  (NEW — adds sh_protected)
	eststo c5: reg std_`yvar' ${X1_int} ${X4} ${FE4}, vce(cluster eafolk_id)
	gl n5 = `e(N)'

	** Column 6: X0 + X2_int
	eststo c6: reg std_`yvar' ${X2_int} ${X0} ${FEO}, vce(cluster eafolk_id)
	gl n6 = `e(N)'

	** Column 7: X1 + X2_int
	eststo c7: reg std_`yvar' ${X2_int} ${X1} ${FE1}, vce(cluster eafolk_id)
	gl n7 = `e(N)'

	** Column 8: X2 + X2_int
	eststo c8: reg std_`yvar' ${X2_int} ${X2} ${FE2}, vce(cluster eafolk_id)
	gl n8 = `e(N)'

	** Column 9: X3 + X2_int  (adds tri_mean elev_mean)
	eststo c9: reg std_`yvar' ${X2_int} ${X3} ${FE3}, vce(cluster eafolk_id)
	gl n9 = `e(N)'

	** Column 10: X4 + X2_int  (NEW — adds sh_protected)
	eststo c10: reg std_`yvar' ${X2_int} ${X4} ${FE4}, vce(cluster eafolk_id)
	gl n10 = `e(N)'

	*-------------------------------------------------------------------------------
	* Export
	*-------------------------------------------------------------------------------
	esttab c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 using "${tables}/Table_peroutcome_`yvar'.tex", ///
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
				`" & \multicolumn{10}{c}{`ylab' - Nature Exclusive} \\"' ///
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
				 `"Observations & ${n1} & ${n2} & ${n3} & ${n4} & ${n5} & ${n6} & ${n7} & ${n8} & ${n9} & ${n10} \\"' ///
				 `"\bottomrule"' ///
				 `"\end{tabular}"')
}


*-------------------------------------------------------------------------------
* SEPARATE QUESTION: Share of Protected Land as outcome
*   sh_protected is the LHS, so X4 (which adds sh_protected as a control)
*   is dropped — 8-column table: (X0/X1/X2/X3) × (X1_int / X2_int).
*-------------------------------------------------------------------------------
la var sh_protected "Share of Protected Land"

cap drop std_sh_protected
egen std_sh_protected = std(sh_protected)

local yvar  sh_protected
local ylab : variable label `yvar'
if "`ylab'" == "" local ylab "`yvar'"

eststo clear

** Column 1: X0 + X1_int
eststo c1: reg std_`yvar' ${X1_int} ${X0} ${FEO}, vce(cluster eafolk_id)
gl n1 = `e(N)'

** Column 2: X1 + X1_int
eststo c2: reg std_`yvar' ${X1_int} ${X1} ${FE1}, vce(cluster eafolk_id)
gl n2 = `e(N)'

** Column 3: X2 + X1_int
eststo c3: reg std_`yvar' ${X1_int} ${X2} ${FE2}, vce(cluster eafolk_id)
gl n3 = `e(N)'

** Column 4: X3 + X1_int  (adds tri_mean elev_mean)
eststo c4: reg std_`yvar' ${X1_int} ${X3} ${FE3}, vce(cluster eafolk_id)
gl n4 = `e(N)'

** Column 5: X0 + X2_int
eststo c5: reg std_`yvar' ${X2_int} ${X0} ${FEO}, vce(cluster eafolk_id)
gl n5 = `e(N)'

** Column 6: X1 + X2_int
eststo c6: reg std_`yvar' ${X2_int} ${X1} ${FE1}, vce(cluster eafolk_id)
gl n6 = `e(N)'

** Column 7: X2 + X2_int
eststo c7: reg std_`yvar' ${X2_int} ${X2} ${FE2}, vce(cluster eafolk_id)
gl n7 = `e(N)'

** Column 8: X3 + X2_int  (adds tri_mean elev_mean)
eststo c8: reg std_`yvar' ${X2_int} ${X3} ${FE3}, vce(cluster eafolk_id)
gl n8 = `e(N)'

esttab c1 c2 c3 c4 c5 c6 c7 c8 using "${tables}/Table_peroutcome_`yvar'.tex", ///
	keep(${X1_int} ${X2_int}) ///
	coeflabels( ///
		sh_nat_socl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}" ///
		sh_nat_scl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
		sh_nat_ocl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}") ///
	se nocons star(* 0.10 ** 0.05 *** 0.01) ///
	label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
	booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{8}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{8}{c}{`ylab' - Nature Exclusive} \\"' ///
			`"\cmidrule(lr){2-9}"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"' ///
			`"\midrule"') ///
	postfoot(`" & & & & & & & & \\"' ///
			 `" HII control               & No  & Yes & Yes & Yes & No  & Yes & Yes & Yes \\"' ///
			 `" Climatic-zone FE          & No  & No  & Yes & Yes & No  & No  & Yes & Yes \\"' ///
			 `" Ruggedness \& elevation   & No  & No  & No  & Yes & No  & No  & No  & Yes \\"' ///
			 `" Country fixed effects     & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
			 `" & & & & & & & & \\"' ///
			 `"Observations & ${n1} & ${n2} & ${n3} & ${n4} & ${n5} & ${n6} & ${n7} & ${n8} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')


*-------------------------------------------------------------------------------
* MODIS vs LANDSAT
*-------------------------------------------------------------------------------
binscatter sh_treecover sh_treecover_modis, nq(100) ///
	xtitle("Tree Cover Share (MODIS, %)") ///
	ytitle("Tree Cover Share (Hansen, %)")
gr export "${plots}\binscatter_modis_landsat.pdf", replace as(pdf)


gl depvar "sh_treecover sh_treecover_modis"

foreach yvar of global depvar {

	local ylab : variable label `yvar'
	if "`ylab'" == "" local ylab "`yvar'"

	gl IF "if `yvar'>0"

	eststo clear

	** Column 1: X0 + X1_int
	eststo c1: reg std_`yvar' ${X1_int} ${X0} ${FEO} ${IF}, vce(cluster eafolk_id)
	gl n1 = `e(N)'

	** Column 2: X1 + X1_int
	eststo c2: reg std_`yvar' ${X1_int} ${X1} ${FE1} ${IF}, vce(cluster eafolk_id)
	gl n2 = `e(N)'

	** Column 3: X2 + X1_int
	eststo c3: reg std_`yvar' ${X1_int} ${X2} ${FE2} ${IF}, vce(cluster eafolk_id)
	gl n3 = `e(N)'

	** Column 4: X3 + X1_int  (adds tri_mean elev_mean)
	eststo c4: reg std_`yvar' ${X1_int} ${X3} ${FE3} ${IF}, vce(cluster eafolk_id)
	gl n4 = `e(N)'

	** Column 5: X4 + X1_int  (NEW — adds sh_protected)
	eststo c5: reg std_`yvar' ${X1_int} ${X4} ${FE4} ${IF}, vce(cluster eafolk_id)
	gl n5 = `e(N)'

	** Column 6: X0 + X2_int
	eststo c6: reg std_`yvar' ${X2_int} ${X0} ${FEO} ${IF}, vce(cluster eafolk_id)
	gl n6 = `e(N)'

	** Column 7: X1 + X2_int
	eststo c7: reg std_`yvar' ${X2_int} ${X1} ${FE1} ${IF}, vce(cluster eafolk_id)
	gl n7 = `e(N)'

	** Column 8: X2 + X2_int
	eststo c8: reg std_`yvar' ${X2_int} ${X2} ${FE2} ${IF}, vce(cluster eafolk_id)
	gl n8 = `e(N)'

	** Column 9: X3 + X2_int  (adds tri_mean elev_mean)
	eststo c9: reg std_`yvar' ${X2_int} ${X3} ${FE3} ${IF}, vce(cluster eafolk_id)
	gl n9 = `e(N)'

	** Column 10: X4 + X2_int  (NEW — adds sh_protected)
	eststo c10: reg std_`yvar' ${X2_int} ${X4} ${FE4} ${IF}, vce(cluster eafolk_id)
	gl n10 = `e(N)'

	*-------------------------------------------------------------------------------
	* Export
	*-------------------------------------------------------------------------------
	esttab c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 using "${tables}/Table_peroutcome_`yvar'_comparison.tex", ///
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
				`" & \multicolumn{10}{c}{`ylab' - Nature Exclusive} \\"' ///
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
				 `"Observations & ${n1} & ${n2} & ${n3} & ${n4} & ${n5} & ${n6} & ${n7} & ${n8} & ${n9} & ${n10} \\"' ///
				 `"\bottomrule"' ///
				 `"\end{tabular}"')
}


*-------------------------------------------------------------------------------
* ROBUSTNESS: Two-way clustering (eafolk_id + country_code)
*   Same per-outcome 10-column tables as the main block, but SEs are
*   two-way clustered at ethnic-folklore + country level via reghdfe.
*-------------------------------------------------------------------------------
gl depvar "bii sh_treecover sh_treecover_modis changewater sh_treeloss"

foreach yvar of global depvar {

	local ylab : variable label `yvar'
	if "`ylab'" == "" local ylab "`yvar'"

	eststo clear

	** Column 1: X0 + X1_int
	eststo c1: reghdfe std_`yvar' ${X1_int} ${X0}, absorb(country_code) vce(cluster eafolk_id country_code)
	gl n1 = `e(N)'

	** Column 2: X1 + X1_int
	eststo c2: reghdfe std_`yvar' ${X1_int} ${X1}, absorb(country_code) vce(cluster eafolk_id country_code)
	gl n2 = `e(N)'

	** Column 3: X2 + X1_int
	eststo c3: reghdfe std_`yvar' ${X1_int} ${X2}, absorb(country_code dom_climzone) vce(cluster eafolk_id country_code)
	gl n3 = `e(N)'

	** Column 4: X3 + X1_int  (adds tri_mean elev_mean)
	eststo c4: reghdfe std_`yvar' ${X1_int} ${X3}, absorb(country_code dom_climzone) vce(cluster eafolk_id country_code)
	gl n4 = `e(N)'

	** Column 5: X4 + X1_int  (adds sh_protected)
	eststo c5: reghdfe std_`yvar' ${X1_int} ${X4}, absorb(country_code dom_climzone) vce(cluster eafolk_id country_code)
	gl n5 = `e(N)'

	** Column 6: X0 + X2_int
	eststo c6: reghdfe std_`yvar' ${X2_int} ${X0}, absorb(country_code) vce(cluster eafolk_id country_code)
	gl n6 = `e(N)'

	** Column 7: X1 + X2_int
	eststo c7: reghdfe std_`yvar' ${X2_int} ${X1}, absorb(country_code) vce(cluster eafolk_id country_code)
	gl n7 = `e(N)'

	** Column 8: X2 + X2_int
	eststo c8: reghdfe std_`yvar' ${X2_int} ${X2}, absorb(country_code dom_climzone) vce(cluster eafolk_id country_code)
	gl n8 = `e(N)'

	** Column 9: X3 + X2_int  (adds tri_mean elev_mean)
	eststo c9: reghdfe std_`yvar' ${X2_int} ${X3}, absorb(country_code dom_climzone) vce(cluster eafolk_id country_code)
	gl n9 = `e(N)'

	** Column 10: X4 + X2_int  (adds sh_protected)
	eststo c10: reghdfe std_`yvar' ${X2_int} ${X4}, absorb(country_code dom_climzone) vce(cluster eafolk_id country_code)
	gl n10 = `e(N)'

	esttab c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 using "${tables}/Table_peroutcome_`yvar'_2wcluster.tex", ///
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
				`" & \multicolumn{10}{c}{`ylab' - Nature Exclusive (2-way clustered SEs)} \\"' ///
				`"\cmidrule(lr){2-11}"' ///
				`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
				`"\midrule"') ///
		postfoot(`" & & & & & & & & & & \\"' ///
				 `" HII control                       & No  & Yes & Yes & Yes & Yes & No  & Yes & Yes & Yes & Yes \\"' ///
				 `" Climatic-zone FE                  & No  & No  & Yes & Yes & Yes & No  & No  & Yes & Yes & Yes \\"' ///
				 `" Ruggedness \& elevation           & No  & No  & No  & Yes & Yes & No  & No  & No  & Yes & Yes \\"' ///
				 `" Share of protected land           & No  & No  & No  & No  & Yes & No  & No  & No  & No  & Yes \\"' ///
				 `" Country fixed effects             & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
				 `" Cluster (ethnic-folklore + country) & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
				 `" & & & & & & & & & & \\"' ///
				 `"Observations & ${n1} & ${n2} & ${n3} & ${n4} & ${n5} & ${n6} & ${n7} & ${n8} & ${n9} & ${n10} \\"' ///
				 `"\bottomrule"' ///
				 `"\end{tabular}"')
}


*-------------------------------------------------------------------------------
* ROBUSTNESS: Conley spatial standard errors (500 km cutoff)
*   Same per-outcome 10-column tables as the main block, but SEs are spatially
*   adjusted via acreg using the polygon centroid lat/lon, with a 500 km
*   distance threshold (~4.5 degrees, uniform kernel).
*   Requires: ssc install acreg
*-------------------------------------------------------------------------------
cap which acreg
if _rc ssc install acreg

* acreg requires id and time variables — for cross-sectional data set id=_n, time=1
cap drop _conley_id _conley_t
gen _conley_id = _n
gen _conley_t  = 1

gl depvar "bii sh_treecover sh_treecover_modis changewater sh_treeloss"

foreach yvar of global depvar {

	local ylab : variable label `yvar'
	if "`ylab'" == "" local ylab "`yvar'"

	eststo clear

	** Column 1: X0 + X1_int
	eststo c1: acreg std_`yvar' ${X1_int} ${X0} ${FEO}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n1 = `e(N)'

	** Column 2: X1 + X1_int
	eststo c2: acreg std_`yvar' ${X1_int} ${X1} ${FE1}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n2 = `e(N)'

	** Column 3: X2 + X1_int
	eststo c3: acreg std_`yvar' ${X1_int} ${X2} ${FE2}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n3 = `e(N)'

	** Column 4: X3 + X1_int  (adds tri_mean elev_mean)
	eststo c4: acreg std_`yvar' ${X1_int} ${X3} ${FE3}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n4 = `e(N)'

	** Column 5: X4 + X1_int  (adds sh_protected)
	eststo c5: acreg std_`yvar' ${X1_int} ${X4} ${FE4}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n5 = `e(N)'

	** Column 6: X0 + X2_int
	eststo c6: acreg std_`yvar' ${X2_int} ${X0} ${FEO}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n6 = `e(N)'

	** Column 7: X1 + X2_int
	eststo c7: acreg std_`yvar' ${X2_int} ${X1} ${FE1}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n7 = `e(N)'

	** Column 8: X2 + X2_int
	eststo c8: acreg std_`yvar' ${X2_int} ${X2} ${FE2}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n8 = `e(N)'

	** Column 9: X3 + X2_int  (adds tri_mean elev_mean)
	eststo c9: acreg std_`yvar' ${X2_int} ${X3} ${FE3}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n9 = `e(N)'

	** Column 10: X4 + X2_int  (adds sh_protected)
	eststo c10: acreg std_`yvar' ${X2_int} ${X4} ${FE4}, ///
		id(_conley_id) time(_conley_t) spatial latitude(lat) longitude(lon) dist(500)
	gl n10 = `e(N)'

	esttab c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 using "${tables}/Table_peroutcome_`yvar'_conley500km.tex", ///
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
				`" & \multicolumn{10}{c}{`ylab' - Nature Exclusive (Conley SEs, 500 km)} \\"' ///
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
				 `"Observations & ${n1} & ${n2} & ${n3} & ${n4} & ${n5} & ${n6} & ${n7} & ${n8} & ${n9} & ${n10} \\"' ///
				 `"\bottomrule"' ///
				 `"\end{tabular}"')
}

