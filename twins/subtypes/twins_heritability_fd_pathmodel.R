
# Parameters
rm(list = ls())
require(OpenMx)
path_root = '/home/yassinebha/Google_Drive/twins_movie/'
scrub = 'noscrub'
path_fmri = paste(path_root,'fmri_preprocess_',scrub,.Platform$file.sep,sep = '');
permute = 100000 # set the number of permutations

# Load Data
#Read fd_pedigree combined file
myTwinData <- read.csv(paste(path_fmri, "/combine_pedig_fd_",scrub,".csv",sep=''), header=TRUE, na.strings="NaN")
myTwinData <- myTwinData[complete.cases(myTwinData$id_scan_pedig), ] # remove NA rows
allDup <- function (value) 
{ 
  duplicated(value) | duplicated(value, fromLast = TRUE) # function to detect non duplicated variable
}
# remove non twins based on the familly id
myTwinData  <- myTwinData[allDup(myTwinData$nofamill),]  

# check for duplicated subject IDs
if (any(duplicated(myTwinData$id_scan_pedig) == TRUE )) { warning( "the duplicated subjects ID are: \n" ,(myTwinData$id_scan_pedig[duplicated(myTwinData$id_scan_pedig)]),"\n") }
myTwinData <- myTwinData[!duplicated(myTwinData$id_scan_pedig),] # remove the dulicated subject
myTwinData  <- myTwinData[allDup(myTwinData$nofamill),]  # remove non twins based on the familly id (second round after removing extra subjects)
write.csv(myTwinData,paste(path_fmri, "/combine_pedig_fd_",scrub,"_CLEAN_test.csv",sep=''))# write a test table 

# build an empty table to store the result 
TabResult <- matrix( nrow = 1, ncol = 11) # empty matrix to hold results for each fir times point
colnames(TabResult) <- cbind("","a2","a2_p","c2","c2_p","e2","e2_p","LL_ACE","LL_ACE_p","shapiroPvalue_Tw1","shapiroPvalue_Tw2")
TabResult <- data.frame(TabResult)

# Re-arrange pedigre-fd to fit openMX input format
myTwinDataVars <- subset(myTwinData, zygotie == 0 | zygotie == 1, c("id_scan_pedig","nofamill","sexe","zygotie","FD")) #subset variable of interest
myTwinDataVars  <- myTwinDataVars[allDup(myTwinDataVars$nofamill),] #remove the remaining non twins aftre subsetting variale
myTwinDataVars <- myTwinDataVars[order(myTwinDataVars$nofamill),] # oredr table assending 
TabTmp <- matrix( nrow = dim(myTwinDataVars)[1]+1, ncol = dim(myTwinDataVars)[2]+3) # create empty matrix to hold Twin1 and Twin2 subtypes wheights and sexe
colnames(TabTmp) <- cbind(paste(names(myTwinDataVars['id_scan_pedig']),"_twin1",sep=''),
                          paste(names(myTwinDataVars['id_scan_pedig']),"_twin2",sep=''),
                          names(myTwinDataVars['nofamill']),
                          paste(names(myTwinDataVars['FD']),"_twin1",sep=''),
                          paste(names(myTwinDataVars['FD']),"_twin2",sep=''),
                          paste(names(myTwinDataVars['sexe']),"_twin1",sep=''),
                          paste(names(myTwinDataVars['sexe']),"_twin2",sep=''),
                          names(myTwinDataVars['zygotie']))
TabTmp <- data.frame(TabTmp) # empty data frame
for (i in seq(dim(myTwinDataVars)[1]-1)) {
  if (myTwinDataVars[[c(2,i)]] == myTwinDataVars[[c(2,i+1)]] ) {
    TabTmp[i+1,] <- cbind(myTwinDataVars$id_scan_pedig[i],
                          myTwinDataVars$id_scan_pedig[i+1],
                          myTwinDataVars$nofamill[i],
                          myTwinDataVars$FD[i],
                          myTwinDataVars$FD[i+1],
                          myTwinDataVars$sexe[i],
                          myTwinDataVars$sexe[i+1],
                          myTwinDataVars$zygotie[i])  # fill table
  }
}
TabTmp <- TabTmp[complete.cases(TabTmp),] # remove empty rows
# set varables classes
TabTmp[['FD_twin1']] <- as.numeric(TabTmp[['FD_twin1']])
TabTmp[['FD_twin2']] <- as.numeric(TabTmp[['FD_twin2']])
TabTmp[['nofamill']] <- as.numeric(TabTmp[['nofamill']])
TabTmp[['sexe_twin1']] <- as.numeric(TabTmp[['sexe_twin1']])
TabTmp[['sexe_twin2']] <- as.numeric(TabTmp[['sexe_twin2']])
TabTmp[['zygotie']] <- as.numeric(TabTmp[['zygotie']])

