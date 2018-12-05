# macrosight
## A MATLAB package for the analysis of overlapping macrophages
This code is based on the [phagosight](https://github.com/phagosight/phagosight)
software, but modules for the analysis of overlapping cells within a video sequence
have been added.

## Quick start
A brief summary to start the analysis as quickly as possible.
### Requirements of the data
The macrophages dataset need to be in individual files, with the following naming 
convention: 
```
/path/to/data/MACROSN/T000ix.tif
```
where `N` corresponds to the nth experiment and  `ix` correspond to each image's 
identifier.

Functionalities will soon be included to prepare the data automatically.

### Quick start guide
Macrosight takes images storede in a hard drive, and saves the output to other
folders following a specific naming scheme. 

For **segmentation**, see the file [`preinit_segmentation.m`](../preinit_segmentation.m).
This script arranges the data into the cooresponding output folders
+ `_data_Ha`
+ `_data_Re`
+ `_data_La

**Tracking** and inclusion of **clump information**, is done in the initialisation
file: [`initscript.m`](../initscript.m). The file allows the user to select an 
experiment and continue on a previously loaded dataset.

## Troubleshooting and questions
Macrosight is an ongoing project at an early stage. We welcome all feedback and 
comments in the [issues](https://github.com/alonsoJASL/macrosight/issues) 
page.

## Log files
The log files kept for this package are not written for a full explanation, but
rather as a way to keep track of the developments made. So if there is some
problem with it, just ask me! The log files can be read in the following order:
+ [Shape analysis log](./md-logs/shapeanalysis-log.md)
+ [Single cell following log](./md-logs/shapeanalysis-singlecell.md), a
previous step from   __shape evolution__.
+ [Shape evolution](./md-logs/shapeevolution-log.md) **CURRENTLY under development**. 
Some of the images present can be hard to see, but the MATLAB fig or EPS files are 
present in the [`figs` folder](./figs).
+ (Original development, then switched approach to **shape evolution**)
[SOM shape evolution log](./md-logs/shapeandsom-log.md). This is not finalised.

Also, please notice that this research is ongoing, so bugs are likely to appear. 
Some of the functions might not be present, because they are part of another package
that has not been uploaded. 
If you are thinking of using our code, please feel free to submit any issues to the 
[issues page](https://github.com/alonsoJASL/macrosight/issues), so that small bugs are 
dealt with. 
