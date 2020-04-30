% CONFIGURE MACROSIGHT SCRIPT
%
clc;

MACROHOME_ = pwd;
test_ = input(sprintf('Is this the right folder for macrosight? \n\t[%s]\n Y/N [Y]:',...
    MACROHOME_),'s');
if isempty(test_)
    test_='Y';
end
if strcmpi(test_, 'n')
    disp('Pick the location of Macrosight');
    pause(0.5);
    MACROHOME_ = uigetdir(pwd,'Pick a directory');
end

a_ = dir('..');
a_([a_.isdir]==0) = [];
a_(contains({a_.name}, '..')) = [];
b_ = fullfile(a_(1).folder, {a_.name}');
test_ = contains({a_.name}, 'phagosight', 'IgnoreCase', true);

if sum(test_) == 0
    disp('Is the folder containing Phagosight in the following list?');
    for ix=1:length(b_)
        fprintf('% d : %s\n', ix, b_{ix});
    end
    folderchoice_ = input('Choose the folder containing PhagoSight (press 0 if none is)');
else
    b_ = b_(test_);
    disp('Is the folder containing Phagosight in the following list?');
    fprintf('\n\tOPTIONS:\n\t[%d]: %s\n', 1, b_{1});
    for ix=2:length(b_)
        fprintf('\t%d: %s\n', ix, b_{ix});
    end
    folderchoice_ = input(sprintf(...
        '\nChoose the folder containing PhagoSight \n%s\n%s\n%s\n%s:__', ...
        '0 := it is not found', '1 := default', 'C := not using phagosight', 'Your choice'),'s');
end

if isempty(folderchoice_)
    folderchoice_ = '1';
end

if strcmpi(folderchoice_, 'c')
    mcrsght_info('Not using PhagoSight - some features might not work.', 'ATTENTION');
    fprintf('Adding the following to the MATLAB path:\n%s\n%s\n', ...
        fullfile(MACROHOME_, 'CODE'), ...
        fullfile(MACROHOME_, 'CODE', 'DEMOS'));
    
    addpath(fullfile(MACROHOME_, 'CODE'), ...
        fullfile(MACROHOME_, 'CODE', 'DEMOS'));
else
    
    if strcmpi(folderchoice_,'0') % not found
        disp('Pick the location of PhagoSight');
        pause(0.5);
        PHAGOHOME_ = uigetdir(MACROHOME_,'Pick a directory');
    else
        PHAGOHOME_ = b_{str2num(folderchoice_)};
    end
    fprintf('Adding the following to the MATLAB path:\n%s\n%s\n%s\n', ...
        fullfile(PHAGOHOME_, 'CODE'), ...
        fullfile(MACROHOME_, 'CODE'), ...
        fullfile(MACROHOME_, 'CODE', 'DEMOS'));
    
    addpath(fullfile(PHAGOHOME_, 'CODE'), ...
        fullfile(MACROHOME_, 'CODE'), ...
        fullfile(MACROHOME_, 'CODE', 'DEMOS'));
end



clear a_ b_ folderchoice_ ix test_;

