
# -----------------------------------------------------------------------
# Program: UnivariateTwinAnalysis_MatrixRaw.R  
# Author: Yassine BHA
# Dataset: twins_perusse
# DataType: Twin
# ModelType: ACE
# Field: Human Behavior Genetics 
#
# Purpose: 
#      Univariate Twin Analysis model to estimate causes of variation in HCP dataset 
#      Path style model input - Raw data input
# -----------------------------------------------------------------------------
#--------------- set Parameters----------------------------------
# Load Library
require(OpenMx)
require(pracma)
#Prepare Data
rm(list = ls())
#-----------------------------------------------------------------------
fir_norm   = 'perc'
scale = 'sci10_scg7_scf6'
scrub = 'noscrub'
num_clusters  =  str2num(substr(scale, start=strfind(scale,"scf")+3,nchar(scale)))# the number of clusters 
permute = 1 # set the number of permutations
subtypes = 5 +1 # 5 subtytes plus one part
cluster = seq(num_clusters) # set the liste of  clusters
#num_clusters = length(cluster)
#-------------------------------------------------------------------
#Read fir_pedigree combined file
#myTwinData <- read.csv(paste("/media/yassinebha/database2/Google_Drive/twins_movie/stability_fir_all_sad_blocs_", scrub ,"_" ,fir_norm, "/combine_scan_pedig_fir_",fir_norm,"_subtypes_weights_scale_",scale,".csv",sep=''), header=TRUE, na.strings="NaN")
myTwinData <- read.csv(paste("~/Google_Drive/twins_movie/stability_fir_all_sad_blocs_", scrub ,"_" ,fir_norm, "/combine_scan_pedig_fir_",fir_norm,"_subtypes_weights_scale_",scale,".csv",sep=''), header=TRUE, na.strings="NaN")
names(myTwinData)[1] <- "subj_id" # put the header for the scan's id
myTwinData$subj_id <- as.character(myTwinData$subj_id)
myTwinData <- myTwinData[complete.cases(myTwinData$subj_id), ] # remove NA rows
allDup <- function (value) 
{ 
  duplicated(value) | duplicated(value, fromLast = TRUE) # function to detect non duplicated variable
}

myTwinData  <- myTwinData[allDup(myTwinData$nofamill),]  # remove non twins based on the familly id
#write.csv(myTwinData,paste("/media/yassinebha/database2/Google_Drive/twins_movie/stability_fir_all_sad_blocs_", scrub ,"_" ,fir_norm,"/test.csv",sep = ''))# write a test table 
write.csv(myTwinData,paste("~/Google_Drive/twins_movie/stability_fir_all_sad_blocs_", scrub ,"_" ,fir_norm,"/test.csv",sep = ''))# write a test table 
# check for duplicated subject IDs
if (any(duplicated(myTwinData$subj_id) == TRUE )) { warning( "the duplicated subjects ID are: \n" ,(myTwinData$subj_id[duplicated(myTwinData$subj_id)]),"\n") }
myTwinData <- myTwinData[!duplicated(myTwinData$subj_id),] # remove the dulicated subject

# build an empty table to store the result 
TabResult <- matrix( nrow = ((subtypes)*num_clusters), ncol = 11) # empty matrix to hold results for each fir times point
colnames(TabResult) <- cbind("clust_subt","a2","a2_p","c2","c2_p","e2","e2_p","LL_ACE","LL_ACE_p","shapiroPvalue_Tw1","shapiroPvalue_Tw2")
TabResult <- data.frame(TabResult)

