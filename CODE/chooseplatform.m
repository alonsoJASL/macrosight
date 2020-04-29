function [platformused] = chooseplatform()
% CHOOSE PLATFORM. Returns 'linux', 'mac' or 'win' depending on the
% operating system.
% 

test = isunix + ismac;

switch test
    case 0
        platformused = 'win';
    case 1
        platformused = 'linux';
    case 2
        platformused = 'mac';
end