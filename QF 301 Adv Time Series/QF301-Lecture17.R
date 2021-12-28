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
abline(v=0,col="red",lwd=2,lty=3)

# Accuracy from underlying relationship:
relationship.err = 1/N * sum(abs(y - (x > 0))) # Error rate
relationship.acc = 1 - relationship.err # Accuracy
relationship.acc

## Consider using decision tree to determine the classification
library(tree)
y.factor = as.factor(y)
df.tree = data.frame(x,y=y.factor)

tree.class = tree(y ~ x , data=df.tree)

plot(tree.class)
text(tree.class,pretty=0)

#Consider tree performance
summary(tree.class)
tree.pred = predict(tree.class,df.tree,type="class")
table(tree.pred,df.tree$y) #Confusion matrix
mean(tree.pred==df.tree$y) #Compare accuracy to summary

#To prune the tree (note that cv.tree will give an error if data frame is called "df"):
cv.tree.class = cv.tree(object=tree.class,FUN=prune.misclass) #Cross-validation of a tree to prune (based on misclassification)
names(cv.tree.class)
cv.tree.class
#Deviance appears to be minimized in the full tree -- size = 5
#See this visually:
par(mfrow=c(1,2))
plot(cv.tree.class$size,cv.tree.class$dev,type="b")
plot(cv.tree.class$k,cv.tree.class$dev,type="b")

#Though 5 is minimum, 2 is comparable deviance and much simpler model
prune.class = prune.misclass(tree.class,best=2) #Prune the tree to size 2
par(mfrow=c(1,1))
plot(prune.class)
text(prune.class,pretty=0)

prune.pred=predict(prune.class,df.tree,type="class")
table(prune.pred,df.tree$y) #Confusion matrix
mean(prune.pred==df.tree$y) #Compare accuracy to full tree (only marginally better)

# What do our decision boundaries look like for both trees?




## Consider bagging (random forest) classification
library(randomForest)

bag.class = randomForest(y ~ x,data=df.tree,mtry=1,importance=TRUE) #bagging because only 1 predictor
bag.class #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

bag.pred = predict(bag.class,newdata=df.tree)
table(bag.pred,df.tree$y) #Confusion matrix
mean((bag.pred==df.tree$y))
1-mean((bag.pred==df.tree$y)) #Compare with OOB estimate of 25% [looks much better because this is on training rather than testing data!]



## Consider a neural network for classification
library(keras)

nn.class = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 2, activation = "relu") %>%
  layer_dense(1 , activation = "sigmoid")

summary(nn.class)

nn.class %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "binary_crossentropy", # Using crossentropy loss function
    metrics = c("accuracy"), # Allows us to output extra information from training
    optimizer = "adam"
  )

losses = nn.class %>% # Fit the model to training data
  fit(
    x = df$x, y = df$y,
    epochs = 500, # how long to train for
    verbose = 0
  )

plot(losses) # Notice we are able to see the accuracy as well

nn.pred.prob = predict(nn.class, df$x) # Make predictions on the test data
nn.pred = (nn.pred.prob > 0.5) + 0
table(nn.pred,df$y) #Confusion matrix
mean((nn.pred==df$y))



## Consider SVM with linear kernel (maximal margin + support vector classifier)
library(e1071) # Again we can use the e1071 package

y.factor = as.factor(y)
df.svm = data.frame(x,y=y.factor)

# Maximal margin (as much as possible)
mm.class = svm(y ~ x,data=df.svm,kernel="linear",cost=10000,scale=T) #Maximal margin classifier (high cost --> maximal margin)
summary(mm.class)
names(mm.class)
mm.class$SV #Print out the support vectors

mm.pred=predict(mm.class,newdata = df.svm)
table(predict=mm.pred,truth=df.svm$y) #Confusion matrix with manually given names
mean((mm.pred==df.svm$y))

# Support vector classifier
svc.class = svm(y ~ x,data=df.svm,kernel="linear",cost=0.1,scale=T) #Support vector classifier (low cost)
summary(svc.class)
names(svc.class)
#svc.class$SV #Print out the support vectors

svc.pred=predict(svc.class,newdata = df.svm)
table(predict=svc.pred,truth=df.svm$y) #Confusion matrix with manually given names
mean((svc.pred==df.svm$y))

