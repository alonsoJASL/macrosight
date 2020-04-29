function [V, Vtxt] = getvectorandtext(T, str)
% helper function. 
if strcmpi(str, 'aspectratio')
    V = T.MinorAxisLength ./ T.MajorAxisLength;
    Vtxt = 'aspect ratio';
else
    V = T.(str);
    Vtxt = str;
end
end