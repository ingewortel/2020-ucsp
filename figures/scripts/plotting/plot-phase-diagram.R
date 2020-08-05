argv <- commandArgs( trailingOnly = TRUE )

library( ggplot2 )
library( dplyr, warn.conflicts = FALSE )
source( "../scripts/plotting/mytheme.R" )

infile <- argv[1]
outplot <- argv[2]
Nbin <- as.numeric( argv[3] ) -1
nsim <- as.numeric( argv[4] )
highlights <- argv[5]

d <- read.table( infile, header = TRUE )
highlights <- read.table( highlights )
colnames( highlights ) <- c("mact","lact","type")
highlights$num <- seq(1,nrow(highlights))

# preprocessing step 1 : 
# the mixture model fits cells as two gaussians if the distribution is slightly different
# in shape from one normal. However, this does not mean the cell is moving.
# Here: if the model has fitted two peaks and the mean/SD of those peaks are closer 
# together than a given threshold, we count them as one peak (to distinguish from a 
# scenario where the cell really is moving in two distinct peaks).
threshold <- 1
d$n2 <- sapply( 1:nrow(d), function(x) {
	if( is.na(d$n[x] ) || d$n[x] != 2 ){
		return(d$n[x])
	} else {
		if( d$dmuRel[x] < threshold ){
			return( 1 )
		} else {
			return( 2 )
		}
	}
})


# preprocessing step 2 : 
# if 3 peaks, only classify as IRW when the middle peak at dx = 0 has a mixing prop of
# at least some threshold.
threshold <- 0.05
d$n2 <- sapply( 1:nrow(d), function(x) {
	if( is.na(d$n2[x] ) || d$n[x] != 3 ){
		return(d$n2[x])
	} else {
		if( d$mp[x] < threshold ){
			return( 2 )
		} else {
			return( 3 )
		}
	}
})


dsummary <- d %>%
	group_by( mact, lact ) %>%
	summarise(
		count1 = sum( n2 == 1, na.rm = TRUE ),
		count2 = sum( n2 == 2, na.rm = TRUE ),
		count3 = sum( n2 == 3, na.rm = TRUE ), 
		broken = mean( broken, na.rm = TRUE ) * nsim )
		
ncomp <- sapply( 1:nrow(dsummary), function(x){
	counts <- as.numeric( dsummary[x,3:6] )
	return( which.max( counts) )
})
ncount <- sapply( 1:nrow(dsummary), function(x){
	counts <- as.numeric( dsummary[x,3:6] )
	return( counts[ which.max( counts) ] )
})

dsummary$ncomp <- as.character( ncomp )

nameLookup <- c( "1" = "NM", "2" = "P-RW", "3" = "I-RW", "4" = "broken" )

dsummary$motion <- nameLookup[ dsummary$ncomp ]
dsummary$motion <- factor( dsummary$motion, levels = c( "NM", "I-RW", "P-RW", "broken" ) )
dsummary$count <- ncount

colScale <- c( "broken" = "gray", "NM" = "red", "I-RW" = "forestgreen", "P-RW" = "blue" )


dftest <- data.frame( mact = c( 0, 30, 10, 30, 50, 50, 30 ), lact = c(0, 100, 700, 500, 80, 100, 150 ))

theme.size = 8
geom.text.size = (5/14) * theme.size



p <- ggplot( dsummary, aes( x = lact, y = mact ) ) + 
	geom_tile( aes( fill = motion, alpha = count ) ) +
	scale_x_continuous( expand = c(0,0) ) +
	scale_y_continuous( expand = c(0,0) ) +
	labs( x = expression(lambda["act"] ), y = expression( "max"["act"] ) ) +
	scale_fill_manual( values = colScale ) +
	scale_alpha_continuous( guide = "none" ) +
	geom_point( data = highlights, color = "white", size = 0.8 ) +
	geom_text( data = highlights, aes( label = num, x = lact + 50, y = mact + 3 ), size = geom.text.size, color = "white"  ) +
	#annotate( "point", x = 30, y = 150, color = "yellow", size = 1 ) +
	mytheme +
	theme(
		axis.line = element_blank(),
		panel.border = element_rect(colour = "black", fill = NA, size = 1 ),
		legend.position = "right"
	)


ggsave( outplot , width = 9, height = 6, units = "cm" )

# 
# dbroken <- d %>% 
# 	group_by( mact, lact ) %>%
# 	summarise( broken = mean( broken, na.rm = TRUE ) )
# 
# 
# mrange <- range( d$mact )
# lrange <- range( d$lact )
# mseq <- seq( mrange[1], mrange[2], Nbin+1 )
# lseq <- seq( lrange[1], lrange[2], Nbin+1 )
# 
# dm <- diff(mseq)[1]
# dl <- diff(lseq)[1]
# 
# threshold <- 0.2
# 
# 
# 
# d <- d %>%
# 	filter( !is.na(n) )
# 
# d2 <- d %>% filter( broken <= 0.2 ) 
# 
# 
# d2$col <- "x"
# 
# 
# mostFrequent <- function(x){
# 	counts <- sort( table(x), decreasing = TRUE  )
# 	return( as.numeric( names(counts)[1] ) )
# }
# 
# 
# dsum <- d %>%
# 	group_by( mact, lact ) %>%
# 	summarise( count1 = sum( n == 1, na.rm=TRUE ),
# 				count2 = sum( n == 2, na.rm = TRUE ),
# 				count3 = sum( n ==3, na.rm = TRUE ), 
# 				broken = mean(broken) )
# 
# d$n[ d$broken > threshold ] <- NA
# dsum$n[ dsum$broken ] <- NA

