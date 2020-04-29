function [padstr] = num2padstr(num, pad)
% NUMBER TO PADDED STRING. Helpful for experiments. 
%
% USAGE: 
%           [padstr] = num2padstr(num, pad)
%           [padstr] = num2padstr(num)
%
% By default pad=3. 
%
% Example: 
%           num2str(4) returns '4', while 
%           num2padstr(4) returns '004'
%           num2padstr(4,10) returns '0000000004'
% 
if nargin < 2
    pad=3;
end

padstr = num2str(num);
if length(padstr)<pad
    for ix=1:(pad-length(padstr))    
        padstr = strcat('0',padstr);
    end
end
