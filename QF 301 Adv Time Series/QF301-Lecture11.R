library(tree)
library(randomForest)
library(keras)

## Linear Relationship
set.seed(0)
# Create a fictitious data set
N = 100
x = rnorm(N)
epsilon = rnorm(N,sd=2)
B0 = 2
B1 = 3
y = B0+B1*x+epsilon
df = data.frame(x,y)

plot(x,y)
abline(B0,B1,col="red",lwd=2)

# Run a linear regression
lin.reg = glm(y~x,data=df)
abline(lin.reg,col="blue",lwd=2)

# Run a regression tree
tree.reg <- tree(y~x,data=df) #Regression Tree
plot(tree.reg)
text(tree.reg) #Notice how easy it is to see how the regression is drawn

# Run a random forest
bag.reg = randomForest(y~x,data=df,mtry=ncol(df)-1,importance=TRUE) #mtry=ncol(Direc)-1 means will do bagging because we use all predictors
bag.reg #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

# Test/plot fits
x.test = seq(from=min(x),to=max(x),by=0.01) # Test x values
y.true = B0 + B1*x.test # True relationship without noise
df.test = data.frame(x=x.test,y=y.true)
plot(x,y)
abline(B0,B1,col="red",lwd=2)

y.lin.pred = predict(lin.reg, df.test) # Make predictions on the test data
lin.MSE = mean((y.true - y.lin.pred)^2)
lin.MSE
abline(lin.reg,col="blue",lwd=2)

y.tree.pred = predict(tree.reg, df.test) # Predict with the single regression tree
tree.MSE = mean((y.true - y.tree.pred)^2)
tree.MSE
lines(x.test,y.tree.pred,col="orange",lwd=2)

y.bag.pred = predict(bag.reg, df.test) # Predict with the bagged trees
bag.MSE = mean((y.true - y.bag.pred)^2)
bag.MSE
lines(x.test,y.bag.pred,col="green",lwd=2)


## Nonlinear Relationship
set.seed(0)
# Create a fictitious data set
N = 100
x = rnorm(N)
epsilon = rnorm(N,sd=2)
B0 = 2
B1 = 3
y = B0+B1*x^2+epsilon
df = data.frame(x,y)

x.test = seq(from=min(x),to=max(x),by=0.01)
y.true = B0+B1*x.test^2
df.test = data.frame(x=x.test,y=y.true)

# Run a linear regression
lin.reg = glm(y ~ x , data=df)
summary(lin.reg)$coefficients

# Run a quadratic regression (since we know this is the ground truth)
quad.reg = glm(y ~ x + I(x^2) , data=df)
summary(quad.reg)$coefficients

# Run a single regression tree
tree.reg <- tree(y~x,data=df) #Regression Tree
plot(tree.reg)
text(tree.reg) #Notice how easy it is to see how the regression is drawn

# Run a random forest
bag.reg = randomForest(y~x,data=df,mtry=ncol(df)-1,importance=TRUE) #mtry=ncol(Direc)-1 means will do bagging because we use all predictors
bag.reg #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate


# Consider a deep neural network for comparison
# What is the shape of this network?
nn.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(1 , activation = "linear")

summary(nn.reg)

nn.reg %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

nn.reg %>% # Fit the model to training data
  fit(
    x = df$x, y = df$y,
    epochs = 500, # how long to train for
    verbose = 0
  )


# Test/plot fits
plot(x,y)
lines(x.test,y.true,col="red",lwd=2)

y.lin.pred = predict(lin.reg , df.test)
abline(lin.reg,col="blue",lwd=2)
lin.MSE = mean((y.true - y.lin.pred)^2)
lin.MSE

y.quad.pred = predict(quad.reg , df.test)
lines(x.test , y.quad.pred , col="blue",lwd=2)
quad.MSE = mean((y.true - y.quad.pred)^2)
quad.MSE

y.tree.pred = predict(tree.reg, df.test) # Predict with the single regression tree
lines(x.test,y.tree.pred,col="orange",lwd=2)
tree.MSE = mean((y.true - y.tree.pred)^2)
tree.MSE

y.bag.pred = predict(bag.reg, df.test) # Predict with the bagged trees
lines(x.test,y.bag.pred,col="green",lwd=2)
bag.MSE = mean((y.true - y.bag.pred)^2)
bag.MSE


y.nn.pred = predict(nn.reg, x.test) # Predict with the neural network
lines(x.test,y.nn.pred,col="purple",lwd=2)
nn.MSE = mean((y.true - y.nn.pred)^2) 
nn.MSE



## Should be wary of overfitting?
set.seed(0)
# Generate random data
N = 100
M = 20 # Larger number of inputs
x = matrix(rnorm(N*M), N,M)
B0 = 0
B = c(3,0.75,rep(0,M-2)) # Only use x1 and x2
y = B0 + x%*%B + rnorm(N,0,1) 
df = data.frame(y,x)
head(df)

train = sample(N,N/2,replace=FALSE)

tree.reg = tree(y~.,data=df,subset=train)
plot(tree.reg)
text(tree.reg)

mean((y[train] - predict(tree.reg, df[train,]))^2) #Training MSE

y.tree.pred = predict(tree.reg, df[-train,]) # Predict with the single regression tree
tree.MSE = mean((y[-train] - y.tree.pred)^2)
tree.MSE #Test MSE

# Can prune the tree further if desired
tree.pruned <- prune.tree(tree.reg, best=4) #Prune to 4 terminal nodes
plot(tree.pruned)
text(tree.pruned)
summary(tree.pruned)

mean((y[train] - predict(tree.pruned, df[train,]))^2) #Training MSE

