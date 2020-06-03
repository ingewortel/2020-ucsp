library( dplyr, warn.conflicts = FALSE )
library( ggplot2, warn.conflicts = FALSE )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
pmeasure <- argv[3]
cellength <- as.numeric( argv[4] )
labeljust <- as.numeric( unlist( strsplit( argv[5], " ") ) )
mactvalues <- as.numeric( unlist( strsplit( argv[6], " " ) ) )
nc <- as.numeric( argv[7] )

if( is.na(nc) ){
	nc <- 3
}

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

# compute mean and SD. Only include parameter combinations where persistence estimation succeeded
# at least twice.
ymax <- 10000 #10^ceiling( log10( max(dmean$m_persistence,na.rm=TRUE ) ) )

dmean <- d %>%
	group_by( lact, mact ) %>%
	filter( mact %in% mactvalues ) %>%
	summarise( 	m_speed = mean(speed, na.rm=TRUE),
			sd_speed = sd(speed, na.rm=TRUE),
			m_persistence = mean( persistence, na.rm=TRUE ),
			sd_persistence = sd( persistence, na.rm=TRUE ),
			values_persistence = sum( !is.na( persistence ) ) ) %>%
	filter( mact != 19 )

# If enough estimations were made, only include parameter combinations where persistence 
# estimation succeeded at least twice. Otherwise issue a warning.
group_n <- max( dmean$values_persistence )
if( group_n >= 3 ){
	dmean <- dmean %>% filter( values_persistence > 1 )
} else {
	warning( "Not enough analysis groups to check if persistence estimates are reliable. Just plotting all data." )
}



dmean$mact2 <- factor(dmean$mact, labels = paste0("max[act] : ", levels(factor(dmean$mact)) ) )
dmean$minP <- 0.1*cellength/dmean$m_speed

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
dspeeds$mact2 <- factor(dspeeds$mact, labels = paste0("max[act] : ", levels(factor(dspeeds$mact)) ) )


npanels <- length( unique( dmean$mact ) )
npanelrows <- ceiling( npanels/nc )

# Plot the correlation
p <- ggplot( dmean, aes( 	x = m_speed, 
				y = m_persistence )) +	
	# shade the area where persistence is meaningless (less than a cellength)
	geom_ribbon( data = dspeeds, inherit.aes = FALSE, aes( x = m_speed, ymin=0, ymax = minP, group = mact2 ), alpha = 0.1, color=NA,fill = "black" )+
	# shaded +/- SD of the persistence over sims
	geom_ribbon( aes( 	ymin=m_persistence - sd_persistence, 
				ymax = m_persistence + sd_persistence ), alpha=0.3, color=NA ) + 
	geom_point( size = 0.8 ) +
	# Show lact values
	geom_text( aes( label = lact ) , size=2, hjust=labeljust[1],vjust=labeljust[2]) +
	geom_path() +
	labs( 	x = "mean speed (pixels/MCS)",
		y = "persistence time (MCS)" ) +
	scale_y_log10( limits=c(5,ymax) , expand=c(0,0)) +
	scale_x_continuous( expand=c(0,0) ) +
	facet_wrap( ~mact2, scales="free_x", ncol = nc, labeller=label_parsed )+
	mytheme + theme(
		legend.position = "right",
	panel.spacing.x = unit(1, "lines")
	)

pheight <- ifelse( npanelrows == 2, 9, 5 )
pw <- 5.25*nc+1
if( pw > 18 ){pw <- 18}

ggsave( outplot, width = pw, height = pheight, units="cm")