# 
# brokenFun <- function(x){
# 	if( any( x > threshold ) ){ 
# 		return (1) 
# 	} else {
# 		return (0)
# 	}
# }
# 
# p1 <- ggplot( d, aes( x = lact, y = mact ) ) +
# 	stat_summary_2d( aes( z = n ), fun = "median", bins = Nbin, vjust = 0, hjust = 0, drop = FALSE ) +
# 	#stat_summary_2d( data = dbroken[dbroken$broken > threshold,], aes( z = broken > threshold, alpha = broken ), fun = "mean" , bins = Nbin, drop = TRUE ) +
# 	#geom_bin2d( data = d2, aes( alpha = -stat(density) ), fill = "red", bins = Nbin ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()
# 
# p1b <- ggplot( d2, aes( x = lact, y = mact ) ) +
# 	geom_raster( aes( fill = n ) ) +
# 	#geom_bin2d( data = d2, aes( alpha = -stat(density) ), fill = "red", bins = Nbin ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()
# 
# p2 <- ggplot( d2, aes( x = lact, y = mact ) ) +
# 	stat_summary_2d( aes( z = n ), fun = "mean", bins = Nbin ) +
# 	#geom_bin2d( data = d2, aes( alpha = -stat(density) ), fill = "red", bins = Nbin ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	
# 	
# p2b <- ggplot( d, aes( x = lact, y = mact ) ) +
# 	stat_density_2d( data = d[ d$n == 1, ], aes( alpha = stat(density)), fill = "red", geom="raster",contour=FALSE ) +
# 	stat_density_2d( data = d[ d$n == 2 , ], aes( alpha = stat(density)), fill = "blue", geom="raster",contour=FALSE ) +
# 	stat_density_2d( data = d[ d$n == 3, ], aes( alpha = stat(density)), fill = "forestgreen", geom="raster",contour=FALSE ) +
# 	#geom_raster( data = dbroken, aes( alpha = broken ), fill = "black" ) +
# 	#geom_density_2d( data = d[ d$broken > 0, ] ) +
# 	scale_alpha_continuous( range=c(0,1) ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	
# 
# 	
# p3 <- ggplot( d, aes( x = lact, y = mact ) ) +
# 	stat_summary_2d( aes( z = dBIC23  ), fun = "mean", bins = Nbin ) +
# 	#geom_bin2d( data = d2, aes( alpha = -stat(density) ), fill = "red", bins = Nbin ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	
# 	
# p4 <- ggplot( d, aes( x = lact, y = mact ) ) +
# 	stat_summary_2d( aes( z = dBIC13  ), fun = "mean", bins = Nbin ) +
# 	#geom_bin2d( data = d2, aes( alpha = -stat(density) ), fill = "red", bins = Nbin ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	
# 	
# p5 <- ggplot( d, aes( x = lact, y = mact ) ) +
# 	stat_summary_2d( aes( z = dBIC12  ), fun = "mean", bins = Nbin ) +
# 	#geom_bin2d( data = d2, aes( alpha = -stat(density) ), fill = "red", bins = Nbin ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	
# 
# 	
# p6 <- ggplot( d, aes( x = lact, y = mact ) ) +
# 	stat_density_2d( data = d[ d$n == 1, ], aes( alpha = stat(density)), fill = "red", geom="raster",contour=FALSE ) +
# 	scale_alpha_continuous( range=c(0,0.8) ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	
# 	
# p7 <- ggplot( d, aes( x = lact, y = mact ) ) +
# 	stat_density_2d( data = d[ d$n == 2 , ], aes( alpha = stat(density)), fill = "blue", geom="raster",contour=FALSE ) +
# 	scale_alpha_continuous( range=c(0,0.8) ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	
# 	
# p8 <- ggplot( d, aes(x = lact, y = mact ) ) +
# 	stat_density_2d( data = d[ d$n == 3, ], aes( alpha = stat(density)), fill = "forestgreen", geom="raster",contour=FALSE ) +
# 	scale_alpha_continuous( range=c(0,0.8) ) +
# 	#scale_x_log10() +
# 	#scale_y_log10() +
# 	theme_bw()	

# library(cowplot)
# 
# p <- plot_grid( p1, p2, p2b, p6, p7, p8, p3, p4, p5,  ncol = 3)
# 	
# ggsave( outplot, height = 10, width = 12 )

