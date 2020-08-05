library( dplyr, warn.conflicts = FALSE )
library( ggplot2 , warn.conflicts = FALSE )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
mactvalues <- as.numeric( unlist( strsplit( argv[3], " " ) ) )
nc <- as.numeric( argv[4] )



# Load data and create the variable for generating the facet labels:
load( datafile )
data <- data %>% filter( mact %in% mactvalues )

#data <- sample_n( data, nrow(data)/100 )
data$mact2 <- factor(data$mact, labels = paste0("max[act] : ", levels(factor(data$mact)) ) )


# Remove all observations with a connectivity below 100 from the instantaneous step data. 
# These can cause artefacts from cell breaking.
remove.rows <- data$conn < 1
print( paste0( "WARNING --- Removing ", sum(remove.rows), " rows from data with broken cells..." ) )
data <- data[ !remove.rows, ]


# Find the maximum density (which will be the max of the y axis later on; need this
# to get proper positioning of the lambda act labels)
ymax <- 0
for( m in unique(data$mact) ){
	dtmp <- data %>% filter( mact == m ) %>% filter( lact == min(lact) ) %>% as.data.frame()
	h <- hist(dtmp$v, plot = FALSE )
	if( max(h$density)*1.1 > ymax ){ ymax <- max(h$density)*1.1 }
}

# For each max act value, generate positions for the corresponding range of lambda act values.
# used later for plotting by geom_text
data2 <- data.frame()
annotationdata <- data.frame()
for( m in unique( data$mact ) ){
  dtmp <- data %>% filter( mact == m ) %>% as.data.frame()
  dtmp$lact2 <- ( dtmp$lact - min(dtmp$lact) ) / ( max( dtmp$lact ) - min(dtmp$lact) )
  
  adtmp <- data.frame( mact = m, 
                       mact2 = unique(dtmp$mact2),
                       lact = unique( dtmp$lact ), 
                       lact2 = unique( dtmp$lact2),
                       v = 0.92*max(dtmp$v) )
  adtmp$pos <- seq( 0.85*ymax, 0.05*ymax, length.out = length( unique( dtmp$lact ) ) )
  data2 <- rbind( data2, dtmp)
  annotationdata <- rbind( annotationdata, adtmp )
}

annotationdata2 <- annotationdata %>% 
  group_by( mact, mact2 ) %>%
  summarise( v = mean(v), pos = 0.95*ymax )


# Create the plot
p <- ggplot( data2, aes( x = v, y = ..density.., color = lact2, group = lact ) ) + 
  geom_freqpoly(bins=50, show.legend=FALSE) + 
  facet_wrap( ~mact2, scales="free_x", ncol = nc, labeller=label_parsed )+ 
  scale_color_gradientn( colors=c("red4","red","darkorange1","orange")) +
  labs( 	x = "instantaneous speed (pixels/MCS)",
         y = "density" ) +
  scale_y_continuous( limits = c(0,ymax), expand=c(0,0) ) +
  scale_x_continuous( expand = c(0,0) ) +
  # sizes in geom_text are in mm = 14/5 pt, so multiply textsize in pt with 5/14 to get
  # proper size in geom_text.
  geom_text( data = annotationdata, aes( y = pos, label = lact ), size=0.87*mytheme$text$size*(5/14), show.legend = FALSE ) +
  geom_text(data = annotationdata2, aes( y = pos, x = v, group = mact), color = "black", size=mytheme$text$size*(5/14), 
            label = "lambda[act]", parse = TRUE ) +
  mytheme + theme(
    legend.position = "right",
    axis.line.x = element_blank(),
    panel.spacing.y = unit(-1, "mm")
  )

npanels <- length( unique( data$mact ) )
npanelrows <- ceiling( npanels/nc )
pheight <- 3.5*npanelrows+0.5
pw <- 4.5*nc+1
if( pw > 18 ){pw <- 18}

ggsave( outplot, width = pw, height = pheight, units="cm")
