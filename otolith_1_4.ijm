
macro "Otolith detection" {
//getting file and Dir List:
	dir1 = getDirectory("Choose source directory "); 		
	list = getFileList(dir1);								
	dir2 = getDirectory("Choose destination directory ");	
//Option dialog:
	Dialog.create("Options");
	Dialog.addCheckbox("Save binary shape Drawing", true);
	Dialog.addCheckbox("Save Outline indication", true);
	Dialog.addCheckbox("Use batch mode ", false);
	Dialog.addCheckbox("Save a log file ", false);
	Dialog.addChoice("which type of detection?: ", newArray("simple", "reflection corrected", "abstract"),"reflection corrected");
	Dialog.show();
	SP = Dialog.getCheckbox();		
	OL = Dialog.getCheckbox();	
	batch = Dialog.getCheckbox();
	logg = Dialog.getCheckbox();	
	Meth = Dialog.getChoice();
	
//Make folders:
	SHAPE = dir2 + "SHAPE" + File.separator;
	OUT = dir2 + "OUTLINE" + File.separator;
	if (SP==true){
		File.makeDirectory(SHAPE);	
	}
	if (OL==true){
		File.makeDirectory(OUT);	
	}
//CLEAN:
	run("Close All");
	print("\\Clear");
	print("Reset: log, Results, ROI Manager");
	run("Clear Results");
	updateResults;
	roiManager("reset");
	while (nImages>0) {
		selectImage(nImages);
		close();
	}
//Set and start:
	if (batch==true){
		setBatchMode(true);
		print("_");
		print("running in batch mode");
	}
	run("Set Measurements...", "area centroid perimeter shape feret's redirect=None decimal=4");
//counter for report
	N=0;
	nImg=0;
	r="0";
	if(Meth=="simple"){
	//Simple:
		print("detection type:"+Meth+"");
		r="s";
			for (i=0; i<list.length; i++) {						
				path = dir1+list[i];	
				roiManager("reset");						
				print("start processing of "+path+"");
				getDateAndTime(year, month, week, day, hour, min, sec, msec);
				print("Starting detection at: "+day+"/"+month+"/"+year+" :: "+hour+":"+min+":"+sec+"");
				N=N+1;
				nImg=list.length;
				open(path);
				title1= getTitle;
				title2 = File.nameWithoutExtension;
				print("opened image "+N+"/"+nImg+": "+title1+"");
				run("Duplicate...", " ");
				titleS= getTitle;
				print("tresholding using AutoThreshold:Triangle");
				setAutoThreshold("Triangle dark");
				setThreshold(6, 255);
				run("Convert to Mask");
				print("otolith detection [150000-infinity; circularity=0.0001-1.00");
				run("Analyze Particles...", "size=150000-Infinity circularity=0.0001-1.00 show=Outlines include add");
				selectWindow(""+titleS+"");
				roiManager("Select", 0);
				print("Measure");
				roiManager("Measure");
				selectWindow(""+title1+"");
				setResult("File", nResults-1, getTitle());
				updateResults();
				if(OL==true){
					print("saving Outline indication");
					selectWindow(""+title1+"");
					run("Enhance Contrast", "saturated=0.35");
					roiManager("Deselect");
					roiManager("Select", 0);
					run("Flatten");
					saveAs("jpg", OUT+title2+"_s_OL.jpg");
					close();
					print("exported binary "+title2+"_s_OL.jpg to folder"+OUT+"");
					print("_");
				}else {
					selectWindow(""+title1+"");
					close();
					print("_");
				}
				if(SP==true){
					print("_");
					print("saving binary shape Drawing");
					selectWindow(""+titleS+"");
					roiManager("Select", 0);
					run("Clear", "slice");
					run("Colors...", "foreground=white background=black selection=magenta");
					roiManager("Select", 0);
					run("Clear Outside");
					roiManager("Deselect");
					roiManager("Show None");
					saveAs("jpg", SHAPE+title2+"_s_bin.jpg");
					close();
					print("exported binary "+title2+"_s_bin.jpg to folder"+SHAPE+"");
				}else {
					selectWindow(""+titleS+"");
					close();
				}
				print(""+title1+" measured");
				print("_");
				while (nImages>0) {
					selectImage(nImages);
					close();
				}
				run("Colors...", "foreground=black background=white selection=magenta");
			}
	} else if (Meth=="reflection corrected"){
	//Reflection corrected:
		print("detection type:"+Meth+"");
		r="c";
		for (i=0; i<list.length; i++) {						
			path = dir1+list[i];	
			roiManager("reset");						
			print("start processing of "+path+"");
			getDateAndTime(year, month, week, day, hour, min, sec, msec);
			print("Starting detection at: "+day+"/"+month+"/"+year+" :: "+hour+":"+min+":"+sec+"");
			N=N+1;
			nImg=list.length;
			open(path);
			title1= getTitle;
			title2 = File.nameWithoutExtension;
			print("opened image "+N+"/"+nImg+": "+title1+"");
			run("Duplicate...", " ");
			titleS= getTitle;
			run("Duplicate...", " ");
			setAutoThreshold("Shanbhag dark");
			setThreshold(210, 255);
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Dilate");
			run("Analyze Particles...", "size=2000-200000 circularity=0.01-1.00 show=Outlines include add");
			roiManager("Select", newArray());
			ROIc = roiManager("count");
			if (ROIc!=1) {
				roiManager("select", newArray());
				roiManager("Combine");
				roiManager("Add");
			}
			ROIc = roiManager("count");
			while (ROIc!=1) {
				roiManager("select", 0);
				roiManager("delete");
				ROIc = roiManager("count");
			}
			selectWindow(""+titleS+"");
			roiManager("Select", 0);
			run("Enlarge...", "enlarge=10");
			run("Clear", "slice");
			run("Invert");
			roiManager("reset");		
			selectWindow(""+titleS+"");
			run("Select None");
			run("Enhance Contrast", "saturated=0.35");
			print("tresholding using AutoThreshold:Triangle");
			setAutoThreshold("Triangle dark");
			setThreshold(11, 255);
			run("Convert to Mask");
			run("Erode");
			run("Gaussian Blur...", "sigma=2");
			run("Mean...", "radius=5");
			setAutoThreshold("Shanbhag dark");
			setThreshold(224, 255);
			run("Convert to Mask");
			run("Fill Holes");
			run("Dilate");
			run("Close-");
			print("otolith detection [150000-infinity; circularity=0.10-1.00");
			run("Analyze Particles...", "size=150000-Infinity circularity=0.10-1.00 show=Outlines include add");
			selectWindow(""+titleS+"");
			roiManager("Select", 0);				
			print("Measure");
			roiManager("Measure");
			selectWindow(""+title1+"");
			setResult("File", nResults-1, getTitle());
			updateResults();
			if(OL==true){
				print("saving Outline indication");
				selectWindow(""+title1+"");
				run("Enhance Contrast", "saturated=0.35");
				roiManager("Deselect");
				roiManager("Select", 0);
				run("Flatten");
				saveAs("jpg", OUT+title2+"_c_OL.jpg");
				close();
				print("exported binary "+title2+"_c_OL.jpg to folder"+OUT+"");
				print("_");
			}else {
				selectWindow(""+title1+"");
				close();
				print("_");
			}
			if(SP==true){
				print("_");
				print("saving binary shape Drawing");
				selectWindow(""+titleS+"");
					roiManager("Select", 0);
					run("Clear", "slice");
					run("Colors...", "foreground=white background=black selection=magenta");
					roiManager("Select", 0);
					run("Clear Outside");
					roiManager("Deselect");
					roiManager("Show None");
				saveAs("jpg", SHAPE+title2+"_c_bin.jpg");
				close();
				print("exported binary "+title2+"_c_bin.jpg to folder"+SHAPE+"");
			}else {
				selectWindow(""+titleS+"");
				close();
			}
			print(""+title1+" measured");
			print("_");
			while (nImages>0) {
				selectImage(nImages);
				close();
			}
			run("Colors...", "foreground=black background=white selection=magenta");	
		}
		} else if (Meth=="abstract") {
		//abstract:
			print("detection type:"+Meth+"");
			r="a";
			for (i=0; i<list.length; i++) {						
				path = dir1+list[i];	
				roiManager("reset");						
				print("start processing of "+path+"");
				getDateAndTime(year, month, week, day, hour, min, sec, msec);
				print("Starting detection at: "+day+"/"+month+"/"+year+" :: "+hour+":"+min+":"+sec+"");
				N=N+1;
				nImg=list.length;
				open(path);
				title1= getTitle;
				title2 = File.nameWithoutExtension;
				print("opened image "+N+"/"+nImg+": "+title1+"");
				run("Duplicate...", " ");
				titleS= getTitle;
				run("Duplicate...", " ");
				setAutoThreshold("Shanbhag dark");
				setThreshold(210, 255);
				setOption("BlackBackground", true);
				run("Convert to Mask");
				run("Dilate");
				run("Analyze Particles...", "size=2000-200000 circularity=0.01-1.00 show=Outlines include add");
				roiManager("Select", newArray());
				ROIc = roiManager("count");
				if (ROIc!=1) {
					roiManager("select", newArray());
					roiManager("Combine");
					roiManager("Add");
				}
				ROIc = roiManager("count");
				while (ROIc!=1) {
					roiManager("select", 0);
					roiManager("delete");
					ROIc = roiManager("count");
				}
				selectWindow(""+titleS+"");
				roiManager("Select", 0);
				run("Enlarge...", "enlarge=10");
				run("Clear", "slice");
				run("Invert");
				roiManager("reset");		
				selectWindow(""+titleS+"");
				run("Select None");
				run("Enhance Contrast", "saturated=0.35");
				print("tresholding using AutoThreshold:Triangle");
				setAutoThreshold("Triangle dark");
				setThreshold(11, 255);
				run("Convert to Mask");
				run("Erode");
				run("Gaussian Blur...", "sigma=2");
				run("Mean...", "radius=5");
				setAutoThreshold("Shanbhag dark");
				setThreshold(224, 255);
				run("Convert to Mask");
				run("Fill Holes");
				run("Dilate");
				run("Close-");
				print("otolith detection [150000-infinity; circularity=0.10-1.00");
				run("Analyze Particles...", "size=150000-Infinity circularity=0.10-1.00 show=Outlines include add");
				selectWindow(""+titleS+"");
				roiManager("Select", 0);	
				run("Convex Hull");	
				roiManager("Add");
				roiManager("Select", 0);
				roiManager("Delete");
				roiManager("Select", 0);
				print("Measure");
				roiManager("Measure");
				selectWindow(""+title1+"");
				setResult("File", nResults-1, getTitle());
				updateResults();
				if(OL==true){
					print("saving Outline indication");
					selectWindow(""+title1+"");
					run("Enhance Contrast", "saturated=0.35");
					roiManager("Deselect");
					roiManager("Select", 0);
					run("Flatten");
					saveAs("jpg", OUT+title2+"_a_OL.jpg");
					close();
					print("exported binary "+title2+"_a_OL.jpg to folder"+OUT+"");
					print("_");
				}else {
					selectWindow(""+title1+"");
					close();
					print("_");
				}
				if(SP==true){
					print("_");
					print("saving binary shape Drawing");
					selectWindow(""+titleS+"");
					roiManager("Select", 0);
					run("Clear", "slice");
					run("Colors...", "foreground=white background=black selection=magenta");
					roiManager("Select", 0);
					run("Clear Outside");
					roiManager("Deselect");
					roiManager("Show None");
					saveAs("jpg", SHAPE+title2+"_a_bin.jpg");
					close();
					print("exported binary "+title2+"_a_bin.jpg to folder"+SHAPE+"");
				}else {
					selectWindow(""+titleS+"");
					close();
				}
				print(""+title1+" measured");
				print("_");
				while (nImages>0) {
					selectImage(nImages);
					close();
				}
				run("Colors...", "foreground=black background=white selection=magenta");
			}
		}
	print("saving results");
	print("_");
	saveAs("Results", ""+dir2+"/"+r+"Results.xls");
//report
	if(logg==true){
		selectWindow("Log");
		saveAs("Text", ""+dir2+"/log_otoliths_"+day+"-"+month+"-"+year+"_"+hour+"h"+min+"min.txt");
	}
	print("finished measurements at: "+day+"/"+month+"/"+year+" :: "+hour+":"+min+":"+sec+"");
	print("_");
	while (nImages>0) {
		selectImage(nImages);
		close();
	}
	waitForUser(" Processed "+N+" images. See Folder: "+dir2+"");
}
//Jens_15.05.20
