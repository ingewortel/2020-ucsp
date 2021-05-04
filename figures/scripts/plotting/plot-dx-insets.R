library( ggplot2 )
library( dplyr )
source("../scripts/plotting/mytheme.R")


argv <- commandArgs( trailingOnly = TRUE )

allParams <- argv[1]
plotPoints <- argv[2]
outfile <- argv[3]



parms <- read.table( allParams )
colnames( parms ) <- c( "mact", "lact" )
parms$i <- seq( 1, nrow(parms) )


highlights <- read.table( plotPoints )
colnames( highlights ) <- c( "mact", "lact", "type" )
highlights$number <- seq(1,nrow(highlights))


pointIndex <- function( mactp, lactp, tol = 0.1 ){

	p <- parms %>%
		filter( abs( mact - mactp ) < tol ) %>%
		filter( abs( lact - lactp ) < tol )
		
	return( p$i )

}

highlights$i <- sapply( 1:nrow(highlights), function(x) {
	pointIndex( highlights$mact[x], highlights$lact[x] )
})

print( head(highlights ) )


dxList <- lapply( 1:nrow(highlights), function(x){
	
	i <- highlights$i[x]
	dxfile <- paste0( "data/analysis/p", i, "data/dx.rds" )
	dxData <- readRDS( dxfile )[[1]]
	
	tmp <- data.frame( 
		mact = highlights$mact[x],
		lact = highlights$lact[x],
		i = highlights$i[x],
		num = highlights$number[x],
		type = highlights$type[x],
		dx = dxData[[1]]		
	)
	
	return(tmp)
})

dxData <- bind_rows( dxList )

dxData$num <- paste0( "point: ", dxData$num )

p <- ggplot( dxData, aes( x = dx , color = type ) ) +
	geom_density( show.legend = FALSE ) +
	scale_color_manual( values = c( "NM" = "red", "IRW" = "forestgreen", "PRW" = "blue" ) ) +
	labs( x = expression( Delta*"x displacement (pixels)" ) ) +
	facet_wrap( ~num, ncol = 4, scales = "free_y" ) +
	mytheme
	
ggsave( outfile,  width = 9, height = 5, units = "cm" )