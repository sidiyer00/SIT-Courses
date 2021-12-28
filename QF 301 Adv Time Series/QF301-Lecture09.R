library("keras") #Other Neural Net Packages Exist

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

# Consider a neural network
# What is the shape of this network?
nn.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 2, activation = "relu") %>%
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

x.lin = seq(from=min(x),to=max(x),by=0.01) # Test x values
y.nn.pred = predict(nn.reg, x.lin) # Make predictions on the test data
lines(x.lin,y.nn.pred,col="purple",lwd=2)

# What happens if we fit this neural network again?
nn.reg %>% # Fit the model to training data
  fit(
    x = df$x, y = df$y,
    epochs = 500, # how long to train for
    verbose = 0
  )

x.lin = seq(from=min(x),to=max(x),by=0.01) # Test x values
y.nn.pred = predict(nn.reg, x.lin) # Make predictions on the test data
lines(x.lin,y.nn.pred,col="orange",lwd=2)


# Manually compare linear and neural network fits to "ground truth" y = B0 + B1*x
y.true = B0 + B1*x.lin
df.lin = data.frame(x=x.lin,y=y.true)
y.lin.pred = predict(lin.reg, df.lin) # Make predictions on the test data
lin.MSE = mean((y.true - y.lin.pred)^2)
lin.MSE

nn.MSE = mean((y.true - y.nn.pred)^2) #Using our last neural network
nn.MSE
nn.reg %>% 
  evaluate(x.lin, y.true, verbose = 0) #Another way to compute the MSE (losses)

# Let's go back to line 24 and consider other network structures
# What are the mathematical formulations for these structures?



## In case you want to save or load a model
#save_model_tf(object = model, filepath = "C:/Users/zfeinstein/Downloads/model") #Replace with your own file path
#reloaded_model = load_model_tf("C:/Users/zfeinstein/Downloads/model")
##all.equal(predict(nn.reg, x.lin), predict(reloaded_model, x.lin))




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

plot(x,y)
lines(x.test,y.true,col="red",lwd=2)

# Run a linear regression
lin.reg = glm(y ~ x , data=df)
summary(lin.reg)$coefficients

y.lin.pred = predict(lin.reg , df.test)
abline(lin.reg,col="blue",lwd=2)
lin.MSE = mean((y.true - y.lin.pred)^2)
lin.MSE

# Run a quadratic regression (since we know this is the ground truth)
quad.reg = glm(y ~ x + I(x^2) , data=df)
summary(quad.reg)$coefficients

y.quad.pred = predict(quad.reg , df.test)
lines(x.test , y.quad.pred , col="blue",lwd=2)
quad.MSE = mean((y.true - y.quad.pred)^2)
quad.MSE

# Consider a neural network
# What is the shape of this network?
nn.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
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

y.nn.pred = predict(nn.reg, x.test) # Make predictions on the test data
lines(x.test,y.nn.pred,col="purple",lwd=2)
nn.MSE = mean((y.true - y.nn.pred)^2) #Using our last neural network
nn.MSE

# How about a *deep* neural network
# What is the structure of this neural network?
nn.deep.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(1 , activation = "linear")

summary(nn.deep.reg)

nn.deep.reg %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

nn.deep.reg %>% # Fit the model to training data
  fit(
    x = df$x, y = df$y,
    epochs = 1000, # how long to train for
    verbose = 0
  )

y.nn.deep.pred = predict(nn.deep.reg, x.test) # Make predictions on the test data
lines(x.test,y.nn.deep.pred,col="orange",lwd=2)
nn.deep.MSE = mean((y.true - y.nn.deep.pred)^2)
nn.deep.MSE

# Let's go back to line 122 and consider other network structures
# What are the mathematical formulations for these structures?







## But be wary of overfitting
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


