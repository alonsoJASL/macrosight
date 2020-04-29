function [ccode] = getclumpcode(labelsinvector)
% GET CLUMP CODE. Get code assigned to clump based on the labels of the
% nuclei found within it. 

ccode = uint64(0);
uintsorted = uint64(sort(labelsinvector));

for kx=1:length(uintsorted)
    ccode = ccode + uintsorted(kx)*(1000)^(kx-1); 
end