#Cross-Validation to get the optimal cost
tune.out = tune(svm,y ~ x,data=df.svm,kernel="linear",ranges=list(cost=c(0.001,.01,.1,1,5,10,100))) #Try to tune the cost through cross-validation
summary(tune.out) #See the error for different cost values

best.svc.class = tune.out$best.model #Choose the best model
best.svc.class$cost # Cost found
summary(best.svc.class)


best.svc.pred=predict(best.svc.class,newdata = df.svm)
table(predict=best.svc.pred,truth=df.svm$y) #Confusion matrix with manually given names
mean((best.svc.pred==df.svm$y))


## Consider SVM with radial basis kernel
svm.class = svm(y ~ x,data=df.svm,kernel="radial",cost=10,gamma=1,scale=T) #Support vector classifier (low cost)
summary(svm.class)
names(svm.class)
#svm.class$SV #Print out the support vectors

svm.pred=predict(svm.class,newdata = df.svm)
table(predict=svm.pred,truth=df.svm$y) #Confusion matrix with manually given names
mean((svm.pred==df.svm$y))

#Cross-Validation to get the optimal cost
tune.out = tune(svm,y ~ x,data=df.svm,kernel="radial",ranges=list(cost=c(0.001,.01,.1,1,5,10,100),gamma=c(.5,1,2,3,4))) #Try to tune the cost through cross-validation
summary(tune.out) #See the error for different cost values

best.svm.class = tune.out$best.model #Choose the best model
best.svm.class$cost # Cost found
best.svm.class$gamma # Gamma found
summary(best.svm.class)


best.svm.pred=predict(best.svm.class,newdata = df.svm)
table(predict=best.svm.pred,truth=df.svm$y) #Confusion matrix with manually given names
mean((best.svm.pred==df.svm$y))






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

## Consider using decision tree to determine the classification
y.factor = as.factor(y)
df.tree = data.frame(y=y.factor , x)

tree.class = tree(y ~ . , data=df.tree , subset = train)

plot(tree.class)
text(tree.class,pretty=0)

#Consider tree performance
summary(tree.class)
tree.pred = predict(tree.class,df.tree[-train,],type="class")
table(tree.pred,df.tree$y[-train]) #Confusion matrix
mean(tree.pred==df.tree$y[-train]) #Compare accuracy to summary

#To prune the tree (note that cv.tree will give an error if data frame is called "df"):
cv.tree.class = cv.tree(object=tree.class,FUN=prune.misclass) #Cross-validation of a tree to prune (based on misclassification)
cv.tree.class
#Deviance appears to be minimized in the full tree -- size = 5
#See this visually:
par(mfrow=c(1,2))
plot(cv.tree.class$size,cv.tree.class$dev,type="b")
plot(cv.tree.class$k,cv.tree.class$dev,type="b")

#Though 7 is minimum, 2 is comparable deviance and much simpler model
prune.class = prune.misclass(tree.class,best=2) #Prune the tree to size 2
par(mfrow=c(1,1))
plot(prune.class)
text(prune.class,pretty=0)

prune.pred=predict(prune.class,df.tree[-train,],type="class")
table(prune.pred,df.tree$y[-train]) #Confusion matrix
mean(prune.pred==df.tree$y[-train]) #Compare accuracy to full tree (only marginally better)

# What do our decision boundaries look like for both trees?




## Consider bagging (random forest) classification
rf.class = randomForest(y ~ .,data=df.tree,subset=train,mtry=5,importance=TRUE) # consider 5 variables per tree
rf.class #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

rf.pred = predict(rf.class,newdata=df.tree[-train,])
table(rf.pred,df.tree$y[-train]) #Confusion matrix
mean((rf.pred==df.tree$y[-train]))
1-mean((rf.pred==df.tree$y[-train])) #Compare with OOB estimate of 15% 



## Consider a neural network for classification
nn.class = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(20)) %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(1 , activation = "sigmoid")

summary(nn.class)

nn.class %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "binary_crossentropy", # Using crossentropy loss function
    metrics = c("accuracy"), # Allows us to output extra information from training
    optimizer = "adam"
  )

losses = nn.class %>% # Fit the model to training data
  fit(
    x = as.matrix(df[train,-1]), y = df$y[train],
    epochs = 500, # how long to train for
    verbose = 0
  )

