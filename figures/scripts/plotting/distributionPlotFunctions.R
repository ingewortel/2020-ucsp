source("../scripts/analysis/trackAnalysisFunctions.R")

readAllTracks <- function( lact, mact, nsim, ndim=3, torus.fieldsize=NULL ){
  
  tname <- paste0("data/tracks/CPM",ndim,"D-lact",lact,"-mact",mact,"-sim")
  tlist <- lapply( seq(1,nsim), function(x) readTracks( paste0(tname,x,".txt"), ndim, torus.fieldsize ) )
  tlist <- as.tracks( tlist )
  
  # If any of the simulations contain multiple tracks, merge them all together into
  # a single list.
  if( is.list( tlist[[1]]) ){
    tlist <- as.tracks( unlist( tlist, recursive = FALSE ) )
  }
  
  # normalize the startpoint of all tracks to 0
  tlist <- lapply( tlist, function(x) apply( x, 2, function(y) y - y[1] ) ) 
  if( !is.tracks(tlist)){
    tlist <- as.tracks( tlist )
  }
  
  return( tlist )
  
}

#t <- readAllTracks( 40, 30, 20 )
#plot( t[1:20], cex = 0.1, lwd = 0.1 )


displacementPlot <- function( listoflists, names = NULL ){
  require( celltrackR )
  require( ggplot2 )
  
  d <- data.frame()
  for( i in 1:length(listoflists ) ){
    
    tlist <- listoflists[[i]]
    n <- round( mean( sapply( tlist, nrow ) ) )
    dt <- diff( tlist[[1]][1:2,"t"])
    
    data <- aggregate( tlist, displacement, subtrack.length = seq(1, round(n/5) ) )
    data$t <- data$i*dt
    if( is.null( names ) ){
      data$p <- i
    } else {
      data$p <- names[i]
    }
    
    d <- rbind( d, data)
  } 

  p <- ggplot( d, aes( x = sqrt( t ), y = value, color = p, group = p ) ) +
    geom_line() + 
    labs( x = expression( sqrt(time) ~ (MCS) ),
          y = "Displacement (pixels)") +
    theme_classic()
  
  return(p)
  
}

speedDistr <- function( tlist ){
  
  speeds <- lapply( tlist, function(x) 
    sapply( 1:(nrow(x)-2), function(y) speed( x[y:(y+2),] ) ))
  
  speeds <- unlist(speeds)
  return(speeds)
  
}

angleDistr <- function( tlist ){
  
  angles <- lapply( tlist, function(x) 
    sapply( 1:(nrow(x)-2), function(y) overallAngle( x[y:(y+2),] ) ))
  
  angles <- unlist(angles)
  angles <- 360*(angles/(2*pi))
  return(angles)
  
}

lactList <- function( lactvec, mact, nsim ){
  l <- lapply( lactvec, function(x) readAllTracks( x, mact, nsim ) )
  return(l)
}

speedHists <- function( lactvec, mact, nsim ){
  
  require( ggplot2 )
  l1 <- lactList( lactvec, mact, nsim )
  l <- lapply( l1, function(x) speedDistr( x ) ) 
  dlist <- lapply( 1:length(lactvec), function(x) data.frame( v = l[[x]], p = lactvec[x] ) )
  
  #plist <- lapply( dlist, function(d) ggplot( d, aes( x = v, color = p ) ) + geom_freqpoly(bins=100) + theme_classic() )
  #return(plist) 
  d <- data.frame()
  for( i in 1:length(dlist) ){
    d <- rbind( d, dlist[[i]] )
  }
  
  p <- ggplot( d, aes( x = v, color = p, group = p) ) + geom_freqpoly( bins = 100 ) + theme_classic()
  return(p)
}

angleHists <- function( lactvec, mact, nsim ){
  
  require( ggplot2 )
  l1 <- lactList( lactvec, mact, nsim )
  l <- lapply( l1, function(x) angleDistr( x ) ) 
  dlist <- lapply( 1:length(lactvec), function(x) data.frame( a = l[[x]], p = lactvec[x] ) )
  
  d <- data.frame()
  for( i in 1:length(dlist) ){
    d <- rbind( d, dlist[[i]] )
  }
  
  p <- ggplot( d, aes( x = a, color = p, group = p) ) + 
    geom_freqpoly( bins = 100 ) + 
    labs( x = "Turning Angle (degrees)",
          color = expression( lambda[act] ),
          title = mact ) +
    theme_classic()
  return(p)
}

