source("../scripts/analysis/trackAnalysisFunctions.R")
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )
outplot <- argv[1]

library( ggplot2, warn.conflicts = FALSE )

# read the tracks and center their starting positions
t <- readTracks("data/tracks/CPM2D-lact0-mact0-sim1.txt", 2, 
	torus.fieldsize = c(150,150) )
t <- normalizeTracks( t )

# plot the first 1000 MCS of the first track
d <- as.data.frame( t[[1]] )
d$t <- d$t - d$t[1]
d <- d[ d$t <= 1000, ]


n <- nrow(d)

p <- ggplot( d, aes( x = x, y = y, color = t )  ) +
  geom_path( aes( color = t ), show.legend = FALSE, lineend="round" ) +
  scale_colour_gradient( low = "gray60", high="black" )+
  mytheme + theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.line = element_blank(),
    axis.title = element_blank()
  )


ggsave(outplot, height = 3.5, width = 3.5, units="cm" )


