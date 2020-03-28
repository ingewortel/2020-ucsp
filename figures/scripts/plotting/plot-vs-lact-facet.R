library( dplyr, warn.conflicts = FALSE )
library( ggplot2 , warn.conflicts = FALSE )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
groupvar <- argv[3]
cellength <- as.numeric( argv[4] )

# Mean dataframe
d <- read.table( datafile, header = TRUE )

speedscales <- ifelse( datafile == "data/CPM1D-speedpersistence-all.txt", "free", "free_x" )

if( groupvar == "lp" ){

	dmean <- d %>%
		group_by( mact, lact, lp ) %>% 
		summarise( 	v = mean(speed),
				sdv = sd(speed),
				p = mean(phalf),
				sdp = sd(phalf) )
	dmean$group <- dmean$lp
	dmean$group2 <- factor(dmean$lp, labels = paste0("lambda[P] : ", levels(factor(dmean$lp)) ) )
	grouplabel <- expression( lambda["P"])


} else if (groupvar == "mact" ){

	dmean <- d %>%
		group_by( mact, lact ) %>% 
		summarise( 	v = mean(speed),
				sdv = sd(speed),
				p = mean(phalf),
				sdp = sd(phalf) )
	dmean$group <- dmean$mact
	dmean$group2 <- factor(dmean$mact, labels = paste0("max[act] : ", levels(factor(dmean$mact)) ) )
	grouplabel <- expression( "max"["act"])

}
dmean$minP <- dmean$p < (0.1*cellength/dmean$v)

npanels <- length( unique( dmean$group ) )
npanelrows <- ceiling( npanels/3 )
pheight <- 4*npanelrows + 1

# plotting speed
speedplot <- ggplot( dmean, aes( x = lact, y = v, group = group) ) +
	geom_ribbon( aes( ymin = v - sdv, ymax = v + sdv ), color = NA, alpha = 0.3 ) +
	geom_path() +
	geom_point( size = 1.2, shape = 21, aes( fill = minP ), show.legend = FALSE ) +
	labs( 
		x = expression( lambda["act"] ),
		y = "mean speed (pixels/MCS)"
	) +
	scale_fill_manual( values = c( "TRUE" = "white", "FALSE" = "black" ) ) +
	facet_wrap( ~group2, scales=speedscales, ncol = 3, labeller=label_parsed ) +
	mytheme + theme(
		legend.title = element_text(),
		legend.position = "right"
	)

speedtitle <- paste0( outplot, "-speed.pdf" )
ggsave(speedtitle, width = 18, height = pheight, units = "cm" )

# plotting persistence
ymax <- ceiling( log10( max(dmean$p,na.rm=TRUE ) ) )
persistenceplot <- ggplot( dmean, aes( x = lact, y = p, group = group ) ) +
	geom_ribbon( aes( ymin = p - sdp, ymax = p + sdp), color = NA, alpha = 0.3 ) +
	geom_path() +
	geom_point( size = 1.2, shape = 21, aes( fill = minP ), show.legend = FALSE ) +
	labs( 
		x = expression( lambda["act"] ),
		y = "persistence time (MCS)"
	) +
	scale_fill_manual( values = c( "TRUE" = "white", "FALSE" = "black" ) ) +
	facet_wrap( ~group2, scales="free_x", ncol = 3, labeller=label_parsed ) +
	scale_y_log10( limits=c(5,10^ymax), expand=c(0,0) ) +
	mytheme + theme(
		legend.title = element_text(),
		legend.position = "right"
	)

persistencetitle <- paste0( outplot, "-persistence.pdf" )
ggsave(persistencetitle, width = 18, height = pheight, units = "cm" )


