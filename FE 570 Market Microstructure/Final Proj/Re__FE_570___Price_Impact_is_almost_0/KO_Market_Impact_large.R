# Libraries
library(xts)
library(highfrequency)
library(quantmod)
library(stats)

Sys.setenv(TZ = "EST")  # dataset is timestamped in GMT
options(digits.secs=3)

# Load Data
load("taqdata_KO_20220301EX.RData")
head(tqdata)

# Filter trades only in Exchange: ADF
tqdata_adf = tqdata[tqdata$EX == "ADF"]




