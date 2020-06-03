library( dplyr, warn.conflicts = FALSE )
library( ggplot2, warn.conflicts = FALSE )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
pmeasure <- argv[3]


# Read the data and compute averages over sims
d <- read.table( datafile, header = TRUE )

if( pmeasure == "pexp" ){
	lab = "Autocovariance decay"
	d$persistence <- d$pexp
} else if( pmeasure == "phalf" ){
	lab = "Autocovariance halflife"
	d$persistence <- d$phalf
} else if( pmeasure == "pintmean" ){
	lab = "Interval mean length"
	d$persistence <- d$pintmean
} else if( pmeasure == "pintmedian" ){
	lab = "Interval median length"
	d$persistence <- d$pintmedian
} else {
	stop( "Unknown persistence measure. Please choose pexp/phalf/pintmean/pintmedian." )
}

# compute mean and SD. Only include parameter combinations where persistence estimation 
# succeeded at least twice.
dmean <- d %>%
	group_by( lact, mact ) %>%
	summarise( 	m_speed = mean(speed, na.rm=TRUE),
			sd_speed = sd(speed, na.rm=TRUE),
			m_persistence = mean( persistence, na.rm=TRUE ),
			sd_persistence = sd( persistence, na.rm=TRUE ),
			values_persistence = sum( !is.na( persistence ) ) ) 
			
# If enough estimations were made, only include parameter combinations where persistence 
# estimation succeeded at least twice. Otherwise issue a warning.
group_n <- max( dmean$values_persistence )
if( group_n >= 3 ){
	dmean <- dmean %>% filter( values_persistence > 1 )
} else {
	warning( "Not enough analysis groups to check if persistence estimates are reliable. Just plotting all data." )
}



# Compute the limit of the yaxis to plot.
ymax <- 10^4 #10^ceiling( log10( max(dmean$m_persistence,na.rm=TRUE ) ) )

# Compute the spearman correlation coefficient
spearman_r <- round( cor.test( dmean$m_speed, dmean$m_persistence, method="spearman" )$estimate, 3)


# Plot the correlation
p <- ggplot( dmean, aes( 	x = m_speed, 
				y = m_persistence ) ) +
	geom_point( size = 0.8 ) +
	stat_smooth( method = "loess", color = "red", size=0.5 ) +
	annotate("text",x=0.95*max(dmean$m_speed),y=2,label=paste("rho ==",spearman_r),hjust=1,size=mytheme$text$size*(5/14), parse = TRUE ) +
	labs( 	x = "mean speed (pixels/MCS)",
		y = "persistence time (MCS)" ) +
	scale_y_log10( expand=c(0,0)) +
	scale_x_continuous( limits=c(0,NA),expand=c(0,0) ) +
	coord_cartesian( ylim = c(1,ymax)) +
	mytheme + theme(
		legend.position = "right",
		plot.title = element_text(size = 9),
		legend.title = element_text( size = 9 ),
		strip.background =element_rect(fill=NA,color=NA)
	)

ggsave(outplot, width=6, height=4, units="cm")
