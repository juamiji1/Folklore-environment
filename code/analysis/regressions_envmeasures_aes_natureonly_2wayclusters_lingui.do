/*------------------------------------------------------------------------------
PROJECT:
AUTHOR: JMJR
TOPIC: Regressions with Nature Exclusive Measures (REPLICATION) — ZAES with 2-way clusters (v98 + country)
DATE:

NOTES: Mirrors regressions_envmeasures_aes_natureonly_NEW_2wayclusters.do but
       the two-way cluster is (v98, country_code) instead of
       (eafolk_id, country_code) via reghdfe.

       The AES (avg_effect) block is omitted because avg_effect does not
       support multi-way clustering. Only the ZAES outcome is reported here.

       Output filename ends in `_2wcluster_v98` so it can run alongside the
       eafolk_id variant without overwriting it.

       Requires: ssc install reghdfe ; ssc install ftools
       Requires: v98 to be present in folklore_envmeasures.dta — if missing,
       add `v98` to the keep list in create_folklore_envmeasures.do.
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


*===============================================================================
* 1. Preparing everything for estimating ZAES
*
*===============================================================================
use "${data}/final/folklore_envmeasures.dta", clear

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

gl X1 "${countrycodes}"
gl X2 "hii ${countrycodes}"
gl X3 "hii ${domclimezone} ${countrycodes}"
gl X4 "hii elev_mean ${domclimezone} ${countrycodes}"
gl X5 "hii elev_mean tri_mean ${domclimezone} ${countrycodes}"
gl X6 "hii elev_mean tri_mean sh_protected ${domclimezone} ${countrycodes}"

gl IF "hii!=. & missing_values==0"
gl CL "v98 country_code"

*-------------------------------------------------------------------------------
* Labels for the table title
*-------------------------------------------------------------------------------
la var bii                "Biodiversity Intactness Index"
la var sh_treecover       "Tree Cover Share (Hansen)"
la var sh_treecover_modis "Tree Cover Share (MODIS)"
la var changewater        "Surface Water Change"
la var hii                "Human Influence Index"
la var sh_treeloss        "Tree Loss Share (treeloss / 2000 tree cover)"
la var sh_permwater_base  "Permanent Surface Water"
la var sh_seasonwater_base "Seasonal Surface Water"


*===============================================================================
* Z-AES results — one outcome, 12 columns, 2-way clustered SEs (v98 + country)
*
*===============================================================================
gl depvars  "bii sh_treecover sh_seasonwater_base"
gl zdepvars "std_bii std_sh_treecover std_sh_seasonwater_base"

*-------------------------------------------------------------------------------
* Estimations
*-------------------------------------------------------------------------------
eststo clear

forval c=1/6{

	local k=`c'+6

	* First specification: zaes ~ sh_nat_socl_atl
	cap drop missing_values
	egen missing_values = rowmiss(${depvars} ${X`c'} ${X1_int})

	foreach yvar of global depvars {
		cap drop std_`yvar'
		egen std_`yvar'= std(`yvar') if ${IF}
	}

	cap drop aes_z
	egen aes_z = rowmean(${zdepvars}) if ${IF}

	* Estimation of 1st spec — reghdfe with 2-way clustered SEs (v98 + country)
	eststo zaes`c': reghdfe aes_z ${X`c'} ${X1_int} if ${IF}, noabsorb vce(cluster ${CL}) keepsing
	gl n`c'   = "`e(N)'"
	gl clf`c' = "`e(N_clust1)'"
	gl clc`c' = "`e(N_clust2)'"

	summ aes_z if e(sample)==1
	gl my`c' = "`=string(round(r(mean), .001), "%9.3f")'"
	gl sd`c' = "`=string(round(r(sd),   .001), "%9.3f")'"

	* Second specification: zaes ~ sh_nat_scl_atl + sh_nat_ocl_atl
	cap drop missing_values
	egen missing_values = rowmiss(${depvars} ${X`c'} ${X2_int})

	foreach yvar of global depvars {
		cap drop std_`yvar'
		egen std_`yvar'= std(`yvar') if ${IF}
	}

	cap drop aes_z
	egen aes_z = rowmean(${zdepvars}) if ${IF}

	* Estimation of 2nd spec — reghdfe with 2-way clustered SEs (v98 + country)
	eststo zaes`k': reghdfe aes_z ${X`c'} ${X2_int} if ${IF}, noabsorb vce(cluster ${CL}) keepsing
	gl n`k'   = "`e(N)'"
	gl clf`k' = "`e(N_clust1)'"
	gl clc`k' = "`e(N_clust2)'"

	summ aes_z if e(sample)==1
	gl my`k' = "`=string(round(r(mean), .001), "%9.3f")'"
	gl sd`k' = "`=string(round(r(sd),   .001), "%9.3f")'"
}

*-------------------------------------------------------------------------------
* Table
*-------------------------------------------------------------------------------
esttab zaes1 zaes2 zaes3 zaes5 zaes6 zaes7 zaes8 zaes9 zaes11 zaes12 ///
	using "${tables}/Table_folklore_zaes_natureonly_2wcluster_v98.tex", ///
	keep(sh_nat_socl_atl sh_nat_scl_atl sh_nat_ocl_atl) ///
	coeflabels( ///
		sh_nat_socl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}" ///
		sh_nat_scl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
		sh_nat_ocl_atl  "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}") ///
	se nocons star(* 0.10 ** 0.05 *** 0.01) ///
	label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
	booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{10}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{10}{c}{Environmental Measures (ZAES) - Nature Exclusive (2-way clustered SEs: v98 + country)} \\"' ///
			`"\cmidrule(lr){2-11}"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"' ///
			`"\midrule"') ///
	postfoot(`" & & & & & & & & & & \\"' ///
			 `" HII control               & No  & Yes & Yes & Yes & Yes & No  & Yes & Yes & Yes & Yes \\"' ///
			 `" Climatic-zone FE          & No  & No  & Yes & Yes & Yes & No  & No  & Yes & Yes & Yes \\"' ///
			 `" Ruggedness + Elevation    & No  & No  & No  & Yes & Yes & No  & No  & No  & Yes & Yes \\"' ///
			 `" Share of protected land   & No  & No  & No  & No  & Yes & No  & No  & No  & No  & Yes \\"' ///
			 `" Country fixed effects     & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\"' ///
			 `" & & & & & & & & & & \\"' ///
			 `"Observations & ${n1} & ${n2} & ${n3} & ${n5} & ${n6} & ${n7} & ${n8} & ${n9} & ${n11} & ${n12} \\"' ///
			 `"Mean of dep. var. & ${my1} & ${my2} & ${my3} & ${my5} & ${my6} & ${my7} & ${my8} & ${my9} & ${my11} & ${my12} \\"' ///
			 `"Linguistic clusters & ${clf1} & ${clf2} & ${clf3} & ${clf5} & ${clf6} & ${clf7} & ${clf8} & ${clf9} & ${clf11} & ${clf12} \\"' ///
			 `"Country clusters & ${clc1} & ${clc2} & ${clc3} & ${clc5} & ${clc6} & ${clc7} & ${clc8} & ${clc9} & ${clc11} & ${clc12} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "Z-AES with 2-way clustered SEs (v98 + country) — table completed!"


*END
