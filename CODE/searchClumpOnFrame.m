function [clumpcode, nucleiofclump] = searchClumpOnFrame(handles, fr)
% SEACRCH CLUMP ON FRAME. (Provided it exists) this code shows the 
% dataGL segmentation of frame fr inside handles and prompts
% the user to click on the clump he wants to find the code out of.
%
% [clumpcode, nucleiofclump] = searchClumpOnFrame(handles, fr);
%
filenames = dir(fullfile(handles.dataLa,'*.mat'));
filenames = {filenames.name};

[singleframe] = getdatafromhandles(handles, filenames{fr});

uiwait(warndlg('Select the CLUMP in the figure to get its unique code', ...
    'SELECT CLUMP'));
testIm = singleframe.clumphandles.overlappingClumps;

figure(66)
imagesc(testIm);
title('Click on the clump you want to analyse')
[qx, qy] = ginput(1);

val = testIm(fix(qy), fix(qx));
seglabels = unique((testIm==val).*singleframe.dataL);
seglabels(1) = [];

options.savebool = false;
options.outputpath = '.';
options.filename = 'fulldataset-nodenet.xlsx';
    
tablenet = nodenetwork2xls(handles.nodeNetwork(:,1:31),options);

idx = ismember(tablenet(tablenet.timeframe==fr,:).seglabel,seglabels);
nucleiofclump = tablenet(tablenet.timeframe==fr,:).finalLabel(idx);
clumpcode = getclumpcode(nucleiofclump);

close(66);