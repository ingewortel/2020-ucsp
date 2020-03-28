let config = {

	// Grid settings
	ndim : 3,
	field_size : [150,150,150],
	
	// CPM parameters and configuration
	conf : {
		// Basic CPM parameters
		torus : [true,true,true],			// Should the grid have linked borders?
		seed : 1,							// Seed for random number generation.
		T : 7,								// CPM temperature
		
		// Constraint parameters. 
		// Mostly these have the format of an array in which each element specifies the
		// parameter value for one of the cellkinds on the grid.
		// First value is always cellkind 0 (the background) and is often not used.
				
		// Adhesion parameters:
		J: [[0,5], [5,0]],
		
		// VolumeConstraint parameters
		LAMBDA_V: [0,25],					// VolumeConstraint importance per cellkind
		V: [0,1800],						// Target volume of each cellkind
		
		// PerimeterConstraint parameters
		LAMBDA_P: [0,0.01],					// PerimeterConstraint importance per cellkind
		P : [0,8600],						// Target perimeter of each cellkind
		
		// ActivityConstraint parameters
		LAMBDA_ACT : [0,0],					// ActivityConstraint importance per cellkind
		MAX_ACT : [0,0],					// Activity memory duration per cellkind
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
		
		// Visualization: none in 3D.
		SAVEIMG : false,					// Should a png image of the grid be saved
		// Output stats etc
		STATSOUT : { browser: false, node: true }, // Should stats be computed?
		LOGRATE : 5								// Output stats every <LOGRATE> MCS.

	}
}


if( typeof module !== "undefined" ){
	module.exports = config
}
