function REJECT=local_fdr(P_VALUE)
% Simulate some P-values
%TEST_STAT = [normrnd(0,1,[100 1]);normrnd(1,1,[100 1])];
%P_VALUE = 1 - normcdf(TEST_STAT, 0, 1);
%% Compute Z-values
Z_VALUE = norminv(1-P_VALUE,0,1);

% Set an EM algorithm Tolerance Value
TOL = 10^-3;

% Declare FDR Control LEVEL
ALPHA = 0.05;

% Initialize Variables
%% Get length of Z_VALUE
N = length(Z_VALUE);
%% Initialize Mixing Probabilities
PI_A = 0.5;
PI_B = 0.5;
%% Initialize Means
MEAN_A = 0;
MEAN_B = 2;
%% Initialize Standard Deviations
SD_A = 1;
SD_B = 1;

% Initialize Loglikelihood function
LOGLIKE = 0;
for ii = 1:N
  LOGLIKE = LOGLIKE + log(PI_A*normpdf(Z_VALUE(ii),MEAN_A,SD_A) +
            PI_B*normpdf(Z_VALUE(ii),MEAN_B,SD_B));
endfor
%% Create an old Loglikelihood value
LOGOLD = -Inf;

% EM Algorithm Loopq
while LOGLIKE - LOGOLD > TOL
  %% Update Old LL Value
  LOGOLD = LOGLIKE;
  
  %% Compute A Posteriori Probability (E-STEP)
  TAU_A = PI_A*normpdf(Z_VALUE,MEAN_A,SD_A)./(PI_A*
            normpdf(Z_VALUE,MEAN_A,SD_A) +
            PI_B*normpdf(Z_VALUE,MEAN_B,SD_B));
  TAU_B = 1 - TAU_A;
  
  %% Estimate Means (M-STEP part 1)
  MEAN_A = sum(TAU_A.*Z_VALUE)/sum(TAU_A);
  MEAN_B = sum(TAU_B.*Z_VALUE)/sum(TAU_B);
  
  %% Estimate SDs (M-STEP part 2)
  SD_A = sqrt(sum(TAU_A.*(Z_VALUE-MEAN_A).^2)/sum(TAU_A));
  SD_B = sqrt(sum(TAU_B.*(Z_VALUE-MEAN_B).^2)/sum(TAU_B));
  
  %% Recompute Loglikelihood
  LOGLIKE = 0;
  for ii = 1:N
    LOGLIKE = LOGLIKE + log(PI_A*normpdf(Z_VALUE(ii),MEAN_A,SD_A) +
              PI_B*normpdf(Z_VALUE(ii),MEAN_B,SD_B));
  endfor
endwhile

% Find out which is the NULL and which is the ALT distribution
if MEAN_A < MEAN_B
  
  %% Put All of the A stuff into 0 (NULL)
  MEAN_0 = MEAN_A;
  SD_0 = SD_A;
  PI_0 = PI_A;
  %% Put all of the B stuff into 1 (ALT)
  MEAN_1 = MEAN_B;
  SD_1 = SD_B;
  PI_1 = PI_B;
else
  %% Put All of the A stuff into 1 (ALT)
  MEAN_1 = MEAN_A;
  SD_1 = SD_A;
  PI_1 = PI_A;
  %% Put all of the B stuff into 0 (NULL)
  MEAN_0 = MEAN_B;
  SD_0 = SD_B;
  PI_0 = PI_B;
endif

% Compute local FDR
LFDR = PI_0*normpdf(Z_VALUE,MEAN_0,SD_0)./(PI_0*
            normpdf(Z_VALUE,MEAN_0,SD_0) +
            PI_1*normpdf(Z_VALUE,MEAN_1,SD_1));

% Get possibly global FDR values
FDR = cumsum(sort(LFDR))./transpose(1:N);
%% Find the Critical value for which FDR is controlled at ALPHA
CRIT = sort(LFDR)(find(FDR>ALPHA)(1));

% Get vector of Rejected P-Values
REJECT = LFDR < CRIT;
%% Print out vector of Rejected P-Values in Order
disp(REJECT)

