library( dplyr, warn.conflicts = FALSE )
library( ggplot2, warn.conflicts = FALSE )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
cellength <- as.numeric( argv[3] )

# Mean dataframe
d <- read.table( datafile, header = TRUE )


dmean <- d %>%
	group_by( mact, lact, tissue ) %>% 
	summarise( 	v = mean(speed),
			sdv = sd(speed),
			p = mean(phalf),
			sdp = sd(phalf) )

dmean$tissue2 <- factor(dmean$tissue, labels = paste0("tissue : ", levels(factor(dmean$tissue)) ) )
dmean$mact2 <- factor( dmean$mact, labels = paste0( "max[act] : ",levels(factor(dmean$mact))))


dmean$minP <- dmean$p < (0.1*cellength/dmean$v)

# plotting speed
speedplot <- ggplot( dmean, aes( x = lact, y = v, group = tissue, color = tissue, fill = tissue ) ) +
	geom_ribbon( aes( ymin = v - sdv, ymax = v + sdv ), color = NA, alpha = 0.3 ) +
	geom_path() +
	geom_point( size = 1.2, aes( shape = minP ), show.legend = FALSE ) +
	scale_shape_manual( values = c( "TRUE"=1,"FALSE"=16) )+
	facet_wrap( ~mact2, scales = "free_x", ncol = 2, labeller = labeller( .cols=label_parsed ) ) +
	scale_color_manual( values = c( "deformable" = "red", "stiff" = "black" ) ) +
	scale_fill_manual( values = c( "deformable" = "red", "stiff" = "black" ) ) +
	#scale_colour_gradient2(high="red4", mid="red",low="orange", midpoint=2.5,breaks = groupvalues)+
	#scale_fill_gradient2(high="red4", mid="red", low="orange",midpoint=2.5,breaks=groupvalues)+
	labs( 
		x = expression( lambda["act"] ),
		y = "mean speed (pixels/MCS)",
		fill = "tissue",
		color = "tissue"
	) +
	mytheme + theme(
		legend.title = element_text(),
		legend.position = "right"
	)

speedtitle <- paste0( outplot, "-speed.pdf" )
ggsave(speedtitle, width = 15, height = 6, units = "cm" )

# plotting persistence
ymax <- ceiling( log10( max(dmean$p,na.rm=TRUE ) ) )
persistenceplot <- ggplot( dmean, aes( x = lact, y = p, group = tissue, color = tissue, fill = tissue ) ) +
	geom_ribbon( aes( ymin = p - sdp, ymax = p + sdp), color = NA, alpha = 0.3 ) +
	geom_path() +
	geom_point( size = 1.2, aes( shape = minP ), show.legend = FALSE ) +
	scale_shape_manual( values = c( "TRUE"=1,"FALSE"=16) )+
	scale_color_manual( values = c( "deformable" = "red", "stiff" = "black" ) ) +
	scale_fill_manual( values = c( "deformable" = "red", "stiff" = "black" ) ) +
	#scale_colour_gradient2(high="red4", mid="red",low="orange", midpoint=2.5,breaks = groupvalues)+
	#scale_fill_gradient2(high="red4", mid="red", low="orange",midpoint=2.5,breaks=groupvalues)+
	facet_wrap( ~mact2, scales = "free_x", ncol = 2, labeller = labeller( .cols=label_parsed ) ) +
	labs( 
		x = expression( lambda["act"] ),
		y = "persistence time (MCS)",
		fill = "tissue",
		color = "tissue"
	) +
	scale_y_log10( limits=c(5,10^ymax), expand=c(0,0) ) +
	mytheme + theme(
		legend.title = element_text(),
		legend.position = "right"
	)

persistencetitle <- paste0( outplot, "-persistence.pdf" )
ggsave(persistencetitle, width = 15, height = 6, units = "cm" )


