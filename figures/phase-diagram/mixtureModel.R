library( mclust )
library( ggplot2 )
library( celltrackR )


# functions using mclust to estimate number of gaussians and dAIC
estimateComponents <- function( data ){
  
  fit <- Mclust( data )
  parms <- fit$parameters
  
  out <- data.frame( 
    prop = parms$pro,
    mu = parms$mean,
    sd = sqrt( parms$variance$sigmasq)
  )
  
  out
  
}

deltaAIC <- function( data, kref, k ){
  
  fit1 <- Mclust( data, G = kref )
  fit2 <- Mclust( data, G = k )
  
  AIC1 <- AIC( fit1 )
  AIC2 <- AIC( fit2 )
  
  dAIC <- AIC2 - AIC1
  dAIC
  
}

# First test that the package works
# make data from 2 norm distr
data1 <- rnorm( 1000 )
data2 <- rnorm( 1000, 3 )
data <- c( data1, data2 )

# this should give 2 comps
estimateComponents( data )

# this should be negative
deltaAIC( data, 1, 2 )




# Now use the track data.
# Load first:
load( "tracks1D.Rdata" )

# get param combo's from names
parms <- names( all.tracks )

# uncomment this to subsample tracks (a lot faster)
# all.tracks <- lapply( all.tracks, subsample, k = 5 )

# get dx displacement
dxData <- lapply( all.tracks, function(x) {
  t( sapply( subtracks( x, 1 ), displacementVector ) )[,1] 
})

# get parm combo's in dataframe
parms <- as.data.frame( t( sapply( names(dxData), function(x) unlist( strsplit( x, "-"))) ) )
colnames(parms) <- c("mact","lact")

# compute number of components estimated by fitting algorithm:
nComp <- sapply( seq(1,length(dxData)), function(x){
  estimateComponents( dxData[[x]] )
} )
nComp2 <- sapply( nComp, length )
# take every third value (length for prop, mu, sd all represent one fit)
nComp3 <- nComp2[ seq(1,length(nComp2))%%3 == 0]

# compute deltaAIC for 3 versus 1 component:
dAIC <- sapply( seq(1,length(dxData)), function(x){
  deltaAIC( dxData[[x]], 1, 3 )
} )

# combine data
output <- parms
output$nC <- nComp3
output$dAIC <- dAIC


ggplot( output, aes( x = mact, y = lact, color = nC ) ) +
  geom_point()+
  scale_x_log10()+
  scale_y_log10()


ggplot( output, aes( x = mact, y = lact, color = dAIC ) ) +
  geom_point()+
  scale_x_log10()+
  scale_y_log10()