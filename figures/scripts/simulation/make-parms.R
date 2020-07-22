
argv <- commandArgs( trailingOnly = TRUE )

mrange <- as.numeric( unlist( strsplit( argv[1], " " ) ) )
lrange <- as.numeric( unlist( strsplit( argv[2], " " ) ) )
N <- as.numeric( argv[3] )
out <- argv[4]

#mrange <- c( 5, 100 )
#lrange <- c( 5, 1500 )

mlogrange <- log10( mrange )
llogrange <- log10( lrange )

#N <- 15


mlog <- seq( mlogrange[1], mlogrange[2], length.out = N+1 )
llog <- seq( llogrange[1], llogrange[2], length.out = N+1 )


m <- round( 10^mlog, 3 )
l <- round( 10^llog, 3 )

d <- expand.grid( m, l )
colnames(d) <- c("m","l" )

write.table( d, file = out, col.names=FALSE, row.names=FALSE, quote=FALSE)



#d$z <- rnorm( nrow(d) )

#plot(m,l, data=d, log="xy")


#ggplot( d, aes( m,l ) )+
#scale_x_log10(  ) +
#scale_y_log10(  ) +
#stat_summary_2d( bins = N, aes( z = z ), fun = "median" )