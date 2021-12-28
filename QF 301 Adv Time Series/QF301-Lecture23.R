library(quantmod)
library(quadprog)
library(MASS)
library(randomForest)

set.seed(0)

# Create a simple implementation of the mean-variance optimization problem
# Since we can write it as a quadratic objective to minimize, we can use QP solvers
mv <- function(mu,C,lambda) {
  n = length(mu)
  ones = matrix(1,n,1)
  S = solve.QP(Dmat=C , dvec=lambda*mu , Amat=ones , bvec=1 , meq=1)
  w=S$solution
  P = list(w=w , r=t(mu)%*%w , sd=sqrt(t(w)%*%C%*%w))
  return(P)
}

# Let's start with a simple test implementation and compare our optimal values
# First we need mean and covariance structures
n = 3
mu = matrix(c(0.05,0.1,0.025),nrow=n,ncol=1)
rho = 0.5 # Set constant correlations with variances of 1
C = matrix(rho,nrow=n,ncol=n)
diag(C) = 1

M = 51
lambda = c(0,10^seq(from=-4,to=1.5,length.out=M-1))
rbar = rep(0,M)
sigbar = rep(0,M)
# Optimize over a large choice of risk-aversions
for (i in seq(1,M)) {
  P = mv(mu,C,lambda[i])
  rbar[i] = P$r
  sigbar[i] = P$sd
}
# Mean-Variance efficient frontier
plot(sigbar,rbar,"b",col=1)

# Let's compare this with random portfolios
M = 1000
randR = rep(0,M)
randSD = rep(0,M)
for (i in seq(1,M)) {
  w = rnorm(n,mean=0,sd=100)
  w = w/sum(w)
  w = matrix(w,n,1)
  randR[i] = t(mu)%*%w
  randSD[i] = sqrt(t(w)%*%C%*%w)
}
points(randSD,randR,col=4)
points(sigbar,rbar,col=2)


## Let's replace the true mean and variance with estimates
set.seed(0)
r = mvrnorm(n=252 , mu=mu , Sigma=C)
hatMu = matrix(colMeans(r) , n,1)
mu
hatMu

hatC = cov(r)
C
hatC

# Draw the true efficient frontier again
plot(sigbar,rbar,"b",col=1)

# Compute efficient frontier from estimated mu and C
M = length(lambda)
expected.rbar = rep(0,M)
expected.sig = rep(0,M)
true.rbar = rep(0,M)
true.sig = rep(0,M)
# Optimize over a large choice of risk-aversions
for (i in seq(1,M)) {
  P = mv(hatMu,hatC,lambda[i])
  expected.rbar[i] = P$r
  expected.sig[i] = P$sd
  
  w = matrix(P$w , n,1)
  true.rbar[i] = t(mu)%*%w
  true.sig[i] = sqrt(t(w)%*%C%*%w)
}
# Efficient frontier we would expect vs. what we actual get
points(expected.sig,expected.rbar,col=2)
points(true.sig,true.rbar,col=4)

# What happens if we change the number of data points we simulate over?




## Let's now consider financial data
set.seed(0)
getSymbols(c("SPY","AAPL","AMZN","GS","GE","F"),from="2011-01-01",to="2021-01-01")
rSPY = dailyReturn(SPY$SPY.Adjusted,type="arithmetic")
rAAPL = dailyReturn(AAPL$AAPL.Adjusted,type="arithmetic")
rAMZN = dailyReturn(AMZN$AMZN.Adjusted,type="arithmetic")
rGS = dailyReturn(GS$GS.Adjusted,type="arithmetic")
rGE = dailyReturn(GE$GE.Adjusted,type="arithmetic")
rF = dailyReturn(F$F.Adjusted,type="arithmetic")
Returns = data.frame(AAPL=as.numeric(rAAPL),AMZN=as.numeric(rAMZN),
                     GS=as.numeric(rGS),GE=as.numeric(rGE),F=as.numeric(rF))
head(Returns)
n = ncol(Returns)

T = 252 # Consider rolling window of approximately 1 year of daily data > 1/2*n*(n+1) necessary

