set.seed(0)

## First lets create a simple dataset for doing binary classification
N = 100
x = rnorm(N)
epsilon = rnorm(N,sd=2)
B0 = 2
B1 = 3
y = (B0+B1*x+epsilon > B0) # If the line is above B0 then "1" otherwise "0"
head(y)
y = y+0 # "+0" converts from TRUE/FALSE to 1/0
head(y)
df = data.frame(x,y)

plot(x,y)
abline(1/2,B1/(2*B0),col="black",lwd=2)
abline(1/2,0,col="black",lwd=2,lty=2)
abline(v=0,col="red",lwd=2,lty=3)

# Accuracy from underlying relationship:
relationship.err = 1/N * sum(abs(y - (x > 0))) # Error rate
relationship.acc = 1 - relationship.err # Accuracy
relationship.acc

## Consider using linear regressions to determine the classification
# For binary classification the one hot encoding are values y and 1-y
y1 = y
y0 = 1-y1
df.ohe = data.frame(x,y1,y0) #one hot encoding data frame

lin1.reg = glm(y1 ~ x , data=df.ohe)
summary(lin1.reg)

lin0.reg = glm(y0 ~ x , data=df.ohe)
summary(lin0.reg)

# What does the decision boundary look like?
lin1.B0 = summary(lin1.reg)$coefficients[1,1]
lin1.B1 = summary(lin1.reg)$coefficients[2,1]

lin0.B0 = summary(lin0.reg)$coefficients[1,1]
lin0.B1 = summary(lin0.reg)$coefficients[2,1]

# From notes: the decision boundary is when lin1.reg = lin0.reg
lin.db.B0 = lin1.B0 - lin0.B0
lin.db.B1 = lin1.B1 - lin0.B1
# Decision boundary is lin.db.B0 + lin.db.B1 * x = 0 --> x = -lin.db.B0/lin.db.B1
-lin.db.B0/lin.db.B1
abline(v = -lin.db.B0/lin.db.B1,col="blue",lty=3)

# Use decision boundary for classification to test accuracy
lin.db.err = 1/N * sum(abs(y - (x > -lin.db.B0/lin.db.B1))) # Error rate
lin.db.acc = 1 - lin.db.err # Accuracy
lin.db.acc

# Let's classify all our training points based on the greater linear regression
y1.pred = predict(lin1.reg , df.ohe)
y0.pred = predict(lin0.reg , df.ohe)
y.lin.pred = (y1.pred > y0.pred)+0 # "+0" to make this 1/0

# Use predictions for classification
lin.err = 1/N * sum(abs(y - y.lin.pred)) # Error rate
lin.acc = 1 - lin.err # Accuracy
lin.acc # Should be identical to lin.db.acc


## Consider logistic regression
logistic.reg = glm(y ~ x , data=df , family=binomial) # Fit logistic regression [family=binomial]
summary(logistic.reg)
coef(logistic.reg)
summary(logistic.reg)$coef
logistic.probs=predict(logistic.reg,type="response") # Predict the probability for direction on training data

x.test = seq(from=min(x),to=max(x),by=0.01) # Test x values
logistic.probs.test = predict(logistic.reg , newdata=data.frame(x=x.test) , type="response") # Compute probabilities
lines(x.test,logistic.probs.test,col="green",lwd=2)

# Use probabilities to make predictions
y.logistic.pred=rep(0,N) # Create repeated vector of "0"
y.logistic.pred[logistic.probs>.5] = 1 # Predict "1" if logistic regression gives greater probability to "1"

# Evaluate the accuracy
table(y.logistic.pred , y) # Confusion matrix of results

logistic.acc = mean(y.logistic.pred==y) # Directly compute the accuracy
logistic.acc





## Consider now a more complex binary classification problem
set.seed(0)
# Generate random data
N = 200
M = 20 # Larger number of inputs
x = matrix(rnorm(N*M), N,M)
B0 = 0
B = c(3,0.75,rep(0,M-2)) # Only use x1 and x2
y = (B0 + x%*%B + rnorm(N,0,1) > 0)+0 # "+0" to make this 1/0
df = data.frame(y,x)
head(df)

