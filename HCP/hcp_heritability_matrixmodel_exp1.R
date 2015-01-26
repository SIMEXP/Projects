
# -----------------------------------------------------------------------
# Program: UnivariateTwinAnalysis_MatrixRaw.R  
# Author: Yassine BHA
# Dataset: HCP
# DataType: Twin
# ModelType: ACE
# Field: Human Behavior Genetics 
#
# Purpose: 
#      Univariate Twin Analysis model to estimate causes of variation in HCP dataset 
#      Path style model input - Raw data input
# -----------------------------------------------------------------------------
#--------------- set Parameters----------------------------------
rm(list = ls())
# Load Library
require(OpenMx)
#Prepare Data
task  = 'motor'
fir_exp   = 'hcp_perc'
trial = 'rh'
fir_scale = 'sci80_scg80_scf83'
volume      = 24 # set times points or volume
num_clusters     = 83 # set the number of clusters 
permute = 1000 # set the number of permutations
cluster = c(10,63) # set the liste of  clusters
num_clusters = length(cluster)
#-------------------------------------------------------------------
#Read fir_pedigree combined file
myTwinData <- read.csv(paste("~/Dropbox/HCP_fir_heritability/niak_combine_scan_pedig_",task,"_",trial,"_",fir_scale,"_",fir_exp,".csv",sep=''), header=TRUE, na.strings="NaN")
names(myTwinData)[1000] <- "id_scan" # put the header for the scan's id
myTwinData$id_scan <- as.character(myTwinData$id_scan)
myTwinData <- myTwinData[complete.cases(myTwinData$Subject), ] # remove NA rows
allDup <- function (value) 
{ 
  duplicated(value) | duplicated(value, fromLast = TRUE) # function to detect non duplicated variable
}

myTwinData  <- myTwinData[allDup(myTwinData$Mother_ID),]  # remove non twins based on the familly id
write.csv(myTwinData,"~/Dropbox/HCP_fir_heritability/test.csv")# write a test table 
# check for duplicated subject IDs
if (any(duplicated(myTwinData$id_scan) == TRUE )) { warning( "the duplicated subjects ID are: \n" ,(myTwinData$id_scan[duplicated(myTwinData$id_scan)]),"\n") }
myTwinData <- myTwinData[!duplicated(myTwinData$id_scan),] # remove the dulicated subject

# bult empty table to store the result 
TabResult <- matrix(, nrow = (volume*num_clusters), ncol = 13) # empty matrix to hold results for each fir times point
colnames(TabResult) <- cbind("clust_vol","a2","a2_p","c2","c2_p","e2","e2_p","LL_ACE","LL_ACE_p","fir_mean","fir_var","shapiroPvalue_Tw1","shapiroPvalue_Tw2")
TabResult <- data.frame(TabResult)