rNaive = rep(0,nrow(Returns)-T)
rOpt = rep(0,nrow(Returns)-T)
for (t in seq(T+1,nrow(Returns))) {
  # Returns for equal-weighted portfolio
  rNaive[t-T] = sum(Returns[t,])/n
  
  # Returns for optimal portfolio
  # First find the rolling estimate for the mean/covariance structure
  mu = matrix(colMeans(Returns[(t-T):(t-1),]) , n,1)
  C = cov(Returns[(t-T):(t-1),])
  # Compute the optimal portfolio
  optPortfolio = mv(mu,C,1) # Risk aversion of 1 chosen arbitrarily
  # Find the realized returns in the next day
  rOpt[t-T] = sum(Returns[t,]*optPortfolio$w)
}
# Compare the mean and standard deviations of actual returns
c(mean(rSPY[(T+1):length(rSPY)]) , sd(rSPY[(T+1):length(rSPY)]))
c(mean(rNaive) , sd(rNaive))
c(mean(rOpt) , sd(rOpt))
# For quicker comparison, let's look at the Sharpe portfolio
mean(rSPY[(T+1):length(rSPY)])/sd(rSPY[(T+1):length(rSPY)])
mean(rNaive)/sd(rNaive)
mean(rOpt)/sd(rOpt)

# Investing in SPY alone provides the best risk-return tradeoff of those options


set.seed(0)
getSymbols(c("SPY","IEF","^VIX"),from="2011-01-01",to="2021-01-01")
rSPY = dailyReturn(SPY$SPY.Adjusted,type="arithmetic")
rIEF = dailyReturn(IEF$IEF.Adjusted,type="arithmetic")
rVIX = dailyReturn(VIX$VIX.Adjusted,type="arithmetic")

SPY0 = as.numeric(rSPY)[-(1:2)]
SPY1 = as.numeric(lag(rSPY,k=1))[-(1:2)]
SPY2 = as.numeric(lag(rSPY,k=2))[-(1:2)]
IEF0 = as.numeric(rIEF)[-(1:2)]
IEF1 = as.numeric(lag(rIEF,k=1))[-(1:2)]
IEF2 = as.numeric(lag(rIEF,k=2))[-(1:2)]
VIX0 = as.numeric(rVIX)[-(1:2)]
VIX1 = as.numeric(lag(rVIX,k=1))[-(1:2)]
VIX2 = as.numeric(lag(rVIX,k=2))[-(1:2)]

tau = 0
Direction = (SPY0 > tau) + 0

df = data.frame(Direction,SPY1,SPY2,IEF1,IEF2,VIX1,VIX2)

# Let's use just the first 1515 days for training (leaving 1000 for testing)
# Better, but more computationally inefficient, would be to consider rolling window
train = seq(1,1515)
test = seq(1516,2515)

# As baseline comparison: consider the Sharpe ratio for the SPY index
c(mean(SPY0[test]) , sd(SPY0[test]))
mean(SPY0[test])/sd(SPY0[test])
# Consider also a Sharpe ratio for 60-40 equity-fixed income portfolio
r.naive = 0.6*SPY0[test] + 0.4*IEF0[test]
c(mean(r.naive) , sd(r.naive))
mean(r.naive)/sd(r.naive)


## Approach 1: Classification for direction
# Logistic regression
log.reg = glm(Direction~. , data=df , subset=train , family=binomial)
summary(log.reg)

log.prob = predict(log.reg , newdata=df[test,] , type="response")
head(log.prob) # Notice these are close to 50%

r.log = rep(0,length(test))
for (t in test) {
  ind = t - max(train)
  if (log.prob[ind] >= 0.5) {
    r.log[ind] = SPY0[t]
  } else {
    r.log[ind] = IEF0[t]
  }
}
c(mean(r.log) , sd(r.log))
mean(r.log)/sd(r.log) # Compare with Sharpe ratio of the SPY (0.05166) and 60-40 (0.06687)

# What if we take a different tau value?
# Take the mean value of IEF
tau = mean(IEF0[train])
Direction = (SPY0 > tau) + 0

df = data.frame(Direction,SPY1,SPY2,IEF1,IEF2,VIX1,VIX2)

log.reg = glm(Direction~. , data=df , subset=train , family=binomial)
summary(log.reg)

log.prob = predict(log.reg , newdata=df[test,] , type="response")
head(log.prob) # Notice these are close to 50%

r.log = rep(0,length(test))
for (t in test) {
  ind = t - max(train)
  if (log.prob[ind] >= 0.5) {
    r.log[ind] = SPY0[t]
  } else {
    r.log[ind] = IEF0[t]
  }
}
c(mean(r.log) , sd(r.log))
mean(r.log)/sd(r.log) # Compare with Sharpe ratio of the SPY (0.05166) and 60-40 (0.06687)