train = sample(N,N/2,replace=FALSE) # Train/test split

## Consider using linear regressions to determine the classification
# For binary classification the one hot encoding are values y and 1-y
y1 = y
df1 = data.frame(x,y1) #one hot encoding data frame
y0 = 1-y1
df0 = data.frame(x,y0) #one hot encoding data frame

lin1.reg = glm(y1 ~ . , data=df1 , subset=train)
summary(lin1.reg)

lin0.reg = glm(y0 ~ . , data=df0 , subset=train)
summary(lin0.reg)

# Let's classify all our test points based on the greater linear regression
y1.pred = predict(lin1.reg , df1[-train,])
y0.pred = predict(lin0.reg , df0[-train,])
y.lin.pred = (y1.pred > y0.pred)+0 # Again "+0" to make this 1/0

# Use predictions for classification
lin.err = 1/N * sum(abs(y[-train] - y.lin.pred)) # Error rate
lin.acc = 1 - lin.err # Accuracy
lin.acc 

table(y.lin.pred , y[-train]) # Confusion matrix of results


## Consider the logistic regression now
logistic.reg = glm(y ~ . , data=df , subset=train , family=binomial) # Again, binomial makes it a logistic regression

# Let's classify all our test points based on the probability of being "1"
logistic.probs = predict(logistic.reg , newdata=df[-train,] , type="response") # Compute probabilities

# Use probabilities to make predictions
y.logistic.pred=rep(0,N/2) # Create repeated vector of "0"
y.logistic.pred[logistic.probs>.5] = 1 # Predict "1" if logistic regression gives greater probability to "1"

# Evaluate the accuracy
logistic.acc = mean(y.logistic.pred==y[-train]) # Directly compute the accuracy
logistic.acc

table(y.logistic.pred , y[-train]) # Confusion matrix of results


## Consider the Naive Bayes Classifier
# Note that our input data is independent in this case
library("e1071")

nb = naiveBayes(x[train,] , y[train])

y.nb.prob = predict(nb , newdata=x[-train,] , type="raw") # Compute probabilities
head(y.nb.prob)
y.nb.pred = (y.nb.prob[,1] < y.nb.prob[,2])+0 # 1st column is "0", 2nd column is "1"

# Evaluate the accuracy
nb.acc = mean(y.nb.pred==y[-train]) # Directly compute the accuracy
nb.acc

table(y.nb.pred , y[-train]) # Confusion matrix of results





#Loading financial data
library(quantmod)
set.seed(0)
#Use SPY data from 2004 onward
getSymbols("SPY",from="2004-01-01")
r = dailyReturn(SPY,type="log")

r1 = as.numeric(lag(r,k=1))[-(1:3)]
r2 = as.numeric(lag(r,k=2))[-(1:3)]
r3 = as.numeric(lag(r,k=3))[-(1:3)]
r0 = as.numeric(r)[-(1:3)]
direction = (r0 > 0)+0 # First let's consider direction of SPY
df = data.frame(direction,r1,r2,r3)

train = sample(length(r0),3*length(r0)/4,replace=FALSE) # Train/test split

## Consider using linear regressions to determine the classification
# For binary classification the one hot encoding are values y and 1-y
y1 = direction
df1 = data.frame(r1,r2,r3,y1) #one hot encoding data frame
y0 = 1-y1
df0 = data.frame(r1,r2,r3,y0) #one hot encoding data frame

lin1.reg = glm(y1 ~ . , data=df1 , subset=train)
summary(lin1.reg)

lin0.reg = glm(y0 ~ . , data=df0 , subset=train)
summary(lin0.reg)

# Let's classify all our test points based on the greater linear regression
y1.pred = predict(lin1.reg , df1[-train,])
y0.pred = predict(lin0.reg , df0[-train,])
y.lin.pred = (y1.pred > y0.pred)+0 # Again "+0" to make this 1/0

# Use predictions for classification
lin.acc = mean(y.lin.pred==direction[-train]) # Directly compute the accuracy
lin.acc 

table(y.lin.pred , direction[-train]) # Confusion matrix of results


