library(tree)
library(randomForest)
library(keras)
library(e1071)

set.seed(0)
# Generate random data
N = 200
M = 20 # Larger number of inputs
x = matrix(rnorm(N*M), N,M)
B0 = 0
B = 2^seq(from=1,to=-10,length.out=M) # Decreasing actual importance
y = (B0 + x%*%B + rnorm(N,0,1) > 0) + 0 # "+0" to make this 1/0

df = data.frame(y,x)
head(df)

train = sample(N,N/2,replace=FALSE)

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

# Mean Decrease in Impurity
tree.data = tree.class$frame
tree.data
tree.mdi = rep(0,ncol(df.tree)-1) # Number of predictors

gini.impurity = rep(0,nrow(tree.data)) # Initialize all Gini values as 0
names(gini.impurity) <- rownames(tree.data) # Keep labels of the splits
for (i in 1:nrow(tree.data)) {
  gini.impurity[i] = tree.data$yprob[i,2]*(1-tree.data$yprob[i,2]) # p_1*(1-p_1)
}

predictors = colnames(df.tree)[-1]
nodes = sort(as.integer(rownames(tree.data)))
max.seen = 1
for (i in 1:nrow(tree.data)) {
  if (toString(tree.data$var[i]) == "<leaf>") { #No decisions at leaf nodes
    next
  }
  # Compute the change in Gini impurity
  gini.importance = tree.data[toString(nodes[i]),2]*gini.impurity[toString(nodes[i])] #2nd column of tree.data is number of elements
  gini.importance = gini.importance - tree.data[toString(nodes[max.seen+1]),2]*gini.impurity[toString(nodes[max.seen+1])]
  gini.importance = gini.importance - tree.data[toString(nodes[max.seen+2]),2]*gini.impurity[toString(nodes[max.seen+2])]
  max.seen = max.seen + 2
  
  feature = toString(tree.data[toString(nodes[i]),1])
  for (p in 1:M) {
    if (feature == predictors[p]) {
      tree.mdi[p] = tree.mdi[p] + gini.importance # Update the importance for the appropriate predictor
      break
    }
  }
}
names(tree.mdi) <- predictors
tree.mdi



# Mean Decrease in Accuracy
accuracy = mean(tree.pred==df.tree$y[-train]) # Compute the test accuracy of full tree (computed above)
tree.mda = rep(0,M)
for (i in 1:M) {
  df.mda = df.tree
  df.mda[train,i+1] = sample(df.mda[train,i+1],length(train),replace=FALSE) # Permute the i-th predictor
  
  tree.mda.class = tree(y ~ . , data=df.mda , subset = train) # Train a tree on the altered data set
  
  tree.mda.pred = predict(tree.mda.class,df.mda[-train,],type="class")
  tree.acc = mean(tree.mda.pred==df.mda$y[-train]) #Compute the accuracy for mda
  tree.mda[i] = accuracy - tree.acc
}
names(tree.mda) <- predictors
tree.mda # Compare these importances with MDI





#We can prune our tree and see if this changes the importances
#To prune the tree (note that cv.tree will give an error if data frame is called "df"):
cv.tree.class = cv.tree(object=tree.class,FUN=prune.misclass) #Cross-validation of a tree to prune (based on misclassification)
cv.tree.class
#Deviance appears to be minimized with 6 nodes -- size = 6
#See this visually:
par(mfrow=c(1,2))
plot(cv.tree.class$size,cv.tree.class$dev,type="b")
plot(cv.tree.class$k,cv.tree.class$dev,type="b")

# Prune to the best 6 nodes
tree.pruned <- prune.tree(tree.class, best=6) #Prune to 6 terminal nodes
par(mfrow=c(1,1))
plot(tree.pruned)
text(tree.pruned)

#Consider tree performance
summary(tree.pruned)
tree.pred = predict(tree.pruned,df.tree[-train,],type="class")
table(tree.pred,df.tree$y[-train]) #Confusion matrix
mean(tree.pred==df.tree$y[-train]) #Compare accuracy to summary


# Mean Decrease in Impurity
tree.data = tree.pruned$frame
tree.data
tree.mdi = rep(0,ncol(df.tree)-1) # Number of predictors

