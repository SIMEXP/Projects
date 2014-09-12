#----------------------------------------------------------------------------------------------------------------------
#                                                             Twin_simulate
# Based on script in OpenMXUserGuide, p 15.
# Purpose: 
# 1-Test the stability of hertability estimate by decreasing the number of subjects until reaching 
# critical point where the script fail to retrive heritability from the simulated data.
# 2-define the critcal mz/dz ration for different sampe size 
#----------------------------------------------------------------------------------------------------------------------

# ########################################## simulated dataset #########################################
rm(list=ls())
require(OpenMx)   # not needed for the simulation, but will be needed when we come to model specification
require(MASS)    # needed for multivariate random number generation
simu <- "simu1c"  
mya2<-0.5 #Additive genetic variance component (a squared)
myc2<-0.3 #Common environment variance component (c squared)
mye2<-1-mya2-myc2 #Specific environment variance component (e squared)

my_rMZ <-mya2+myc2          # correlation between MZ twin1 and twin2
my_rDZ <- .5*mya2+myc2     # correlation between DZ twin 1 and twin 2
nb_subj <- 1000 # number of total subjects
step_seq <- 10 # step sequence to encrement the number of subjects
min_subj <- 10 #the minimum sample dataset size
percentil <- c(.25, .50, .75) # the sliding ratio MZ/DZ

for (nSub in seq(min_subj,nb_subj,step_seq)){
  seq_MzDz=as.integer(quantile(seq(nSub), percentil))
  for (nMz in seq_MzDz){
    nb_Mz = nMz
    nb_Dz = nSub - nMz
    
    set.seed(200)        # specified seed ensures same random number set generated on each run
    mzData <- mvrnorm (nb_Mz, c(0,0), matrix(c(1,my_rMZ,my_rMZ,1),2,2))
    set.seed(100)        # specified seed ensures same random number set generated on each run
    dzData <- mvrnorm (nb_Dz, c(0,0), matrix(c(1,my_rDZ,my_rDZ,1),2,2))
     
    colnames(mzData) <- c('twin1', 'twin2') # assign column names
    colnames(dzData) <- c('twin1', 'twin2')
#     summary(mzData)
#     summary(dzData)
#     colMeans(mzData,na.rm=TRUE) #na.rm means ignore NA values (non-numeric)
#     colMeans(dzData,na.rm=TRUE) 
#     cov(mzData,use="complete") # "complete" specifies use only cases with data in all columns
#     cov(dzData,use="complete") 
#     alltwin=cbind(mzData,dzData)
#     colnames(alltwin)=c("MZ_twin1","MZ_twin2","DZ_twin1","DZ_twin2")
    # write.table(alltwin,"mytwinfile")     # Saves a copy of mydata in your R directory under name "mytwinfile"
    selVars <- c('twin1','twin2')
    
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
    # store the result in a tale 
    if (nMz == seq_MzDz[1] & nSub == min_subj) {
      TabResult <- matrix(, nrow = 1, ncol = 7) # empty matrix to hold results
      colnames(TabResult) <- cbind("a2","c2","e2","LL_ACE","numMz","numDz","total")
      TabResult <- data.frame(TabResult)
      TabResult[1,] <- cbind(a2,c2,e2,LL_ACE,nb_Mz,nb_Dz,nSub)
      i=1
    } else {
      i=i+1
      TabResult[i,] <- cbind(a2,c2,e2,LL_ACE,nb_Mz,nb_Dz,nSub)
    }
  }
}

# generate figure in plotly


library(plotly)
p <- plotly(username='YassineBHA', key='8d314mov50')
trace1 <- list(
  x = TabResult$total[seq(1,nb_subj/step_seq*length(percentil),3)],
  y = TabResult$a2[seq(1,nb_subj/step_seq*length(percentil),3)],
  mode = "markers", 
  name = "25% MZ-DZ Ratio", 
  marker = list(
    color = "rgba(31, 119, 180, 0)", 
    size = 8, 
    symbol = "circle", 
    line = list(
      color = "rgb(163, 54, 204)", 
      width = 2
    )
  ), 
  type = "scatter"
)
trace2 <- list(
  x = TabResult$total[seq(2,nb_subj/step_seq*length(percentil),3)],
  y = TabResult$a2[seq(2,nb_subj/step_seq*length(percentil),3)],
  mode = "markers", 
  name = "50% MZ-DZ Ratio", 
  marker = list(
    color = "rgb(255, 147, 30)", 
    size = 8, 
    symbol = "cross", 
    line = list(color = "rgba(188, 189, 34, 0)")
  ), 
  type = "scatter"
)
trace3 <- list(
  x = TabResult$total[seq(3,nb_subj/step_seq*length(percentil),3)],
  y = TabResult$a2[seq(3,nb_subj/step_seq*length(percentil),3)],
  mode = "markers", 
  name = "75% MZ-DZ Ratio", 
  marker = list(
    color = "rgba(44, 160, 44, 0)", 
    size = 8, 
    symbol = "square", 
    line = list(
      color = "rgb(51, 255, 51)", 
      width = 1
    )
  ), 
  type = "scatter"
)

