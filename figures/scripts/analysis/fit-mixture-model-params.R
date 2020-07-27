library( celltrackR )
suppressMessages( library( mclust, quietly = TRUE ) )
library( dplyr, warn.conflicts = FALSE )
library( ggplot2, quietly = TRUE )

argv <- commandArgs( trailingOnly = TRUE )


dxfile <- argv[1]
brokenfile <- argv[2]
outfile <- argv[3]


dxData <- readRDS( dxfile )
broken <- readRDS( brokenfile )

parmID <- names( dxData )[1]

parms <-  unlist( strsplit( parmID, "-" ) )
mact <- parms[1]
lact <- parms[2]


estimateComponents <- function( datalist ){
  
  broken2 <- broken[[1]]
  broken2 <- sum(broken2)/length(broken2)
  
  if( !is.null( datalist ) ){
  
	  fitsi <- lapply(datalist, function(x) Mclust( x, G=1:3,modelNames = "V" ))
	  names(fitsi) <- seq(1,length(fitsi))
  
	  n <- sapply( fitsi, function(x) x$G )
	  dmuRel <- sapply( fitsi, function(x) {
	  	n <- x$G
	  	if( n == 2){
	  		dmu <- diff( x$parameters$mean )
	  		sdmax <- sqrt( max( x$parameters$variance$sigmasq ) )
	  		return( dmu/sdmax )
	  	} else {
	  		return( NA )
	  	}
	  })
	  
	  
	  BIC13 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[3,1]) - as.numeric(fitsi[[x]]$BIC[1,1] ))
	  BIC12 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[2,1]) - as.numeric(fitsi[[x]]$BIC[1,1] ))
	  BIC23 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[3,1]) - as.numeric(fitsi[[x]]$BIC[2,1] ))
  
	  df <- data.frame( n = n, dBIC13 = BIC13, dBIC12 = BIC12, dBIC23 = BIC23, broken = broken2, dmuRel = dmuRel, mact = mact, lact = lact )
  } else {
  	  df <- data.frame( n = NA, dBIC13 = NA, dBIC12 = NA, dBIC23 = NA, broken = broken2, dmuRel = dmuRel, mact = mact, lact = lact )
  }
  return(df)
  
}

# fit mixture models to get num components and BICs
fits <- lapply( dxData, estimateComponents )
outdata <- bind_rows(fits)

write.table( outdata, file = outfile, col.names=FALSE, row.names=FALSE, quote=FALSE)