gini.impurity = rep(0,nrow(tree.data)) # Initialize all Gini values as 0
names(gini.impurity) <- rownames(tree.data) # Keep labels of the splits
for (i in 1:nrow(tree.data)) {
  gini.impurity[i] = tree.data$yprob[i,2]*(1-tree.data$yprob[i,2]) # p_1*(1-p_1)
}

predictors = colnames(df.tree)[-1]
nodes = sort(as.integer(rownames(tree.data)))
max.seen = 1
for (i in 1:nrow(tree.data)) {
  if (toString(tree.data$var[i]) == "<leaf>") { #No decisions at leaf nodes
    next
  }
  # Compute the change in Gini impurity
  gini.importance = tree.data[toString(nodes[i]),2]*gini.impurity[toString(nodes[i])] #2nd column of tree.data is number of elements
  gini.importance = gini.importance - tree.data[toString(nodes[max.seen+1]),2]*gini.impurity[toString(nodes[max.seen+1])]
  gini.importance = gini.importance - tree.data[toString(nodes[max.seen+2]),2]*gini.impurity[toString(nodes[max.seen+2])]
  max.seen = max.seen + 2
  
  feature = toString(tree.data[toString(nodes[i]),1])
  for (p in 1:M) {
    if (feature == predictors[p]) {
      tree.mdi[p] = tree.mdi[p] + gini.importance # Update the importance for the appropriate predictor
      break
    }
  }
}
names(tree.mdi) <- predictors
tree.mdi



# Mean Decrease in Accuracy
accuracy = mean(tree.pred==df.tree$y[-train]) # Compute the test accuracy of full tree (computed above)
tree.mda = rep(0,M)
for (i in 1:M) {
  df.mda = df.tree
  df.mda[train,i+1] = sample(df.mda[train,i+1],length(train),replace=FALSE) # Permute the i-th predictor
  
  tree.mda.class = tree(y ~ . , data=df.mda , subset = train) # Train a tree on the altered data set
  tree.mda.class <- prune.tree(tree.mda.class, best=6)
  
  tree.mda.pred = predict(tree.mda.class,df.mda[-train,],type="class")
  tree.acc = mean(tree.mda.pred==df.mda$y[-train]) #Compute the accuracy for mda
  tree.mda[i] = accuracy - tree.acc
}
names(tree.mda) <- predictors
tree.mda # Compare these importances with MDI




# Importances are easier to compute with Random Forest
# Built into the randomForest package
set.seed(0)
rf.class = randomForest(y ~ . , data=df.tree , subset=train , mtry=5 , importance=TRUE)
rf.class
rf.class$importance # MeanDecreaseGini is MDI
                    # MeanDecreaseAccuracy is MDA (based on bagging errors)
varImpPlot(rf.class) # Plot the feature importances

# Compare the manual MDA on test error to the bagging MDA
rf.pred = predict(rf.class,newdata=df.tree[-train,])
table(rf.pred,df.tree$y[-train]) #Confusion matrix
accuracy = mean((rf.pred==df.tree$y[-train]))
accuracy

rf.mda = rep(0,M)
for (i in 1:M) {
  df.mda = df.tree
  df.mda[,i+1] = sample(df.mda[,i+1],nrow(df.mda),replace=FALSE) # Permute the i-th predictor
  # Permutations can be done on the training data only or all data
  
  rf.mda.class = randomForest(y ~ . , data=df.mda , subset = train) # Train a random forest on the altered data set

  rf.mda.pred = predict(rf.mda.class,df.mda[-train,])
  rf.acc = mean(rf.mda.pred==df.mda$y[-train]) #Compute the accuracy for mda
  rf.mda[i] = accuracy - rf.acc
}
names(rf.mda) <- predictors
rf.mda # Manually computed
rf.class$importance[,"MeanDecreaseAccuracy"] # Values computed by randomForest

# Because of the random permutations, if we run this again we get a different result on feature importance




# Consider MDA for Neural Network
# Notice how this can be slow
set.seed(0)
nn.class = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(M)) %>%
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
accuracy = mean((nn.pred==df$y[-train]))
accuracy

