# cell_confluency

Cell Segmentation and Confluency Estimates

To Run MATLAB code:
1) Run the script at matlab_code/egt_source_code/Edge_Detection_GUI_v1.m
2) A GUI should appear.
3) Enter the path to your data in the "Raw Images Path" text box (note: only .tif, .png, and .jpg  files are currently supported)
4) Enter a common name for your files in the "Raw Common Name" text box, without the image extension.
   For example: if you have files named ["File A.tif", "File B.tif", "File C.tif"], then a common name could be "File" 
5) Click "Load Images" to run

Please see a much more detailed explanation of the functions and parameters in the file at: cell_confluency_project/matlab_code/egt_source_code/Edge_Detection_Readme.txt

This uses the EGT Segmentation algorithm and software developed at the NIST:
https://isg.nist.gov/deepzoomweb/resources/csmet/pages/EGT_segmentation/EGT_segmentation.html
