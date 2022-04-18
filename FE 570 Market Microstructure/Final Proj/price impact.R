library(highfrequency)
library(readxl)

trade_dir = getTradeDirection(tqdata)
#tqdata_df = na.omit(tqdata_df)
#trade_dir = na.omit(trade_dir)

trade_dir_df = data.frame(trade_dir)

write.csv(trade_dir_df, "trade_dir.csv")