nn.mda = rep(0,M)
for (i in 1:M) {
  df.mda = df
  df.mda[,i+1] = sample(df.mda[,i+1],nrow(df.mda),replace=FALSE) # Permute the i-th predictor
  # Permutations can be done on the training data only or all data
  
  nn.class %>% # Re-train the neural network on the altered data set
    fit(
      x = as.matrix(df.mda[train,-1]), y = df.mda$y[train],
      epochs = 500, # may want to use fewer epochs to speed up the code
      verbose = 0
    ) 
  
  nn.mda.prob = predict(nn.class , as.matrix(df.mda[-train,-1]))
  nn.mda.pred = (nn.mda.prob > 0.5) + 0
  nn.acc = mean(nn.mda.pred==df.mda$y[-train]) #Compute the accuracy for mda
  nn.mda[i] = accuracy - nn.acc
}
names(nn.mda) <- predictors
nn.mda # Manually computed




## Feature Selection (including SFI)
set.seed(0)
# Let's use our cross-validation function from Lecture 13
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

K = 10
cv.df = cv(K,df) #10-fold cross-validation data set

## Consider logistic regression with only 1 feature
# Single Feature Importance (SFI)
log.sfi = rep(0,M)
for (i in seq(1,M)) {
  cv.error = rep(0,K)
  for (k in seq(1,K)) {
    df.train = cv.df$train[[k]][,c(1,i+1)] # Extract only the output and a single feature
    df.test = cv.df$val[[k]][,c(1,i+1)]
    
    log.reg = glm(y ~ . , data=df.train , family=binomial)
    
    log.probs = predict(log.reg , newdata=df.test , type="response")
    log.pred = (log.probs > 0.5) + 0 # Extract predicted class
    cv.error[k] = mean(log.pred == df.test$y)
  }
  log.sfi[i] = mean(cv.error)
}
names(log.sfi) <- predictors
log.sfi


# Forward selection of features
# Sequentially add whichever feature improves predictions the most
names(log.sfi) <- seq(1,M)
accuracy = rep(0,M)
feature = list()
feature[[1]] = as.integer(names(sort(log.sfi , decreasing = TRUE)[1]))
accuracy[1] = max(log.sfi)
for (j in seq(2,M)) { # We already considered the first feature with SFI
  log.acc = rep(0,M)
  for (i in seq(1,M)) {
    if (i %in% feature[[j-1]]) {
      log.acc[i] = -1
      next
    }
    cv.error = rep(0,K)
    for (k in seq(1,K)) {
      df.train = cv.df$train[[k]][,c(1,feature[[j-1]]+1,i+1)] # Extract only the output, previous features and a single extra feature
      df.test = cv.df$val[[k]][,c(1,feature[[j-1]]+1,i+1)]
      
      log.reg = glm(y ~ . , data=df.train , family=binomial)
      
      log.probs = predict(log.reg , newdata=df.test , type="response")
      log.pred = (log.probs > 0.5) + 0 # Extract predicted class
      cv.error[k] = mean(log.pred == df.test$y)
    }
    log.acc[i] = mean(cv.error)
  }
  names(log.acc) <- seq(1,M)
  feature[[j]] = c(feature[[j-1]] , as.integer(names(sort(log.acc , decreasing = TRUE)[1])))
  accuracy[j] = max(log.acc)
}
feature
accuracy

# Choose the set of features that has good tradeoff between complexity (number of variables) and performance (accuracy)
# 4 predictors gives maximum accuracy with fewest features
feature[[4]]



# Backward selection of features
# Sequentially remove whichever feature is least important for predictions

accuracy = rep(0,M)
feature = list()
feature[[M]] = seq(1,M)

cv.error = rep(0,K)
for (k in seq(1,K)) { # Compute cross-validation error when using all features
  df.train = cv.df$train[[k]]
  df.test = cv.df$val[[k]]
  
  log.reg = glm(y ~ . , data=df.train , family = binomial)
  
  log.probs = predict(log.reg , newdata=df.test , type="response")
  log.pred = (log.probs > 0.5) + 0 # Extract predicted class
  cv.error[k] = mean(log.pred == df.test$y)
}
accuracy[M] = mean(cv.error)

