% MOVEMENT INTERACTION ANALYSIS: Script to display results of changes in
% direction from cell-cell contact. 
%
%% 

tidy;

whichmacro = 1; % 1, 2 or 3
initscript;

load('angleChanges');
T = readtable('./macros123.xlsx');
TS = readtable('./macros123singles.xlsx');

T(~contains(upper(T.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];
TS(~contains(upper(TS.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

vn = {'macros1', 'macros2', 'macros3'};
boxlabels = {'Clump size', 'Angle change'};
dsetID = [angleChangesWithInteraction.datasetID];

% Global variables to create generalised analysis.
for ix=1:length(experimentInfo.whichmacro)
    a.(vn{ix}) = angleChangesWithInteraction(dsetID==ix);
    noa.(vn{ix}) = angleNoInteraction(dsetID==ix);
    istats.(vn{ix}) = interactionStats(dsetID==ix);
end

Tab = [vertcat(interactionStats.clumpsize) ...
    vertcat(interactionStats.thx) ...
    vertcat(angleNoInteraction.angleChange)];
groups = ones(size(Tab));
groups(:,3) = 1.1;
groups = groups.*repmat(dsetID,1,3);

clumpsizes = vertcat(interactionStats.clumpsize);


%% General analysis
close all;
figure(1)
subplot(131)
boxplot(Tab(:,1), groups(:,1))
title('Clump size');
axis square;

subplot(132)
boxplot(abs([Tab(:,2);Tab(:,3)]), ...
    [groups(:,2);groups(:,3)]);
title('Angle change');
axis square;
%
subplot(133)
hold on
for ix=1:3
scatter(Tab(dsetID==ix,1), Tab(dsetID==ix,2))
xlabel('Clump size');
ylabel('angle change');
title('(c) MACROS2')
grid on
axis([0 80 0 200])
axis square;

end