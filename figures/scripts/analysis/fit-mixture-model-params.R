library( celltrackR )
library( mclust )
library( dplyr, warn.conflicts = FALSE )
library( ggplot2 )

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
  
  datalist <- dxData[[dataname]]
  broken <- broken[[dataname]]
  
  fitsi <- lapply(datalist, function(x) Mclust( x, G=1:3,modelNames = "V" ))
  names(fitsi) <- seq(1,length(fitsi))
  
  n <- sapply( fitsi, function(x) x$G )
  BIC13 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[3,1]) - as.numeric(fitsi[[x]]$BIC[1,1] ))
  BIC12 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[2,1]) - as.numeric(fitsi[[x]]$BIC[1,1] ))
  BIC23 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[3,1]) - as.numeric(fitsi[[x]]$BIC[2,1] ))
  
  df <- data.frame( n = n, dBIC13 = BIC13, dBIC12 = BIC12, dBIC23 = BIC23, broken = broken, mact = mact, lact = lact )
  return(df)
  
}

# fit mixture models to get num components and BICs
fits <- lapply( names(dxData), function(x) estimateComponents[[x]] )
outdata <- bind_rows(fits)

write.table( outdata, file = outfile, col.names=FALSE, row.names=FALSE, quote=FALSE)