for (j in seq(M-1,1)) { # We already considered the final list (all features)
  log.acc = rep(-1,M)
  for (i in seq(1,length(feature[[j+1]]))) {
    cv.error = rep(0,K)
    for (k in seq(1,K)) {
      df.train = cv.df$train[[k]][,c(1,feature[[j+1]][-i]+1)] # Extract the output and all previous features except a single one
      df.test = cv.df$val[[k]][,c(1,feature[[j+1]][-i]+1)]
      
      log.reg = glm(y ~ . , data=df.train , family=binomial)
      
      log.probs = predict(log.reg , newdata=df.test , type="response")
      log.pred = (log.probs > 0.5) + 0 # Extract predicted class
      cv.error[k] = mean(log.pred == df.test$y)
    }
    log.acc[feature[[j+1]][i]] = mean(cv.error)
  }
  names(log.acc) <- seq(1,M)
  worst.feature = as.integer(names(sort(log.acc , decreasing = TRUE)[1]))
  feature[[j]] = feature[[j+1]][-which(feature[[j+1]]==worst.feature)]
  accuracy[j] = max(log.acc)
}
feature
accuracy

# Choose the set of features that has good tradeoff between complexity (number of variables) and performance (accuracy)
# 6 predictors gives good tradeoff between accuracy with features
feature[[6]]

# Other selection approaches exist





#Principal Component Analysis
setwd("C:/Users/zfeinstein/Dropbox/TEACHING/QF301/2021-Fall/Week11") #Update to whereever you saved the data

AdjCl=read.csv("FinDataAdjCl.csv",header=T)
head(AdjCl)

spylog=log(AdjCl$SPY[2:1258]/AdjCl$SPY[1:1257])
spylog=spylog[-1258]
spmean=mean(spylog)
spsd=sd(spylog)
spydirec=spylog
for (i in 1:length(spylog))
{
  if(spylog[i]<(spmean-spsd))
  {
    spydirec[i]=1
  }
  else if(spylog[i]<spmean)
  {
    spydirec[i]=2
  }
  else if(spylog[i]<spmean+spsd)
  {
    spydirec[i]=3
  }
  else
  {spydirec[i]=4}
}

spydirec=as.factor(spydirec)

spydirec2=as.factor(sign(log(AdjCl$SPY[2:1258]/AdjCl$SPY[1:1257])))

LogRet=AdjCl[,-c(1,9,10)]
AdjCl2=AdjCl[,-c(1,9)] #Get rid of date, Roku
temp=LogRet

for (i in 1:26)
{
  LogRet[1:1257,i]=log(temp[2:1258,i]/temp[1:1257,i])
}
LogRet=LogRet[-1258,]


length(LogRet[,1])
index=seq(1:1257)
set.seed(314)
train=sample(1257,630,replace=FALSE)
Direc=cbind(spydirec,LogRet)
SpyLog=cbind(spylog,LogRet)




#AdjCl2 is all stocks other than Roku (also removes date)
pr.out=prcomp(AdjCl2,scale=TRUE) #Make sure you scale the vectors for principal component analysis

names(pr.out)

pr.out$center #The mean of the values
pr.out$scale #By what degree these inputs had to be scaled

pr.out$rotation #Provides the unit vectors for PCA

dim(pr.out$x) #data points by dimensions

biplot(pr.out,scale=0) #Plot data projected onto the first 2 principal components

#Notice that the negative of our loadings give the same fit
pr.out$rotation=-pr.out$rotation
pr.out$x=-pr.out$x
biplot(pr.out,scale=0)

pr.out$sdev #Standard deviation explained by each principal component
pr.var=pr.out$sdev^2 #Variance explained
pr.var

pve=pr.var/sum(pr.var) #Proportion of variance explained
pve 

plot(pve,xlab="Principal Component",ylab="Proportion of Variance Explained", ylim=c(0,1), type='b')
plot(cumsum(pve),xlab="Principal Component",ylab="Cumulative Proportion",ylim=c(0,1),type='b') #Scree plot


#What if we do not scale our data first?
pr.out2=prcomp(AdjCl2,scale=FALSE)

pr.out2$center #Means
pr.out2$scale #No scaling

biplot(pr.out2,scale=0) #First principal component mostly captures Amazon and Google
#Happens because Amazon and Google have stock prices much higher than everyone else

pr.out2$sdev
pr.var2=pr.out2$sdev^2
pr.var2

pve2=pr.var2/sum(pr.var2)
pve2 #Even just a single principal component captures almost all the variance

plot(pve2,xlab="Principal Component",ylab="Proportion of Variance Explained", ylim=c(0,1), type='b')
plot(cumsum(pve2),xlab="Principal Component",ylab="Cumulative Proportion",ylim=c(0,1),type='b') #Scree plot







