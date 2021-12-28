##Cluster Explanation
##K-means clustering
set.seed(2)
x=matrix(rnorm(50*2),ncol=2) #Randomly generated data
x[1:25,1]=x[1:25,1]+3
x[1:25,2]=x[1:25,2]-4

km.out=kmeans(x,2,nstart=20) #2 clusters; nstart is how many times to do the assignment
km.out$cluster #the best cluster; in this case this is the true clusters from how we constructed data

plot(x,col=(km.out$cluster+1),main="K-Means Clustering K=2",xlab="",ylab="",pch=20,cex=2)

set.seed(4)
km.out=kmeans(x,3,nstart=20) #What if we consider 3 clusters instead
km.out #Mostly divides the first cluster into 2 classes
plot(x,col=(km.out$cluster+1),main="K-Means Clustering K=3",xlab="",ylab="",pch=20,cex=2)

#Compare different choices of nstart
set.seed(314)
km.out=kmeans(x,3,nstart=1)
km.out$tot.withins
plot(x,col=(km.out$cluster+1),main="K-Means Clustering K=3",xlab="",ylab="",pch=20,cex=2)
km.out=kmeans(x,3,nstart=20)
km.out$tot.withins
plot(x,col=(km.out$cluster+1),main="K-Means Clustering K=3",xlab="",ylab="",pch=20,cex=2)


##Hierarchical clustering
#Cluster by different inter-cluster dissimilarity methods
hc.complete=hclust(dist(x),method="complete")
hc.average=hclust(dist(x),method="average")
hc.single=hclust(dist(x),method="single")

par(mfrow=c(1,3))
plot(hc.complete,main="Complete Linkage",cex=.9)
plot(hc.average,main="Average Linkage",cex=.9)
plot(hc.single,main="Single Linkage",cex=.9)
#Notice the heights are different for these different methods
#Also, though similar in appearance they do give different clusters

#Even differ when cut at 2 clusters
cutree(hc.complete,2)
cutree(hc.average,2)
cutree(hc.single,2) #Tendency to put a single point by itself

cutree(hc.single,4) #2 large clusters + 2 single points
#Try different numbers of classes on your own



##Let's now consider clustering financial data
library(quantmod)
set.seed(0)
#Use 21 stocks from the S&P500 from 2011 onward
getSymbols(c("MMM","AMZN","AAL","AAPL","BA","CAT","CSCO","CME","DLTR","EBAY","EFX","XOM","F","GM","IBM","GS","NFLX","T","MS","UAL","V"),from="2011-01-01")

## K-means clustering
AdjCl = data.frame(MMM$MMM.Adjusted,AMZN$AMZN.Adjusted,
                   AAL$AAL.Adjusted,AAPL$AAPL.Adjusted,
                   BA$BA.Adjusted,CAT$CAT.Adjusted,
                   CSCO$CSCO.Adjusted,CME$CME.Adjusted,
                   DLTR$DLTR.Adjusted,EBAY$EBAY.Adjusted,
                   EFX$EFX.Adjusted,XOM$XOM.Adjusted,
                   F$F.Adjusted,GM$GM.Adjusted,IBM$IBM.Adjusted,
                   GS$GS.Adjusted,NFLX$NFLX.Adjusted,
                   T$T.Adjusted,MS$MS.Adjusted,UAL$UAL.Adjusted,
                   V$V.Adjusted)
colnames(AdjCl) <- c("MMM","AMZN","AAL","AAPL","BA","CAT","CSCO","CME","DLTR","EBAY","EFX","XOM","F","GM","IBM","GS","NFLX","T","MS","UAL","V")

#Initial exploration of data
pairs(AdjCl[,1:5],lower.panel=NULL) #Only on first 5 stocks because of size

#Cluster based on the adjusted close
km.equity = kmeans(t(AdjCl),5,nstart=20) 
#Transpose so that we find clusters between assets rather than dates
km.equity$cluster
sort(km.equity$cluster) #Notice this is not scaled but still gives clusters 

#Try other cluster sizes

#What if we forgot to transpose (check your clusters as a quick check)
km.dates = kmeans(AdjCl,5,nstart=20)
head(km.dates$cluster)