for (ii in seq(num_clusters)) {
  cc = cluster[ii]
  for (ss in seq(subtypes)) {
    if (ss == 1){
      clust_sub_tmp <- paste("net_",cc,"_part",sep='')
    } else {
    clust_sub_tmp <- paste("net_",cc,"_weight_subtype_",ss-1,sep='')
    }
    myTwinDataVars <- subset(myTwinData, zygotie == 0 | zygotie == 1, c("subj_id","nofamill","sexe","zygotie",clust_sub_tmp)) #subset variable of interest
    myTwinDataVars  <- myTwinDataVars[allDup(myTwinDataVars$nofamill),] #remove the remaining non twins aftre subsetting variale
    myTwinDataVars <- myTwinDataVars[order(myTwinDataVars$nofamill),] # oredr table assending 
    TabTmp <- matrix( nrow = dim(myTwinDataVars)[1]+1, ncol = dim(myTwinDataVars)[2]+3) # create empty matrix to hold Twin1 and Twin2 subtypes wheights and sexe
    colnames(TabTmp) <- cbind(paste(names(myTwinDataVars['subj_id']),"_twin1",sep=''),
                              paste(names(myTwinDataVars['subj_id']),"_twin2",sep=''),
                              names(myTwinDataVars['nofamill']),
                              paste(names(myTwinDataVars[clust_sub_tmp]),"_twin1",sep=''),
                              paste(names(myTwinDataVars[clust_sub_tmp]),"_twin2",sep=''),
                              paste(names(myTwinDataVars['sexe']),"_twin1",sep=''),
                              paste(names(myTwinDataVars['sexe']),"_twin2",sep=''),
                              names(myTwinDataVars['zygotie']))
    TabTmp <- data.frame(TabTmp) # empty data frame
    for (i in seq(dim(myTwinDataVars)[1]-1)) {
      if (myTwinDataVars[[c(2,i)]] == myTwinDataVars[[c(2,i+1)]] ) {
        TabTmp[i+1,] <- cbind(myTwinDataVars$subj_id[i],
                              myTwinDataVars$subj_id[i+1],
                              myTwinDataVars$nofamill[i],
                              myTwinDataVars[[clust_sub_tmp]][i],
                              myTwinDataVars[[clust_sub_tmp]][i+1],
                              myTwinDataVars$sexe[i],
                              myTwinDataVars$sexe[i+1],
                              myTwinDataVars$zygotie[i])  # fill table
      }
    }
    
    TabTmp <- TabTmp[complete.cases(TabTmp),] # remove empty rows
    # set varables classes
    TabTmp[[paste(clust_sub_tmp,"_twin1",sep='')]] <- as.numeric(TabTmp[[paste(clust_sub_tmp,"_twin1",sep='')]])
    TabTmp[[paste(clust_sub_tmp,"_twin2",sep='')]] <- as.numeric(TabTmp[[paste(clust_sub_tmp,"_twin2",sep='')]])
    TabTmp[['nofamill']] <- as.numeric(TabTmp[['nofamill']])
    TabTmp[['sexe_twin1']] <- as.numeric(TabTmp[['sexe_twin1']])
    TabTmp[['sexe_twin2']] <- as.numeric(TabTmp[['sexe_twin2']])
    TabTmp[['zygotie']] <- as.numeric(TabTmp[['zygotie']])
    
    # create  permutation vector for weight_t1 and weight_t2
#     
#     set.seed(200)
#     permTab<-replicate(permute,sample(TabTmp$zygotie)) # create permutation table
#     permTab <- cbind(TabTmp$zygotie,permTab) # first colomn as the real data
    
    set.seed(200)
    permTab_t1 <- replicate(permute,sample(TabTmp[[paste(clust_sub_tmp,"_twin1",sep='')]]))
    permTab_t1 <- cbind(TabTmp[[paste(clust_sub_tmp,"_twin1",sep='')]],permTab_t1) # first colomn as the real data
    set.seed(100)
    permTab_t2<-replicate(permute,sample(TabTmp[[paste(clust_sub_tmp,"_twin2",sep='')]]))
    permTab_t2 <- cbind(TabTmp[[paste(clust_sub_tmp,"_twin2",sep='')]],permTab_t2) # first colomn as the real data
    permTab <- cbind(permTab_t1,permTab_t2)
    
    for (pp in seq(permute+1)) { #permutation test for subtype weight column
      TabTmp[[paste(clust_sub_tmp,"_twin1",sep='')]] <- permTab[,pp]
      TabTmp[[paste(clust_sub_tmp,"_twin2",sep='')]] <- permTab[,pp+permute+1]
      selVars <- c(paste(clust_sub_tmp,"_twin1",sep=''),paste(clust_sub_tmp,"_twin2",sep=''))
      mzData <- as.matrix(subset(TabTmp, zygotie == 1,selVars))
      dzData <- as.matrix(subset(TabTmp, zygotie == 0, selVars))
      
      # compute mean and cov dz mz
      #     colMeans(mzData,na.rm=TRUE)
      #     colMeans(dzData,na.rm=TRUE)
      #     cov(mzData,use="complete")
      #     cov(dzData,use="complete")
      
      
      twinACEModel <- mxModel("twinACE",
                              mxModel("ACE",
                                      # Matrices a, c, and e to store a, c, and e path coefficients
                                      mxMatrix(
                                        type="Lower",
                                        nrow=1,
                                        ncol=1,
                                        free=TRUE,
                                        values=0.6,
                                        labels="a11",
                                        name="a"
                                      ),
                                      mxMatrix(
                                        type="Lower",
                                        nrow=1,
                                        ncol=1,
                                        free=TRUE,
                                        values=0.6,
                                        labels="c11",
                                        name="c"
                                      ),
                                      mxMatrix(
                                        type="Lower",
                                        nrow=1,
                                        ncol=1,
                                        free=TRUE,
                                        values=0.6,
                                        labels="e11",
                                        name="e"
                                      ),
                                      # Matrices A, C, and E compute variance components
                                      mxAlgebra(
                                        expression=a %*% t(a),
                                        name="A"
                                      ),
                                      mxAlgebra(
                                        expression=c %*% t(c),
                                        name="C"
                                      ),
                                      mxAlgebra(
                                        expression=e %*% t(e),
                                        name="E"
                                      ),
                                      # Matrix & Algebra for expected means vector
                                      mxMatrix(
                                        type="Full",
                                        nrow=1,
                                        ncol=1,
                                        free=TRUE,
                                        values=20,
                                        label="mean",
                                        name="Mean"
                                      ),
                                      mxAlgebra(
                                        expression= cbind(Mean,Mean),
                                        name="expMean"
                                      ),
                                      # Algebra for expected variance/covariance matrix in MZ
                                      mxAlgebra(
                                        expression=rbind (cbind(A + C + E , A + C),
                                                          cbind(A + C     , A + C + E)),
                                        name="expCovMZ"
                                      ),
                                      # Algebra for expected variance/covariance matrix in DZ
                                      mxAlgebra(
                                        expression=rbind (cbind(A + C + E     , 0.5 %x% A + C),
                                                          cbind(0.5 %x% A + C , A + C + E)),
                                        name="expCovDZ"
                                      )
                              ),
                              mxModel("MZ",
                                      mxData(
                                        observed=mzData,
                                        type="raw"
                                      ),
                                      mxFIMLObjective(
                                        covariance="ACE.expCovMZ",
                                        means="ACE.expMean",
                                        dimnames=selVars
                                      )
                              ),
                              mxModel("DZ",
                                      mxData(
                                        observed=dzData,
                                        type="raw"
                                      ),
                                      mxFIMLObjective(
                                        covariance="ACE.expCovDZ",
                                        means="ACE.expMean",
                                        dimnames=selVars
                                      )
                              ),
                              mxAlgebra(
                                expression=MZ.objective + DZ.objective,
                                name="minus2loglikelihood"
                              ),
                              mxAlgebraObjective("minus2loglikelihood")
      )
      twinACEFit <- mxRun(twinACEModel)
      if (pp == 1) {
        # Observed heritability estimate
        MZc <- mxEval(ACE.expCovMZ, twinACEFit)
        DZc <- mxEval(ACE.expCovDZ, twinACEFit)
        M <- mxEval(ACE.expMean, twinACEFit)
        A <- mxEval(ACE.A, twinACEFit)
        C <- mxEval(ACE.C, twinACEFit)
        E <- mxEval(ACE.E, twinACEFit)
        V <- (A+C+E)
        a2 <- A/V
        c2 <- C/V
        e2 <- E/V
        ACEest <- rbind(cbind(A,C,E),cbind(a2,c2,e2))
        LL_ACE <- mxEval(objective, twinACEFit)
        
        # test nornality of subtypes distribution
        shapiroPvalue_Tw1 <- shapiro.test(TabTmp[[paste(clust_sub_tmp,"_twin1",sep='')]])
        shapiroPvalue_Tw2 <- shapiro.test(TabTmp[[paste(clust_sub_tmp,"_twin2",sep='')]]) 
      }else {
        A <- mxEval(ACE.A, twinACEFit)
        C <- mxEval(ACE.C, twinACEFit)
        E <- mxEval(ACE.E, twinACEFit)
        V <- (A+C+E)
        a2[pp] <- A/V
        c2[pp] <- C/V
        e2[pp] <- E/V
        LL_ACE[pp] <- mxEval(objective, twinACEFit)  
      }
      
    }
    # P-value is the fraction of how many times the permuted heritability estimate is equal or more extreme than the observed 
    # heritability estimate
    a2_p = sum(abs(a2[2:NROW(a2)]) >= abs(a2[1])) / permute
    c2_p = sum(abs(c2[2:NROW(c2)]) >= abs(c2[1])) / permute
    e2_p = sum(abs(e2[2:NROW(e2)]) >= abs(e2[1])) / permute
    LL_ACE_p = sum(abs(LL_ACE[2:NROW(LL_ACE)]) >= abs(LL_ACE[1])) / permute
    
    TabResult[subtypes*(cc-1)+ss,] <- cbind(clust_sub_tmp,a2[1],a2_p,c2[1],c2_p,e2[1],e2_p,LL_ACE[1],LL_ACE_p,shapiroPvalue_Tw1$p.value,shapiroPvalue_Tw2$p.value)
   
  } 
  # # # # # # # # # # plotly tools# # # # # # # # # # # # # 
  
#   ## First, install and load the devtools package. From within the R console, enter:
#   #install.packages("viridis")
#   library("viridis")
#   
#   #install.packages("devtools")
#   library("devtools")
#   #devtools::install_github("ropensci/plotly")
#   
#   
#   ## import the Plotly R library
#   library(plotly)
#   
#   ## Authentication : to be exuted only the first time using a Plotly API!
#   # set_credentials_file(username="YassineBHA", api_key="8d314mov50")
  
  trace1 <- list(
    x = TabResult$clust_subt[subtypes*(cc-1)+seq(subtypes)], 
    y = as.numeric(TabResult$a2[subtypes*(cc-1)+seq(subtypes)]),
    name = "$a^2$",
    fillcolor = "rgba(31, 119, 180, 0.55)",
    mode = "lines+markers",
    fill = "tozeroy", 
    type = "scatter"
  )
  trace2 <- list(
    x = TabResult$clust_subt[subtypes*(cc-1)+seq(subtypes)], 
    y = as.numeric(TabResult$c2[subtypes*(cc-1)+seq(subtypes)]), 
    name = "$c^2$",
    mode = "markers",
    fill = "tonexty", 
    type = "scatter"
  )
  trace3 <- list(
    x = TabResult$clust_subt[subtypes*(cc-1)+seq(subtypes)], 
    y = as.numeric(TabResult$e2[subtypes*(cc-1)+seq(subtypes)]),
    name = "$e^2$",
    fill = "tonexty",
    type = "scatter",
    fillcolor = "rgba(44, 160, 44, 0.24)",
    mode = "none"
  )
  trace4 <- list(
    x = TabResult$clust_subt[subtypes*(cc-1)+seq(subtypes)], 
    y = as.numeric(TabResult$a2_p[subtypes*(cc-1)+seq(subtypes)]),
    name = "$a^2 P value$",
    mode = "lines",
    yaxis = "y2",
    type = "scatter",
    color = "rgb(148, 103, 189)"
  )
  data <- list(trace1, trace2, trace3, trace4)
  layout <- list(
    title = paste("clust_",as.character(cc),"_",scale,"_",fir_norm,"_",scrub,sep = ''), 
    xaxis = list(title = "Fir Times Points"), 
    yaxis = list(title = "Heritability Estimate"), 
    yaxis2 = list(
      title = "P_value", 
      titlefont = list(color = "rgb(148, 103, 189)"), 
      tickfont = list(color = "rgb(148, 103, 189)"), 
      side = "right", 
      overlaying = "y"
    )
  )
  x = TabResult$clust_subt[subtypes*(cc-1)+seq(subtypes)]
  plot_ly(x = x, y = trace1$y, name = trace1$name, line = list(shape = "linear"), filename=paste("clust_",as.character(cc),"_",scale,"_",fir_norm,"_",scrub,sep = '')) %>%
    add_trace(y = trace2$y, name = trace2$name, line = list(shape = "linear")) %>%
    add_trace(y = trace3$y, name = trace3$name, line = list(shape = "linear"))
  
  filename <- paste("clust_",as.character(cc),"_",scale,"_",fir_norm,"_",scrub,sep = '')
  TabResultTmp <- TabResult[(subtypes)*(cc-1)+seq(subtypes),]
  TabResultTmp$a2 <- as.numeric(TabResultTmp$a2)
  TabResultTmp$a2_p <- as.numeric(TabResultTmp$a2_p)
  TabResultTmp$c2 <- as.numeric(TabResultTmp$c2)
  TabResultTmp$c2_p <- as.numeric(TabResultTmp$c2_p)
  TabResultTmp$e2 <- as.numeric(TabResultTmp$e2)
  TabResultTmp$e2_p <- as.numeric(TabResultTmp$e2_p)
  TabResultTmp$LL_ACE <- as.numeric(TabResultTmp$LL_ACE)
  TabResultTmp$LL_ACE_p <- as.numeric(TabResultTmp$LL_ACE_p)
  TabResultTmp$shapiroPvalue_Tw1 <- as.numeric(TabResultTmp$shapiroPvalue_Tw1)
  TabResultTmp$shapiroPvalue_Tw2 <- as.numeric(TabResultTmp$shapiroPvalue_Tw2)
  # Write csv copy of the results table for each cluster
  write.csv(TabResultTmp, file = paste("/media/yassinebha/database2/Google_Drive/twins_movie/stability_fir_all_sad_blocs_",scrub,"_",fir_norm,"/",paste("clust_",as.character(cc),"_",scale,"_",fir_norm,"_",scrub,".csv",sep = ''),sep = ''))
  #write.csv(TabResultTmp, file = paste("~/Google_Drive/twins_movie/stability_fir_all_sad_blocs_",scrub,"_",fir_norm,"/",paste("clust_",as.character(cc),"_",scale,"_",fir_norm,"_",scrub,".csv",sep = ''),sep = ''))  
} 


