function [regs, outX] = macregionprops(x, whichX)
% CUSTOM REGIONPROPS. Forget about coding exactly what you're computing!
%
% USAGE:
%         [regs] = macregionprops(x);
% equivalent to doing:
%          regs = regionprops(x>0, 'BoundingBox', 'Perimeter', 'Area',...
%            'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity');
%
% Or, you can also try:
%
%          [regs] = macregionprops(x, whichX);
%
% which is equivalent to:
%
%          regs = regionprops(x==whichX, 'BoundingBox', 'Perimeter', 'Area',...
%            'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity');
%
% in case you want the regionprops of a particular labelled object.
%

if nargin == 1
    singleX = x>0;
    regs = regionprops(x>0, 'BoundingBox', 'Perimeter', 'Area',...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', ...
        'Solidity', 'Orientation');
elseif nargin == 2
    singleX = x==whichX;
    regs = regionprops(singleX, 'BoundingBox', 'Perimeter', 'Area',...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', ...
        'Solidity', 'Orientation');
else
    fprintf('%s: ERROR. Wrong input. Try: \n\n\t help macregionprops',...
        mfilename);
    regs = [];
    return;
end

[regs(:).circularity] = deal(0);
for ix=1:length(regs)
    regs(ix).circularity = (4*pi).*(regs(ix).Area./(regs(ix).Perimeter.^2));
end

if nargout > 1
    outX = singleX;
end