y.pruned.pred = predict(tree.pruned, df[-train,]) # Predict with the single regression tree
tree.pruned.MSE = mean((y[-train] - y.pruned.pred)^2)
tree.pruned.MSE #Test MSE


# Does bagging or random forest improve the fit?
# Bagging
bag.reg = randomForest(y~.,data=df,subset=train,mtry=ncol(df)-1,importance=TRUE) #mtry=ncol(Direc)-1 means will do bagging because we use all predictors
bag.reg #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

mean((y[train] - predict(bag.reg, df[train,]))^2)

y.bag.pred = predict(bag.reg, df[-train,]) # Predict with bagging
bag.MSE = mean((y[-train] - y.bag.pred)^2)
bag.MSE

# Random Forest
rf.reg = randomForest(y~.,data=df,subset=train,mtry=ceiling(sqrt(ncol(df)-1)),importance=TRUE) #mtry=sqrt(ncol(Direc)-1) to try square root rule of thumb
rf.reg #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

mean((y[train] - predict(rf.reg, df[train,]))^2)

y.rf.pred = predict(rf.reg, df[-train,]) # Predict with bagging
rf.MSE = mean((y[-train] - y.rf.pred)^2)
rf.MSE

# Why do you think we persist with overfitting?





# Trees for financial data
set.seed(1)
library("quantmod")
getSymbols(c('SPY','MSFT','GE'),src='yahoo',from='2010-01-01',to='2020-01-01')
rSPY = dailyReturn(SPY$SPY.Adjusted,type='log')
rMSFT = dailyReturn(MSFT$MSFT.Adjusted,type='log')
rGE = dailyReturn(GE$GE.Adjusted,type='log')

# Create lagged data
rSPY1 = as.numeric(lag(rSPY,k=1)[-(1:5)])
rSPY2 = as.numeric(lag(rSPY,k=2)[-(1:5)])
rSPY3 = as.numeric(lag(rSPY,k=3)[-(1:5)])
rSPY4 = as.numeric(lag(rSPY,k=4)[-(1:5)])
rSPY5 = as.numeric(lag(rSPY,k=5)[-(1:5)])
rMSFT1 = as.numeric(lag(rMSFT,k=1)[-(1:5)])
rMSFT2 = as.numeric(lag(rMSFT,k=2)[-(1:5)])
rMSFT3 = as.numeric(lag(rMSFT,k=3)[-(1:5)])
rMSFT4 = as.numeric(lag(rMSFT,k=4)[-(1:5)])
rMSFT5 = as.numeric(lag(rMSFT,k=5)[-(1:5)])
rGE1 = as.numeric(lag(rGE,k=1)[-(1:5)])
rGE2 = as.numeric(lag(rGE,k=2)[-(1:5)])
rGE3 = as.numeric(lag(rGE,k=3)[-(1:5)])
rGE4 = as.numeric(lag(rGE,k=4)[-(1:5)])
rGE5 = as.numeric(lag(rGE,k=5)[-(1:5)])
rSPY = as.numeric(rSPY[-(1:5)])

df = data.frame(rSPY,rSPY1,rSPY2,rSPY3,rSPY4,rSPY5,
                rMSFT1,rMSFT2,rMSFT3,rMSFT4,rMSFT5,
                rGE1,rGE2,rGE3,rGE4,rGE5)

train = sample(length(rSPY),0.75*length(rSPY),replace=FALSE)

# Regression Tree for Predictions
tree.reg = tree(rSPY~.,data=df,subset=train)
plot(tree.reg)
text(tree.reg)
summary(tree.reg)

sqrt(mean((rSPY[train] - predict(tree.reg, df[train,]))^2)) #Training RMSE

rSPY.tree.pred = predict(tree.reg, df[-train,]) # Predict with the single regression tree
tree.MSE = mean((rSPY[-train] - rSPY.tree.pred)^2)
sqrt(tree.MSE) #Test RMSE

# Can prune the tree further if desired
tree.pruned <- prune.tree(tree.reg, best=4) #Prune to 4 terminal nodes
plot(tree.pruned)
text(tree.pruned)
summary(tree.pruned)

sqrt(mean((rSPY[train] - predict(tree.pruned, df[train,]))^2)) #Training RMSE

rSPY.pruned.pred = predict(tree.pruned, df[-train,]) # Predict with the single regression tree
tree.pruned.MSE = mean((rSPY[-train] - rSPY.pruned.pred)^2)
sqrt(tree.pruned.MSE) #Test RMSE


# Does bagging or random forest improve the fit?
# Bagging
bag.reg = randomForest(rSPY~.,data=df,subset=train,ntree=250,mtry=ncol(df)-1,importance=TRUE) #mtry=ncol(Direc)-1 means will do bagging because we use all predictors
bag.reg #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

sqrt(mean((rSPY[train] - predict(bag.reg, df[train,]))^2)) #Training RMSE

rSPY.bag.pred = predict(bag.reg, df[-train,]) # Predict with bagging
bag.MSE = mean((rSPY[-train] - rSPY.bag.pred)^2)
sqrt(bag.MSE) #Test RMSE

# Random Forest
rf.reg = randomForest(rSPY~.,data=df,subset=train,ntree=250,mtry=ceiling(sqrt(ncol(df)-1)),importance=TRUE) #mtry=sqrt(ncol(Direc)-1) to try square root rule of thumb
rf.reg #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

sqrt(mean((rSPY[train] - predict(rf.reg, df[train,]))^2)) #Training RMSE

rSPY.rf.pred = predict(rf.reg, df[-train,]) # Predict with bagging
rf.MSE = mean((rSPY[-train] - rSPY.rf.pred)^2)
sqrt(rf.MSE) #Test RMSE