nn.reg = keras_model_sequential() %>% # Creating a model can sometimes take a bit of time
  layer_flatten(input_shape = c(M)) %>%
  layer_dense(units = 16, activation = "tanh") %>%
  layer_dense(units = 16, activation = "tanh") %>%
  layer_dense(1 , activation = "linear")

summary(nn.reg)

nn.reg %>% # State the loss function and optimizer (adam is a good choice usually)
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

losses = nn.reg %>% # Fit the model to training data
  fit(
    x = as.matrix(df[train,-1]), y = df$y[train], # remove y from the input data
    epochs = 1000, # how long to train for
    verbose = 0
  )

plot(losses) # Allows us to plot the training losses
tail(losses$metrics$loss) # Training errors in final fits

y.nn.pred = predict(nn.reg, as.matrix(df[-train,-1])) # Make predictions on the test data
nn.MSE = mean((y[-train] - y.nn.pred)^2) 
nn.MSE # If overfit, the test error is much larger than the training error


# Evaluate fit earlier than test data:
# Validation!
losses = nn.reg %>% # Fit the model to training data
  fit(
    x = as.matrix(df[train,-1]), y = df$y[train], # remove y from the input data
    epochs = 1000, # how long to train for
    validation_split = 0.2, # split training data to do an early "test"
    verbose = 0
  )

plot(losses) # Allows us to plot the training losses
tail(losses$metrics$loss) # Training errors in final fits
tail(losses$metrics$val_loss) # Can output the validation losses as well

y.nn.pred = predict(nn.reg, as.matrix(df[-train,-1])) # Make predictions on the test data
nn.MSE = mean((y[-train] - y.nn.pred)^2) 
nn.MSE # If overfit, the test error is much larger than the training error

# Do we still get overfitting if we try different networks?
# Go back to line 198 and try


########################################



## Feedforward NN for financial data
library("fBasics")
library("quantmod")

getSymbols('IBM',src='yahoo',from='2010-01-01',to='2020-01-01')
r = dailyReturn(IBM,type='log')

train_X = r[1:2000] #Train/test split based on time instead of random
test_X = r[2001:2515]
train_y = r[2:2001]
test_y = r[2002:2516]

nn.reg = keras_model_sequential() %>%
  layer_flatten(input_shape = c(1)) %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(units = 1, activation = "linear")

summary(nn.reg)

nn.reg %>%
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

losses = nn.reg %>%
  fit(
    x = train_X, y = train_y,
    epochs = 100,
    validation_split = 0.1,
    verbose = 0
  )

plot(losses)
tail(losses$metrics$loss)
tail(losses$metrics$val_loss)

nn.reg %>% 
  evaluate(test_X, test_y, verbose = 0) 

# How does this compare with an AR(1) model
df.train = data.frame(x=as.numeric(train_X),y=as.numeric(train_y))
df.test = data.frame(x=as.numeric(test_X),y=as.numeric(test_y))

ar1 = glm(y~x , data = df.train)

y.pred = predict(ar1 , df.test)
mean((test_y - y.pred)^2)


# How should we modify this NN to consider 2+ lags?

# What other network structures should we try?






#############################################

## Advanced topics:
## Recurrent NN and LSTM NN

# nn.reg = keras_model_sequential() %>%
#   layer_embedding(input_dim = 1, output_dim = 2) %>%
#   layer_simple_rnn(units = 16, activation = "relu") %>%
#   layer_dense(units = 1, activation = "linear")

nn.reg = keras_model_sequential() %>%
  layer_embedding(input_dim = 1, output_dim = 2) %>% 
  layer_lstm(units = 16) %>%
  layer_dense(units = 1, activation = "linear")

summary(nn.reg)

nn.reg %>%
  compile(
    loss = "mean_squared_error",
    optimizer = "adam"
  )

losses = nn.reg %>%
  fit(
    x = train_X, y = train_y,
    epochs = 100,
    batch_size = 32,
    verbose = 0
  )

plot(losses)

nn.reg %>% 
  evaluate(test_X, test_y, verbose = 0)