# create  permutation vector for FD twin1 and 2
set.seed(200)
permTab_t1 <- replicate(permute,sample(TabTmp[['FD_twin1']]))
permTab_t1 <- cbind(TabTmp[['FD_twin1']],permTab_t1) # first colomn as the real data
set.seed(100)
permTab_t2<-replicate(permute,sample(TabTmp[['FD_twin2']]))
permTab_t2 <- cbind(TabTmp[['FD_twin2']],permTab_t2) # first colomn as the real data
permTab <- cbind(permTab_t1,permTab_t2)
#permutation test for FD column
for (pp in seq(permute+1)) { 
  TabTmp[['FD_twin1']] <- permTab[,pp]
  TabTmp[['FD_twin2']] <- permTab[,pp+permute+1]
  
  # Select Variables for Analysis
  selVars <- c('FD_twin1','FD_twin2')
  mzData <- as.matrix(subset(TabTmp, zygotie == 1,selVars))
  dzData <- as.matrix(subset(TabTmp, zygotie == 0, selVars))
  aceVars   <- c("A1","C1","E1","A2","C2","E2")
  
#   # Generate Descriptive Statistics
#   colMeans(mzData,na.rm=TRUE)
#   colMeans(dzData,na.rm=TRUE)
#   cov(mzData,use="complete")
#   cov(dzData,use="complete")
  
  # Path objects for Multiple Groups
  manifestVars=selVars
  latentVars=aceVars
  # variances of latent variables
  latVariances <- mxPath( from=aceVars, arrows=2,
                          free=FALSE, values=1 )
  # means of latent variables
  latMeans     <- mxPath( from="one", to=aceVars, arrows=1,
                          free=FALSE, values=0 )
  # means of observed variables
  obsMeans     <- mxPath( from="one", to=selVars, arrows=1,
                          free=TRUE, values=20, labels="mean" )
  # path coefficients for twin 1
  pathAceT1    <- mxPath( from=c("A1","C1","E1"), to="FD_twin1", arrows=1,
                          free=TRUE, values=.5,  label=c("a","c","e") )
  # path coefficients for twin 2
  pathAceT2    <- mxPath( from=c("A2","C2","E2"), to="FD_twin2", arrows=1,
                          free=TRUE, values=.5,  label=c("a","c","e") )
  # covariance between C1 & C2
  covC1C2      <- mxPath( from="C1", to="C2", arrows=2,
                          free=FALSE, values=1 )
  # covariance between A1 & A2 in MZ twins
  covA1A2_MZ   <- mxPath( from="A1", to="A2", arrows=2,
                          free=FALSE, values=1 )
  # covariance between A1 & A2 in DZ twins
  covA1A2_DZ   <- mxPath( from="A1", to="A2", arrows=2,
                          free=FALSE, values=.5 )
  
  # Data objects for Multiple Groups
  dataMZ       <- mxData( observed=mzData, type="raw" )
  dataDZ       <- mxData( observed=dzData, type="raw" )
  
  # Combine Groups
  paths        <- list( latVariances, latMeans, obsMeans,
                        pathAceT1, pathAceT2, covC1C2 )
  modelMZ      <- mxModel(model="MZ", type="RAM", manifestVars=selVars,
                          latentVars=aceVars, paths, covA1A2_MZ, dataMZ )
  modelDZ      <- mxModel(model="DZ", type="RAM", manifestVars=selVars,
                          latentVars=aceVars, paths, covA1A2_DZ, dataDZ )
  minus2ll     <- mxAlgebra( expression=MZ.fitfunction + DZ.fitfunction,
                             name="minus2loglikelihood" )
  obj          <- mxFitFunctionAlgebra( "minus2loglikelihood" )
  modelACE     <- mxModel(model="ACE", modelMZ, modelDZ, minus2ll, obj )
  
  # Run Model
  fitACE       <- mxRun(modelACE)

  if (pp == 1) { 
    sumACE    <- summary(fitACE)
    # Generate & Print Output
    # additive genetic variance, a^2
    A  <- mxEval(a*a, fitACE)
    # shared environmental variance, c^2
    C  <- mxEval(c*c, fitACE)
    # unique environmental variance, e^2
    E  <- mxEval(e*e, fitACE)
    # total variance
    V  <- (A+C+E)
    # standardized A
    a2 <- A/V
    # standardized C
    c2 <- C/V
    # standardized E
    e2 <- E/V
    # table of estimates
    estACE <- rbind(cbind(A,C,E),cbind(a2,c2,e2))
    # likelihood of ACE model
    LL_ACE <- mxEval(fitfunction, fitACE)
    
    # test nornality of subtypes distribution
    shapiroPvalue_Tw1 <- shapiro.test(TabTmp[['FD_twin1']])
    shapiroPvalue_Tw2 <- shapiro.test(TabTmp[['FD_twin2']]) 
  }else {
    # additive genetic variance, a^2
    A  <- mxEval(a*a, fitACE)
    # shared environmental variance, c^2
    C  <- mxEval(c*c, fitACE)
    # unique environmental variance, e^2
    E  <- mxEval(e*e, fitACE)
    # total variance
    V  <- (A+C+E)
    # standardized A
    a2[pp] <- A/V
    # standardized C
    c2[pp] <- C/V
    # standardized E
    e2[pp] <- E/V
    # likelihood of ACE model
    LL_ACE[pp] <- mxEval(fitfunction, fitACE)
  }

}
# P-value is the fraction of how many times the permuted heritability estimate is equal or more extreme than the observed 
# heritability estimate
a2_p = sum(abs(a2[2:NROW(a2)]) >= abs(a2[1])) / permute
c2_p = sum(abs(c2[2:NROW(c2)]) >= abs(c2[1])) / permute
e2_p = sum(abs(e2[2:NROW(e2)]) >= abs(e2[1])) / permute
LL_ACE_p = sum(abs(LL_ACE[2:NROW(LL_ACE)]) >= abs(LL_ACE[1])) / permute

TabResult[1,] <- cbind('FD',a2[1],a2_p,c2[1],c2_p,e2[1],e2_p,LL_ACE[1],LL_ACE_p,shapiroPvalue_Tw1$p.value,shapiroPvalue_Tw2$p.value)
 
