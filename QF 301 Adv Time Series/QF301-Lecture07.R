set.seed(0) #very optional step

#Loading financial data
library(quantmod)
#Use SPY data from 2004 onward
getSymbols("SPY",from="2004-01-01")
r = dailyReturn(SPY,type="log")
plot(r)
#Autoregressive model as linear regression:
#AR(1)
r1 = as.numeric(lag(r,k=1))[-1]
r0 = as.numeric(r)[-1]
df = data.frame(r0,r1)

train=sample(length(r0),length(r0)/2,replace=FALSE) #50% Train/Test split

ar1 = glm(r0~.,data=df,subset=train)
summary(ar1)

pred=predict(ar1,df[-train,])
MSE = mean((pred-df$r0[-train])^2) #Test MSE
sqrt(MSE) #Root mean squared error

#Compare with naive/constant predictor:
MSE0 = mean((mean(df$r0[train])-df$r0[-train])^2) #Test MSE
sqrt(MSE0)


#Check coefficients/check unit-root nonstationary
summary(ar1)$coefficients
b0 = summary(ar1)$coefficients[1,1]
b1 = summary(ar1)$coefficients[2,1]
b1.se = summary(ar1)$coefficients[2,2]
abs(b1) < 1 #If true then suspect weakly stationary

#Test for unit-root nonstationary
t = (b1 - 1)/b1.se
t
pnorm(t) #Large enough data, treat as normal
#If small enough then reject the null hypothesis


#Forecasting:
N = length(df$r0)
sig = sqrt(MSE)
hat_r = matrix(nrow=length(df$r0)-5,ncol=5)
e = matrix(nrow=N-5,ncol=5)
var_e = rep(NA, 5)

hat_r[,1] = b0 + b1*df$r0[1:(N-5)]
e[,1] = df$r0[2:(N-4)] - hat_r[,1]
var_e[1] = sig^2
for (l in seq(2,5)) {
  hat_r[,l] = b0 + b1*hat_r[,l-1]
  e[,l] = df$r0[(l+1):(N-5+l)]
  var_e[l] = sig^2 + b1^2*var_e[l-1] #Why is this the correct equation?
}

#Compare empirical and theoretical forecast standard deviation
sqrt(var_e)
emp_e = c(var(e[,1]),var(e[,2]),var(e[,3]),var(e[,4]),var(e[,5]))
sqrt(emp_e)
#How well does the empirical forecast follow the theoretical formulation:
sqrt(emp_e[2]) - sqrt((1+b1^2)*emp_e[1])