## Consider the logistic regression now
logistic.reg = glm(direction ~ . , data=df , subset=train , family=binomial) # Again, binomial makes it a logistic regression

# Let's classify all our test points based on the probability of being "1"
logistic.probs = predict(logistic.reg , newdata=df[-train,] , type="response") # Compute probabilities

# Use probabilities to make predictions
y.logistic.pred=rep(0,length(r0)/4) # Create repeated vector of "0"
y.logistic.pred[logistic.probs>.5] = 1 # Predict "1" if logistic regression gives greater probability to "1"

# Evaluate the accuracy
logistic.acc = mean(y.logistic.pred==direction[-train]) # Directly compute the accuracy
logistic.acc

table(y.logistic.pred , direction[-train]) # Confusion matrix of results


## Consider the Naive Bayes Classifier
# Note that our input data is (most likely) not independent in this case
df.r = data.frame(r1,r2,r3)
nb = naiveBayes(df.r[train,] , direction[train])

y.nb.prob = predict(nb , newdata=df.r[-train,] , type="raw") # Compute probabilities
head(y.nb.prob)
y.nb.pred = (y.nb.prob[,1] < y.nb.prob[,2])+0 # 1st column is "0", 2nd column is "1"

# Evaluate the accuracy
nb.acc = mean(y.nb.pred==direction[-train]) # Directly compute the accuracy
nb.acc

table(y.nb.pred , direction[-train]) # Confusion matrix of results






## Consider now the multiple class classifier
# Assume normal data; split into thirds
mu = mean(r0[train])
sig = sd(r0[train])
direction = rep("Down",length(r0))
direction[r0 > mu - 0.43*sig] = "Flat"
direction[r0 > mu + 0.43*sig] = "Up"

# Check how well this actually splits data:
sum(direction == "Down")
sum(direction == "Flat")
sum(direction == "Up")

df = data.frame(direction,r1,r2,r3)

## Consider using linear regressions to determine the classification
y.D = (direction == "Down")+0
df.D = data.frame(r1,r2,r3,y.D) #one hot encoding data frame
y.F = (direction == "Flat")+0
df.F = data.frame(r1,r2,r3,y.F) #one hot encoding data frame
y.U = (direction == "Up")+0
df.U = data.frame(r1,r2,r3,y.U) #one hot encoding data frame

linD.reg = glm(y.D ~ . , data=df.D , subset=train)
linF.reg = glm(y.F ~ . , data=df.F , subset=train)
linU.reg = glm(y.U ~ . , data=df.U , subset=train)

# Let's classify all our test points based on the greater linear regression
y.D.pred = predict(linD.reg , df.D[-train,])
y.F.pred = predict(linF.reg , df.F[-train,])
y.U.pred = predict(linU.reg , df.U[-train,])

y.max.pred = pmax(y.D.pred,y.F.pred,y.U.pred)

# Use predictions for classification
y.lin.pred = rep("Down",length(y.D.pred))
#y.lin.pred[y.D.pred == y.max.pred] = "Down"
y.lin.pred[y.F.pred == y.max.pred] = "Flat"
y.lin.pred[y.U.pred == y.max.pred] = "Up"

# Consider the accuracy
lin.acc = mean(y.lin.pred==direction[-train]) # Directly compute the accuracy
lin.acc 

table(y.lin.pred , direction[-train]) # Confusion matrix of results


## Consider the logistic regression now
# Can be done with glm, but that is much more complicated
# Instead we use the multinom function
library(nnet)

logistic.reg = multinom(direction ~ . , data=df , subset = train)
summary(logistic.reg)

# Let's classify all our test points
y.logistic.pred = predict(logistic.reg , newdata = df[-train,])

# Consider the accuracy
logistic.acc = mean(y.logistic.pred==direction[-train]) # Directly compute the accuracy
logistic.acc 

table(y.logistic.pred , direction[-train]) # Confusion matrix of results



## Consider the Naive Bayes Classifier
# Note that our input data is (most likely) not independent in this case
df.r = data.frame(r1,r2,r3)
nb = naiveBayes(df.r[train,] , direction[train])