plot(losses) # Notice we are able to see the accuracy as well

nn.pred.prob = predict(nn.class, as.matrix(df[-train,-1])) # Make predictions on the test data
nn.pred = (nn.pred.prob > 0.5) + 0
table(nn.pred,df$y[-train]) #Confusion matrix
mean((nn.pred==df$y[-train]))



## Consider SVM with linear kernel (maximal margin + support vector classifier)
y.factor = as.factor(y)
df.svm = data.frame(x,y=y.factor)

# Maximal margin (as much as possible)
mm.class = svm(y ~ .,data=df.svm,subset=train,kernel="linear",cost=10000,scale=T) #Maximal margin classifier (high cost --> maximal margin)
summary(mm.class)
names(mm.class)

mm.pred=predict(mm.class,newdata = df.svm[-train,])
table(predict=mm.pred,truth=df.svm$y[-train]) #Confusion matrix with manually given names
mean((mm.pred==df.svm$y[-train]))

# Support vector classifier
svc.class = svm(y ~ .,data=df.svm,subset=train,kernel="linear",cost=0.1,scale=T) #Support vector classifier (low cost)
summary(svc.class)
names(svc.class)
#svc.class$SV #Print out the support vectors

svc.pred=predict(svc.class,newdata = df.svm[-train,])
table(predict=svc.pred,truth=df.svm$y[-train]) #Confusion matrix with manually given names
mean((svc.pred==df.svm$y[-train]))

#Cross-Validation to get the optimal cost
tune.out = tune(svm,y ~ .,data=df.svm[train,],kernel="linear",ranges=list(cost=c(0.001,.01,.1,1,5,10,100))) #Try to tune the cost through cross-validation
summary(tune.out) #See the error for different cost values

best.svc.class = tune.out$best.model #Choose the best model
best.svc.class$cost # Cost found
summary(best.svc.class)


best.svc.pred=predict(best.svc.class,newdata = df.svm[-train,])
table(predict=best.svc.pred,truth=df.svm$y[-train]) #Confusion matrix with manually given names
mean((best.svc.pred==df.svm$y[-train]))


## Consider SVM with radial basis kernel
#Cross-Validation to get the optimal cost
tune.out = tune(svm,y ~ .,data=df.svm[train,],kernel="radial",ranges=list(cost=c(0.001,.01,.1,1,5,10,100),gamma=c(.5,1,2,3,4))) #Try to tune the cost through cross-validation
summary(tune.out) #See the error for different cost values

best.svm.class = tune.out$best.model #Choose the best model
best.svm.class$cost # Cost found
best.svm.class$gamma # Gamma found
summary(best.svm.class)


best.svm.pred=predict(best.svm.class,newdata = df.svm[-train,])
table(predict=best.svm.pred,truth=df.svm$y[-train]) #Confusion matrix with manually given names
mean((best.svm.pred==df.svm$y[-train]))





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

train = sample(length(r0),length(r0)/2,replace=FALSE) # Train/test split

## Consider using decision tree to determine the classification
direction.factor = as.factor(direction)
df.tree = data.frame(direction=direction.factor , r1,r2,r3)

tree.class = tree(direction ~ . , data=df.tree , subset = train)

# plot(tree.class) # Single-node tree
tree.class

#Consider tree performance
summary(tree.class)
tree.pred = predict(tree.class,df.tree[-train,],type="class")
table(predict=tree.pred,truth=df.tree$direction[-train]) #Confusion matrix
mean(tree.pred==df.tree$direction[-train]) #Compare accuracy to summary




## Consider bagging (random forest) classification
rf.class = randomForest(direction ~ .,data=df.tree,subset=train,mtry=2,importance=TRUE) # consider 2 variables per tree
rf.class #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

rf.pred = predict(rf.class,newdata=df.tree[-train,])
table(predict=rf.pred,truth=df.tree$direction[-train]) #Confusion matrix
mean((rf.pred==df.tree$direction[-train]))
1-mean((rf.pred==df.tree$direction[-train])) #Compare with OOB estimate of 46.23% 



## Consider a neural network for classification
nn.class = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(3)) %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(1 , activation = "sigmoid")

summary(nn.class)

nn.class %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "binary_crossentropy", # Using crossentropy loss function
    metrics = c("accuracy"), # Allows us to output extra information from training
    optimizer = "adam"
  )

