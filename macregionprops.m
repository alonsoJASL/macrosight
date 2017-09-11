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
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity'); 
elseif nargin == 2
    singleX = x==whichX;
    regs = regionprops(singleX, 'BoundingBox', 'Perimeter', 'Area',...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength', 'Solidity');
else 
    fprintf('%s: ERROR. Wrong input. Try: \n\n\t help macregionprops',...
        mfilename);
    regs = [];
end

if nargout > 1
    outX = singleX;
end