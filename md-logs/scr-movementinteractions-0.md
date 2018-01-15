# Movement and interactions of macrophages
This file follows the development of the script
[scr_movementandinteractions.m](../scr_movementandinteractions.m).
In this work, an analysis of the movement of the nuclei in the
**RED** channel will be made, focusing on the interactions that
happen before and after a couple of cells leave a clump.

This log will follow the development of the code. The overall flow
of the work should:
+ Initialise: through [initscript.m](../initscript.m) and by
  choosing a clump `whichclump`.
+ Choose the entries in `tablenet` that contain the tracks in
  `whichclump`. Get them into variable `trackinfo`.
+ Evaluate the tracks and choose an appropriate segment of the
  dataset that shows the cells before and after the clump.
+ Analyse the mean velocity before and after a certain amount of
  frames (10?, 100?, ...)
+ Analyse the direction before and after the clump.
