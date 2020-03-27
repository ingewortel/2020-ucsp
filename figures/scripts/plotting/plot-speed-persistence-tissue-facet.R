library( dplyr )
library( ggplot2 )
library( ggrepel )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
cellength <- as.numeric( argv[3] )
labeljust <- as.numeric( unlist( strsplit( argv[4], " ") ) )


pmeasure <- "phalf"
lab <- "Autocovariance decay"


# Read the data and compute averages over sims
d <- read.table( datafile, header = TRUE )
d$persistence <- d$phalf

# compute mean and SD. Only include parameter combinations where persistence estimation succeeded
# at least twice.
dmean <- d %>%
	group_by( lact, mact, tissue ) %>%
	summarise( 	m_speed = mean(speed, na.rm=TRUE),
			sd_speed = sd(speed, na.rm=TRUE),
			m_persistence = mean( persistence, na.rm=TRUE ),
			sd_persistence = sd( persistence, na.rm=TRUE ),
			values_persistence = sum( !is.na( persistence ) ) ) %>%
	filter( values_persistence > 2 ) 

ymax <- 300 #ceiling( log10( max(dmean$m_persistence,na.rm=TRUE ) ) )

dmean$mact2 <- factor(dmean$mact, labels = paste0("max[act] : ", levels(factor(dmean$mact)) ) )
dmean$tissue2 <- factor( dmean$tissue, labels = paste0("tissue : ", levels(factor(dmean$tissue)) ) )
dmean$minP <- 0.1*cellength/dmean$m_speed
print(dmean$minP)


dspeeds <- data.frame()
for( m in unique( dmean$mact ) ){

	dtmp <- dmean %>%
		filter( mact == m ) %>%
		filter( m_persistence < 10000 ) %>% 
		as.data.frame()

	minv <- min( dtmp$m_speed, na.rm = TRUE )
	maxv <- max( dtmp$m_speed, na.rm = TRUE )
	v <- seq( minv-0.05*(maxv-minv), maxv+0.1*(maxv-minv), length.out = 50 )
	minp <- 0.1*cellength/v
	dspeeds <- rbind( dspeeds, data.frame( mact = m, m_speed = v, minP = minp ) )
}
#dspeeds$tissue2 <- factor(dspeeds$tissue, labels = paste0("tissue : ", levels(factor(dspeeds$tissue)) ) )
dspeeds$mact2 <- factor( dspeeds$mact, labels = paste0( "max[act] : ", levels(factor(dspeeds$mact))))

# Plot the correlation
p <- ggplot( dmean, aes( 	x = m_speed, 
				y = m_persistence, 
				group=tissue, color = tissue ) ) +
	
	# shade the area where persistence is meaningless (less than a cellength)
	geom_ribbon( data = dspeeds, inherit.aes = FALSE, aes( x = m_speed, ymin=0, ymax = minP, group = mact2 ), alpha = 0.1, color=NA,fill = "black" )+
	# shaded +/- SD of the persistence over sims
	#geom_ribbon( aes( 	ymin=m_persistence - sd_persistence, 
	#			ymax = m_persistence + sd_persistence ), alpha=0.3, color=NA ) + 
	geom_point(size = 0.8, show.legend = FALSE ) +
	geom_path() +
	# Show lact values
	geom_text_repel( data=dmean[ dmean$tissue=="stiff",], aes( label=lact), box.padding=0, point.padding = 0.4, segment.color="grey50", size = 2, segment.size = 0.2, min.segment.length = unit(0, 'lines'), nudge_x=0.005, nudge_y=-0.13, force = 5 , show.legend = FALSE )+
	labs( 	x = "mean speed (pixels/MCS)",
		y = "persistence time (MCS)",
		color = "") +
	scale_y_log10( expand=c(0,0)) +
	scale_x_continuous( expand=c(0,0) ) +
	scale_color_manual( values=c(stiff="black",deformable="red"), labels=c(stiff="stiff tissue",deformable="deformable tissue"))+
	guides(color=guide_legend(
                 keyheight=0.3,
                 default.unit="cm")
      	) +
	coord_cartesian( ylim=c(5,ymax)) +
	facet_wrap( ~mact2 , scales="free_x", ncol=2,labeller = label_parsed )+
	mytheme + theme(
		legend.position = c(0.85,0.17),
		legend.background = element_rect( fill = NA ),
		legend.margin=margin(-15,0,-10,0),
		plot.title = element_text(size = 9),
		legend.title = element_text( size = 9 ),
		strip.background =element_rect(fill=NA,color=NA)
	)

npanels <- length( unique( dmean$tissue ) )
npanelrows <- 1 # ceiling( npanels/3 )

pheight <- npanelrows*4+1

pwidth <- 11 

ggsave( outplot, width = pwidth, height = pheight, units="cm")
