/*------------------------------------------------------------------------------
PROJECT:
AUTHOR: JMJR
TOPIC: AES regressions with Nature Exclusive Measures (REPLICATION)
       — 1-way clustering at linguistic level (v98)
       — Standardized estimates (ZAE) per outcome
DATE:

NOTES: Mirrors regressions_envmeasures_aes_natureonly.do
       but with 1-way clustering at v98 (linguistic level) instead of eafolk_id.

       Standardizes each outcome before regression (ZAE), then averages
       results into an AES (Average Effect Size) table.

       Output filenames append `_aes_1wcluster_v98_zae` so this can run
       alongside other versions without overwriting.

       Requires: v98 to be present in folklore_envmeasures.dta
       Requires: ssc install estout (for esttab, eststo)
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
gl CL "eafolk_id"

*===============================================================================
* 1. Per-year ZAES regression — sh_nat_socl_atl on year-specific aes_z
*    Yearly outcomes are already in folklore_envmeasures.dta (built in
*    create_folklore_envmeasures.do): bii_{2000,2005,2010,2015,2020},
*    sh_treecover_{2000..2024}, sh_seasonwater_{2000..2021}.
*    BII has 5-year cadence, so we carry it forward: years 2000-2004 use
*    bii_2000, 2005-2009 use bii_2005, etc.
*    Full controls (X6). One regression per year y in 2000..2020.
*===============================================================================

* Storage matrices: one column per year (2000..2020 = 21 years)
local nyrs = 21
matrix b_y  = J(1, `nyrs', .)
matrix se_y = J(1, `nyrs', .)
matrix p_y  = J(1, `nyrs', .)

eststo clear

local j = 0
forval y = 2000/2020 {
	local ++j
	local biiy = floor(`y'/5)*5     // carry-forward 5-yr BII

	cap drop missing_values
	egen missing_values = rowmiss(bii_`biiy' sh_treecover_`y' sh_seasonwater_`y' ${X6} ${X1_int})

	cap drop std_bii_y`y'
	cap drop std_sh_treecover_y`y'
	cap drop std_sh_seasonwater_y`y'
	egen std_bii_y`y'           = std(bii_`biiy')        if ${IF}
	egen std_sh_treecover_y`y'  = std(sh_treecover_`y')  if ${IF}
	egen std_sh_seasonwater_y`y'= std(sh_seasonwater_`y') if ${IF}

	cap drop aes_z_y`y'
	egen aes_z_y`y' = rowmean(std_bii_y`y' std_sh_treecover_y`y' std_sh_seasonwater_y`y') if ${IF}

	eststo zaes_y`y': reg aes_z_y`y' ${X6} ${X1_int} if ${IF}, vce(cluster ${CL})

	matrix b_y[1,`j']  = _b[sh_nat_socl_atl]
	matrix se_y[1,`j'] = _se[sh_nat_socl_atl]
	local t = _b[sh_nat_socl_atl] / _se[sh_nat_socl_atl]
	matrix p_y[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "Year `y' (BII source: `biiy') — N = `e(N)' — coef = " _b[sh_nat_socl_atl]
}

* Column names → x-axis tick labels (2-digit years)
matrix colnames b_y  = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
matrix colnames se_y = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
matrix colnames p_y  = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"


*===============================================================================
* 2. Coefficient plot — sh_nat_socl_atl across years 2000..2020
*===============================================================================

* Requires: ssc install coefplot
* Uses the matrix-based syntax: coefplot reads (b, se, p) from the matrices we
* filled inside the loop, and the matrix column names become the x-axis ticks.

coefplot (matrix(b_y), se(se_y) aux(p_y) ///
          msymbol(O) msize(medium) color(black) ///
          ciopts(lcolor(black))), ///
    vert ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.1f)) ///
    l2title("Correlation with Environmental Measures (AES)", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject or object in a triplet") ///
           position(6) rows(1) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_sh_nat_socl_atl.pdf", replace as(pdf)

di _n "Coefplot exported: ${plots}/coefplot_acrossyears_sh_nat_socl_atl.pdf"


*===============================================================================
* 3. Per-year ZAES regression — Panel B (X2_int = sh_nat_scl_atl + sh_nat_ocl_atl)
*    Stores TWO sets of matrices, one per treatment variable.
*===============================================================================

* Storage matrices for subject (scl) and object (ocl)
local nyrs = 21
matrix b_scl  = J(1, `nyrs', .)
matrix se_scl = J(1, `nyrs', .)
matrix p_scl  = J(1, `nyrs', .)
matrix b_ocl  = J(1, `nyrs', .)
matrix se_ocl = J(1, `nyrs', .)
matrix p_ocl  = J(1, `nyrs', .)

local j = 0
forval y = 2000/2020 {
	local ++j
	local biiy = floor(`y'/5)*5

	cap drop missing_values
	egen missing_values = rowmiss(bii_`biiy' sh_treecover_`y' sh_seasonwater_`y' ${X6} ${X2_int})

	cap drop std_bii_y`y'
	cap drop std_sh_treecover_y`y'
	cap drop std_sh_seasonwater_y`y'
	egen std_bii_y`y'           = std(bii_`biiy')        if ${IF}
	egen std_sh_treecover_y`y'  = std(sh_treecover_`y')  if ${IF}
	egen std_sh_seasonwater_y`y'= std(sh_seasonwater_`y') if ${IF}

	cap drop aes_z_y`y'
	egen aes_z_y`y' = rowmean(std_bii_y`y' std_sh_treecover_y`y' std_sh_seasonwater_y`y') if ${IF}

	eststo zaes_b_y`y': reg aes_z_y`y' ${X6} ${X2_int} if ${IF}, vce(cluster ${CL})

	matrix b_scl[1,`j']  = _b[sh_nat_scl_atl]
	matrix se_scl[1,`j'] = _se[sh_nat_scl_atl]
	local t = _b[sh_nat_scl_atl] / _se[sh_nat_scl_atl]
	matrix p_scl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	matrix b_ocl[1,`j']  = _b[sh_nat_ocl_atl]
	matrix se_ocl[1,`j'] = _se[sh_nat_ocl_atl]
	local t = _b[sh_nat_ocl_atl] / _se[sh_nat_ocl_atl]
	matrix p_ocl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "Year `y' — subj coef = " _b[sh_nat_scl_atl] " — obj coef = " _b[sh_nat_ocl_atl]
}

* Column names → x-axis tick labels (2-digit years)
foreach M in b_scl se_scl p_scl b_ocl se_ocl p_ocl {
	matrix colnames `M' = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
}


*===============================================================================
* 4. Coefficient plot — sh_nat_scl_atl + sh_nat_ocl_atl across years 2000..2020
*    Two series on one plot, slightly offset so CIs don't overlap.
*===============================================================================

coefplot (matrix(b_scl), se(se_scl) aux(p_scl) ///
          msymbol(O) msize(medium) color(black) ///
          ciopts(lcolor(black))) ///
         (matrix(b_ocl), se(se_ocl) aux(p_ocl) ///
          msymbol(D) msize(medium) color(gs7) ///
          ciopts(lcolor(gs7))), ///
    vert  ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.1f)) ///
    l2title("Correlation with Environmental Measures (AES)", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject in a triplet" ///
                 4 "Share of motifs with at least one nature-only object in a triplet") ///
           position(6) rows(2) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_sh_nat_subj_obj.pdf", replace as(pdf)

di _n "Coefplot exported: ${plots}/coefplot_acrossyears_sh_nat_subj_obj.pdf"


*END
