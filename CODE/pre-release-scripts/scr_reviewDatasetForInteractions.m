% Analysis of interactions project:
% Review a certain dataset looking for interactions.
%
%% INITIALISATION
% It is better to do the initialisation 
% tidy
% % choose 1,2, or 3
% whichmacro=2;
% initscript;

%%
S=5;

ix=1;
wuc = clumpidcodes(ix);
tablenetplusclumps = [tablenet clumptracktable];

[cicltable, winsclump] = displayCellsInClump(tablenetplusclumps, wuc, S);


%% CHECK FOR SINGLE MOVEMENTS
tidy
% choose 1,2, or 3
whichmacro=1;
initscript;
S = 5;

T = readtable('./macros123.xlsx');
if whichmacro==1
    T(~contains(upper(T.whichdataset), [ds(1:end-1) '1']),:) = [];
else
    T(~contains(upper(T.whichdataset), ds(1:end-1)),:) = [];
end

%clc;
%% 

for ix=1:size(T,1)
    clc;
    mT = T(ix,:);
    
    clumplab =  getlabelsfromcode(mT.whichclump);
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    
    
    pre_init = mT.initialframe - S;
    pre_fin = mT.clumpinit;
    post_init = mT.clumpfin;
    post_fin = mT.finalframe + S;
    
   
    disp(trackinfo(ismember(trackinfo.timeframe,pre_init:pre_fin),:));
    disp(trackinfo(ismember(trackinfo.timeframe,post_init:post_fin),:));
    
    disp(mT.whichclump)
    fprintf('\n Pre-clump: %d and %d', pre_init, pre_fin);
    fprintf('\n Post-clump: %d and %d', post_init, post_fin);
    
    fprintf('\n Pre-clump: %d\t%d\t%d\t%d\t%d\t%d',...
        pre_init,pre_fin,post_init+1,post_fin,pre_fin-pre_init,post_fin-post_init);
    pause;
end



