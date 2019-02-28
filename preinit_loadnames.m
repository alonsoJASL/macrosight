
for whichmacro =1:5
 
    [dn,dsets] = loadnames('kclmacros', chooseplatform);
    ds = dsets.control{whichmacro};
    handlesdir = getMatFolders(fullfile(dn,ds));
    
    fprintf('Starting CONTROL [%d] data reduction and segmentation:\n',...
        whichmacro);
    preinit_segmentation;

    ds = dsets.mutant{whichmacro};
    handlesdir = getMatFolders(fullfile(dn,ds));

    fprintf('Starting MUTANT [%d] data reduction and segmentation:\n',...
        whichmacro);
    preinit_segmentation;
end

for whichmacro =6:11
    
    [dn,dsets] = loadnames('kclmacros', chooseplatform);
    ds = dsets.mutant{whichmacro};
    handlesdir = getMatFolders(fullfile(dn,ds));
    
    preinit_segmentation;
end

%% 
% 126, 159

for ix=1:handles.numFrames
clc;
disp(ix);
curr = load(['F:\KCL_MACROPHAGES\CONTROL01_mat_La\T' num2padstr(ix,4) '.mat']);
curr2 = load(['F:\KCL_MACROPHAGES\CONTROL01_mat_Re\T' num2padstr(ix,4) '.mat']);

try 
    imagesc(curr.dataL+curr.dataG);
    title(num2padstr(ix));
    pause(0.5);
catch
    disp('fixing...')
    options.methodUsed = 'clump';
    options.parameters = [];
    options.foldername = 'La';
    hhla = rgbdataprocessing(['F:\KCL_MACROPHAGES\CONTROL01_mat_Re\T' ...
        num2padstr(ix,4) '.mat'], options);
    
    fixedcurr = load(['F:\KCL_MACROPHAGES\CONTROL01_mat_La\T' num2padstr(ix,4) '.mat']);
    
end
end