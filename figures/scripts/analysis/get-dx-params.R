library( celltrackR )
library( ggplot2 )
library( dplyr, warn.conflicts=FALSE )

argv <- commandArgs( trailingOnly = TRUE )


trackfile <- argv[1]
outfile <- argv[2]
outplot <- argv[3]

all.tracks <- readRDS( trackfile )

getDx <- function(tracks ){
  
  nsim <- length(tracks)
  
  if( nsim > 0 ){
  
	  # steps from tracks, then shuffle them (wo regard for simulation they come from)
	  steps <- subtracks(tracks,2)
	  steps <- sample( steps, length( steps ) )
	  #steps <- steps[1:5000]
  
	  # compute displacement and divide in nsim groups of displacements
	  disp <- t( sapply( steps, displacementVector) )[,1]
	  ind <- split(seq_along(disp), cut_number(seq_along(disp), nsim))
	  disp <- lapply( ind, function(x) disp[x] )
  } else {
  	disp <- NULL
  }
  
  return( disp )
}

# get the displacements
dxData <- lapply( all.tracks, getDx )

saveRDS( dxData, file = outfile )

if( !any( sapply( dxData, is.null ) ) ){


	dxdfs <- lapply( 1:length(dxData[[1]] ) , function(x){ 
		return( data.frame( num = x, 
							dx = unname( dxData[[1]][[x]] ) ) )
	})
	dxdf <- bind_rows(dxdfs)


	p <- ggplot( dxdf, aes( x = dx ) ) + 
		geom_density() + 
		facet_wrap( ~num ) +
		labs( title = names( all.tracks )[1] ) +
		theme_bw()
	
	ggsave( outplot, width = 7, height = 7 )
}