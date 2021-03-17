library( dplyr )
library( ggplot2 )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

dataFile <- argv[1]
outPlot <- argv[2]
outPlotBreaking <- argv[3]



pConnThresh <- 0.95


d <- read.table( dataFile, header = TRUE )


lpVec <- sort(unique( d$lp ) )

override.linetype <- rep( 1, length(lpVec ) )
override.linetype[ lpVec == 2 ] <- 2 

dMean <- d %>%
	group_by( lact, lp ) %>%
	summarise( speed = mean(speed), pt = mean(phalf), pconn = mean(pconn) )


plotBroken <- ggplot( d, aes( x = lact, y = pconn, group = lp, color = log(lp+.1), linetype = (lp == 2 ) ) ) +
	geom_line( data = dMean, ) +
	geom_point( show.legend = FALSE, size = 0.5 ) +
	labs( x = expression(lambda["act"]), 
			y = "mean connectedness", 
			color = expression( lambda["P"]),
			linetype = expression( lambda["P"]) ) +
	scale_color_gradient2( midpoint = log(2.1), breaks = log(lpVec+.1), 
		guide = guide_legend( keyheight = 0.4, default.unit = "cm" , override.aes = list(linetype = override.linetype) ),
		mid = "gray",
		low = scales::muted("blue" ),
		high = scales::muted("red" ),
		labels = lpVec ) +
	scale_linetype(guide = FALSE) +
	scale_x_continuous( limits = c(0, 1500), expand = c(0,0) ) +
	scale_y_continuous( limits = c(0,1.05), expand = c(0,0), breaks = seq(0,1,by=0.25) ) +
	#scale_color_manual( values = colValues ) + 
	mytheme + theme(
		legend.position="right",
		legend.title = element_text()
	)
	
ggsave( outPlotBreaking, width = 8, height = 6, units = "cm" )


dMeanFiltered <- dMean %>% filter( pconn >= pConnThresh )
lpVec2 <- sort(unique( dMeanFiltered$lp ) )
override.linetype <- rep( 1, length(lpVec2 ) )
override.linetype[ lpVec2 == 2 ] <- 2 

plotUCSP <- ggplot( dMeanFiltered, aes ( x = speed, y = pt, group = lp, color = log(lp+.1 ), linetype = (lp == 2 ) ) ) +
	geom_line() +
	geom_point( show.legend = FALSE, size = 0.5 ) +
	labs( x = "speed (pixels/MCS)", 
			y = "persistence time (MCS)", 
			color = expression( lambda["P"]),
			linetype = expression( lambda["P"]) ) +
	scale_color_gradient2( midpoint = log(2.1), breaks = log(lpVec2+.1), 
		guide = guide_legend( keyheight = 0.4, default.unit = "cm" , override.aes = list(linetype = override.linetype) ),
		mid = "gray",
		low = scales::muted("blue" ),
		high = scales::muted("red" ),
		labels = lpVec2 ) +
	scale_linetype(guide = FALSE) +
	scale_y_log10( limits=c(5,10000), expand = c(0,0)) +
	# scale_x_continuous( limits = c(0, 1500), expand = c(0,0) ) +
	# scale_y_continuous( limits = c(0,1.05), expand = c(0,0), breaks = seq(0,1,by=0.25) ) +
	mytheme + theme(
		legend.position="right",
		legend.title = element_text()
	)
	

ggsave( outPlot, width = 10, height = 6, units = "cm" )
	
	
	
	