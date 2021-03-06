rm(list=ls())
library(randomForest)
library(nlme)
library(cem)
library(MatchIt)

 
data <- read.dta("truthrec.dta")
 
## Recode Rustand
 
 
recodefunction <- function (x) {
  y <- recode(x, "1:2=-1; 3:5=1; 8:9=NA",as.numeric.result = T)
  return(y)
}
 
data$RUSTAND <- recodefunction(data$RUSTAND)
data$RFRIEND2 <- recodefunction(data$RFRIEND2)
data$RCRIME <- recodefunction(data$RCRIME)
data$RTRUST <- recodefunction(data$RTRUST)
data$RSELF <- recodefunction(data$RSELF)
data$RUNCOMP <- recodefunction(data$RUNCOMP)
data$RBELIEV <- recodefunction(data$RBELIEV)
data$RNONE <- recodefunction(data$RNONE)
data$RPARTY <- recodefunction(data$RPARTY)
 
## construct the reconciliation index
reconindex <- subset(data, select=c(RUSTAND,RFRIEND2,RCRIME,RTRUST,RSELF,RUNCOMP,RBELIEV,
                                    RNONE,RPARTY))
reconindex <- apply(as.matrix(reconindex), 1, sum)
data$reconindex <- reconindex
sum <- summary(reconindex)
 
 
## recode truth index
data$TRUTH6 <- recode(data$TRUTH6, "3:4 = 0; 1:2 = 1; 8:9 = NA")
data$TRUTH1 <- recode(data$TRUTH1, "3:4 = 1; 1:2 = 0; 8:9 = NA")
data$TRUTH4 <- recode(data$TRUTH4, "3:4 = 1; 1:2 = 0; 8:9 = NA")
data$ATROC2 <- recode(data$ATROC2, "3:5 = -0; 1:2 = 1; 8:9 = NA")
data$ATROC3 <- recode(data$ATROC3, "1:3 = -0; 4:5 = 1; 8:9 = NA")
 
## construct the truth index
truthindex <- subset(data, select=c(TRUTH6,TRUTH1,TRUTH4,ATROC2,ATROC3))
truthindex <- apply(as.matrix(truthindex), 1, sum)
data$truthindex <- truthindex
 
## recode treatment
trcknow <- recode(data$TRCKNOW, "1:2 = 1; 3:4 = 0; 8:9 = NA")
data$trcknow <- trcknow
 
## recode variables that need to be controlled
data$male <- recode(data$SEX, "1=1;else=0")
data$BLACK <- recode(data$RACE, "1=1; else=0") 
data$WHITE <- recode(data$RACE, "2=1; else=0")
data$COLOR <- recode(data$RACE, "3=1; else=0")
data$ASIAN <- recode(data$RACE, "4=1; else=0")
data$APARTH9 <- recode(data$APARTH9, "1=1; 2=0; else=NA")
data$MEDIA1 <- recode(data$MEDIA1, "8:9=NA")
data$HLANG <- recode(data$HLANG, "10=1;else=0")
 
## construct a dataset for matching
dataformatch <- na.omit(as.data.frame(cbind(reconindex, truthindex, 
                                   data$BLACK,data$WHITE, data$COLOR, 
                                   data$ASIAN, data$APARTH9, data$MEDIA1, 
                                   data$HLANG, data$EDUC, data$male, 
                                   data$AGE, data$trcknow)))
names(dataformatch) <- c("reconindex","truthindex","BLACK","WHITE","COLOR","ASIAN",
                         "APARTH9","MEDIA1","HLANG","EDUC","male","AGE","trcknow")
 
head(covariates)
##check the balance of covariates before matching
covariates <- dataformatch[,-c(1,2)]
mean.t.unmatch <- apply(subset(covariates, trcknow==1),2,mean)[-11] ## means of covariates under treatment
mean.c.unmatch <- apply(subset(covariates, trcknow==0),2,mean)[-11] ## means of covariates under control
sd.t.unmatch <- apply(subset(covariates, trcknow==1),2,sd)[-11]     ## s.d. of covariates under treatment
sd.c.unmatch <- apply(subset(covariates, trcknow==0),2,sd)[-11]     ## s.d. of covariates under control
ratiovar.umatch <- sd.t.unmatch^2/sd.c.unmatch^2[-11]               ## ratio of the treatment's s.d. to the control's
 
## balance test before matching
attach(covariates)
head(covariates)
 
treat.covariates <- subset(covariates, trcknow==1)
nrow(treat.covariates)
 
control.covariates <- subset(covariates, trcknow==0)
nrow(control.covariates)
 
