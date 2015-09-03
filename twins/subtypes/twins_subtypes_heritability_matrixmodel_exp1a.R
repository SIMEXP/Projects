require(OpenMx)
require(psych)

# Load Data
data(twinData)
describe(twinData, skew=F)

# Select Variables for Analysis
Vars      <- 'bmi'
nv        <- 1       # number of variables
ntv       <- nv*2    # number of total variables
selVars   <- paste(Vars,c(rep(1,nv),rep(2,nv)),sep="")   #c('bmi1','bmi2')

# Select Data for Analysis
mzData    <- subset(twinData, zyg==1, selVars)
dzData    <- subset(twinData, zyg==3, selVars)

# Generate Descriptive Statistics
colMeans(mzData,na.rm=TRUE)
colMeans(dzData,na.rm=TRUE)
cov(mzData,use="complete")
cov(dzData,use="complete")

# Set Starting Values
svMe      <- 20      # start value for means
svPa      <- .6      # start value for path coefficients (sqrt(variance/#ofpaths))

# ACE Model
# Matrices declared to store a, d, and e Path Coefficients
pathA     <- mxMatrix( type="Full", nrow=nv, ncol=nv,
                       free=TRUE, values=svPa, label="a11", name="a" )
pathC     <- mxMatrix( type="Full", nrow=nv, ncol=nv,
                       free=TRUE, values=svPa, label="c11", name="c" )
pathE     <- mxMatrix( type="Full", nrow=nv, ncol=nv,
                       free=TRUE, values=svPa, label="e11", name="e" )

# Matrices generated to hold A, C, and E computed Variance Components
covA      <- mxAlgebra( expression=a %*% t(a), name="A" )
covC      <- mxAlgebra( expression=c %*% t(c), name="C" )
covE      <- mxAlgebra( expression=e %*% t(e), name="E" )

# Algebra to compute total variances
covP      <- mxAlgebra( expression=A+C+E, name="V" )

# Algebra for expected Mean and Variance/Covariance Matrices in MZ & DZ twins
meanG     <- mxMatrix( type="Full", nrow=1, ncol=ntv,
                       free=TRUE, values=svMe, label="mean", name="expMean" )
covMZ     <- mxAlgebra( expression=rbind( cbind(V, A+C),
                                          cbind(A+C, V)), name="expCovMZ" )
covDZ     <- mxAlgebra( expression=rbind( cbind(V, 0.5%x%A+ 0.25%x%C),
                                          cbind(0.5%x%A+ 0.25%x%C , V)), name="expCovDZ" )

# Data objects for Multiple Groups
dataMZ    <- mxData( observed=mzData, type="raw" )
dataDZ    <- mxData( observed=dzData, type="raw" )

# Objective objects for Multiple Groups
expMZ     <- mxExpectationNormal( covariance="expCovMZ", means="expMean",
                                  dimnames=selVars )
expDZ     <- mxExpectationNormal( covariance="expCovDZ", means="expMean",
                                  dimnames=selVars )
funML     <- mxFitFunctionML()

# Combine Groups
pars      <- list( pathA, pathC, pathE, covA, covC, covE, covP )
modelMZ   <- mxModel( pars, meanG, covMZ, dataMZ, expMZ, funML, name="MZ" )
modelDZ   <- mxModel( pars, meanG, covDZ, dataDZ, expDZ, funML, name="DZ" )
fitML     <- mxFitFunctionMultigroup(c("MZ.fitfunction","DZ.fitfunction") )
AceModel  <- mxModel( "ACE", pars, modelMZ, modelDZ, fitML )

# Run ADE model
AceFit    <- mxRun(AceModel, intervals=T)
AceSumm   <- summary(AceFit)
AceSumm

# Generate ACE Model Output
estMean   <- mxEval(expMean, AceFit$MZ)       # expected mean
estCovMZ  <- mxEval(expCovMZ, AceFit$MZ)      # expected covariance matrix for MZ's
estCovDZ  <- mxEval(expCovDZ, AceFit$DZ)      # expected covariance matrix for DZ's
estVA     <- mxEval(a*a, AceFit)              # additive genetic variance, a^2
estVC     <- mxEval(c*c, AceFit)              # dominance variance, d^2
estVE     <- mxEval(e*e, AceFit)              # unique environmental variance, e^2
estVP     <- (estVA+estVC+estVE)              # total variance
estPropVA <- estVA/estVP                      # standardized additive genetic variance
estPropVC <- estVC/estVP                      # standardized dominance variance
estPropVE <- estVE/estVP                      # standardized unique environmental variance
estACE    <- rbind(cbind(estVA,estVC,estVE),  # table of estimates
                   cbind(estPropVA,estPropVC,estPropVE))
LL_ACE    <- mxEval(objective, AceFit)        # likelihood of ADE model

# Run AE model
AeModel   <- mxModel( AceFit, name="AE" )
AeModel   <- omxSetParameters( AeModel, labels="c11", free=FALSE, values=0 )
AeFit     <- mxRun(AeModel)

# Generate AE Model Output
estVA     <- mxEval(a*a, AeFit)               # additive genetic variance, a^2
estVE     <- mxEval(e*e, AeFit)               # unique environmental variance, e^2
estVP     <- (estVA+estVE)                    # total variance
estPropVA <- estVA/estVP                      # standardized additive genetic variance
estPropVE <- estVE/estVP                      # standardized unique environmental variance
estAE     <- rbind(cbind(estVA,estVE),        # table of estimates
                   cbind(estPropVA,estPropVE))
LL_AE     <- mxEval(objective, AeFit)         # likelihood of AE model

LRT_ACE_AE <- LL_AE - LL_ACE

#Print relevant output
estACE
estAE
LRT_ACE_AE