y.nb.prob = predict(nb , newdata=df.r[-train,] , type="raw") # Compute probabilities
head(y.nb.prob)
y.max.prob = pmax(y.nb.prob[,1],y.nb.prob[,2],y.nb.prob[,3])

# Use predictions for classification
y.nb.pred = rep("Down",length(y.max.prob))
#y.nb.pred[y.nb.prob[,1] == y.max.prob] = "Down"
y.nb.pred[y.nb.prob[,2] == y.max.prob] = "Flat"
y.nb.pred[y.nb.prob[,3] == y.max.prob] = "Up"

# Evaluate the accuracy
nb.acc = mean(y.nb.pred==direction[-train]) # Directly compute the accuracy
nb.acc

table(y.nb.pred , direction[-train]) # Confusion matrix of results





## Do you think these prediction would improve if the data is more balanced?
direction = rep("Down",length(r0))
quantile(r0,c(1/3,2/3))
direction[r0 > quantile(r0,1/3)] = "Flat"
direction[r0 > quantile(r0,2/3)] = "Up"

# Check how well this actually splits data:
sum(direction == "Down")
sum(direction == "Flat")
sum(direction == "Up")

df = data.frame(direction,r1,r2,r3)

## Consider using linear regressions to determine the classification
y.D = (direction == "Down")+0
df.D = data.frame(r1,r2,r3,y.D) #one hot encoding data frame
y.F = (direction == "Flat")+0
df.F = data.frame(r1,r2,r3,y.F) #one hot encoding data frame
y.U = (direction == "Up")+0
df.U = data.frame(r1,r2,r3,y.U) #one hot encoding data frame

linD.reg = glm(y.D ~ . , data=df.D , subset=train)
linF.reg = glm(y.F ~ . , data=df.F , subset=train)
linU.reg = glm(y.U ~ . , data=df.U , subset=train)

# Let's classify all our test points based on the greater linear regression
y.D.pred = predict(linD.reg , df.D[-train,])
y.F.pred = predict(linF.reg , df.F[-train,])
y.U.pred = predict(linU.reg , df.U[-train,])

y.max.pred = pmax(y.D.pred,y.F.pred,y.U.pred)

# Use predictions for classification
y.lin.pred = rep("Down",length(y.D.pred))
#y.lin.pred[y.D.pred == y.max.pred] = "Down"
y.lin.pred[y.F.pred == y.max.pred] = "Flat"
y.lin.pred[y.U.pred == y.max.pred] = "Up"

# Consider the accuracy
lin.acc = mean(y.lin.pred==direction[-train]) # Directly compute the accuracy
lin.acc 

table(y.lin.pred , direction[-train]) # Confusion matrix of results


## Consider the logistic regression now
# Can be done with glm, but that is much more complicated
# Instead we use the multinom function from nnet
logistic.reg = multinom(direction ~ . , data=df , subset = train)
summary(logistic.reg)

# Let's classify all our test points
y.logistic.pred = predict(logistic.reg , newdata = df[-train,])

# Consider the accuracy
logistic.acc = mean(y.logistic.pred==direction[-train]) # Directly compute the accuracy
logistic.acc 

table(y.logistic.pred , direction[-train]) # Confusion matrix of results



## Consider the Naive Bayes Classifier
# Note that our input data is (most likely) not independent in this case
df.r = data.frame(r1,r2,r3)
nb = naiveBayes(df.r[train,] , direction[train])

y.nb.prob = predict(nb , newdata=df.r[-train,] , type="raw") # Compute probabilities
head(y.nb.prob)
y.max.prob = pmax(y.nb.prob[,1],y.nb.prob[,2],y.nb.prob[,3])

# Use predictions for classification
y.nb.pred = rep("Down",length(y.max.prob))
#y.nb.pred[y.nb.prob[,1] == y.max.prob] = "Down"
y.nb.pred[y.nb.prob[,2] == y.max.prob] = "Flat"
y.nb.pred[y.nb.prob[,3] == y.max.prob] = "Up"

# Evaluate the accuracy
nb.acc = mean(y.nb.pred==direction[-train]) # Directly compute the accuracy
nb.acc

table(y.nb.pred , direction[-train]) # Confusion matrix of results