data <- list(trace1, trace2, trace3)
layout <- list(
  title = paste("Heritability Estimate on Simulated Data (",simu,")",sep = ''), 
  titlefont = list(
    family = "Lucida Console, Monaco, monospace", 
    size = 0, 
    color = "rgb(226, 226, 226)"
  ), 
  font = list(
    family = "Lucida Console, Monaco, monospace", 
    size = 12, 
    color = "rgb(226, 226, 226)"
  ), 
  showlegend = TRUE, 
  autosize = FALSE, 
  width = 700, 
  height = 500, 
  xaxis = list(
    title = "Total subjects", 
    titlefont = list(
      family = "", 
      size = 0, 
      color = ""
    ), 
    range = c(min_subj-10, nb_subj), 
    domain = c(0, 1), 
    type = "linear", 
    rangemode = "normal", 
    autorange = FALSE, 
    showgrid = FALSE, 
    zeroline = FALSE, 
    showline = TRUE, 
    autotick = FALSE, 
    nticks = 0, 
    ticks = "outside", 
    showticklabels = TRUE, 
    tick0 = 0, 
    dtick = 100, 
    ticklen = 5, 
    tickwidth = 1, 
    tickcolor = "#000", 
    tickangle = "auto", 
    tickfont = list(
      family = "", 
      size = 0, 
      color = ""
    ), 
    exponentformat = "e", 
    showexponent = "all", 
    mirror = FALSE, 
    gridcolor = "rgb(255, 255, 255)", 
    gridwidth = 1, 
    zerolinecolor = "#000", 
    zerolinewidth = 1, 
    linecolor = "rgb(217, 217, 217)", 
    linewidth = 2, 
    anchor = "y", 
    overlaying = FALSE, 
    position = 0
  ), 
  yaxis = list(
    title = "Heritability Estimate", 
    titlefont = list(
      family = "", 
      size = 0, 
      color = ""
    ), 
    range = c(0, 1), 
    domain = c(0, 1), 
    type = "linear", 
    rangemode = "normal", 
    autorange = FALSE, 
    showgrid = FALSE, 
    zeroline = FALSE, 
    showline = TRUE, 
    autotick = FALSE, 
    nticks = 0, 
    ticks = "outside", 
    showticklabels = TRUE, 
    tick0 = 0, 
    dtick = 0.5, 
    ticklen = 1, 
    tickwidth = 1, 
    tickcolor = "#000", 
    tickangle = "auto", 
    tickfont = list(
      family = "", 
      size = 0, 
      color = ""
    ), 
    exponentformat = "e", 
    showexponent = "all", 
    mirror = FALSE, 
    gridcolor = "#ddd", 
    gridwidth = 1, 
    zerolinecolor = "#000", 
    zerolinewidth = 1, 
    linecolor = "rgb(217, 217, 217)", 
    linewidth = 2, 
    anchor = "x", 
    overlaying = FALSE, 
    position = 0
  ), 
  legend = list(
    x = 0.980952380952, 
    y = 0.0233333333333, 
    traceorder = "normal", 
    font = list(
      family = "", 
      size = 0, 
      color = ""
    ), 
    bgcolor = "rgb(0, 0, 0)", 
    bordercolor = "rgba(0, 0, 0, 0)", 
    borderwidth = 10, 
    xanchor = "auto", 
    yanchor = "auto"
  ), 
  annotations = list(
    list(
      x = -0.047619047619, 
      y = -0.193333333333, 
      xref = "paper", 
      yref = "paper", 
      text = "<i>Source:http://goo.gl/30AkBc</i>", 
      showarrow = FALSE, 
      font = list(
        family = "", 
        size = 0, 
        color = ""
      ), 
      xanchor = "auto", 
      yanchor = "auto", 
      align = "left", 
      arrowhead = 1, 
      arrowsize = 1, 
      arrowwidth = 0, 
      arrowcolor = "", 
      ax = 500, 
      ay = 196, 
      bordercolor = "", 
      borderwidth = 10, 
      borderpad = 1, 
      bgcolor = "rgba(0,0,0,0)", 
      opacity = 1
    )
  ), 
  margin = list(
    l = 100, 
    r = 80, 
    b = 100, 
    t = 100, 
    pad = 5, 
    autoexpand = TRUE
  ), 
  paper_bgcolor = "rgb(31, 31, 31)", 
  plot_bgcolor = "rgb(31, 31, 31)", 
  hovermode = "x", 
  dragmode = "zoom", 
  separators = ".,", 
  barmode = "stack", 
  bargap = 0.2, 
  bargroupgap = 0, 
  boxmode = "overlay", 
  hidesources = FALSE
)
response <- p$plotly(data, kwargs=list(layout=layout, filename=paste("heritability_",simu,sep = ''),fileopt="overwrite"))
url <- response$url
