% MOVEMENT INTERACTION ANALYSIS CHANGING TRACK LENGTHS: 
% Script to display results of changes in direction from cell-cell contact
% when changing the frames before and after contact. 
%
% The parameter changing is S.
%
% for general use, INITSCRIPT, or use INITSCRIP_DEV to automise things for
% you.
%% 
tidy;


whichmacro = 3; % 1, 2 or 3
initscript_dev;
%
load('angleChanges');
T = readtable('./macros123.xlsx');
TS = readtable('./macros123singles.xlsx');

T(~contains(upper(T.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];
TS(~contains(upper(TS.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

vn = {'macros1', 'macros2', 'macros3'};
markers = {'+','*','o'};
cc = {[0 0.53 0.79], [0.89 0.41 0.12], [.95 .74 .16]};
boxlabels = {'Clump size', 'Angle change'};
dsetID = [angleChangesWithInteraction.datasetID]';

% Global variables to create generalised analysis.
for ix=1:length(experimentInfo.whichmacro)
    a.(vn{ix}) = angleChangesWithInteraction(dsetID==ix);
    noa.(vn{ix}) = angleNoInteraction(dsetID==ix);
    istats.(vn{ix}) = interactionStats(dsetID==ix);
end

%% 
S = 5;