losses = nn.class %>% # Fit the model to training data
  fit(
    x = as.matrix(df[train,-1]), y = df$direction[train],
    epochs = 500, # how long to train for
    verbose = 0
  )

plot(losses) # Notice we are able to see the accuracy as well

nn.pred.prob = predict(nn.class, as.matrix(df[-train,-1])) # Make predictions on the test data
nn.pred = (nn.pred.prob > 0.5) + 0
table(predict=nn.pred,truth=df$direction[-train]) #Confusion matrix
mean((nn.pred==df$direction[-train]))



## Consider SVM with linear kernel
direction.factor = as.factor(direction)
df.svm = data.frame(direction=direction.factor,r1,r2,r3)

svc.class = svm(direction ~ .,data=df.svm,subset=train,kernel="linear",cost=0.1,scale=T) #Support vector classifier 
summary(svc.class)
names(svc.class)
#svc.class$SV #Print out the support vectors

svc.pred=predict(svc.class,newdata = df.svm[-train,])
table(predict=svc.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
mean((svc.pred==df.svm$direction[-train]))

## Skip "tune" because very slow
##Cross-Validation to get the optimal cost
#tune.out = tune(svm,direction ~ .,data=df.svm[train,],kernel="linear",ranges=list(cost=c(.01,1,100))) #Notice this can be very slow on larger data
#summary(tune.out) #See the error for different cost values
#
#best.svc.class = tune.out$best.model #Choose the best model
#best.svc.class$cost # Cost found
#summary(best.svc.class)
#
#best.svc.pred=predict(best.svc.class,newdata = df.svm[-train,])
#table(predict=best.svc.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
#mean((best.svc.pred==df.svm$direction[-train]))


## Consider SVM with radial basis kernel
svm.class = svm(direction ~ .,data=df.svm,subset=train,kernel="radial",cost=0.1,gamma=1,scale=T) #Support vector classifier 
summary(svm.class)
names(svm.class)
#svc.class$SV #Print out the support vectors

svm.pred=predict(svm.class,newdata = df.svm[-train,])
table(predict=svm.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
mean((svm.pred==df.svm$direction[-train]))

## Skip "tune" because very slow
##Cross-Validation to get the optimal cost
#tune.out = tune(svm,direction ~ .,data=df.svm[train,],kernel="radial",ranges=list(cost=c(.01,1,100),gamma=c(0.5,1,2))) #Try to tune the cost through cross-validation
#summary(tune.out) #See the error for different cost values
#
#best.svm.class = tune.out$best.model #Choose the best model
#best.svm.class$cost # Cost found
#summary(best.svm.class)
#
#best.svm.pred=predict(best.svm.class,newdata = df.svm[-train,])
#table(predict=best.svm.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
#mean((best.svm.pred==df.svm$direction[-train]))






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

## Consider using decision tree to determine the classification
direction.factor = as.factor(direction)
df.tree = data.frame(direction=direction.factor , r1,r2,r3)

tree.class = tree(direction ~ . , data=df.tree , subset = train)

plot(tree.class) 
text(tree.class,pretty=0)

#Consider tree performance
summary(tree.class)
tree.pred = predict(tree.class,df.tree[-train,],type="class")
table(predict=tree.pred,truth=df.tree$direction[-train]) #Confusion matrix
mean(tree.pred==df.tree$direction[-train]) #Compare accuracy to summary




## Consider bagging (random forest) classification
rf.class = randomForest(direction ~ .,data=df.tree,subset=train,mtry=2,importance=TRUE) # consider 2 variables per tree
rf.class #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

rf.pred = predict(rf.class,newdata=df.tree[-train,])
table(predict=rf.pred,truth=df.tree$direction[-train]) #Confusion matrix
mean((rf.pred==df.tree$direction[-train]))
1-mean((rf.pred==df.tree$direction[-train])) #Compare with OOB estimate of 48.46% 



## Consider a neural network for classification
head(direction)
direction.encode = rep(2,length(df$direction)) #Down
direction.encode[df$direction=="Flat"] = 1
direction.encode[df$direction=="Up"] = 0
direction.ohe = to_categorical(direction.encode,num_classes=3)
head(direction.ohe) #Always remember to check the order that your categories are encoded

nn.class = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(3)) %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(3 , activation = "softmax")

summary(nn.class)

nn.class %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "categorical_crossentropy", # Using crossentropy loss function
    metrics = c("accuracy"), # Allows us to output extra information from training
    optimizer = "adam"
  )

