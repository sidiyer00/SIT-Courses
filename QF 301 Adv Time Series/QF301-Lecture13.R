## First let's create our own function for K-Fold Cross-Validation
# This exists in various packages, but let's explore the way this works on our own first
cv <- function(K,data) {
  N = nrow(data) # Number of data points
  D = 1:N # Original set of data points to sample from
  df = list()
  for (k in seq(1,K-1)) {
    val.data = sample(D,N/K,replace = FALSE) # Randomly sample N/K data points from those not already selected
    D = D[!D %in% val.data] # Remove these data points from the collection so that they are not resampled
    df[[k]] = data[val.data,] # Create the kth fold of data
  }
  df[[K]] = data[D,] # Data remaining after creating the first K-1 groups
  
  cv.train = list()
  cv.val = list()
  for (k in seq(1,K)) {
    CV.Training = data.frame()
    for (l in seq(1,K)) {
      if (l != k) {
        CV.Training = rbind(CV.Training,df[[l]]) # Create a training data set by binding all folds but k
      }
    }
    cv.train[[k]] = CV.Training
    cv.val[[k]] = df[[k]] # Validation set by taking the kth fold
  }
  CV = list(train = cv.train, val = cv.val)
  return(CV)
}

library(glmnet)
library(tree)
library(randomForest)
library(keras)
library(boot) # Has a lot of bootstrapping and cross-validation tools

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

# Create 5-fold cross-validation data set
K = 5
cv.df = cv(K,df)

## Consider linear regression
lin.cv.error = rep(0,K)
for (k in seq(1,K)) {
  lin.reg = glm(y ~ x , data=cv.df$train[[k]])
  lin.cv.error[k] = mean((cv.df$val[[k]]$y - predict(lin.reg , cv.df$val[[k]]))^2)
}
mean(lin.cv.error)

# Compare this manual approach with the "boot" package
glm.reg = glm(y ~ x , data=df)
cv.glm(df , glm.reg , K=K)$delta[1]


## Consider a regression tree now
tree.cv.error = rep(0,K)
for (k in seq(1,K)) {
  tree.reg = tree(y ~ x , data=cv.df$train[[k]])
  tree.cv.error[k] = mean((cv.df$val[[k]]$y - predict(tree.reg , cv.df$val[[k]]))^2)
}
mean(tree.cv.error)

## Consider a random forest (same as bagging in this case)
rf.cv.error = rep(0,K)
for (k in seq(1,K)) {
  rf.reg = randomForest(y~x,data=cv.df$train[[k]],mtry=1,importance=TRUE)
  rf.cv.error[k] = mean((cv.df$val[[k]]$y - predict(rf.reg , cv.df$val[[k]]))^2)
}
mean(rf.cv.error)


## Consider a neural network
# Single hidden layer with 2 units first
nn.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 2, activation = "relu") %>%
  layer_dense(1 , activation = "linear")

nn.reg %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

nn.cv.error = rep(0,K)
for (k in seq(1,K)) {
  nn.reg %>% 
    fit(
      x = cv.df$train[[k]]$x , y = cv.df$train[[k]]$y,
      epochs = 100,
      verbose = 0
    )
  
  nn.cv.error[k] = mean((cv.df$val[[k]]$y - predict(nn.reg , cv.df$val[[k]]$x))^2)
}
mean(nn.cv.error)

# What about if we have more hidden units?
nn.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(1 , activation = "linear")

nn.reg %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

nn.cv.error = rep(0,K)
for (k in seq(1,K)) {
  nn.reg %>% 
    fit(
      x = cv.df$train[[k]]$x , y = cv.df$train[[k]]$y,
      epochs = 100,
      verbose = 0
    )
  
  nn.cv.error[k] = mean((cv.df$val[[k]]$y - predict(nn.reg , cv.df$val[[k]]$x))^2)
}
mean(nn.cv.error)

# What about for a deep neural network?
nn.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(1 , activation = "linear")

nn.reg %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

nn.cv.error = rep(0,K)
for (k in seq(1,K)) {
  nn.reg %>% 
    fit(
      x = cv.df$train[[k]]$x , y = cv.df$train[[k]]$y,
      epochs = 100,
      verbose = 0
    )
  
  nn.cv.error[k] = mean((cv.df$val[[k]]$y - predict(nn.reg , cv.df$val[[k]]$x))^2)
}
mean(nn.cv.error)




## Let's return to an example from Lecture 5
set.seed(0)
#Ridge Regression
x1=rnorm(500,0,2)
x2=rnorm(500,.5,.1)
x3=rnorm(500,.1,.001)
x4=rnorm(500,-1,1)
y=3*x1+.75*x3+rnorm(500,0,1) #notice x2 and x4 are not included
examp=data.frame(y,x1,x2,x3,x4)

lambda=10^seq(-2,4,by=.01)
x=model.matrix(y~.,examp)[,-1]
y=examp$y

