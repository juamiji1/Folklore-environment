/*------------------------------------------------------------------------------
PROJECT: Folklore-environment
AUTHOR:  JMJR
TOPIC:   Master do-file — sets globals and runs create_data + regressions
DATE:

NOTES: Set the `run_*` locals below to 1/0 to toggle which steps execute.
       All downstream do-files read paths from the globals defined here and
       should NOT redefine `localpath`, `data`, `maps`, `plots`, `tables`,
       or `code`.
------------------------------------------------------------------------------*/

clear all
set more off

*-------------------------------------------------------------------------------
* Directories (user switch)
*-------------------------------------------------------------------------------
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Measures_work"
	gl code      "C:\Github\Folklore-environment\code\analysis"
	gl do        "C:\Github\ethnographic-atlas\code"
	gl plots     "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\plots"
	gl tables    "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\tables"
}
else {
	*gl localpath "C:\Users/`c(username)'\Dropbox\"
	*gl code      ""
	*gl do        ""
	*gl plots     ""
	*gl tables    ""
}

gl data "${localpath}\data"
gl maps "${localpath}\maps"

cd "${data}"

*-------------------------------------------------------------------------------
* Plot scheme
*-------------------------------------------------------------------------------
set scheme s2mono
capture grstyle init
capture grstyle title color black
capture grstyle color background white
capture grstyle color major_grid dimgray

/*-------------------------------------------------------------------------------
* 1. Data preparation
*-------------------------------------------------------------------------------
do "${code}/create_folklore_envmeasures.do"

*-------------------------------------------------------------------------------
* 2-5. AES / ZAES regressions (combined outcomes)
*-------------------------------------------------------------------------------
do "${code}/regressions_envmeasures_aes_natureonly.do"
do "${code}/regressions_envmeasures_aes_natureonly_1waycluster_lingui.do"
do "${code}/regressions_envmeasures_aes_natureonly_2wayclusters_ethnic.do"
do "${code}/regressions_envmeasures_aes_natureonly_2wayclusters_lingui.do"
do "${code}/regressions_envmeasures_aes_natureonly_conley500km.do"

*-------------------------------------------------------------------------------
* 6-9. Per-outcome regressions
*-------------------------------------------------------------------------------
do "${code}/regressions_envmeasures_peroutcome_natureonly.do"
do "${code}/regressions_envmeasures_peroutcome_natureonly_1waycluster_lingui.do"
do "${code}/regressions_envmeasures_peroutcome_natureonly_2wayclusters_ethnic.do"
do "${code}/regressions_envmeasures_peroutcome_natureonly_2wayclusters_lingui.do"
do "${code}/regressions_envmeasures_peroutcome_natureonly_conley500km.do"



do "${code}/regressions_envmeasures_peroutcome_natureonly_treecover_comparison.do"

di _n "Master pipeline finished."
