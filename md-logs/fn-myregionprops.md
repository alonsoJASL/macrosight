# Custom region props: `macregionprops`
[This](../macregionprops.m) function is used primarily in functions
[`getKnownTracksVariables`](../getKnownTracksVariables.m) and
[`updateKnownFrame`](../updateKnownFrame.m), where the same calculations
are made many times.

This is a simple function to compute the region props in a customised way to
make the code more readable, understandable, and to have a single point of
change if a need to change the region properties to be computed.
```Matlab
function [regs] = macregionprops(x, whichX)
% CUSTOM REGIONPROPS. Forget about coding exactly what you're computing!

if nargin == 1
    regs = regionprops(x>0, 'BoundingBox', 'Perimeter', 'Area',...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity');
elseif nargin == 2
    regs = regionprops(x==whichX, 'BoundingBox', 'Perimeter', 'Area',...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity');
else
    fprintf('%s: ERROR. Wrong input. Try: \n\n\t help macregionprops',...
        mfilename);
    regs = [];
end
```
Running this routine is simple:
```Matlab
[regs] = macregionprops(x);
```
is equivalent to doing:
```Matlab
regs = regionprops(x>0, 'BoundingBox', 'Perimeter', 'Area',...
    'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity');
```
Alternatively, you can also try:
```Matlab
[regs] = macregionprops(x, whichX);
```
which, in turn, is equivalent to:
```Matlab
regs = regionprops(x==whichX, 'BoundingBox', 'Perimeter', 'Area',...
    'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity');
```
in case you want the `regionprops` of a particular labelled object.