#However prices are skewed by magnitudes. Normalize for potentially better results
#Returns naturally normalize the values
LogRet = data.frame(diff(log(MMM$MMM.Adjusted))[-1],diff(log(AMZN$AMZN.Adjusted))[-1],
                    diff(log(AAL$AAL.Adjusted))[-1],diff(log(AAPL$AAPL.Adjusted))[-1],
                    diff(log(BA$BA.Adjusted))[-1],diff(log(CAT$CAT.Adjusted))[-1],
                    diff(log(CSCO$CSCO.Adjusted))[-1],diff(log(CME$CME.Adjusted))[-1],
                    diff(log(DLTR$DLTR.Adjusted))[-1],diff(log(EBAY$EBAY.Adjusted))[-1],
                    diff(log(EFX$EFX.Adjusted))[-1],diff(log(XOM$XOM.Adjusted))[-1],
                    diff(log(F$F.Adjusted))[-1],diff(log(GM$GM.Adjusted))[-1],
                    diff(log(IBM$IBM.Adjusted))[-1],diff(log(GS$GS.Adjusted))[-1],
                    diff(log(NFLX$NFLX.Adjusted))[-1],diff(log(MS$MS.Adjusted))[-1],
                    diff(log(T$T.Adjusted))[-1],diff(log(UAL$UAL.Adjusted))[-1],
                    diff(log(V$V.Adjusted))[-1])
colnames(LogRet) <- c("MMM","AMZN","AAL","AAPL","BA","CAT","CSCO","CME","DLTR","EBAY","EFX","XOM","F","GM","IBM","GS","NFLX","T","MS","UAL","V")

km.returns = kmeans(t(LogRet),5,nstart=20) 
#Transpose so that we find clusters between assets rather than dates
km.returns$cluster
sort(km.returns$cluster) #Notice this is not scaled but still gives clusters 

#Try other cluster sizes





## Hierarchical clustering

#Cluster the adjusted close by different inter-cluster dissimilarity methods
hc.complete=hclust(dist(t(AdjCl)),method="complete") 
hc.average=hclust(dist(t(AdjCl)),method="average")
hc.single=hclust(dist(t(AdjCl)),method="single")

par(mfrow=c(1,3))
plot(hc.complete,main="Complete Linkage",cex=.9)
plot(hc.average,main="Average Linkage",cex=.9)
plot(hc.single,main="Single Linkage",cex=.9)
#Notice the heights are different for these different methods
#Also, though similar in appearance they do give different clusters

#All give the same clusters when cut at 2 (Amazon vs all the rest)
cutree(hc.complete,2)
cutree(hc.average,2)
cutree(hc.single,2)

cutree(hc.single,4) #Amazon, Boeing, and Netflix all remain their own classes
#Try different numbers of classes on your own

xsc=scale(t(AdjCl)) #What if we scale the data first?
par(mfrow=c(1,1))
plot(hclust(dist(xsc),method="complete"),main="Hierarchical Clustering with Scaled")
cutree(hclust(dist(xsc),method="complete"),3) #Notice how much closer Amazon is to the rest



#Cluster on log returns instead
hc.complete=hclust(dist(t(LogRet)),method="complete")
hc.average=hclust(dist(t(LogRet)),method="average")
hc.single=hclust(dist(t(LogRet)),method="single")

#Notice that the clusters are now completely different
par(mfrow=c(1,3))
plot(hc.complete,main="Complete Linkage",cex=.9)
plot(hc.average,main="Average Linkage",cex=.9)
plot(hc.single,main="Single Linkage",cex=.9)

cutree(hc.complete,2) #Now Netflix is "alone" in the final clustering
cutree(hc.average,2)
cutree(hc.single,2)

cutree(hc.single,4) #American Airlines, Netflix, and United Airlines all remain their own classes

xsc=scale(t(LogRet)) #Can scale the log returns too; Netflix is still an outlier but not as drastic
par(mfrow=c(1,1))
plot(hclust(dist(xsc),method="complete"),main="Hierarchical Clustering with Scaled")
plot(hclust(dist(xsc),method="single"),main="Hierarchical Clustering with Scaled")
plot(hclust(dist(xsc),method="average"),main="Hierarchical Clustering with Scaled")


