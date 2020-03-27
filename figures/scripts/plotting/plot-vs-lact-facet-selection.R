library( dplyr )
library( ggplot2 )
library( cowplot )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
groupvar <- argv[3]
cellength <- as.numeric( argv[4] )
mactvalues <- as.numeric( unlist( strsplit( argv[5], " " ) ) )
nc <- as.numeric( argv[6] )

# Mean dataframe
d <- read.table( datafile, header = TRUE )
d <- d %>% filter( mact %in% mactvalues )

speedscales <- ifelse( datafile == "data/CPM1D-speedpersistence-all.txt", "free", "free_x" )

if( groupvar == "tissue" ){

	dmean <- d %>%
		group_by( mact, lact, tissue ) %>% 
		summarise( 	v = mean(speed),
				sdv = sd(speed),
				p = mean(phalf,na.rm=TRUE),
				sdp = sd(phalf) ) %>%
		filter( !is.na( p ) )
	dmean$group <- dmean$tissue
	dmean$group2 <- factor(dmean$tissue, labels = paste0("tissue : ", levels(factor(dmean$lp)) ) )
	grouplabel <- "tissue"


} else if (groupvar == "mact" ){

	dmean <- d %>%
		group_by( mact, lact ) %>% 
		summarise( 	v = mean(speed),
				sdv = sd(speed),
				p = mean(phalf,na.rm=TRUE),
				sdp = sd(phalf) ) %>%
		filter( !is.na(p) )
	dmean$group <- dmean$mact
	dmean$group2 <- factor(dmean$mact, labels = paste0("max[act] : ", levels(factor(dmean$mact)) ) )
	grouplabel <- expression( "max"["act"])

}
dmean$minP <- dmean$p < (0.1*cellength/dmean$v)
#print(as.data.frame(dmean))

npanels <- length( unique( dmean$group ) )
npanelrows <- ceiling( npanels/nc )
pheight <- 3.5*npanelrows + 1

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
	facet_wrap( ~group2, scales=speedscales, ncol = nc, labeller=label_parsed ) +
	mytheme + theme(
		legend.title = element_text(),
		legend.position = "right"
	)


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
	facet_wrap( ~group2, scales="free_x", ncol = nc, labeller=label_parsed ) +
	scale_y_log10( limits=c(5,10^ymax), expand=c(0,0) ) +
	mytheme + theme(
		legend.title = element_text(),
		legend.position = "right"
	)

pw <- nc*4+1
if( pw > 18 ){
pw <- 18
}

p <- plot_grid( plotlist = list( speedplot, persistenceplot ), labels = NULL, align = "v", ncol = 1 )
ggsave(outplot, width = pw, height = 8, units= "cm")

