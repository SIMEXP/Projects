#!/usr/local/bin/python

__author__ = "Christian Dansereau"
__copyright__ = "Copyright 2015, Local FDR"
__credits__ = [""]
__license__ = "GPL"
__version__ = "0.1"
__email__ = ""
__status__ = "Development"

import numpy as np
from scipy.stats import norm

def local_fdr(P_VALUE):
    ## Compute Z-values
    Z_VALUE = norm.ppf(1-P_VALUE,loc=0, scale=1)
    # Set an EM algorithm Tolerance Value
    TOL = 10**-3
    # Declare FDR Control LEVEL
    ALPHA = 0.05

    # Initialize Variables
    ## Get length of Z_VALUE
    N = len(Z_VALUE)

    ## Initialize Mixing Probabilities
    PI_A = 0.5
    PI_B = 0.5
    ## Initialize Means
    MEAN_A = 0
    MEAN_B = 2
    ## Initialize Standard Deviations
    SD_A = 1
    SD_B = 1

    # Initialize Loglikelihood function
    LOGLIKE = 0
    for ii in range(N):
        LOGLIKE = LOGLIKE + np.log(PI_A*norm.pdf(Z_VALUE[ii],MEAN_A,SD_A) + PI_B*norm.pdf(Z_VALUE[ii],MEAN_B,SD_B))

    ## Create an old Loglikelihood value
    LOGOLD = -np.inf


    # EM Algorithm Loopq
    while LOGLIKE - LOGOLD > TOL:
        ## Update Old LL Value
        LOGOLD = LOGLIKE

        ## Compute A Posteriori Probability (E-STEP)
        TAU_A = PI_A*norm.pdf(Z_VALUE,MEAN_A,SD_A)/(PI_A*
                norm.pdf(Z_VALUE,MEAN_A,SD_A) +
                PI_B*norm.pdf(Z_VALUE,MEAN_B,SD_B))
        TAU_B = 1 - TAU_A

        ## Estimate Means (M-STEP part 1)
        MEAN_A = np.sum(TAU_A*Z_VALUE)/np.sum(TAU_A)
        MEAN_B = np.sum(TAU_B*Z_VALUE)/np.sum(TAU_B)

        ## Estimate SDs (M-STEP part 2)
        SD_A = np.sqrt(np.sum(TAU_A*(Z_VALUE-MEAN_A)**2)/np.sum(TAU_A))
        SD_B = np.sqrt(np.sum(TAU_B*(Z_VALUE-MEAN_B)**2)/np.sum(TAU_B))

        ## Recompute Loglikelihood
        LOGLIKE = 0
        for ii in range(N):
            LOGLIKE = LOGLIKE + np.log(PI_A*norm.pdf(Z_VALUE[ii],MEAN_A,SD_A) + PI_B*norm.pdf(Z_VALUE[ii],MEAN_B,SD_B))


    # Find out which is the NULL and which is the ALT distribution
    if MEAN_A < MEAN_B:
        ## Put All of the A stuff into 0 (NULL)
        MEAN_0 = MEAN_A
        SD_0 = SD_A
        PI_0 = PI_A
        ## Put all of the B stuff into 1 (ALT)
        MEAN_1 = MEAN_B
        SD_1 = SD_B
        PI_1 = PI_B
    else:
        ## Put All of the A stuff into 1 (ALT)
        MEAN_1 = MEAN_A
        SD_1 = SD_A
        PI_1 = PI_A
        ## Put all of the B stuff into 0 (NULL)
        MEAN_0 = MEAN_B
        SD_0 = SD_B
        PI_0 = PI_B

    # Compute local FDR
    LFDR = PI_0*norm.pdf(Z_VALUE,MEAN_0,SD_0)/(PI_0*
                norm.pdf(Z_VALUE,MEAN_0,SD_0) +
                PI_1*norm.pdf(Z_VALUE,MEAN_1,SD_1))

    # Get possibly global FDR values
    FDR = np.cumsum(np.sort(LFDR))/np.array(range(1,N+1))

    ## Find the Critical value for which FDR is controlled at ALPHA
    CRIT = np.sort(LFDR)[np.where(FDR>ALPHA)[0][0]]

    # Get vector of Rejected P-Values
    REJECT = np.array(LFDR < CRIT,dtype=int)
    ## Print out vector of Rejected P-Values in Order
    print(REJECT)
    return REJECT
