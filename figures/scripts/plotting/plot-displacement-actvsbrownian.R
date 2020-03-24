source("../scripts/analysis/trackAnalysisFunctions.R")
source("../scripts/plotting/distributionPlotFunctions.R")
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

lact <- as.numeric( argv[1] ) #200
mact <- as.numeric( argv[2] ) #30
nsim <- as.numeric( argv[3] ) #20
ndim <- as.numeric( argv[4] ) #2
dt <- as.numeric( argv[5] ) #5 MCS between measurements
outplot <- argv[6]


params <- data.frame( lact = c(0,lact), mact = c(0,mact) )

d <- data.frame()
for( i in 1:nrow(params) ){
  
  lact <- params$lact[i]
  mact <- params$mact[i]
  tlist <- readAllTracks( lact, mact, nsim, ndim = ndim, c(150,150) )
  dispdata <- aggregate( tlist, displacement, subtrack.length = c(seq(0,100),seq(150,1000, by =50)) )
  dispdata$lact <- lact
  dispdata$mact <- mact
  
  d <- rbind( d, dispdata )
  
}

#dt <- 5
d$t <- d$i * dt

p <- ggplot( d, aes( x = sqrt(t), y = value, colour = lact, group = lact ) ) +
  annotate("rect", xmin=0, xmax=12,ymin=0,ymax=40, alpha=0.15) +
  annotate("rect", xmin=23, xmax=35,ymin=0,ymax=40, alpha=0.15) +
  annotate("text", x=6, y=37,label="persistent",size=2,color="gray40")+
  annotate("text", x=29, y=37, label="brownian",size=2,color="gray40")+
  geom_line( show.legend = FALSE ) +
  #geom_vline( xintercept = 17, lty = 2 ) +
  scale_x_continuous( limits=c(0,35), expand = c(0,0)) +
  scale_y_continuous( limits=c(0,40), expand = c(0,0)) +
  scale_colour_gradient( low = "gray40", high="red" ) +
  labs( x = expression(sqrt(time)), y = "displacement") +
  mytheme
#print(p)
ggsave(outplot, height=3.5, width=5, units="cm")