losses = nn.class %>% # Fit the model to training data
  fit(
    x = as.matrix(df[train,-1]), y = direction.ohe[train,],
    epochs = 500, # how long to train for
    verbose = 0
  )

plot(losses) # Notice we are able to see the accuracy as well

nn.pred.prob = predict(nn.class, as.matrix(df[-train,-1])) # Make predictions on the test data
head(nn.pred.prob)
nn.max.prob = pmax(nn.pred.prob[,1],nn.pred.prob[,2],nn.pred.prob[,3])

# Use predictions for classification
nn.pred = rep("Up",length(nn.max.prob))
#nn.pred[nn.pred.prob[,1] == nn.max.prob] = "Up"
nn.pred[nn.pred.prob[,2] == nn.max.prob] = "Flat"
nn.pred[nn.pred.prob[,3] == nn.max.prob] = "Down"

table(predict=nn.pred,truth=df$direction[-train]) #Confusion matrix
mean((nn.pred==df$direction[-train]))



## Consider SVM with linear kernel
direction.factor = as.factor(direction)
df.svm = data.frame(direction=direction.factor,r1,r2,r3)

svc.class = svm(direction ~ .,data=df.svm,subset=train,kernel="linear",cost=0.1,scale=T) #Support vector classifier 
summary(svc.class)
#names(svc.class)
#svc.class$SV #Print out the support vectors

svc.pred=predict(svc.class,newdata = df.svm[-train,])
table(predict=svc.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
mean((svc.pred==df.svm$direction[-train]))

## Skip "tune" because very slow
##Cross-Validation to get the optimal cost
#tune.out = tune(svm,direction ~ .,data=df.svm[train,],kernel="linear",ranges=list(cost=c(.01,1,100))) #Notice this can be very slow on larger data
#summary(tune.out) #See the error for different cost values
#
#best.svc.class = tune.out$best.model #Choose the best model
#best.svc.class$cost # Cost found
#summary(best.svc.class)
#
#best.svc.pred=predict(best.svc.class,newdata = df.svm[-train,])
#table(predict=best.svc.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
#mean((best.svc.pred==df.svm$direction[-train]))


## Consider SVM with radial basis kernel
svm.class = svm(direction ~ .,data=df.svm,subset=train,kernel="radial",cost=0.1,gamma=1,scale=T) #Support vector classifier 
summary(svm.class)
#names(svm.class)
#svc.class$SV #Print out the support vectors

svm.pred=predict(svm.class,newdata = df.svm[-train,])
table(predict=svm.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
mean((svm.pred==df.svm$direction[-train]))

## Skip "tune" because very slow
##Cross-Validation to get the optimal cost
#tune.out = tune(svm,direction ~ .,data=df.svm[train,],kernel="radial",ranges=list(cost=c(.01,1,100),gamma=c(0.5,1,2))) #Try to tune the cost through cross-validation
#summary(tune.out) #See the error for different cost values
#
#best.svm.class = tune.out$best.model #Choose the best model
#best.svm.class$cost # Cost found
#summary(best.svm.class)
#
#best.svm.pred=predict(best.svm.class,newdata = df.svm[-train,])
#table(predict=best.svm.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
#mean((best.svm.pred==df.svm$direction[-train]))





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

## Consider using decision tree to determine the classification
direction.factor = as.factor(direction)
df.tree = data.frame(direction=direction.factor , r1,r2,r3)

tree.class = tree(direction ~ . , data=df.tree , subset = train)

plot(tree.class) 
text(tree.class,pretty=0)

#Consider tree performance
summary(tree.class)
tree.pred = predict(tree.class,df.tree[-train,],type="class")
table(predict=tree.pred,truth=df.tree$direction[-train]) #Confusion matrix
mean(tree.pred==df.tree$direction[-train]) #Compare accuracy to summary




## Consider bagging (random forest) classification
rf.class = randomForest(direction ~ .,data=df.tree,subset=train,mtry=2,importance=TRUE) # consider 2 variables per tree
rf.class #Gives both the number of variables at each split but also provides out-of-bag estimate of error rate

rf.pred = predict(rf.class,newdata=df.tree[-train,])
table(predict=rf.pred,truth=df.tree$direction[-train]) #Confusion matrix
mean((rf.pred==df.tree$direction[-train]))
1-mean((rf.pred==df.tree$direction[-train])) #Compare with OOB estimate of 60.42% 



## Consider a neural network for classification
head(direction)
direction.encode = rep(2,length(df$direction)) #Down
direction.encode[df$direction=="Flat"] = 1
direction.encode[df$direction=="Up"] = 0
direction.ohe = to_categorical(direction.encode,num_classes=3)
head(direction.ohe) #Always remember to check the order that your categories are encoded

nn.class = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(3)) %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(3 , activation = "softmax")

summary(nn.class)

nn.class %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "categorical_crossentropy", # Using crossentropy loss function
    metrics = c("accuracy"), # Allows us to output extra information from training
    optimizer = "adam"
  )

