library( ggplot2 )
source("../scripts/plotting/mytheme.R")
library( dplyr, warn.conflicts = FALSE )
suppressMessages( library( cowplot ) )

argv <- commandArgs( trailingOnly = TRUE )
datafile <- argv[1]
datafile2 <- argv[2]
energyplot <- argv[3]
diagramplot <- argv[4]



readData <- function( file ){
  
  d <- read.table( file )
  colnames(d) <- c( "lact", "t", "vol", "act" )
  d <- d %>% filter( t <= 1000)
  d$tot <- d$vol + d$act
  d$state <- ifelse( d$act == 0, "stop", "go" )
  
  transitions <- rle( d$state )
  timepoints <- c( 0, cumsum( transitions$length ) )
  tstart <- timepoints[1:length(timepoints)-1]
  tend <- timepoints[2:length(timepoints)]
  
  lambda <- unique( d$lact )
  
  dtrans <- data.frame(
    lact = lambda,
    tstart = tstart,
    tend = tend,
    state = transitions$values
  )
  
  return( list( d=d, dtrans=dtrans ) )
  
}

l1 <- readData( datafile )
l2 <- readData( datafile2 )

d1 <- l1$d
dtrans1 <- l1$dtrans
lact1 <- unique( d1$lact )

d2 <- l2$d
dtrans2 <- l2$dtrans
lact2 <- unique( d2$lact )

d <- rbind( d1, d2 )
dtrans <- rbind( dtrans1, dtrans2 )

plotEnergies <- function( d, dtrans, plotwhich = "tot", annotate = TRUE ){
  xlab <- ""
  
  if( plotwhich == "vol" ){ 
    d$y <- d$vol 
    ylab <- expression( "H"["volume"])
  } else if( plotwhich == "act" ){
    d$y <- d$act
    ylab <- expression( psi["act"])
  } else if( plotwhich == "tot" ){
    d$y <- d$tot
    ylab <- expression( "H"["cell"])
    xlab <- "t (MCS)"
  } else {
    stop( "unknown 'plotwhich' ")
  }
  if( !annotate ){
    ylab <- ""
  }
  
  p <- ggplot( d ) +
    geom_rect( data = dtrans, ymin = min( d$y ), ymax = max( d$y ), 
               aes( xmin = tstart, xmax = tend, fill = state, alpha = 0.3  ),
               color=NA,size=0, alpha = 0.2, show.legend=FALSE ) + 
    geom_hline( yintercept = 0, size = 0.2 ) +
    geom_line( data = d, aes( x = t, y = y ) , color = "gray30", size = 0.3 ) +
    scale_x_continuous( expand = c(0,0) ) +
    labs( x = xlab, y = ylab ) +
    scale_fill_manual( values=c( "stop" = "dodgerblue", "go" = "white" ) ) +
    mytheme + theme(
      axis.line.x = element_blank(),
      plot.margin = unit(c(0, 0.4, 0, 0), "cm")
    )
  
  if( annotate ){
    p <- p + 
      annotate( "segment", x = 436, xend = 455, y = 220, yend = 220, color = "red", size = 2 )
  }
  
  return(p)
  
}

pvol1 <- plotEnergies( d1, dtrans1, "vol" )
pvol2 <- plotEnergies( d2, dtrans2, "vol", annotate = FALSE )

pact1 <- plotEnergies( d1, dtrans1, "act" )
pact2 <- plotEnergies( d2, dtrans2, "act", annotate = FALSE )

ptot1 <- plotEnergies( d1, dtrans1, "tot" )
ptot2 <- plotEnergies( d2, dtrans2, "tot", annotate = FALSE )


#plot_grid( pvol, pact, ptot, ncol = 1, align="v" )

plot_grid( pvol1, pvol2, pact1, pact2 , ptot1, ptot2 , ncol = 2, align="v" )
ggsave( energyplot, width = 15, height = 6, units = "cm" )


plotStates <- function( d, ylab = TRUE ){
  d2 <- d
  d2$state <- factor( d$state, levels = c("stop","go"))
  d2$tot <- d$tot/1000
  dsum <- d2 %>% group_by( lact, state ) %>% summarise( mu = mean(tot) )
  dline <- dsum %>% group_by( lact ) %>% summarise( start = min(mu), end = max(mu) )
  
  yl <- expression("H"["cell"]~"(x"*10^3*")")
  
  pstates <- ggplot( d2, aes( x = state, y = tot ) ) +
    ggbeeswarm::geom_quasirandom( size = 0.1, color = "gray", alpha = 0.5 ) +
    geom_segment( data = dsum, aes( x = as.numeric(state) - 0.3, xend = as.numeric(state) + 0.3, y = mu, yend = mu  ) ) +
    geom_segment( data = dline, x = 1.5, xend = 1.5, aes( y = start, yend = end ), color = "red",
                  arrow = arrow( ends = "both", angle = 90, length = unit( 1, "mm" ) ) ) +
    #annotate( "segment", x = 1.5, xend = 1.5, y = dsum$mu[1], yend = dsum$mu[2], color = "red",
    geom_text( data = dline, x = 1.5, aes( y = (0 + 0.5*( start - end ) )), label = expression(delta), 
              hjust = 1.5, color = "red", size = 3 ) +
    labs( x = "", y = yl ) +
    facet_wrap( ~lact, ncol = 2, scales="free_y" )+
    mytheme + theme(
      strip.text = element_blank()
    )
  
  return(pstates)
}

ps <- plotStates( d )
ggsave( diagramplot, width = 7, height = 3.2, units = "cm" )

