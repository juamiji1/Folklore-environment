/*------------------------------------------------------------------------------
PROJECT:
AUTHOR: JMJR
TOPIC: Per-outcome regressions across years (2000–2020) — coefplots per outcome
DATE:

NOTES: Mirrors regressions_envmeasures_aes_natureonly_acrossyears.do but runs
       one regression per (year, outcome) pair instead of pooling outcomes
       into a ZAES. One coefplot is produced per outcome.

       Year ranges per outcome:
         * bii                 — 5-year cadence (2000, 2005, 2010, 2015, 2020)
                                 because the underlying raster is only 5-yearly.
         * sh_treecover        — 2000..2020 (yearly, from baseline minus loss)
         * sh_seasonwater      — 2000..2020 (yearly)

       Yearly outcomes already in folklore_envmeasures.dta (built in
       create_folklore_envmeasures.do):
         bii_{2000,2005,2010,2015,2020}, sh_treecover_{2000..2024},
         sh_seasonwater_{2000..2021}.

       Full controls (X6). 1-way clustering at eafolk_id.
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
* 1. BII — 5-year cadence (2000, 2005, 2010, 2015, 2020)
*===============================================================================

local years_bii "2000 2005 2010 2015 2020"
local nyrs_bii : word count `years_bii'

matrix b_bii  = J(1, `nyrs_bii', .)
matrix se_bii = J(1, `nyrs_bii', .)
matrix p_bii  = J(1, `nyrs_bii', .)

eststo clear

local j = 0
foreach y of local years_bii {
	local ++j

	cap drop missing_values
	egen missing_values = rowmiss(bii_`y' ${X6} ${X1_int})

	cap drop std_bii_y`y'
	egen std_bii_y`y' = std(bii_`y') if ${IF}

	eststo zbii_y`y': reg std_bii_y`y' ${X6} ${X1_int} if ${IF}, vce(cluster ${CL})

	matrix b_bii[1,`j']  = _b[sh_nat_socl_atl]
	matrix se_bii[1,`j'] = _se[sh_nat_socl_atl]
	local t = _b[sh_nat_socl_atl] / _se[sh_nat_socl_atl]
	matrix p_bii[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "BII year `y' — N = `e(N)' — coef = " _b[sh_nat_socl_atl]
}

matrix colnames b_bii  = "00" "05" "10" "15" "20"
matrix colnames se_bii = "00" "05" "10" "15" "20"
matrix colnames p_bii  = "00" "05" "10" "15" "20"

coefplot (matrix(b_bii), se(se_bii) aux(p_bii) ///
          msymbol(O) msize(large) color(black) ///
          ciopts(lcolor(black) lwidth(thick))), ///
    vert citop ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.3f)) ///
    l2title("Correlation with BII", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject or object in a triplet") ///
           position(6) rows(1) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_bii_sh_nat_socl_atl.pdf", replace as(pdf)

di _n "Coefplot exported: ${plots}/coefplot_acrossyears_bii_sh_nat_socl_atl.pdf"


*===============================================================================
* 2. Tree cover (Hansen) — yearly (2000..2020)
*===============================================================================

local nyrs_tc = 21

matrix b_tc  = J(1, `nyrs_tc', .)
matrix se_tc = J(1, `nyrs_tc', .)
matrix p_tc  = J(1, `nyrs_tc', .)

eststo clear

local j = 0
forval y = 2000/2020 {
	local ++j

	cap drop missing_values
	egen missing_values = rowmiss(sh_treecover_`y' ${X6} ${X1_int})

	cap drop std_sh_treecover_y`y'
	egen std_sh_treecover_y`y' = std(sh_treecover_`y') if ${IF}

	eststo ztc_y`y': reg std_sh_treecover_y`y' ${X6} ${X1_int} if ${IF}, vce(cluster ${CL})

	matrix b_tc[1,`j']  = _b[sh_nat_socl_atl]
	matrix se_tc[1,`j'] = _se[sh_nat_socl_atl]
	local t = _b[sh_nat_socl_atl] / _se[sh_nat_socl_atl]
	matrix p_tc[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "Tree cover year `y' — N = `e(N)' — coef = " _b[sh_nat_socl_atl]
}

matrix colnames b_tc  = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
matrix colnames se_tc = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
matrix colnames p_tc  = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"

coefplot (matrix(b_tc), se(se_tc) aux(p_tc) ///
          msymbol(O) msize(large) color(black) ///
          ciopts(lcolor(black) lwidth(thick))), ///
    vert citop ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.3f)) ///
    l2title("Correlation with Tree Cover", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject or object in a triplet") ///
           position(6) rows(1) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_sh_treecover_sh_nat_socl_atl.pdf", replace as(pdf)

di _n "Coefplot exported: ${plots}/coefplot_acrossyears_sh_treecover_sh_nat_socl_atl.pdf"


*===============================================================================
* 3. Seasonal surface water — yearly (2000..2020)
*===============================================================================

local nyrs_sw = 21

matrix b_sw  = J(1, `nyrs_sw', .)
matrix se_sw = J(1, `nyrs_sw', .)
matrix p_sw  = J(1, `nyrs_sw', .)

eststo clear

local j = 0
forval y = 2000/2020 {
	local ++j

	cap drop missing_values
	egen missing_values = rowmiss(sh_seasonwater_`y' ${X6} ${X1_int})

	cap drop std_sh_seasonwater_y`y'
	egen std_sh_seasonwater_y`y' = std(sh_seasonwater_`y') if ${IF}

	eststo zsw_y`y': reg std_sh_seasonwater_y`y' ${X6} ${X1_int} if ${IF}, vce(cluster ${CL})

	matrix b_sw[1,`j']  = _b[sh_nat_socl_atl]
	matrix se_sw[1,`j'] = _se[sh_nat_socl_atl]
	local t = _b[sh_nat_socl_atl] / _se[sh_nat_socl_atl]
	matrix p_sw[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "Seasonal water year `y' — N = `e(N)' — coef = " _b[sh_nat_socl_atl]
}

matrix colnames b_sw  = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
matrix colnames se_sw = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
matrix colnames p_sw  = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"

coefplot (matrix(b_sw), se(se_sw) aux(p_sw) ///
          msymbol(O) msize(large) color(black) ///
          ciopts(lcolor(black) lwidth(thick))), ///
    vert citop ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.3f)) ///
    l2title("Correlation with Seasonal Surface Water", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject or object in a triplet") ///
           position(6) rows(1) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_sh_seasonwater_sh_nat_socl_atl.pdf", replace as(pdf)

di _n "Coefplot exported: ${plots}/coefplot_acrossyears_sh_seasonwater_sh_nat_socl_atl.pdf"


*===============================================================================
* 4. Panel B — BII (5-year cadence): subject + object on one plot
*===============================================================================

local years_bii "2000 2005 2010 2015 2020"
local nyrs_bii : word count `years_bii'

matrix b_bii_scl  = J(1, `nyrs_bii', .)
matrix se_bii_scl = J(1, `nyrs_bii', .)
matrix p_bii_scl  = J(1, `nyrs_bii', .)
matrix b_bii_ocl  = J(1, `nyrs_bii', .)
matrix se_bii_ocl = J(1, `nyrs_bii', .)
matrix p_bii_ocl  = J(1, `nyrs_bii', .)

local j = 0
foreach y of local years_bii {
	local ++j

	cap drop missing_values
	egen missing_values = rowmiss(bii_`y' ${X6} ${X2_int})

	cap drop std_bii_y`y'
	egen std_bii_y`y' = std(bii_`y') if ${IF}

	eststo zbii_b_y`y': reg std_bii_y`y' ${X6} ${X2_int} if ${IF}, vce(cluster ${CL})

	matrix b_bii_scl[1,`j']  = _b[sh_nat_scl_atl]
	matrix se_bii_scl[1,`j'] = _se[sh_nat_scl_atl]
	local t = _b[sh_nat_scl_atl] / _se[sh_nat_scl_atl]
	matrix p_bii_scl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	matrix b_bii_ocl[1,`j']  = _b[sh_nat_ocl_atl]
	matrix se_bii_ocl[1,`j'] = _se[sh_nat_ocl_atl]
	local t = _b[sh_nat_ocl_atl] / _se[sh_nat_ocl_atl]
	matrix p_bii_ocl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "BII year `y' — subj coef = " _b[sh_nat_scl_atl] " — obj coef = " _b[sh_nat_ocl_atl]
}

foreach M in b_bii_scl se_bii_scl p_bii_scl b_bii_ocl se_bii_ocl p_bii_ocl {
	matrix colnames `M' = "00" "05" "10" "15" "20"
}

coefplot (matrix(b_bii_scl), se(se_bii_scl) aux(p_bii_scl) ///
          msymbol(O) msize(large) color(black) ///
          ciopts(lcolor(black) lwidth(thick))) ///
         (matrix(b_bii_ocl), se(se_bii_ocl) aux(p_bii_ocl) ///
          msymbol(D) msize(medium) color(gs7) ///
          ciopts(lcolor(gs7))), ///
    vert citop ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.3f)) ///
    l2title("Correlation with BII", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject in a triplet" ///
                 4 "Share of motifs with at least one nature-only object in a triplet") ///
           position(6) rows(2) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_bii_subj_obj.pdf", replace as(pdf)


*===============================================================================
* 5. Panel B — Tree cover (Hansen, yearly): subject + object on one plot
*===============================================================================

local nyrs_tc = 21

matrix b_tc_scl  = J(1, `nyrs_tc', .)
matrix se_tc_scl = J(1, `nyrs_tc', .)
matrix p_tc_scl  = J(1, `nyrs_tc', .)
matrix b_tc_ocl  = J(1, `nyrs_tc', .)
matrix se_tc_ocl = J(1, `nyrs_tc', .)
matrix p_tc_ocl  = J(1, `nyrs_tc', .)

local j = 0
forval y = 2000/2020 {
	local ++j

	cap drop missing_values
	egen missing_values = rowmiss(sh_treecover_`y' ${X6} ${X2_int})

	cap drop std_sh_treecover_y`y'
	egen std_sh_treecover_y`y' = std(sh_treecover_`y') if ${IF}

	eststo ztc_b_y`y': reg std_sh_treecover_y`y' ${X6} ${X2_int} if ${IF}, vce(cluster ${CL})

	matrix b_tc_scl[1,`j']  = _b[sh_nat_scl_atl]
	matrix se_tc_scl[1,`j'] = _se[sh_nat_scl_atl]
	local t = _b[sh_nat_scl_atl] / _se[sh_nat_scl_atl]
	matrix p_tc_scl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	matrix b_tc_ocl[1,`j']  = _b[sh_nat_ocl_atl]
	matrix se_tc_ocl[1,`j'] = _se[sh_nat_ocl_atl]
	local t = _b[sh_nat_ocl_atl] / _se[sh_nat_ocl_atl]
	matrix p_tc_ocl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "Tree cover year `y' — subj coef = " _b[sh_nat_scl_atl] " — obj coef = " _b[sh_nat_ocl_atl]
}

foreach M in b_tc_scl se_tc_scl p_tc_scl b_tc_ocl se_tc_ocl p_tc_ocl {
	matrix colnames `M' = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
}

coefplot (matrix(b_tc_scl), se(se_tc_scl) aux(p_tc_scl) ///
          msymbol(O) msize(large) color(black) ///
          ciopts(lcolor(black) lwidth(thick))) ///
         (matrix(b_tc_ocl), se(se_tc_ocl) aux(p_tc_ocl) ///
          msymbol(D) msize(medium) color(gs7) ///
          ciopts(lcolor(gs7))), ///
    vert citop ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.3f)) ///
    l2title("Correlation with Tree Cover (Hansen)", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject in a triplet" ///
                 4 "Share of motifs with at least one nature-only object in a triplet") ///
           position(6) rows(2) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_sh_treecover_subj_obj.pdf", replace as(pdf)


*===============================================================================
* 6. Panel B — Seasonal water (yearly): subject + object on one plot
*===============================================================================

local nyrs_sw = 21

matrix b_sw_scl  = J(1, `nyrs_sw', .)
matrix se_sw_scl = J(1, `nyrs_sw', .)
matrix p_sw_scl  = J(1, `nyrs_sw', .)
matrix b_sw_ocl  = J(1, `nyrs_sw', .)
matrix se_sw_ocl = J(1, `nyrs_sw', .)
matrix p_sw_ocl  = J(1, `nyrs_sw', .)

local j = 0
forval y = 2000/2020 {
	local ++j

	cap drop missing_values
	egen missing_values = rowmiss(sh_seasonwater_`y' ${X6} ${X2_int})

	cap drop std_sh_seasonwater_y`y'
	egen std_sh_seasonwater_y`y' = std(sh_seasonwater_`y') if ${IF}

	eststo zsw_b_y`y': reg std_sh_seasonwater_y`y' ${X6} ${X2_int} if ${IF}, vce(cluster ${CL})

	matrix b_sw_scl[1,`j']  = _b[sh_nat_scl_atl]
	matrix se_sw_scl[1,`j'] = _se[sh_nat_scl_atl]
	local t = _b[sh_nat_scl_atl] / _se[sh_nat_scl_atl]
	matrix p_sw_scl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	matrix b_sw_ocl[1,`j']  = _b[sh_nat_ocl_atl]
	matrix se_sw_ocl[1,`j'] = _se[sh_nat_ocl_atl]
	local t = _b[sh_nat_ocl_atl] / _se[sh_nat_ocl_atl]
	matrix p_sw_ocl[1,`j']  = 2*ttail(e(df_r), abs(`t'))

	di "Seasonal water year `y' — subj coef = " _b[sh_nat_scl_atl] " — obj coef = " _b[sh_nat_ocl_atl]
}

foreach M in b_sw_scl se_sw_scl p_sw_scl b_sw_ocl se_sw_ocl p_sw_ocl {
	matrix colnames `M' = "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"
}

coefplot (matrix(b_sw_scl), se(se_sw_scl) aux(p_sw_scl) ///
          msymbol(O) msize(large) color(black) ///
          ciopts(lcolor(black) lwidth(thick))) ///
         (matrix(b_sw_ocl), se(se_sw_ocl) aux(p_sw_ocl) ///
          msymbol(D) msize(medium) color(gs7) ///
          ciopts(lcolor(gs7))), ///
    vert citop ///
    yline(0, lcolor(gs10) lpattern(dash)) ///
    mlabcolor(black) mlabsize(vsmall) mlabpos(3) ///
    ylabel(, format(%9.3f)) ///
    l2title("Correlation with Seasonal Surface Water", size(medsmall)) ///
    b2title("Year", size(medium)) ///
    xlabel(, labsize(small)) ///
    legend(order(2 "Share of motifs with at least one nature-only subject in a triplet" ///
                 4 "Share of motifs with at least one nature-only object in a triplet") ///
           position(6) rows(2) size(small)) ///
    graphregion(color(white)) plotregion(color(white))

gr export "${plots}/coefplot_acrossyears_sh_seasonwater_subj_obj.pdf", replace as(pdf)


*END
