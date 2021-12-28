#Simple Linear Regression

set.seed(0) #very optional step
N=100;
x=rnorm(N);
epsilon=rnorm(N,sd=4);
B0=2
B1=3
y=B0+B1*x+epsilon;
plot(x,y);
abline(B0,B1,col="red",lwd=2);
mod=lm(y~x);
abline(mod,col="blue",lwd=2);
legend("topleft",c("Population Regression Line", "Least-Square Line"),col=c("red","blue"),lwd=2);

#Sample from the population and construct each different regression line
stats=matrix(NA,50,2)
plot(x,y)
for (k in 1:50)
{
  i=sample(1:N,20,replace=F)
  mod=lm(y[i]~x[i])
  abline(mod,col="blue",lwd=1)
  stats[k,]=mod$coefficients
}
abline(B0,B1,col="red",lwd=3)
#Note that each sample gives a different estimate of the slope and intercept,
#though since we are creating this data we know the true values (slope=3,intercept=2)

cat(colMeans(stats))#averages of intercept and slope of 50 experiments
cat(apply(stats,2,sd))#their standard deviations

#We can see the p-value for our coefficients
summary(mod)$coefficients




#Multiple Linear Regressions
set.seed(0) #very optional step
N=100;
x1=rnorm(N);
x2=rnorm(N);
epsilon=rnorm(N,sd=2);
B0=2
B1=3
B2=1
y=B0+B1*x1+B2*x2+epsilon;

frame=data.frame(x1,x2,y)
mod=lm(y~x1+x2,data=frame);
summary(mod)$coefficients
#Can also run:
mod2=lm(y~.,data=frame) #If want to fit y to all inputs
summary(mod2)$coefficients

RSS=sum((y-predict(mod))^2) #Training residual sum of squares
#To predict at other inputs: 
X = data.frame(x1 = c(0,1,2),x2 = c(2,1,0))
predict(mod,newdata=X)



#Potential Impact of Outliers
set.seed(0) #very optional step
x=runif(100,1,10)
y=2*x+rnorm(100,0,1)
frame1=data.frame(x,y)
plot(x,y)
fit=lm(y~x,data=frame1)
summary(fit)
x1=c(x,5)
y1=c(y,20)
frame2=data.frame(x1,y1)
plot(x1,y1)
fit2=lm(y1~x1,data=frame2)
summary(fit2)
ypred=predict(fit,frame1)
sum((ypred-y)^2)
ypred2=predict(fit2,frame2)
sum((ypred2-y1)^2)







#Ridge Regression
x1=rnorm(500,0,2)
x2=rnorm(500,.5,.1)
x3=rnorm(500,.1,.001)
x4=rnorm(500,-1,1)
y=3*x1+.75*x3+rnorm(500,0,1) #notice x2 and x4 are not included
examp=data.frame(y,x1,x2,x3,x4)

library(MASS)
lambda=10^seq(-2,4,by=.01)
a=lm.ridge(y~.,data=examp,lambda=lambda)
leg.col=rainbow(dim(a$coef)[1])
matplot(lambda,t(a$coef),
        type='l',
        lty=1,
        lwd=2,
        log="x",
        col=leg.col,
        xlab="lambda",
        ylab="Normalized Coefficients")
to.label=c(1,2,3,4)
legend("topright",rownames(a$coef)[to.label],fill=leg.col[to.label],box.lty="blank")
box()


library(glmnet)
x=model.matrix(y~.,examp)[,-1]
y=examp$y

train=sample(500,250,replace=FALSE) #Train/Test split

ridge.mod=glmnet(x[train,],y[train],alpha=0,lambda=lambda) #Ridge can also be run from glmnet
cv.out=cv.glmnet(x[train,],y[train],alpha=0,lambda=lambda) #Evaluate performance (we will discuss more later in the semester)
plot(cv.out)
bestlam=cv.out$lambda.min
bestlam

base=glm(y~.,data=examp,subset=train) #Compare to base model
pred=predict(base,examp[-train,])
mean((pred-examp$y[-train])^2) #Baseline MSE

bestridge.pred=predict(ridge.mod,s=bestlam,newx=x[-train,])
mean((bestridge.pred-y[-train])^2) #Ridge MSE

ridgecoef=glmnet(x,y,alpha=0,lambda=lambda)
predict(ridgecoef,type="coefficients",s=bestlam)


#Lasso
lasso.mod=glmnet(x[train,],y[train],alpha=1,lambda=lambda) #LASSO is with alpha=1
cv.out=cv.glmnet(x[train,],y[train],alpha=1,lambda=lambda)
plot(cv.out)
bestlam=cv.out$lambda.min
bestlam
bestlasso.pred=predict(lasso.mod,s=bestlam,newx=x[-train,])
mean((bestlasso.pred-y[-train])^2) #Lasso MSE

lassocoef=glmnet(x,y,alpha=1,lambda=lambda)
predict(lassocoef,type="coefficients",s=bestlam)






#Loading financial data
library(quantmod)
#Use SPY data from 2004 onward
getSymbols("SPY",from="2004-01-01")
r = dailyReturn(SPY,type="log")
plot(r)
#Autoregressive model as linear regression:
#AR(2)
x1 = as.numeric(lag(r,k=1))[-(1:2)]
x2 = as.numeric(lag(r,k=2))[-(1:2)]
y = as.numeric(r)[-(1:2)]
ar2 = lm(y~x1+x2)
summary(ar2)