rearrange.covariates <- rbind(treat.covariates, control.covariates)
rearrange.covariates <- rearrange.covariates[,-11]
 
t.test.unmatch <- rbind(as.matrix(apply(as.matrix(rearrange.covariates), 2, function(x) t.test(x[1:1485],x[1486:3127])$p.value)))
ks.test.unmatch <- rbind(as.matrix(apply(as.matrix(rearrange.covariates), 2, function(x) ks.test(x[1:1485],x[1486:3127])$p.value)))
 
## matching 
datamatched.cem <- matchit(trcknow~ BLACK + WHITE + COLOR + ASIAN + APARTH9 + MEDIA1 + HLANG + EDUC + male + AGE, data = dataformatch, method = "cem")

## extract matched data and use QQ plot to see the improvement after matching
datamatched<-match.data(datamatched.cem)
summary(datamatched.cem)
plot(datamatched.cem)
 
## t-test and k.s.-test after matching
treat.matched <- subset(datamatched, trcknow==1)
nrow(treat.matched)
 
control.matched <- subset(datamatched, trcknow==0)
nrow(control.matched)
 
head(rearrange.matched)
nrow(rearrange.matched)
 
rearrange.matched <- rbind(treat.matched, control.matched)
rearrange.matched <- rearrange.matched[,-c(1:2,11,13:16)]
 
t.test.matched <- rbind(as.matrix(apply(as.matrix(rearrange.matched), 2, function(x) t.test(x[1:1197],x[1198:2477])$p.value)))
ks.test.matched <- rbind(as.matrix(apply(as.matrix(rearrange.matched), 2, function(x) ks.test(x[1:1197],x[1198:2477])$p.value)))
 
 
z.out1 <- zelig(reconindex ~ trcknow + APARTH9 + MEDIA1 + EDUC + male + AGE, data=subset(datamatched, BLACK==1), model='ls',robust=T)
## does not make sense here to include HLANG in the model
summary(z.out1)
 
z.out2 <- zelig(reconindex ~ trcknow + APARTH9 + MEDIA1 + HLANG + EDUC + male + AGE, data=subset(datamatched, WHITE==1), model='ls',robust=T)
summary(z.out2)
 
z.out3 <- zelig(reconindex ~ trcknow + APARTH9 + MEDIA1 + HLANG + EDUC + male + AGE, data=subset(datamatched, COLOR==1), model='ls',robust=T)
summary(z.out3)
 
z.out4 <- zelig(reconindex ~ trcknow + MEDIA1 + EDUC + male + AGE, data=subset(datamatched, ASIAN==1), model='ls',robust=T)
summary(z.out4)
 
z.out5 <- zelig(truthindex ~ trcknow + APARTH9 + MEDIA1 + EDUC + male + AGE, data=subset(datamatched, BLACK==1), model='ls',robust=T)
summary(z.out5)
 
z.out6 <- zelig(truthindex ~ trcknow + APARTH9 + MEDIA1 + HLANG + EDUC + male + AGE, data=subset(datamatched, WHITE==1), model='ls',robust=T)
summary(z.out6)
 
z.out7 <- zelig(truthindex ~ trcknow + APARTH9 + MEDIA1 + HLANG + EDUC + male + AGE, data=subset(datamatched, COLOR==1), model='ls',robust=T)
summary(z.out7)
 
z.out8 <- zelig(truthindex ~ trcknow + MEDIA1 + EDUC + male + AGE, data=subset(datamatched, ASIAN==1), model='ls',robust=T)
summary(z.out8)
 
library(stargazer)
stargazer(z.out1, z.out2, z.out3, z.out4, digits=3, column.labels = c("Black","White","Colored","Asian"), keep.stat=c("n","rsq"), dep.var.caption = c(""), dep.var.labels.include = F,
          column.sep.width = "0.5pt", keep = c("trcknow","APARTH9","MEDIA1","HLANG","EDUC","male","AGE"), covariate.labels=c("Exposure to TRC","Profited from the system",
          "Exposure to Media","Language","Education","Male","AGE"), title = c("The effect on Reconciliation Index"))
 
stargazer(z.out5, z.out6, z.out7, z.out8, digits=3, column.labels = c("Black","White","Colored","Asian"), keep.stat=c("n","rsq"), dep.var.caption = c(""), dep.var.labels.include = F,
column.sep.width = "0.5pt", keep = c("trcknow","APARTH9","MEDIA1","HLANG","EDUC","male","AGE"), covariate.labels=c("Exposure to TRC","Profited from the system",
         "Exposure to Media","Language","Education","Male","AGE"), title = c("The effect on Truth Index"))
