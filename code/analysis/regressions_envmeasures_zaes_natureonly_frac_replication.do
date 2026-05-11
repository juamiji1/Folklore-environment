/*------------------------------------------------------------------------------
PROJECT:
AUTHOR: JMJR
TOPIC: ZAES with multi-cluster SEs (single coef, 4 SE rows)
       — Country-level ethnolinguistic fractionalization filter (frac >= 0.15)
DATE:

NOTES: Mirrors regressions_envmeasures_zaes_natureonly_replication.do but
       restricts the sample to countries with within-country area Herfindahl-
       implied fractionalization at or above 0.15:

           share_i,c = area_km2_i / Σ area_km2 within country c
           HHI_c     = Σ_i share_i,c²
           frac_c    = 1 - HHI_c

       This drops countries dominated by a single Ethnologue polygon (where
       within-country FE identification rests on too few "effective" units).

       SE bracket conventions (matches econ-paper convention):
         (se)        Folklore-ethnicity (eafolk_id)
         [se]        Ethnic clusters     (v114)
         {se}        Country             (country_code)
         ((se))      Linguistic          (v114 + country_code)

       Output: Table_folklore_zaes_natureonly_frac.tex.
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
* Country-level ethnolinguistic fractionalization
*   share_i,c = area_km2_i / Σ area_km2 within country c
*   HHI_c     = Σ_i share_i,c²
*   frac_c    = 1 - HHI_c
*-------------------------------------------------------------------------------
cap drop tot_area_country share_country hhi_country frac_country keep_country keep_country_top35

bysort country_code: egen tot_area_country = total(area_km2)
gen share_country = area_km2 / tot_area_country

bysort country_code: egen hhi_country = total(share_country^2)
gen frac_country = 1 - hhi_country

gen byte keep_country =(frac_country >= 0.15)

* Alternative filter: drop the top 35 percent of polygons by HHI
*   (= keep the bottom 65 percent → drop the LEAST diverse countries by HHI).
*   `hhi_country' is the same value for every polygon in a given country, so
*   the 65th-percentile cutoff is taken across the polygon-level distribution.
_pctile hhi_country, p(65)
gen byte keep_country_top35 = (hhi_country <= r(r1))

drop tot_area_country share_country hhi_country

summ frac_country, d

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

* Note: keep_country == 1 enforces the fractionalization filter on every regression.
gl IF "hii!=. & missing_values==0 & keep_country == 1"

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
* 2. ZAES estimation — same regression with 4 clusterings stacked under each coef
*===============================================================================

* Clustering vars (order = SE row order in the table)
*   row 1  ( )       eafolk_id     Folklore-ethnicity
*   row 2  [ ]       v114          Ethnic clusters
*   row 3  { }       country_code  Country
*   row 4  < >     	 v114 + country
local clvars `""eafolk_id" "v114" "country_code" "v114 country_code""'
local cspec_list "1 2 3 5 6"

gl depvars  "bii sh_treecover sh_seasonwater_base"
gl zdepvars "std_bii std_sh_treecover std_sh_seasonwater_base"

*-------------------------------------------------------------------------------
* Panel A: X1_int (sh_nat_socl_atl)
*-------------------------------------------------------------------------------
eststo clear
forval col = 1/5 {
	local c : word `col' of `cspec_list'

	cap drop missing_values
	egen missing_values = rowmiss(${depvars} ${X`c'} ${X1_int})

	foreach yvar of global depvars {
		cap drop std_`yvar'
		egen std_`yvar' = std(`yvar') if ${IF}
	}
	cap drop aes_z
	egen aes_z = rowmean(${zdepvars}) if ${IF}

	* Run once per cluster; first one becomes the active eststo, the others
	* contribute SE/p-value matrices and cluster counts via estadd.
	* foreach ... of local respects the quoted compound element "v114 country_code".
	* reghdfe handles 1-way and 2-way clustering uniformly.
	local i = 0
	foreach cl of local clvars {
		local ++i
		qui reghdfe aes_z ${X`c'} ${X1_int} if ${IF}, noabsorb vce(cluster `cl') keepsing

		matrix se`i' = r(table)["se", 1...]
		matrix p`i'  = r(table)["pvalue", 1...]

		* Cluster count = unique combinations of the cluster vars in the sample
		tempvar clkey
		qui egen `clkey' = group(`cl') if e(sample)
		qui distinct `clkey' if e(sample)
		local nc`i' = r(ndistinct)
		drop `clkey'

		if `i' == 1 {
			eststo a`col'
		}
		estadd matrix se`i'     = se`i' : a`col'
		estadd matrix p`i'      = p`i'  : a`col'
		estadd scalar nclust`i' = `nc`i'' : a`col'
	}
}

*-------------------------------------------------------------------------------
* Panel B: X2_int (sh_nat_scl_atl + sh_nat_ocl_atl)
*-------------------------------------------------------------------------------
forval col = 1/5 {
	local c : word `col' of `cspec_list'

	cap drop missing_values
	egen missing_values = rowmiss(${depvars} ${X`c'} ${X2_int})

	foreach yvar of global depvars {
		cap drop std_`yvar'
		egen std_`yvar' = std(`yvar') if ${IF}
	}
	cap drop aes_z
	egen aes_z = rowmean(${zdepvars}) if ${IF}

	local i = 0
	foreach cl of local clvars {
		local ++i
		qui reghdfe aes_z ${X`c'} ${X2_int} if ${IF}, noabsorb vce(cluster `cl') keepsing

		matrix se`i' = r(table)["se", 1...]
		matrix p`i'  = r(table)["pvalue", 1...]

		tempvar clkey
		qui egen `clkey' = group(`cl') if e(sample)
		qui distinct `clkey' if e(sample)
		local nc`i' = r(ndistinct)
		drop `clkey'

		if `i' == 1 {
			eststo b`col'
		}
		estadd matrix se`i'     = se`i' : b`col'
		estadd matrix p`i'      = p`i'  : b`col'
		estadd scalar nclust`i' = `nc`i'' : b`col'
	}
}


*===============================================================================
* 3. Build the table — Panel A (replace) + Panel B (append) in one tabular env
*===============================================================================

* Cell specs: each in its OWN quoted argument so esttab stacks them as rows
* (a single quoted string would put them as columns within one row).
*
* SE row 4 uses LaTeX math angle brackets $\langle$ ... $\rangle$. We build the
* dollar sign with char(36) to keep Stata from interpreting $\... as a macro.
local D     = char(36)
local angO  = "`D'\langle`D'"
local angC  = "`D'\rangle`D'"

*-------------------------------------------------------------------------------
* Panel A — open the tabular, write Panel A header + coefficients only
*-------------------------------------------------------------------------------
esttab a1 a2 a3 a4 a5 ///
	using "${tables}/Table_folklore_zaes_natureonly_frac_final.tex", ///
	keep(sh_nat_socl_atl) ///
	varlabels( ///
		sh_nat_socl_atl "\multirow{2}{*}{\shortstack[l]{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}", ///
		elist(sh_nat_socl_atl "\addlinespace[1em]")) ///
	cells(`"b(fmt(3))"' ///
	      `"se1(par("{\footnotesize (" ")}") star pvalue(p1) fmt(3))"' ///
	      `"se2(par("{\footnotesize [" "]}") star pvalue(p2) fmt(3))"' ///
	      `"se3(par("{\footnotesize \{" "\}}") star pvalue(p3) fmt(3))"' ///
	      `"se4(par("{\footnotesize `angO'" "`angC'}") star pvalue(p4) fmt(3))"') ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	label collabels(none) nolines nomtitles nonumbers nodepvars noobs booktabs fragment replace ///
	prehead(`"\begin{tabular}[t]{l*{5}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{5}{c}{Environmental Measures (AES) (frac $\geq$ 0.15)} \\"' ///
			`"\cmidrule(lr){2-6}"' ///
			`" & (1) & (2) & (3) & (4) & (5) \\"' ///
			`"\midrule"' ///
			`"\addlinespace"' ///
			`"& \multicolumn{5}{c}{\textit{Panel A. Subject or Object}} \\"' ///
			`"\addlinespace"')

*-------------------------------------------------------------------------------
* Panel B — append Panel B header, coefficients, controls grid (indicate),
*           obs / R² / cluster counts (stats), bottom rule + tabular close.
*-------------------------------------------------------------------------------
esttab b1 b2 b3 b4 b5 ///
	using "${tables}/Table_folklore_zaes_natureonly_frac_final.tex", ///
	keep(sh_nat_scl_atl sh_nat_ocl_atl) ///
	varlabels( ///
		sh_nat_scl_atl "\multirow{2}{*}{\shortstack[l]{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
		sh_nat_ocl_atl "\multirow{2}{*}{\shortstack[l]{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}", ///
		blist(sh_nat_ocl_atl "\addlinespace[1em]") ///
		elist(sh_nat_ocl_atl "\addlinespace[1em]")) ///
	cells(`"b(fmt(3))"' ///
	      `"se1(par("{\footnotesize (" ")}") star pvalue(p1) fmt(3))"' ///
	      `"se2(par("{\footnotesize [" "]}") star pvalue(p2) fmt(3))"' ///
	      `"se3(par("{\footnotesize \{" "\}}") star pvalue(p3) fmt(3))"' ///
	      `"se4(par("{\footnotesize `angO'" "`angC'}") star pvalue(p4) fmt(3))"') ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	label collabels(none) nolines nomtitles nonumbers nodepvars noobs booktabs fragment append ///
	indicate("HII control               = hii"                ///
			 "Climatic-zone FE          = dom_climzone_*"     ///
			 "Ruggedness + Elevation    = elev_mean tri_mean" ///
			 "Share of protected land   = sh_protected"       ///
			 "Country fixed effects     = country_code_*")    ///
	stats(N nclust1 nclust2 nclust3, ///
		  fmt(0) ///
		  labels("Observations" ///
				 "Ethnic groups" "Ethnic clusters" ///
				 "Countries")) ///
	prehead(`"& \multicolumn{5}{c}{\textit{Panel B. Subject vs Object}} \\"' ///
			`"\addlinespace"') ///
	prefoot(`"\addlinespace[1em]"') ///
	postfoot(`"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "ZAES (frac >= 0.15) replication completed!"


*===============================================================================
* 4. Alternative filter — drop top 35 percent of HHI distribution
*    (keep bottom 65 percent by HHI ⇒ drop the LEAST diverse countries)
*    Same multi-cluster SE structure, separate output table.
*===============================================================================

* Swap the country-filter inside ${IF}
gl IF "hii!=. & missing_values==0 & keep_country_top35 == 1"

*-------------------------------------------------------------------------------
* Panel A: X1_int (sh_nat_socl_atl)
*-------------------------------------------------------------------------------
eststo clear
forval col = 1/5 {
	local c : word `col' of `cspec_list'

	cap drop missing_values
	egen missing_values = rowmiss(${depvars} ${X`c'} ${X1_int})

	foreach yvar of global depvars {
		cap drop std_`yvar'
		egen std_`yvar' = std(`yvar') if ${IF}
	}
	cap drop aes_z
	egen aes_z = rowmean(${zdepvars}) if ${IF}

	local i = 0
	foreach cl of local clvars {
		local ++i
		qui reghdfe aes_z ${X`c'} ${X1_int} if ${IF}, noabsorb vce(cluster `cl') keepsing

		matrix se`i' = r(table)["se", 1...]
		matrix p`i'  = r(table)["pvalue", 1...]

		tempvar clkey
		qui egen `clkey' = group(`cl') if e(sample)
		qui distinct `clkey' if e(sample)
		local nc`i' = r(ndistinct)
		drop `clkey'

		if `i' == 1 {
			eststo a`col'
		}
		estadd matrix se`i'     = se`i' : a`col'
		estadd matrix p`i'      = p`i'  : a`col'
		estadd scalar nclust`i' = `nc`i'' : a`col'
	}
}

*-------------------------------------------------------------------------------
* Panel B: X2_int (sh_nat_scl_atl + sh_nat_ocl_atl)
*-------------------------------------------------------------------------------
forval col = 1/5 {
	local c : word `col' of `cspec_list'

	cap drop missing_values
	egen missing_values = rowmiss(${depvars} ${X`c'} ${X2_int})

	foreach yvar of global depvars {
		cap drop std_`yvar'
		egen std_`yvar' = std(`yvar') if ${IF}
	}
	cap drop aes_z
	egen aes_z = rowmean(${zdepvars}) if ${IF}

	local i = 0
	foreach cl of local clvars {
		local ++i
		qui reghdfe aes_z ${X`c'} ${X2_int} if ${IF}, noabsorb vce(cluster `cl') keepsing

		matrix se`i' = r(table)["se", 1...]
		matrix p`i'  = r(table)["pvalue", 1...]

		tempvar clkey
		qui egen `clkey' = group(`cl') if e(sample)
		qui distinct `clkey' if e(sample)
		local nc`i' = r(ndistinct)
		drop `clkey'

		if `i' == 1 {
			eststo b`col'
		}
		estadd matrix se`i'     = se`i' : b`col'
		estadd matrix p`i'      = p`i'  : b`col'
		estadd scalar nclust`i' = `nc`i'' : b`col'
	}
}

*-------------------------------------------------------------------------------
* Panel A — open the tabular, write Panel A header + coefficients only
*-------------------------------------------------------------------------------
esttab a1 a2 a3 a4 a5 ///
	using "${tables}/Table_folklore_zaes_natureonly_frac_top35_final.tex", ///
	keep(sh_nat_socl_atl) ///
	varlabels( ///
		sh_nat_socl_atl "\multirow{2}{*}{\shortstack[l]{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}", ///
		elist(sh_nat_socl_atl "\addlinespace[1em]")) ///
	cells(`"b(fmt(3))"' ///
	      `"se1(par("{\footnotesize (" ")}") star pvalue(p1) fmt(3))"' ///
	      `"se2(par("{\footnotesize [" "]}") star pvalue(p2) fmt(3))"' ///
	      `"se3(par("{\footnotesize \{" "\}}") star pvalue(p3) fmt(3))"' ///
	      `"se4(par("{\footnotesize `angO'" "`angC'}") star pvalue(p4) fmt(3))"') ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	label collabels(none) nolines nomtitles nonumbers nodepvars noobs booktabs fragment replace ///
	prehead(`"\begin{tabular}[t]{l*{5}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{5}{c}{Environmental Measures (AES) (drop top 35\% HHI)} \\"' ///
			`"\cmidrule(lr){2-6}"' ///
			`" & (1) & (2) & (3) & (4) & (5) \\"' ///
			`"\midrule"' ///
			`"\addlinespace"' ///
			`"& \multicolumn{5}{c}{\textit{Panel A. Subject or Object}} \\"' ///
			`"\addlinespace"')

*-------------------------------------------------------------------------------
* Panel B — append Panel B header, coefficients, controls grid (indicate),
*           obs / R² / cluster counts (stats), bottom rule + tabular close.
*-------------------------------------------------------------------------------
esttab b1 b2 b3 b4 b5 ///
	using "${tables}/Table_folklore_zaes_natureonly_frac_top35_final.tex", ///
	keep(sh_nat_scl_atl sh_nat_ocl_atl) ///
	varlabels( ///
		sh_nat_scl_atl "\multirow{2}{*}{\shortstack[l]{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
		sh_nat_ocl_atl "\multirow{2}{*}{\shortstack[l]{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}", ///
		blist(sh_nat_ocl_atl "\addlinespace[1em]") ///
		elist(sh_nat_ocl_atl "\addlinespace[1em]")) ///
	cells(`"b(fmt(3))"' ///
	      `"se1(par("{\footnotesize (" ")}") star pvalue(p1) fmt(3))"' ///
	      `"se2(par("{\footnotesize [" "]}") star pvalue(p2) fmt(3))"' ///
	      `"se3(par("{\footnotesize \{" "\}}") star pvalue(p3) fmt(3))"' ///
	      `"se4(par("{\footnotesize `angO'" "`angC'}") star pvalue(p4) fmt(3))"') ///
	starlevels(* 0.10 ** 0.05 *** 0.01) ///
	label collabels(none) nolines nomtitles nonumbers nodepvars noobs booktabs fragment append ///
	indicate("HII control               = hii"                ///
			 "Climatic-zone FE          = dom_climzone_*"     ///
			 "Ruggedness + Elevation    = elev_mean tri_mean" ///
			 "Share of protected land   = sh_protected"       ///
			 "Country fixed effects     = country_code_*")    ///
	stats(N nclust1 nclust2 nclust3, ///
		  fmt(0) ///
		  labels("Observations" ///
				 "Ethnic groups" "Ethnic clusters" ///
				 "Countries")) ///
	prehead(`"& \multicolumn{5}{c}{\textit{Panel B. Subject vs Object}} \\"' ///
			`"\addlinespace"') ///
	prefoot(`"\addlinespace[1em]"') ///
	postfoot(`"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "ZAES (drop top 35% HHI) replication completed!"


*END
