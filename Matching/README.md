This is a replication and also an extension of Gibson, James L. 2004. “Does Truth Lead to Reconciliation? Testing the 
Causal Assumptionsof the South African Truth and Reconciliation Process.” American Journal of Political Science 48(2)
:201-217.

These data come from a 2000-2001 survey in South Africa that Gibson used to study inter-racial attitudes ten years after 
the release of Nelson Mandela and seven years after the elections of 1994 that marked the formal end of the apartheid era.

I recoded RUSTAND RFRIEND2 RCRIME RTRUST RSELF RUNCOMP RBELIEV RNONE RPARTY to construct a reconciliation index and 
recorded TRUTH6 TRUTH1 TRUTH4 ATROC2 ATROC3 to construct a truth acceptance index. The treatment variable of interest 
is TRCKNOW (exposure to the Truth and Reconciliation commission). The empirical strategy of this paper is to regress the 
reconciliation index and the truth acceptance index on TRCKNOW to identify the effect of TRCKNOW on the reconciliation 
index and truth acceptance index. The problem with the identification strategy Gibson employed is that units in the 
treatment group and control group do not share a common support with respect to several pre-treatment covariates, thus 
matching is needed in assisting (note here: matching never identifies ATE!) to more accurately measure the local average 
treatment effect (LATE). The matching method that I use is the CEM matching through the operation of MatchiIt commend 
(http://gking.harvard.edu/cem). The selection pool of covariates is the list of variables in Table 2 of Gibson(2004). I 
select variables like age, race, profit from the old system, gender and language as the covariates I want to match. For 
readers the selection should be subject to your own careful consideration of which covariate could be regarded as having pre-treatment effect on the potential outcome. I also present test mechanisms (t-test and Kolmogorov-Smirnov test) to check whether the matching method acutally improves the balance of covariates for treatment and control groups. 

Keep in mind that CEM matching is just one of the matching methods that researchers could make use of to do matching. There are several other matching algorithms able to carry out efficient matching, such as Genetic Matching, Entropy Balance Matching, Mahalanobis Distance Matching. Check them out if you are interested in matching methods and see the difference between these methods in their matching results. 