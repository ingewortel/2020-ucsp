source("../scripts/plotting/mytheme.R")
library( dplyr, warn.conflicts = FALSE )
library( ggplot2, warn.conflicts = FALSE )

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outname <- argv[2]

ymax <- 10000

d <- read.table( datafile, header = TRUE )

d2 <- d %>%
	group_by( mact, lact ) %>%
	summarise( v = mean(speed, na.rm = TRUE ), p = mean( phalf, na.rm = TRUE ) ) %>%
	group_by( mact ) %>% 
	summarise( mv = max( v, na.rm = TRUE ), mp = max(p, na.rm = TRUE ) ) %>%
	as.data.frame()

pspeed <- ggplot( d2, aes( x = mact, y = mv ) ) +
	geom_point( size = 0.8 ) +
	geom_line() + 
	scale_y_continuous( limits = c(0,1.1*max(d2$mv,na.rm=TRUE) ), expand=c(0,0) ) +
	labs( x = expression( "max"["act"]),
		y = "max speed (pixels/MCS)" ) +
	mytheme

ggsave(paste0(outname,"-speed.pdf"), width = 4.5, height = 4, units="cm")
	
ppersistence <- ggplot( d2, aes( x = mact, y = mp ) ) +
	geom_point( size = 0.8 ) +
	geom_line() + 
	scale_y_log10( limits=c(5,ymax) , expand=c(0,0)) +
	labs( x = expression( "max"["act"]),
		y = "max persistence (MCS)" ) +
	mytheme

ggsave(paste0(outname,"-persistence.pdf"), width = 4.5, height = 4, units="cm")
