library(highfrequency)
library(xts)

Sys.setenv(TZ = "GMT")  
options(digits.secs=3)

coke_raw <- read.csv("C:/Users/sidiy/Documents/GitHub/SIT-Courses/FE 570 Market Microstructure/Final Proj/FE570KO03012022.csv", header=T)

class(coke_raw)
names(coke_raw)
summary(coke_raw)
length(coke_raw$Price) #864,733 entries (trades+quotes)
head(coke_raw)

tdata <- subset(coke_raw, Type=="Trade") #15,245 observations
qdata <- subset(coke_raw, Type=="Quote") #849,488 observations

length(tdata$Price) #15,245 trades
length(qdata$Price) #849,488 quotes


tdata.small <- data.frame(TIME = gsub("T", " ", tdata$Date.Time, perl=TRUE),
                          SYMBOL = "KO",
                          PRICE = tdata$Price,
                          SIZE = tdata$Volume,
                          EX = tdata$Ex.Cntrb.ID)


length(tdata.small$PRICE)
head(tdata.small,10)



# filter the quotes for each product 

qdata.small <- data.frame(TIME = gsub("T", " ", qdata$Date.Time, perl=TRUE),
                          SYMBOL = "KO",
                          BID = qdata$Bid.Price,
                          BIDSIZ = qdata$Bid.Size,
                          OFR = qdata$Ask.Price,
                          OFRSIZ = qdata$Ask.Size)

head(qdata.small)

options(digits.secs = 12)

# remove the "T" from the Date.Time
longdate <- c('20222-03-01T00:00:00.018791658Z')

shortdate <- gsub("T", " ", longdate, perl=TRUE)

class(tdata.small) # is data.frame. 
# must put it in xts format, to act on it with aggregateTrades



tdata.xts <- xts(tdata.small[,-1], 
                 order.by=as.POSIXct(tdata.small[,1], format = "%Y-%m-%d %H:%M:%OS"))
qdata.xts <- xts(qdata.small[,-1], 
                 order.by=as.POSIXct(qdata.small[,1], format = "%Y-%m-%d %H:%M:%OS"))


class(tdata.xts) # ok this is in xts format
head(tdata.xts) # usual TAQ format
head(qdata.xts)

mergeTradesSameTimestamp(tdata.xts)

length(tdata.xts$PRICE)

#matching trade and quote data
tqdata = matchTradesQuotes(tdata.xts, qdata.xts)
tqdata = tqdata[,-8]

tqdata_df = fortify.zoo(tqdata) 

write.table(tqdata_df, "tqdata_txt.txt", append = FALSE, sep = " ", dec = ".", row.names = TRUE, col.names = TRUE)
