macro "Export Z-stack ratiometric data" {
	// THIS SCRIPT WAS WRITTEN FOR HIGH MAG PAN-NEURONAL HYLIGHT DATA.
	// IT TAKES A TWO CHANNEL Z STACK AND PROCESSES IT TO RATIOS 
	// AT EACH PIXEL WITHIN A THRESHOLDED REGION.
	//
	// Data is output as CSV files per Z slice, with the pixel values exported
	// individually. Those can then be read into python or similar for 
	// aggregation and histogram analyses. 
	//
	// USAGE: begin by selecting a 700x700 area on your 60x image. You need to use
	// the same size area every time, otherwise the thresholding algorithm gives
	// different results. Duplicate that and title it RUNNER. 
	// 
	// The script will ask you where you want to export the data to, then do
	// the rest automatically. I've found Fiji apparently dislikes directories 
	// with spaces in it, so use something easy like the Desktop or something. 

	// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ //

	// Function to add zero padding to output file names
	function leftPad(n, width) {
		p =""+n;
		while (lengthOf(p)<width)
		  p = "0"+p;
		return p;
	}

	// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ //
	
	// Main script. Start by asking for a directory
	dir = getDirectory("Choose save location for XY coordinates");

	// Get stack dimensions
	Stack.getDimensions(w,h,c,s,f);

	// Duplicates your image of interest and create an image that is the sum of 
	// the 488 and 405 nm excitation together. 
	// This way, it doesn't bias thresholding for one channel over the other.  

	selectWindow("RUNNER");
	run("Duplicate...", "title=DUPE duplicate");
	selectWindow("DUPE");
	run("Subtract Background...", "rolling=50");
	run("Split Channels");
	imageCalculator("Add create 32-bit stack", "C1-DUPE","C2-DUPE");
	selectWindow("Result of C1-DUPE");

	// Clear out any previous ROIs in the manager
	makeRectangle(280, 242, 21, 32); // meaningless random square
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Delete");
	run("Select None");
	resetThreshold();
	
	// For each Z slice, take threshold and create a selection.
	// This gets added to the manager. At the end, you'll have 
	// The same number of ROIs as you do Z-slices.   
	for (i=1; i<=s; i++) {
		Stack.setSlice(i);
		setAutoThreshold("Huang dark no-reset stack");
		run("Create Selection");
		if(getValue("selection.size")!=0) {
			roiManager("Add");
			n = roiManager('count')-1;
			roiManager("Select", n);
			roiManager("Update")
			run("Select None");
		}
		// If thresholding captures zero pixels, still add 
		// a single pixel to the manager (it's fine, it's just 
		// one pixel!)
		else {
			makeRectangle(0,0,1,1); //
			roiManager("Add");
			n = roiManager('count')-1;
			roiManager("Select", n);
			roiManager("Update")
			run("Select None");
		}
	}

	// Close extra windows, and apply a gaussian blur to both channels.
	// This is so the background of the ratiometric image isn't a bunch of 
	// NaNs from all the "Divide By Zero" errors. 
	// Then, create the ratiometric image (note that it is 32-bit). 
	close("Result of C1-DUPE");
	selectWindow("C1-DUPE");
	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
	selectWindow("C2-DUPE");
	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
	imageCalculator("Divide create 32-bit stack", "C1-DUPE","C2-DUPE");
	selectWindow("Result of C1-DUPE");
	
	// aesthetics... 
	run("mpl-magma");
	setMinAndMax(0.60, 1.60);
	
	// Save XY coordinates into the originally chosen directory
	// Filenames are padded with zeros, and appended with Z slice number.
	// Each file contains every pixel within the selection, as well as its position.  
	// Then, closes all the extra images. 
	n = roiManager('count');
	for (k = 0; k < n; k++) {
		roiManager('select', k);
		fileName = dir+"XY-"+leftPad(k+1,3)+".csv";
		run("Save XY Coordinates...", "save="+fileName);
	}
	run("Select None");
	close("Result of C1-DUPE");
	close("C1-DUPE");
	close("C2-DUPE");
	close("DUPE");
}
