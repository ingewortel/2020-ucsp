

argv <- commandArgs( trailingOnly = TRUE )

settingsfile <- argv[1]
outfile <- argv[2]

sett <- read.table( settingsfile )

N <- nrow(sett)


files <- paste0( "data/analysis/p", seq(1,N), "data/model.txt" )

df <- data.frame( files = files )

write.table( df, file = outfile, col.names = FALSE, row.names = FALSE, quote = FALSE )
