% Analysis of interactions project:
% Review a certain dataset looking for interactions.
%
%% INITIALISATION
tidy
% choose 1,2, or 3
whichmacro=1;
initscript;
S = 5;
%%
ix=1;
wuc = clumpidcodes(ix);

clc;
fprintf('Analysing clump %d\n', wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);

if length(clumplab)==2
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    
    for jx=1:length(clumplab)
        trinf{jx} = trackinfo(trackinfo.finalLabel==clumplab(jx),:);
    end
    
    % frames in common
    capt = intersect(trinf{1}.timeframe, trinf{2}.timeframe);
    % time frames in clump
    tfc = unique(trackinfo(trackinfo.clumpcode==wuc,1).timeframe);
    % time frames single
    tfs = unique(trackinfo(trackinfo.clumpcode==0,1).timeframe);
    tfs(tfs>max(capt)) = [];
    tfs(tfs<min(capt)) = [];
    
    brtfc = find(diff(tfc)>1);
    brtfs = find(diff(tfs)>1);

    winfc = [[1;brtfc+1] [brtfc;length(tfc)]];
    winfs = [[1;brtfs+1] [brtfs;length(tfs)]];
    
    disp('In clump: ')
    disp(tfc(winfc));
    try 
    disp('Single: ')
    disp(tfs(winfs));
    catch
    end
    
    fprintf('Cell labels: %d and %d')
    disp(trackinfo(ismember(trackinfo.timeframe,(max(1,tfc(1)-S)):(tfc(end)+S)),:));
    
else
    disp('Only working on clumps with two cells') 
end

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
    
    
    pre_init = mT.initialframe - 5;
    pre_fin = mT.clumpinit;
    post_init = mT.clumpfin;
    post_fin = mT.finalframe + 5;
    
    disp(mT.whichclump)
    fprintf('\n Pre-clump: %d and %d', pre_init, pre_fin);
    disp(trackinfo(ismember(trackinfo.timeframe,pre_init:pre_fin),:));
    
    fprintf('\n Post-clump: %d and %d', post_init, post_fin);
    disp(trackinfo(ismember(trackinfo.timeframe,post_init:post_fin),:));
    
    pause;
end



