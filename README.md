# macrosight
[![View macrosight on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/75292-macrosight)
## A MATLAB package for the analysis of overlapping macrophages
This code is based on the [phagosight](https://github.com/phagosight/phagosight)
software, but modules for the analysis of overlapping cells within a video sequence
have been added. For more detailed explanations, developer logs and explanations of 
routines, we are building a [wiki](https://github.com/alonsoJASL/macrosight/wiki).

## Installation
To clone this repository use the following command:
```bash
git clone https://github.com/alonsoJASL/macrosight/
```

To configure the paths automatically, **inside Matlab**, run the command
`configureMacrosight`. If you have @phagosight, then the configuration will
walk you through adding it to your path. Otherwise, you can choose not to use
it.

## Quick start
The best way to see Macrosight's functionalities is through the demos. In
Matlab run
```Matlab
macrosight_demo
```
to get a list of ready-made examples of the software functionalities:
```
macrosight_demo
[MACROSIGHT_DEMOS] Select the demo from the list:
[1] Select contact events - save to xls.
[2] Load from saved data - plot results
[3] Load from saved data - statistical analysis
[9] Demo tidy function
[C] Cancel
Your choice [default=1]:
```

### Quick start using phagosight functionalies (from scratch)
Tracking needs PhagoSight, clone it with the
command:
```bash
git clone https://github.com/phagosight/phagosight/
```
and then in Matlab run `configureMacrosight`.

Macrosight takes images stored in a hard drive, and saves the output to other
folders following a specific naming scheme. For **segmentation**, see the file [`preinit_segmentation.m`](./CODE/pre-release-scripts/preinit_segmentation.m).
This script arranges the data into the cooresponding output folders
+ `_data_Ha`
+ `_data_Re`
+ `_data_La`

**Tracking** and inclusion of **clump information**, is done with the setup
function: [`setupInitialStructures.m`](./CODE/setupInitialStructures.m).
The function allows the user to select an experiment and continue on a
previously loaded dataset.

```Matlab
[tablenet, clumptracktable, clumpidcodes, ~] = setupInitialStructures();
```

## Troubleshooting and questions
Macrosight is an ongoing project at an early stage. We welcome all feedback and
comments in the [issues](https://github.com/alonsoJASL/macrosight/issues)
page.
