library( dplyr, warn.conflicts = FALSE )
library( ggplot2, warn.conflicts = FALSE )
source("../scripts/plotting/mytheme.R")

argv <- commandArgs( trailingOnly = TRUE )

datafile <- argv[1]
outplot <- argv[2]
supp <- !is.na(argv[3])

# Load data and create the variable for generating the facet labels:
load( datafile )
#data <- sample_n( data, nrow(data)/100 )
data$tissue2 <- factor(data$tissue, labels = paste0("tissue : ", levels(factor(data$tissue)) ) )
data$mact2 <- factor( data$mact, labels = paste0( "max[act] : ",levels(factor(data$mact))))

# Remove all observations with a connectivity below 100 from the instantaneous step data. These can cause artefacts from cell breaking.
remove.rows <- data$conn < 1
print( paste0( "WARNING --- Removing ", sum(remove.rows), " rows from data with broken cells..." ) )
data <- data[ !remove.rows, ]

# Find the maximum density (which will be the max of the y axis later on; need this
# to get proper positioning of the lambda act labels)
ymax <- 0
for( p in unique(data$tissue) ){
	for( m in unique( data$mact )){
		dtmp <- data %>% filter( tissue == p & mact == m ) %>% filter( lact == min(lact) ) %>%
		        as.data.frame()
		h <- hist(dtmp$v, plot = FALSE, breaks = 50 )
		if( max(h$density)*1.1 > ymax ){ ymax <- max(h$density)*1.1 }

	}
}

# For each max act value, generate positions for the corresponding range of lambda act values.
# used later for plotting by geom_text
data2 <- data.frame()
annotationdata <- data.frame()
for( p in unique( data$tissue ) ){
	for( m in unique( data$mact ) ){
		 dtmp <- data %>% filter( tissue == p & mact == m ) %>% as.data.frame()
		 dtmp$lact2 <- ( dtmp$lact - min(dtmp$lact) ) / ( max( dtmp$lact ) - min(dtmp$lact) )
  
		adtmp <- data.frame( tissue = p, 
                       mact = m,
		       mact2 = unique( dtmp$mact2 ),
			tissue2 = unique(dtmp$tissue2),
                       lact = unique( dtmp$lact ), 
                       lact2 = unique( dtmp$lact2),
		       v = 0.95*max(dtmp$v) )
  		adtmp$pos <- seq( 0.85*ymax, 0.05*ymax, length.out = length( unique( dtmp$lact ) ) )
  		data2 <- rbind( data2, dtmp)
  		annotationdata <- rbind( annotationdata, adtmp )
	}	
}
annotationdata2 <- annotationdata %>% 
  group_by( tissue, tissue2, mact, mact2 ) %>%
  summarise( v = mean(v), pos = 0.95*ymax )

annotationdata2$tissue3 <- paste0( "(",annotationdata2$tissue, ")" )
data2$tissue3 <- paste0(  "(",data2$tissue,")")


# Create the plot
if( !supp){
p <- ggplot( data2, aes( x = v, y = ..density.., color = lact2, group = lact ) ) + 
  geom_freqpoly(bins=50, show.legend=FALSE) + 
  facet_wrap( ~mact2 + tissue2 ,scales="free_x", ncol = 2, labeller = labeller( .cols = label_parsed, .multi_line=FALSE ))+ 
  scale_color_gradientn( colors=c("red4","red", "darkorange","orange")) +
  labs( 	x = "Instantaneous speed (pixels/MCS)",
         y = "Density" ) +
  scale_x_continuous( expand = c(0,0)) +
  scale_y_continuous( limits = c(0,ymax), expand=c(0,0) ) +
  # sizes in geom_text are in mm = 14/5 pt, so multiply textsize in pt with 5/14 to get
  # proper size in geom_text.
  geom_text( data = annotationdata, aes( y = pos, label = lact ), size=mytheme$text$size*(5/14), show.legend = FALSE ) +
  geom_text(data = annotationdata2, aes( y = pos, x = v, group = tissue), color = "black", size=mytheme$text$size*(5/14), 
            label = "lambda[act]", parse = TRUE ) +
  mytheme + theme(
    legend.position = "right",
    axis.line.x = element_blank(),
    panel.spacing.x = unit(1, "lines")
  )
} else {
p <- ggplot( data2, aes( x = factor(lact), y = v, group = lact) ) + 
  geom_violin(show.legend=FALSE, color = NA, fill = "gray" ) +
  geom_boxplot( outlier.size = 0 ) +  
  labs( 	y = "Instantaneous speed\n(pixels/MCS)",
         x = expression(lambda[act]) ) +
  scale_y_continuous( limits=c(0,NA),expand=c(0,0) ) +
  # sizes in geom_text are in mm = 14/5 pt, so multiply textsize in pt with 5/14 to get
  # proper size in geom_text.
  mytheme + theme(
    legend.position = "right",
    axis.line.x = element_blank(),
    panel.spacing.x = unit(1, "lines")
  )

}

npanels <- length( unique( data$tissue ) )
npanelrows <- 2 # ceiling( npanels/3 )
if( supp ){
	npanelrows <- 1
	pwidth <- 6
} else {
	pwidth <- 18
}
pheight <- 4*npanelrows + 1

ggsave( outplot, width = pwidth, height = pheight, units="cm")