# Take tau < 0
tau = -0.01
Direction = (SPY0 > tau) + 0

df = data.frame(Direction,SPY1,SPY2,IEF1,IEF2,VIX1,VIX2)

log.reg = glm(Direction~. , data=df , subset=train , family=binomial)
summary(log.reg)

log.prob = predict(log.reg , newdata=df[test,] , type="response")
head(log.prob) # Notice these are close to 90%; what do you expect the returns to look like?

r.log = rep(0,length(test))
for (t in test) {
  ind = t - max(train)
  if (log.prob[ind] >= 0.5) {
    r.log[ind] = SPY0[t]
  } else {
    r.log[ind] = IEF0[t]
  }
}
c(mean(r.log) , sd(r.log))
mean(r.log)/sd(r.log) # Compare with Sharpe ratio of the SPY (0.05166) and 60-40 (0.06687)



# What if we attempt a different method?
# Let's try random forest with tau = mean(IEF)
tau = mean(IEF0[train])
Direction = as.factor((SPY0 > tau) + 0)

df = data.frame(Direction,SPY1,SPY2,IEF1,IEF2,VIX1,VIX2)

rf = randomForest(Direction~. , data=df , subset=train , ntree=500 , mtry=3 , importance=TRUE)
rf # Notice the poor out-of-bag estimate of error
varImpPlot(rf)

rf.prob = predict(rf , newdata=df[test,] , type="prob") # Probability based on the votes of each tree in the random forest
head(rf.prob) # Notice these are close to 50%

r.rf = rep(0,length(test))
for (t in test) {
  ind = t - max(train)
  if (rf.prob[ind,2] >= 0.5) {
    r.rf[ind] = SPY0[t]
  } else {
    r.rf[ind] = IEF0[t]
  }
}
c(mean(r.rf) , sd(r.rf))
mean(r.rf)/sd(r.rf) # Compare with Sharpe ratio of the SPY (0.05166), and 60-40 (0.06687), and logistic regression (0.0924)
# Poor performance can be seen by the changing importances in the in-sample vs. out-of-sample approaches



## Approach 2: Classification with confidence
# Logistic regression
# Take tau < 0
tau = -0.01
kappa = 0.9
Direction = (SPY0 > tau) + 0

df = data.frame(Direction,SPY1,SPY2,IEF1,IEF2,VIX1,VIX2)

log.reg = glm(Direction~. , data=df , subset=train , family=binomial)
summary(log.reg)

log.prob = predict(log.reg , newdata=df[test,] , type="response")
head(log.prob) # Notice these are close to 90%; what do you expect the returns to look like?

r.log = rep(0,length(test))
for (t in test) {
  ind = t - max(train)
  if (log.prob[ind] >= kappa) {
    r.log[ind] = SPY0[t]
  } else {
    r.log[ind] = IEF0[t]
  }
}
c(mean(r.log) , sd(r.log))
mean(r.log)/sd(r.log) # Compare with Sharpe ratio of the SPY (0.05166) and 60-40 (0.06687)




# What if we compare these with mean-variance optimization?
# Consider only investing in SPY and IEF
n = 2
Returns = data.frame(SPY0,IEF0)

# Try different risk aversions over rolling windows
M = 11
lambda = c(0,10^seq(from=-4,to=1.5,length.out=M-1))

T = 504 # Roughly 2 years of prior data for rolling window

rbar = rep(0,M)
sigbar = rep(0,M)
for (i in seq(1,M)) {
  rOpt = rep(0,length(test))
  for (t in test) {
    # Returns for optimal portfolio
    # First find the rolling estimate for the mean/covariance structure
    mu = matrix(colMeans(Returns[(t-T):(t-1),]) , n,1)
    C = cov(Returns[(t-T):(t-1),])
    # Compute the optimal portfolio
    optPortfolio = mv(mu,C,lambda[i]) # try different risk aversions
    # Find the realized returns in the next day
    rOpt[t-max(train)] = sum(Returns[t,]*optPortfolio$w)
  }
  # Compare the mean and standard deviations of actual returns
  rbar[i] = mean(rOpt) 
  sigbar[i] = sd(rOpt)
}
sharpe = rbar/sigbar
sharpe
# Notice that, in this case, we happen to perform quite well for risk aversion near 0
# This is when we ignore our potential returns
