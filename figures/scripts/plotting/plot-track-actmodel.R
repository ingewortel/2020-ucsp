source("../scripts/analysis/trackAnalysisFunctions.R")
source("../scripts/plotting/mytheme.R")
source("../scripts/plotting/distributionPlotFunctions.R")
library(ggplot2, warn.conflicts=FALSE)

argv <- commandArgs( trailingOnly = TRUE )
lact <- as.numeric(argv[1]) #200
mact <- as.numeric(argv[2]) #30
nsim <- as.numeric(argv[3]) #5 tracks
ndim <- as.numeric(argv[4]) #2
time <- as.numeric(argv[5]) #1000 MCS
outplot <- argv[6]

## ACT EXAMPLE TRACKS
# read 5 tracks of lact 200, mact 5 in 2D
tlist <- readAllTracks( lact, mact, nsim, ndim = ndim, c(150,150) )
# shift starting point to origin,
tlist <- normalizeTracks( tlist )
dtrack <- data.frame()
for( i in 1:length(tlist) ){

  
  # convert to dataframe for plotting
  dftmp <- as.data.frame( tlist[[i]] )

  # plot only the first [time=1000] MCS
  dftmp <- dftmp[ dftmp$t <= time, ]
  dftmp$sim <- i
  dtrack <- rbind( dtrack, dftmp)
}

# plot them in different colors
cols <- c("1"="red","2"="darkorange","3"="forestgreen","4"="blue","5"="maroon3")
ggplot( dtrack, aes(x = x, y = y, group = sim, colour = as.character(sim))) +
  geom_path( show.legend = FALSE ) +
  geom_point( data = dtrack[1,], color = "black" ) +
  geom_text( data = dtrack[1,], label = "t = 0", hjust = 1.3, vjust = 1, color="black", size = 2 ) +
  coord_fixed() + 
  scale_colour_manual( values = cols )+
  mytheme + theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.line = element_blank(),
    axis.title = element_blank()
  )

# save plot
ggsave(outplot, height = 3.5, width = 4, units="cm" )

