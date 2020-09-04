library( ggplot2 )
source("../scripts/plotting/mytheme.R")
library( dplyr, warn.conflicts = FALSE )

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outfile <- argv[2]

d <- read.table( datafile )
colnames(d) <- c( "lact", "t", "vol", "act" )
d$tot <- ( d$vol + d$act )/1000
d$state <- ifelse( d$act == 0, "stop", "go" )

d2 <- d %>% 
  group_by( lact ) %>% 
  filter( state == "go" ) %>%
  summarise( mu = mean(tot), 
             lo = quantile( tot, probs = c(0.025) ), 
             hi = quantile( tot, probs = c(0.975) ) )


p <- ggplot( d2, aes( x = lact, y = mu ) ) +
  geom_ribbon( aes( ymin = lo, ymax = hi ), fill = "gray" ) +
  geom_line() +
  geom_point( size = 0.5 ) +
  labs( x = expression( lambda["act"] ),
        y = expression( "H"["cell"]^"go"~"(x"*10^3*")" ) ) +
  mytheme


ggsave( outfile, height = 3.2, width = 4.5, units = "cm" )