TabResult$a2 <- as.numeric(TabResult$a2)
TabResult$a2 <- as.numeric(TabResult$a2_p)
TabResult$c2 <- as.numeric(TabResult$c2)
TabResult$c2 <- as.numeric(TabResult$c2_p)
TabResult$e2 <- as.numeric(TabResult$e2)
TabResult$e2 <- as.numeric(TabResult$e2_p)
TabResult$LL_ACE <- as.numeric(TabResult$LL_ACE)
TabResult$LL_ACE <- as.numeric(TabResult$LL_ACE_p)
TabResult$shapiroPvalue_Tw1 <- as.numeric(TabResult$shapiroPvalue_Tw1)
TabResult$shapiroPvalue_Tw2 <- as.numeric(TabResult$shapiroPvalue_Tw2)

# Write a hdf5 copy of the results table 
source("http://bioconductor.org/biocLite.R")
biocLite("rhdf5")
library(rhdf5)
h5createFile(paste("clust_",as.character(cc),"_",scale,"_",fir_norm,"_",scrub,sep = ''))
h5write(TabResult,paste("clust_",as.character(cc),"_",scale,"_",fir_norm,"_",scrub,sep = ''),"TabResult")

# Write csv copy of the results table 
write.csv(TabResult, file = paste("/media/yassinebha/database2/Google_Drive/twins_movie/" , paste("scale",num_clusters,"_",fir_norm,"_",scrub,".csv",sep = ''),sep = ''))
write.csv(TabTmp, file = paste("/media/yassinebha/database2/Google_Drive/twins_movie/" , paste("clust_",as.character(cc),"_",scale,"_TABTMP_",fir_norm,"_",scrub,".csv",sep = ''),sep = ''))