losses = nn.class %>% # Fit the model to training data
  fit(
    x = as.matrix(df[train,-1]), y = direction.ohe[train,],
    epochs = 500, # how long to train for
    verbose = 0
  )

plot(losses) # Notice we are able to see the accuracy as well

nn.pred.prob = predict(nn.class, as.matrix(df[-train,-1])) # Make predictions on the test data
head(nn.pred.prob)
nn.max.prob = pmax(nn.pred.prob[,1],nn.pred.prob[,2],nn.pred.prob[,3])

# Use predictions for classification
nn.pred = rep("Up",length(nn.max.prob))
#y.nb.pred[nn.pred.prob[,1] == nn.max.prob] = "Up"
nn.pred[nn.pred.prob[,2] == nn.max.prob] = "Flat"
nn.pred[nn.pred.prob[,3] == nn.max.prob] = "Down"

table(predict=nn.pred,truth=df$direction[-train]) #Confusion matrix
mean((nn.pred==df$direction[-train]))



## Consider SVM with linear kernel
direction.factor = as.factor(direction)
df.svm = data.frame(direction=direction.factor,r1,r2,r3)

svc.class = svm(direction ~ .,data=df.svm,subset=train,kernel="linear",cost=0.1,scale=T) #Support vector classifier 
summary(svc.class)
#names(svc.class)
#svc.class$SV #Print out the support vectors

svc.pred=predict(svc.class,newdata = df.svm[-train,])
table(predict=svc.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
mean((svc.pred==df.svm$direction[-train]))

## Skip "tune" because very slow
##Cross-Validation to get the optimal cost
#tune.out = tune(svm,direction ~ .,data=df.svm[train,],kernel="linear",ranges=list(cost=c(.01,1,100))) #Notice this can be very slow on larger data
#summary(tune.out) #See the error for different cost values
#
#best.svc.class = tune.out$best.model #Choose the best model
#best.svc.class$cost # Cost found
#summary(best.svc.class)
#
#best.svc.pred=predict(best.svc.class,newdata = df.svm[-train,])
#table(predict=best.svc.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
#mean((best.svc.pred==df.svm$direction[-train]))


## Consider SVM with radial basis kernel
svm.class = svm(direction ~ .,data=df.svm,subset=train,kernel="radial",cost=0.1,gamma=1,scale=T) #Support vector classifier 
summary(svm.class)
#names(svm.class)
#svc.class$SV #Print out the support vectors

svm.pred=predict(svm.class,newdata = df.svm[-train,])
table(predict=svm.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
mean((svm.pred==df.svm$direction[-train]))

## Skip "tune" because very slow
##Cross-Validation to get the optimal cost
#tune.out = tune(svm,direction ~ .,data=df.svm[train,],kernel="radial",ranges=list(cost=c(.01,1,100),gamma=c(0.5,1,2))) #Try to tune the cost through cross-validation
#summary(tune.out) #See the error for different cost values
#
#best.svm.class = tune.out$best.model #Choose the best model
#best.svm.class$cost # Cost found
#summary(best.svm.class)
#
#best.svm.pred=predict(best.svm.class,newdata = df.svm[-train,])
#table(predict=best.svm.pred,truth=df.svm$direction[-train]) #Confusion matrix with manually given names
#mean((best.svm.pred==df.svm$direction[-train]))

