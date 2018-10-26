Disclaimer:  IMPORTANT:  This software was developed at the National Institute of Standards and Technology by employees 
of the Federal Government in the course of their official duties. Pursuant to title 17 Section 105 of the United States 
Code this software is not subject to copyright protection and is in the public domain. This is an experimental system. 
NIST assumes no responsibility whatsoever for its use by other parties, and makes no guarantees, expressed or implied, 
about its quality, reliability, or any other characteristic. We would appreciate acknowledgment if the software is used. 
This software can be redistributed and/or modified freely provided that any derivative works bear some notice that they 
are derived from it, and any modified versions bear some notice that they have been modified.

Modified by: Govin Vatsan, Georgia Institute of Technology, 2018.

****************************************************************
Package Manifest:
imgs/
	NIST_Logo.tif
src/
	EGT_Segmentation.m
	exportGrowthRates.m
	fill_holes.m
	find_edges.m
	find_edges_labeled.m
	modelGrowthRate.m
	percentile_computation.m
	predictGrowthRate.m
	print_to_command.m
	print_update.m
	superimpose_colormap_contour.m
	validate_filepath.m
Edge_Detection_GUI_v1.m
Edge_Detection_Readme.txt


****************************************************************
Instructions
- Download Matlab (requires the "Image Processing" and "Statistics and Machine Learning" toolboxes)
- Navigate Matlab's current folder menu to folder containing "Edge_Detection_GUI_v1.m"
- Run Edge_Detection_GUI_v1.m (make sure all subfolders are added to the path)
- Enter the path to your data in the "Raw Images Path" text box (note: only .tif, .png, and .jpg files are currently supported)
- Enter a common name for your files in the "Raw Common Name" text box, without the image extension. For example: if you have files named ["File A.tif", "File B.tif", "File C.tif"], then a common name could be "File"
- Click "Load Images" to run

****************************************************************
Image Folder Parameters
Raw Images Path
	The directory path to the input images to be segmented.
Raw Common Name
	The common name for the images to be segmented

Segmentation Parameters
Min Cell Area
	The minimum object (cell) area in pixels to be considered valid. Objects smaller than this will be set to background.
Fill Holes Smaller Than
	Minimum area of a hole in the image, in pixels, for that hole to be kept. All holes smaller than this will be removed by setting them to foreground. A hole in the image is a region of background that is not 4 connected to the edge of the image.
Erosion
    Removes pixels on the boundaries of objects (will reduce segmentation sizes)
Dilation
    Adds pixels to the boundaries of objects (will increase segmentation sizes)
Additional Morphological Operation
	Select a morphological operation to be applied after the initial binary segmented image has been created. This morphological operation can be used to clean up the resulting segmentation.
	Operations:	
		None
		Dilate
		Erode
		Open: erode followed by a dilate
		Close: dilate followed by an erode
Note: rad/radius is:
   The radius of the structuring element to be used in the morphological operation. All structuring elements are disks.
   A higher radius means a more powerful operation. 
   For example a disk of radius 1 would look as follows
    0 1 0
    1 1 1
    0 1 0
Greedy
	Controls how greedy foreground is with respect to background. If the segmentation is missing some background, increasing the greedy parameter in the positive direction will result in more image are being considered foreground.
	
Display Parameters
ColorMap
	The colormap to use to display the image being segmented
Label Image
	Select this if you want the output segmentation to be labeled objects instead of binary
Display Contour
	Displays just the exterior contour of the segmented foreground regions
Display Raw Image
	Will display the input raw image behind the segmented results. This is useful, along with Display Contour, to determine the quality of segmentation
Adjust Contrast 
    Increases the contrast of the image on display
Show Labels
	Display the object label numbers on the image
Color Dropdown (Red by default)
	This controls the color used to display foreground in the segmented image; if Label Image is not selected.
Orig. Image
    Shows the original image, without any contour or segmentation

Output Parameters
Save Segmented Images (button)
	This will launch the save dialog, allowing the specification of output parameters and specifying where to save the segmented images

    Format
        The file format to save the images in
    Range
        The range of image numbers to save
    Type
        Save the binary foreground mask or the displayed image (colormap, contour, etc, options preserved)
	
Export Confluency Table (button)
    This exports a CSV file containing the estimated confluencies of all selected images, using the current parameters specified.

    Save Name
        Name of CSV file
    Range
        The range of image numbers to save
    Data Source
        Data source for all confluencies being estimated

Export Growth Rates (button)
    This calculates and saves a fitted growth rate function for all selected images, where selected images
    are grouped by their common name.

    Range
        The range of image numbers to save

Show Growth Rate (button)
    This shows a fitted growth rate function for the current image and all other images in the selected image
    set with the same common name 
	
****************************************************************
Optimal Parameters
180328_121909_GMP047, 180328_125817_GMP007 P1-P2, 180404_121829_GMP007, 180404_123306_GMP087
4x : MCA = 650px, FHST = 500px, Erosion = 1, Dilation = 0, Additional Erosion = 4, Greedy = 0
10x: MCA = 2750px, FHST = 2000px, Erosion = 1, Dilation = 0, Additional Erosion = 4, Greedy = 0

180328_123423_RB137, 180328_124322_RB049-RB182, 180404_124147_RB037
4x : MCA = 650px, FHST = 500px, Erosion = 1, Dilation = 0, Additional Erosion = 2, Greedy = 0
10x: MCA = 2750px, FHST = 2000px, Erosion = 1, Dilation = 0, Additional Erosion = 2, Greedy = 0

181005_124727_RB177 RB183 6WP: MCA: 3000, FHST: 2750, Erosion = 2, Dilation = 2, Additional Erosion: 6, Greedy = -1