# #Run AE model
# twinAEModel <- mxRename(twinACEModel, "twinAE")
# 
# # drop shared environmental path
# twinAEModel$ACE.c <-
#   mxMatrix(
#     type="Full",
#     nrow=1,
#     ncol=1,
#     free=F,
#     values=0,
#     label="c11"
#   )
# 
# twinAEFit <- mxRun(twinAEModel)
# 
# MZc1 <- mxEval(ACE.expCovMZ, twinAEFit)
# DZc1 <- mxEval(ACE.expCovDZ, twinAEFit)
# A1 <- mxEval(ACE.A, twinAEFit)
# C1 <- mxEval(ACE.C, twinAEFit)
# E1 <- mxEval(ACE.E, twinAEFit)
# V1 <- (A1+C1+E1)
# a21 <- A1/V1
# c21 <- C1/V1
# e21 <- E1/V1
# AEest1 <- rbind(cbind(A1,C1,E1),cbind(a21,c21,e21))
# LL_AE1 <- mxEval(objective, twinAEFit)
# 
# #Run CE model
# twinCEModel <- mxRename(twinACEModel, "twinCE")
# # drop additive genetic path
# twinCEModel$ACE.a <-
#   mxMatrix(
#     type="Full",
#     nrow=1,
#     ncol=1,
#     free=F,
#     values=0,
#     label="a11"
#   )
# 
# twinCEFit <- mxRun(twinCEModel)
# 
# MZc2 <- mxEval(ACE.expCovMZ, twinCEFit)
# DZc2 <- mxEval(ACE.expCovDZ, twinCEFit)
# A2 <- mxEval(ACE.A, twinCEFit)
# C2 <- mxEval(ACE.C, twinCEFit)
# E2 <- mxEval(ACE.E, twinCEFit)
# V2 <- (A2+C2+E2)
# a22 <- A2/V2
# c22 <- C2/V2
# e22 <- E2/V2
# AEest2 <- rbind(cbind(A2,C2,E2),cbind(a22,c22,e22))
# LL_AE2 <- mxEval(objective, twinCEFit)