train=sample(500,400,replace=FALSE) #Train/Test split

ridge.mod=glmnet(x[train,],y[train],alpha=0,lambda=lambda) #Ridge can also be run from glmnet
cv.out=cv.glmnet(x[train,],y[train],alpha=0,lambda=lambda) #Evaluate performance
plot(cv.out)
bestlam=cv.out$lambda.min
bestlam

# Let's now do this cross-validation ourselves with K = 10
K = 10
# We want to reset the indices of the training data
df = examp[train,]
row.names(df) <- 1:400
cv.df = cv(K,df)

cv.errors = rep(0,length(lambda))
ind = 1
for (lam in lambda) {
  ridge.cv.error = rep(0,K)
  for (k in seq(1,K)) {
    x.train = model.matrix(y~.,cv.df$train[[k]])
    ridge.reg = glmnet(x.train,cv.df$train[[k]]$y,alpha=0,lambda=lam)
    x.val = model.matrix(y~.,cv.df$val[[k]])
    ridge.cv.error[k] = mean((cv.df$val[[k]]$y - predict(ridge.reg , newx=x.val , s=lam))^2)
  }
  cv.errors[ind] = mean(ridge.cv.error)
  ind = ind+1
}
plot(log(lambda),cv.errors)
mylam = lambda[which.min(cv.errors)]
mylam




#Lasso
lasso.mod=glmnet(x[train,],y[train],alpha=1,lambda=lambda) #LASSO is with alpha=1
cv.out=cv.glmnet(x[train,],y[train],alpha=1,lambda=lambda)
plot(cv.out)
bestlam=cv.out$lambda.min
bestlam


# Let's now do this cross-validation ourselves with K = 10
# We already have our cross-validation groups

cv.errors = rep(0,length(lambda))
ind = 1
for (lam in lambda) {
  lasso.cv.error = rep(0,K)
  for (k in seq(1,K)) {
    x.train = model.matrix(y~.,cv.df$train[[k]])
    lasso.reg = glmnet(x.train,cv.df$train[[k]]$y,alpha=1,lambda=lam)
    x.val = model.matrix(y~.,cv.df$val[[k]])
    lasso.cv.error[k] = mean((cv.df$val[[k]]$y - predict(lasso.reg , newx=x.val , s=lam))^2)
  }
  cv.errors[ind] = mean(lasso.cv.error)
  ind = ind+1
}
plot(log(lambda),cv.errors)
mylam = lambda[which.min(cv.errors)]
mylam # Why might this differ from that found with the built in function?
# Run the loop again (after creating a new cross-validation grouping) and see if it has the same results

# What is the best cross-validation error?
min(cv.errors)

# How do these validation errors compare with the test errors?
bestlasso.pred=predict(lasso.mod,s=bestlam,newx=x[-train,])
mean((bestlasso.pred-y[-train])^2) #Lasso MSE

mylasso.pred=predict(lasso.mod,s=mylam,newx=x[-train,])
mean((mylasso.pred-y[-train])^2) #Lasso MSE




## We conclude by looking at Leave One Out Cross-Validation (K = N) vs. fixed K < N 
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

# Run a linear regression
K = 5
cv.df = cv(K,df)

lin.cv.error = rep(0,K)
for (k in seq(1,K)) {
  lin.reg = glm(y ~ x , data=cv.df$train[[k]])
  lin.cv.error[k] = mean((cv.df$val[[k]]$y - predict(lin.reg , cv.df$val[[k]]))^2)
}
mean(lin.cv.error)
sd(lin.cv.error)

# Run again with new sampling for K-Fold Cross-Validation
K = 5
cv.df = cv(K,df)

lin.cv.error = rep(0,K)
for (k in seq(1,K)) {
  lin.reg = glm(y ~ x , data=cv.df$train[[k]])
  lin.cv.error[k] = mean((cv.df$val[[k]]$y - predict(lin.reg , cv.df$val[[k]]))^2)
}
mean(lin.cv.error)
sd(lin.cv.error)
# Results can depend on the rand samples chosen

# Now consider LOOCV
loocv.df = cv(N,df)
lin.cv.error = rep(0,N)
for (k in seq(1,N)) {
  lin.reg = glm(y ~ x , data=loocv.df$train[[k]])
  lin.cv.error[k] = (loocv.df$val[[k]]$y - predict(lin.reg , loocv.df$val[[k]]))^2 # Why don't we need to consider the mean?
}
mean(lin.cv.error)
sd(lin.cv.error)

# This can also be done more simply by without running our manual "cv" function
lin.cv.error = rep(0,N)
for (i in seq(1,N)) {
  lin.reg = glm(y ~ x , data=df[-i,])
  lin.cv.error[i] = (df$y[i] - predict(lin.reg , df[i,]))^2 # Why don't we need to consider the mean?
}
mean(lin.cv.error)
sd(lin.cv.error)


