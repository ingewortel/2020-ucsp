library( celltrackR )
library( mclust )
library( dplyr )
library( ggplot2 )

argv <- commandArgs( trailingOnly = TRUE )


trackfile <- argv[1]
parmfile <- argv[2]
outfile <- argv[3]



all.tracks <- readRDS( trackfile )
parms <- read.table( parmfile )
colnames(parms) <- c( "mact", "lact" )

estimateComponents <- function( datalist ){
  
  fitsi <- lapply(datalist, function(x) Mclust( x, G=1:3,modelNames = "V" ))
  names(fitsi) <- seq(1,length(fitsi))
  
  n <- sapply( fitsi, function(x) x$G )
  BIC13 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[3,1]) - as.numeric(fitsi[[x]]$BIC[1,1] ))
  BIC12 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[2,1]) - as.numeric(fitsi[[x]]$BIC[1,1] ))
  BIC23 <- sapply(1:length(fitsi), function(x) as.numeric(fitsi[[x]]$BIC[3,1]) - as.numeric(fitsi[[x]]$BIC[2,1] ))
  
  df <- data.frame( n = n, dBIC13 = BIC13, dBIC12 = BIC12, dBIC23 = BIC23 )
  return(df)
  
}

getDx <- function(tracks ){
  
  nsim <- length(tracks)
  
  # steps from tracks, then shuffle them (wo regard for simulation they come from)
  steps <- subtracks(tracks,1)
  steps <- sample( steps, length( steps ) )
  #steps <- steps[1:5000]
  
  # compute displacement and divide in nsim groups of displacements
  disp <- t( sapply( steps, displacementVector) )[,1]
  ind <- split(seq_along(disp), cut_number(seq_along(disp), nsim))
  disp <- lapply( ind, function(x) disp[x] )
  
  return( disp )
}


# get the displacements
dxData <- lapply( all.tracks, getDx )

# fit mixture models to get num components and BICs
fits <- lapply( dxData, estimateComponents )

broken <- readRDS( "data/broken.rds" )

outdata <- lapply( 1:nrow(parms), function(x){
	
	df <- fits[[x]]
	df$broken <- broken[[x]]
	df$mact <- parms$mact[x]
	df$lact <- parms$lact[x]
	return(df)

})

outdata2 <- bind_rows(outdata)


write.table( outdata2, file = outfile, col.names=TRUE, row.names=FALSE, quote=FALSE)