for (ii in seq(num_clusters)) {
  cc = cluster[ii]
  for (vv in seq(volume)) {
    clust_vol_tmp <- paste("clust_",cc,"_v",vv,sep='')
    myTwinDataVars <- subset(myTwinData, Handedness >= 1 , c("id_scan","Mother_ID","Handedness","Zygosity",clust_vol_tmp)) #subset variable of interest
    myTwinDataVars  <- myTwinDataVars[allDup(myTwinDataVars$Mother_ID),] #remove the remaining non twins aftre subsetting variale
    myTwinDataVars <- myTwinDataVars[order(myTwinDataVars$Mother_ID),] # oredr table assending 
    TabTmp <- matrix(, nrow = dim(myTwinDataVars)[1]+1, ncol = dim(myTwinDataVars)[2]+3) # create empty matrix to hold Twin1 and Twin2 fir times point
    colnames(TabTmp) <- cbind(paste(names(myTwinDataVars['id_scan']),"_twin1",sep=''),
                              paste(names(myTwinDataVars['id_scan']),"_twin2",sep=''),
                              names(myTwinDataVars['Mother_ID']),
                              paste(names(myTwinDataVars[clust_vol_tmp]),"_twin1",sep=''),
                              paste(names(myTwinDataVars[clust_vol_tmp]),"_twin2",sep=''),
                              paste(names(myTwinDataVars['Handedness']),"_twin1",sep=''),
                              paste(names(myTwinDataVars['Handedness']),"_twin2",sep=''),
                              names(myTwinDataVars['Zygosity']))
    TabTmp <- data.frame(TabTmp) # empty data frame
    for (i in seq(dim(myTwinDataVars)[1]-1)) {
      if (myTwinDataVars[[c(2,i)]] == myTwinDataVars[[c(2,i+1)]] ) {
        TabTmp[i+1,] <- cbind(myTwinDataVars$id_scan[i],
                              myTwinDataVars$id_scan[i+1],
                              myTwinDataVars$Mother_ID[i],
                              myTwinDataVars[[clust_vol_tmp]][i],
                              myTwinDataVars[[clust_vol_tmp]][i+1],
                              myTwinDataVars$Handedness[i],
                              myTwinDataVars$Handedness[i+1],
                              myTwinDataVars$Zygosity[i])  # fill table
      }
    }
    
    TabTmp <- TabTmp[complete.cases(TabTmp),] # remove empty rows
    # set varables classes
    TabTmp[[paste(clust_vol_tmp,"_twin1",sep='')]] <- as.numeric(TabTmp[[paste(clust_vol_tmp,"_twin1",sep='')]])
    TabTmp[[paste(clust_vol_tmp,"_twin2",sep='')]] <- as.numeric(TabTmp[[paste(clust_vol_tmp,"_twin2",sep='')]])
    TabTmp[['Mother_ID']] <- as.numeric(TabTmp[['Mother_ID']])
    TabTmp[['Handedness_twin1']] <- as.numeric(TabTmp[['Handedness_twin1']])
    TabTmp[['Handedness_twin2']] <- as.numeric(TabTmp[['Handedness_twin2']])
    TabTmp[['Zygosity']] <- as.numeric(TabTmp[['Zygosity']])
    
    # create  permutation vector for fir_t1 and fir_t2
    
    set.seed(200)
    permTab<-replicate(permute,sample(TabTmp$Zygosity))
    permTab <- cbind(TabTmp$Zygosity,permTab)
    for (pp in seq(permute+1)) { #permutation test for Zygosity column
      TabTmp$Zygosity <- permTab[,pp]
      selVars <- c(paste(clust_vol_tmp,"_twin1",sep=''),paste(clust_vol_tmp,"_twin2",sep=''))
      mzData <- as.matrix(subset(TabTmp, Zygosity == 1,selVars))
      dzData <- as.matrix(subset(TabTmp, Zygosity == 2, selVars))
      
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
        
        fir_mean <- mean(myTwinDataVars[[clust_vol_tmp]])
        fir_var <- var(myTwinDataVars[[clust_vol_tmp]])
        shapiroPvalue_Tw1 <- shapiro.test(TabTmp[[paste(clust_vol_tmp,"_twin1",sep='')]])
        shapiroPvalue_Tw2 <- shapiro.test(TabTmp[[paste(clust_vol_tmp,"_twin2",sep='')]]) 
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
    
    TabResult[volume*(cc-1)+vv,] <- cbind(clust_vol_tmp,a2[1],a2_p,c2[1],c2_p,e2[1],e2_p,LL_ACE[1],LL_ACE_p,fir_mean,fir_var,shapiroPvalue_Tw1$p.value,shapiroPvalue_Tw2$p.value)
   
  } 

  # # # # # # # # # # plotly tools# # # # # # # # # # # # # 
  
  ## First, install and load the devtools package. From within the R console, enter:
  # install.packages("devtools")
  # library("devtools")
  
  ## Next, install plotly. From within the R console, enter:
  # install_github("ropensci/plotly")
  
  ## import the Plotly R library
  library(plotly)
  
  ## Authentication : to be exuted only the first time using a Plotly API!
  # set_credentials_file(username="YassineBHA", api_key="8d314mov50")
  
  ###
  p <- plotly(username="YassineBHA", key="8d314mov50")
  
  trace1 <- list(
    x = TabResult$clust_vol[volume*(cc-1)+seq(volume)], 
    y = as.numeric(TabResult$a2[volume*(cc-1)+seq(volume)]),
    name = "$a^2$",
    fillcolor = "rgba(31, 119, 180, 0.55)",
    mode = "lines+markers",
    fill = "tozeroy", 
    type = "scatter"
  )
  trace2 <- list(
    x = TabResult$clust_vol[volume*(cc-1)+seq(volume)], 
    y = as.numeric(TabResult$c2[volume*(cc-1)+seq(volume)]), 
    name = "$c^2$",
    mode = "markers",
    fill = "tonexty", 
    type = "scatter"
  )
  trace3 <- list(
    x = TabResult$clust_vol[volume*(cc-1)+seq(volume)], 
    y = as.numeric(TabResult$e2[volume*(cc-1)+seq(volume)]),
    name = "$e^2$",
    fill = "tonexty",
    type = "scatter",
    fillcolor = "rgba(44, 160, 44, 0.24)",
    mode = "none"
  )
  fn <- function(x) x/max(x, na.rm = TRUE)
  trace4 <- list(
    x = TabResult$clust_vol[volume*(cc-1)+seq(volume)], 
    y = fn(as.vector(scale(as.numeric(TabResult$fir_mean[volume*(cc-1)+seq(volume)])))),
    name = "fir_mean",
    type = "scatter",
    error_y = list(
      type = "percent", 
      value = 10, 
      array = fn(as.vector(scale(as.numeric(TabResult$fir_mean[volume*(cc-1)+seq(volume)])))), 
      visible = TRUE
    )
  )
  trace5 <- list(
    x = TabResult$clust_vol[volume*(cc-1)+seq(volume)], 
    y = as.numeric(TabResult$a2_p[volume*(cc-1)+seq(volume)]),
    name = "$a^2 P value$",
    mode = "lines",
    yaxis = "y2",
    type = "scatter",
    color = "rgb(148, 103, 189)"
  )
  data <- list(trace1, trace2, trace3, trace4, trace5)
  layout <- list(
    title = paste("clust_",as.character(cc),"_",fir_scale,"_",fir_exp,"_",task,"_",trial,sep = ''), 
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
  
  response <- p$plotly(data, kwargs=list(filename=paste("clust_",as.character(cc),"_",fir_scale,"_",fir_exp,"_",task,"_",trial,sep = ''),
                                         layout = layout, 
                                         fileopt="overwrite"))
  filename <- response$filename
  TabResultTmp <- TabResult[volume*(cc-1)+seq(volume),]
  TabResultTmp$a2 <- as.numeric(TabResultTmp$a2)
  TabResultTmp$a2_p <- as.numeric(TabResultTmp$a2_p)
  TabResultTmp$c2 <- as.numeric(TabResultTmp$c2)
  TabResultTmp$c2_p <- as.numeric(TabResultTmp$c2_p)
  TabResultTmp$e2 <- as.numeric(TabResultTmp$e2)
  TabResultTmp$e2_p <- as.numeric(TabResultTmp$e2_p)
  TabResultTmp$LL_ACE <- as.numeric(TabResultTmp$LL_ACE)
  TabResultTmp$LL_ACE_p <- as.numeric(TabResultTmp$LL_ACE_p)
  TabResultTmp$fir_mean <- as.numeric(TabResultTmp$fir_mean)
  TabResultTmp$fir_var <- as.numeric(TabResultTmp$fir_var)
  TabResultTmp$shapiroPvalue_Tw1 <- as.numeric(TabResultTmp$shapiroPvalue_Tw1)
  TabResultTmp$shapiroPvalue_Tw2 <- as.numeric(TabResultTmp$shapiroPvalue_Tw2)
  # Write csv copy of the results table for each cluster
  write.csv(TabResultTmp, file = paste("~/Dropbox/HCP_fir_heritability/" , paste("clust_",as.character(cc),"_",fir_scale,"_",fir_exp,"_",task,"_",trial,".csv",sep = ''),sep = ''))
  
} 


TabResult$a2 <- as.numeric(TabResult$a2)
TabResult$a2 <- as.numeric(TabResult$a2_p)
TabResult$c2 <- as.numeric(TabResult$c2)
TabResult$c2 <- as.numeric(TabResult$c2_p)
TabResult$e2 <- as.numeric(TabResult$e2)
TabResult$e2 <- as.numeric(TabResult$e2_p)
TabResult$LL_ACE <- as.numeric(TabResult$LL_ACE)
TabResult$LL_ACE <- as.numeric(TabResult$LL_ACE_p)
TabResult$fir_mean <- as.numeric(TabResult$fir_mean)
TabResult$fir_var <- as.numeric(TabResult$fir_var)
TabResult$shapiroPvalue_Tw1 <- as.numeric(TabResult$shapiroPvalue_Tw1)
TabResult$shapiroPvalue_Tw2 <- as.numeric(TabResult$shapiroPvalue_Tw2)

# Write a hdf5 copy of the results table 
# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
library(rhdf5)
h5createFile(paste("clust_",as.character(cc),"_",fir_scale,"_",fir_exp,"_",task,"_",trial,sep = ''))
h5write(TabResult,paste("clust_",as.character(cc),"_",fir_scale,"_",fir_exp,"_",task,"_",trial,sep = ''),"TabResult")

# Write csv copy of the results table 
write.csv(TabResult, file = paste("~/Dropbox/HCP_fir_heritability/" , paste("scale",num_clusters,"_",fir_exp,"_",task,"_",trial,".csv",sep = ''),sep = ''))
write.csv(TabTmp, file = paste("~/Dropbox/HCP_fir_heritability/" , paste("clust_",as.character(cc),"_",fir_scale,"_TABTMP_",fir_exp,"_",task,"_",trial,".csv",sep = ''),sep = ''))





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