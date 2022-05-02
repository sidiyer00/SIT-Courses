# Market impact modeling - Glosten-Harris model 
library(xts)
library(highfrequency)
library(quantmod)
library(stats)

Sys.setenv(TZ = "EST")  # dataset is timestamped in GMT
options(digits.secs=3)

load("taqdata_KO_20220301.RData")

# loads a xts file called tqdata
head(tqdata)

#delete 1st row
tqdata <- tqdata[-1]


# keep only a subset of trading hours 9:30 - 16:00 
sampledata <- '2022-03-01 10:00:00::2022-03-01 15:00:00'
tqdata1hr <- tqdata[sampledata]

head(tqdata1hr)

length(tqdata$PRICE) #10,185 trades 



# use signed trade size to estimate lambda

tradeSigns <- getTradeDirection(tqdata1hr)
signed.x <- as.numeric(tqdata1hr$SIZE)*tradeSigns

prices <- as.numeric(tqdata1hr$PRICE)
asks <- as.numeric(tqdata1hr$OFR)
bids <- as.numeric(tqdata1hr$BID)
mids <- 0.5*bids + 0.5*asks
dm <- diff(mids)
dp <- diff(prices)

plot(prices, type="l", col="blue")
lines(mids, type="l", col="red")

acf(dp)

acf(tradeSigns)


class(dm)
signed.x <- signed.x[1:(length(signed.x)-1)] # trim to same size as dm
# equivalently use signedx[-n] with n = length(signedx)
length(dm)
length(signed.x)

plot(signed.x, dm, pch=20,col="blue",
     main="mid-price change vs trade size", 
     xlab="Signed size", ylab="d(mid)", xlim=c(-200,200), ylim=c(-0.1,0.1))



# determine optimal lag from ccf analysis
library(stats)

dm.ts <- ts(dm)
signed.x.ts <- ts(signed.x)

cov(dm,signed.x)
cor(dm,signed.x)

# we expect that dm lags signed_x
dm.x.ccf <- ccf(signed.x.ts, dm.ts)



plot(signed.x[1:length(dm)], dm, pch=20,col="blue",
     main="mid-price change vs trade size", 
     xlab="Signed size", ylab="d(mid)", xlim=c(-200,200), ylim=c(-0.1,0.1))

#x.lag <- Lag(signed.x, 20)

#plot(x.lag, dm, pch=20,col="blue",
#     main="mid-price change vs trade size (ADF 10am-2pm)", 
#     xlab="Signed size", ylab="d(mid)", xlim=c(-200,200), ylim=c(-0.1,0.1))


# plot mid-price change vs LOB imbalance

head(tqdataADF)

bidSize <- as.numeric(tqdataADF$BIDSIZ)
askSize <- as.numeric(tqdataADF$OFRSIZ)

bookImbalance <- (bidSize - askSize)/(askSize + bidSize)

plot(bookImbalance[1:1000], type="l")

dm100 <- diff(mids,lag=100)
plot(bookImbalance[1000:2000], dm100[1000:2000], pch=20,col="blue",
     main="mid-price change vs book imbalance (ADF 10am-2pm)", 
     xlab="Book Imbalance", ylab="d(mid)", xlim=c(-1,1), ylim=c(-0.5,0.5))

?diff
######################################################
# calibrate the Glosten-Harris model (Roll + price impact)
# p(t) = m(t) + c*d(t) + lambda*x(t)
# m(t) = m(t-1) + lambda*x(t-1) + u(t)
####################################################


n <- length(signed.x)
dm.lag <- dm

#(fitGlHarris <- lm(dm ~ signedx[-n]))
(fitGlHarris <- lm(dm.lag ~ signed.x, subset=(abs(signed.x)>10)&abs(signed.x)<30))
#(fitGlHarris <- lm(dm ~ signedx2))
lambda <- fitGlHarris$coeff[2]
# 2.43e-05=  0.243c per 10k shares
# lambda = 1.68e-05 = 0.17c per 10k shares
# lambda = 7.01e-05

plot(signed.x, dm, pch=20,col="blue",
     main="mid-price change vs trade size (ADF 10am-2pm)", 
     xlab="Signed size", ylab="d(mid)", xlim=c(-100,100), ylim=c(-0.05,0.05))

abline(fitGlHarris, col="red")

ns <- length(signed.x)
length(prices)
# Use now also the trade price to estimate c
priceDiff <- prices[1:ns] - mids[1:ns] - lambda*signed.x

(fitGlHarris2 <- lm(priceDiff ~ tradeSigns[1:ns]))

summary(fitGlHarris2) # c(NYSE) = 0.0112

# what is c? This determines the bid-ask spread s = 2*(c + lambda*|x|)
# how does it compare with the Roll model estimate?
#c = -9.031e-04 

################################################
# Price-impact regression using Eq.(5.4) in Foucault, Pagano, Roell
# dp(t) = lambda*d(t) + gamma*d(d(t)) + eps(t)
# regress dp ~ d, dd
# bid-ask spread = 2*(lambda + gamma)

dp <- diff(prices)

dt <- diff(tradeSigns)
tradeSigns <- tradeSigns[1:(length(tradeSigns)-1)] # trim to same size as dt

length(dp)
length(dt)

(fitPriceImpact <- lm(dp ~ tradeSigns + dt))

#Coefficients:
#  (Intercept)   tradeSigns           dt  
#-0.0001182    0.0029871    0.0077869  

residDp <- dp + 0.0001 - 0.00298*tradeSigns - 0.0077869*dt

plot(residDp, type="p", col="black", ylim=c(-0.1,0.1))
plot(dp, type="p", col="black", ylim=c(-0.1,0.1))

plot(dt, dp, pch=20,col="blue",
     main="price change vs price reversal", 
     xlab="Signed size", ylab="d(mid)", xlim=c(-2,2), ylim=c(-0.5,0.5))

abline(fitPriceImpact, col="red")
#################################################

#summarize the trades by exchange
summary(as.data.frame(tqdata$EX))

#ADF    :35322  NASD Alternative Display Facility for Nasdaq Large Cap
#THM    :25973  Third Market Stock
#NYS    :19030  New York Stock Exchange
#BAT    :13789  BATS ECN - RDFD
#PSE    :10959  NYSE Arca
#DEX    : 8349  
#(Other):15969  

#full listing of trade count per exchange
count(tqdataEX.xts, vars="EX")

tradesEX <- as.data.frame(table(tqdataEX.xts$EX))

tradesEX
# 16 exchanges: BAT 13.7k, IEX 3.7k

####################################################
# Bid-ask bounce study 
####################################################
prices <- as.numeric(tqdataTHM$PRICE)
tradeSigns <- getTradeDirection(tqdataTHM)
signedx <- as.numeric(tqdataTHM$SIZE)*tradeSigns

dp <- diff(prices)
acf(dp, main="ACF dp (BAT)")

acf(tradeSigns, lag.max=100, main="ACF(trade signs) - BAT")

summary(signedx)
hist(signed.x,breaks=400, xlim=c(-500,500),main="Trade size (THM)")
?hist

acf(tradeSigns)
