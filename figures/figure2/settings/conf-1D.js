let config = {

	// Grid settings
	ndim : 2,
	field_size : [150,12],
	
	// CPM parameters and configuration
	conf : {
		// Basic CPM parameters
		torus : [true,false],				// Should the grid have linked borders?
		seed : 1,							// Seed for random number generation.
		T : 20,								// CPM temperature
		
		// Constraint parameters. 
		// Mostly these have the format of an array in which each element specifies the
		// parameter value for one of the cellkinds on the grid.
		// First value is always cellkind 0 (the background) and is often not used.
				
		// Adhesion parameters:
		J : [ [NaN,20,0], [20,0,15], [0,15,0] ],
		
		// VolumeConstraint parameters
		LAMBDA_V: [0,30,0],					// VolumeConstraint importance per cellkind
		V: [0,500,0],						// Target volume of each cellkind
		
		// PerimeterConstraint parameters
		LAMBDA_P: [0,2,0],					// PerimeterConstraint importance per cellkind
		P : [0,360,0],						// Target perimeter of each cellkind
		
		// BarrierConstraint parameters
		IS_BARRIER : [false, false, true],
		
		// ActivityConstraint parameters
		LAMBDA_ACT : [0,0,0],				// ActivityConstraint importance per cellkind
		MAX_ACT : [0,0,0],					// Activity memory duration per cellkind
		ACT_MEAN : "geometric"				// Is neighborhood activity computed as a
											// "geometric" or "arithmetic" mean?

	},
	
	// Simulation setup and configuration
	simsettings : {
	
		// Cells on the grid
		NRCELLS : [1],						// Number of cells to seed for all
											// non-background cellkinds.
		// Runtime etc
		BURNIN : 500,
		RUNTIME : 50000,
		
		// Visualization
		CANVASCOLOR : "eaecef",
		CELLCOLOR : ["000000","AAAAAA"],
		ACTCOLOR : [true,false],			// Should pixel activity values be displayed?
		SHOWBORDERS : [false,false],		// Should cellborders be displayed?
		zoom : 2,							// zoom in on canvas with this factor.
		
		// Output images
		SAVEIMG : false,					// Should a png image of the grid be saved
											// during the simulation?
		IMGFRAMERATE : 1,					// If so, do this every <IMGFRAMERATE> MCS.
		SAVEPATH : "data/img",				// ... And save the image in this folder.
		EXPNAME : "EXP",					// Used for the filename of output images.
		
		// Output stats etc
		STATSOUT : { browser: false, node: true }, // Should stats be computed?
		LOGRATE : 5								// Output stats every <LOGRATE> MCS.

	}
}

if( typeof module !== "undefined" ){
	module.exports = config
}
