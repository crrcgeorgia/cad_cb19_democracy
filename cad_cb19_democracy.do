clear

cd "C:\Users\Rati\OneDrive\Other Projects\Caucasus analitical digest\2020 CB special\Data"


*use "making time-series\cb_ts.dta"

use "making time-series\CB2019_Georgia_response_22Jan2020.dta"

svyset PSU [pweight=INDWT], strata(SUBSTRATUM) fpc(NPSUSS) singleunit(certainty) || ID, fpc(NHHPSU) || _n, fpc(NADHH)


/// ===================================================================================================================
/// dependent variable: ATTDEM -- Which of these three statements is closest to your opinion?
/// Recoding pattern: 1 - "Democracy is preferable to any other kind of government"  0 "Everything esle" (non-response missing)
/// ===================================================================================================================
gen democracy = ATTDEM
recode democracy  (1=1) (2/3 = 0) (-2/-1 = 0) (-9 / -3 = .)


/// ===================================================================================================================
/// recoding base demographic model variables: sett, gender, age, education, havejob, minority
/// ===================================================================================================================

/// STRATUM -> settlement type variable
gen sett = STRATUM

/// gender -> gender variable
/// Recoding pattern: Female from 2 to 0
gen gender = RESPSEX
recode gender (2=0) /// female = 0 

/// age -> age variable
gen age = RESPAGE

/// EDUYRS => educatio2  - Education years 
gen education2 = EDUYRS
recode education2 (-3/-1 = .)

//// havejob => employement variable
/// Recoding pattern: 1 = employed  0 = not employed
gen havejob = EMPLSIT
recode havejob (5/6 = 1) (1/4 = 0) (7/8 = 0) (-9 / -1 = . )

///  ETHNIC -- Ethnicity of the respondent
/* 0 = Georgian   1 = Non-Georgian   */
gen minority = ETHNIC
recode minority (4 / 7 = 1)  (3 =0) (2=1) (1=1) (-9 / -1 = .)


/// ===================================================================================================================
/// Liberal democratic value proxies: telorance index; wom_acceptable; homo_tolerance; genequality2; genequality
/// ===================================================================================================================


/////////////////////////////   tolerance_index - marrying women  //////////////////////////// without Georgian MARWGEOr
foreach var of varlist MARWUSA MARWARM MARWAZE MARWITA MARWARA MARWGEO MARWIRA MARWJEW MARWKUR MARWRUS MARWTUR MARWUKR MARWIND MARWABK MARWOSS MARWARG MARWAZG MARWJW {
gen `var'r = `var' 
}

foreach var of varlist MARWUSAr MARWARMr MARWAZEr MARWITAr MARWARAr MARWGEOr MARWIRAr MARWJEWr MARWKURr MARWRUSr MARWTURr MARWUKRr MARWINDr MARWABKr MARWOSSr MARWARGr MARWAZGr MARWJWr {
recode `var' (-9 / -1 = 0)
}

gen tolerance_index = (MARWUSAr + MARWARMr + MARWAZEr + MARWITAr + MARWARAr  + MARWIRAr + MARWJEWr + MARWKURr + MARWRUSr + MARWTURr + MARWUKRr + MARWINDr + MARWABKr + MARWOSSr + MARWARGr + MARWAZGr + MARWJWr)

//// women tollerancy index

foreach var of varlist ACCVODK ACCTOBA ACCSEPL ACCSEBM ACCMARR ACCCOHB {
gen `var'r = `var'
}

foreach var of varlist ACCVODKr ACCTOBAr ACCSEPLr ACCSEBMr ACCCOHBr {
recode `var' (-5 = 1) (-5= 1) (-3/ -1 = .) (1/100 = 0)
}

gen wom_acceptable = (ACCVODKr + ACCTOBAr + ACCSEPLr + ACCSEBMr + ACCCOHBr)

drop ACCVODKr ACCTOBAr ACCSEPLr ACCSEBMr ACCMARRr ACCCOHBr

/// homo_tolerance

gen homo_tolerance = NEIGHBOR 
recode homo_tolerance (6=1) (1/5 = 0) (7/9 = 0) (-2/-1 = 0) (-9 / -3 = .)

//// Equality variables

/// GENBREA -- Who should normally be the breadwinner in families in Georgia – a man or a woman
//// APTINHERT -- The household only owns one apartment.Who should inherit the apartment?
/// recoding pattern equall = 1 , rest = 0

gen genequality=GENBREA
recode genequality (3=1) (1/2=0) (-1=.)


gen genequality2=APTINHERT
recode genequality2 (3=1) (1/2=0)(4=0)(-2/-1=.)


Stop

/// ===================================================================================================================================================================
/// logit model democracy support:  base demo model + liberal values proxies
/// ====================================================================================================================================================================

svy: logit democracy i.sett gender age education2 havejob minority tolerance_index  
margins, at(tolerance_index=(0 2 5 8 11 14 17))
marginsplot

svy: logit democracy i.sett gender age education2 havejob minority wom_acceptable 
margins, at(wom_acceptable=(0 1 2 3 4 5))
marginsplot

svy: logit democracy i.sett gender age education2 havejob minority  homo_tolerance
margins, at(homo=(0 1 ))
marginsplot

svy: logit democracy i.sett gender age education2 havejob minority genequality  
margins, at(genequality=(0 1 ))
marginsplot

svy: logit democracy i.sett gender age education2 havejob minority  genequality2
margins, at(genequality2=(0 1 ))
marginsplot


/// ======================================================================================================================================================================
/// OUTREG2  - command to create a charts for regression coefficients / odds ratios table in MS Word document
/// To install OUTREG2 command in your stata use this command: ssc install outreg2
/// ======================================================================================================================================================================
svy: logit democracy i.sett gender age education2 havejob minority tolerance_index  
outreg2 using myreg2.doc, replace ctitle(Model 1 Logit coeff) 

svy: logit democracy i.sett gender age education2 havejob minority wom_acceptable 
outreg2 using myreg2.doc, append ctitle(Model 2 Logit coeff) 

svy: logit democracy i.sett gender age education2 havejob minority  homo_tolerance
outreg2 using myreg2.doc, append ctitle(Model 3 Logit coeff) 

svy: logit democracy i.sett gender age education2 havejob minority genequality  
outreg2 using myreg2.doc, append ctitle(Model 4 Logit coeff) 

svy: logit democracy i.sett gender age education2 havejob minority  genequality2
outreg2 using myreg2.doc, append ctitle(Model 5 Logit coeff) 

