macro "First Frame [F3]" {
	Stack.getDimensions(w,h,c,s,f);
	Stack.setFrame(1);
}

macro "Last Frame [F4]" {
	Stack.getDimensions(w,h,c,s,f);
	Stack.setFrame(f);
}


macro "Back to start [F1]" {
setSlice(1);
makeRectangle(1, 1, 10, 10);
roiManager("add");
roiManager("Deselect");
roiManager("Delete");
run("Clear Results");
}

macro "Interpolate ROIs [F2]" {
	/*  Start by filling the ROI manager with ROIs. For each frame where
	 *  the cell has moved, move the ROI and add it. 
	 *  The script interpolates the positions 
	 */

	Stack.getDimensions(w,h,c,s,f);
	// Duplicate so nothing happens to the main image.
	//run("Duplicate...", "title=temp duplicate");
	// Background substract the first image (will transfer to the second)
	//run("Subtract Background...", "rolling=50 stack");
	// Each frame needs an ROI
	roi_count = roiManager("count");
	frame_rois = newArray(f);
	last_frame = -1;
	last_x = -1;
	last_y = -1;
	index = 0;
	for (i = 0; i < roi_count; i++) {
    	roiManager('select', i);
    	Roi.getBounds(x, y, w, h);
    	isHyper = Stack.isHyperstack;
		if (isHyper){
			Roi.getPosition(channel, slice, frame);
		}
		else {
			Roi.getPosition(channel, slice, frame);
			//print(channel, slice, frame);
			frame = slice;
		}
    	
    	frame_rois[frame-1] = i;
    	
    	if (last_frame==-1) {
    		last_x = x;
    		last_y = y;
    		last_frame = frame;
    		roiManager("add");
    	}
    	else {
    		new_rois = frame-last_frame;
    		if (new_rois > 1) {
    			for (j=0; j<new_rois-1; j++) {
    				//print("Interp ROI: ",last_frame+j+1);
    				int_x = last_x + (x-last_x)/new_rois*(j+1);
    				int_y = last_y + (y-last_y)/new_rois*(j+1);
    				//int_y = last_y*(1-((int_x-last_x)/(x-last_x)))+y*(1-((x-int_x)/(x-last_x)));
    				if (isNaN(int_y)) {
    					print("NaN!!!!");
    					print(last_y,"*(1-((",int_x,"-",last_x,")/(",x,"-",last_x,")))+",y,"*(1-((",x,"-",int_x,")/(",x,"-",last_x,")))");
    					int_y = last_y;
    				}
    				//print(last_y,int_x,last_x,x,y,int_y);
    				Roi.move(int_x,int_y);
    				if (isHyper) {
    					Roi.setPosition(0,1,last_frame+j+1);
    				}
    				else {
    					Roi.setPosition(last_frame+j+1);
    				}
    				roiManager("add");
    				frame_rois[last_frame+j] = roi_count+index;
    				index++;
    			}
    		}
    		last_frame = frame;
			last_x = x;
			last_y = y;
    		index++;
    		roiManager('select', i);
    		roiManager("add");
    			
    	}
		//print("ROI: ",frame);
	}
	for (i = 0; i < roi_count; i++) {
    	roiManager('select', 0);
    	roiManager('Delete');
	}
	if (c>=1) {
		n = roiManager('count');
		for (j=1;j<=c;j++) {
			//print("CHANNEL ",j);
			for (k = 0; k < n; k++) {
		    	roiManager('select', k);
				Stack.setChannel(j);
				run("Measure");
			}
		}
	}
}