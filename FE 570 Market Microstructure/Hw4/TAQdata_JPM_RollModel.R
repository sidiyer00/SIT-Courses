library(xts)
library(highfrequency)


#   analysis on real data
Sys.setenv(TZ = "EST")  # work in East Coast Time Zone
options(digits.secs=3)

load("taqdata_JPM_20210113_ESTMktHrs.RData")



# loads a xts file called tqdataMktHrs
tqdata <- tqdataMktHrs
tqdata <- tqdata[4281:24400]

head(tqdata)
tail(tqdata)

length(tqdata$SIZE) #129,391 trades on all exchanges

tqdata <- tqdata[tqdata$EX=='ADF']
length(tqdata$SIZE) #34,844 trades on ADF exchange
#####################################################
# Plot prices 

asks <- as.numeric(tqdata$OFR)
bids <- as.numeric(tqdata$BID)
mids <- 0.5*bids + 0.5*asks

pmin = min(as.numeric(tqdata$PRICE))
pmax = max(as.numeric(tqdata$PRICE))
plot(as.numeric(tqdata$PRICE),col="red", type="l", ylab="Trade price", 
     xlab="Trade #", main="Trade price (9:30-16:00)", ylim=c(pmin-0.1,pmax+0.1))
lines(mids, type="l", col="blue")

plot(as.numeric(tqdata$SIZE),col="red", type="l", 
     ylab="Trade size", 
     xlab="Trade #", main="Trade volume", ylim=c(0,100000))

###########################################
# calibrate the Roll model on the real data
###########################################


pr <- as.numeric(tqdata$PRICE)
dpr <- diff(pr)  # Delta price
acpr <- acf(dpr, lag.max=20, type="correlation", 
            plot=TRUE, main="Autocorrelation")

# acf: both autocorrelation and autocovariance

plot(acpr, col="red", lag.max=20, 
     main="Autocorrelation of price changes")

# Roll estimate of bid-ask spread

covpr <- acf(dpr, lag.max=20, type="covariance", 
             main="covariance of price changes")

gamma0 <- sd(dpr)^2
print(gamma0)

gamma0alt <- covpr$acf[1]
print(gamma0alt)

gamma1 <- covpr$acf[2]
print(gamma1)

cparam <- sqrt(-covpr$acf[2])
print(cparam)

sig2u <- gamma0 + 2* gamma1
sigu <- sqrt(sig2u)
print(sigu)


##############################################################
# get Trade direction using Lee, Ready

td <- getTradeDirection(tqdata)

plot(td[1:50],main="trade signs (XXX)",type="b",col="blue")

td_ac <- acf(td, main="NA", lag.max=20,plot=FALSE)
plot(td_ac,main="trade signs autocorrelation (JPM)", col="red")

# improved Roll model estimation, relaxing the assumption of independence of trades

#deps <- diff(td)


mids <- (as.numeric(tqdata$OFR) + as.numeric(tqdata$BID))/2
dm <- diff(mids)
xt = as.numeric(tqdata$SIZE) * td
xt = xt[-length(xt)]
fit.lm = lm(dm ~ xt)

#(fit.lm <- lm(dpr ~ dm + deps))
summary(fit.lm)
lambda = fit.lm$coefficients[2]
xt = as.numeric(tqdata$SIZE) * td

###########################################
# plot the trades in 1 min (118 trades)
min1 <- '2021-01-13 15:00:00::2021-01-13 15:01:00'
summary(as.data.frame(tqdata$EX[min1]))
length(tqdata$EX[min1])

pmin <- min(as.numeric(tqdata$BID[min1]))
pmax <- max(as.numeric(tqdata$OFR[min1]))
prange <- c(pmin- 0.01, pmax+0.02)


plot(as.numeric(tqdata$BID[min1]), type="n", 
     ylim = prange, main = "10:07-08 (ADF)", 
     ylab="price",xlab="Trade index")
lines(as.numeric(tqdata$BID[min1]), type="l", col="blue")
lines(as.numeric(tqdata$OFR[min1]), type="l", col="red")
points(as.numeric(tqdata$PRICE[min1]), col="black", pch=20)

############################################
# determine c 

rhs = pr - mids - lambda*xt # right hands side
fit.lm2 = lm(rhs ~ td)
summary(fit.lm2)
c = fit.lm2$coefficients[2]


############################################
# charts n stuff
plot(xt[-length(xt)], dm)






