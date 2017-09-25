% script: Single shape evolution + shape analysis
%
%% INITIALISATION
initscript;

load DATASETHOLES
clumptracktable(ismember(tablenet.timeframe, DATASETHOLES),:) = [];
tablenet(ismember(tablenet.timeframe, DATASETHOLES),:) = [];
%% FOREACH TR IN TABLENET.FINALLABEL GET TRACKINFO(TR) TABLES

flabs = unique(tablenet.finalLabel);
flabfreq = zeros(length(flabs),1);
cllength = zeros(length(flabs),1);
alltracks = cell(length(flabs),1);

for ix=1:length(flabs)
    wuc = flabs(ix);
    % get labels from the clump
    clumplab = getlabelsfromcode(wuc);
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    flabfreq(ix) = size(trackinfo,1);
    cllength(ix) = sum(trackinfo.clumpcode>0);
    alltracks{ix} = trackinfo;
end
%% CHOOSE ONE TRACK AND SEPARATE INTO MANY SINGLE PATHS (TRACK >> PATH)
% NO OPTIONS

clc;
fid = fopen('fails.txt', 'a');
fprintf(fid,'\nERRORS FOR NO OPTIONS (NOTHING)');
fclose(fid);

%ix=2;
for ix=1:length(flabs)
    wuc=flabs(ix);
    trackinfo=alltracks{ix};
    
    [allpaths, wendys] = getpathsperlabel(wuc, trackinfo);
        
    outfolder = sprintf('%s_mat_TRACKS_lab%d-NOTHING',handlesdir.data, wuc);
    if ~isdir(fullfile(handlesdir.pathtodir, outfolder))
        fprintf('%s: Creating folder %s.\n', mfilename, outfolder);
        mkdir(fullfile(handlesdir.pathtodir, outfolder));
    end
    outtrackname = sprintf('label%dtracks-knwonfr', wuc);
    
    % from here, just choose a path and check the evolutions
    acopt=acoptions('nothing');
    for jx=1:length(allpaths)
        fprintf('\n%s: Analysing path=%d/%d from TRACK=%d\n',...
            mfilename, jx, length(allpaths), wuc);
        thispath = allpaths{jx};
        framet = thispath.timeframe(1);
        [knownfr] = getCommonVariablesPerFrame(handles, thispath, wuc, ...
            filenames{framet}, framet);
        try
        [kftr] = getKnownTracksVariables(knownfr, thispath, clumplab, 1);
        catch eee
            disp('oops');
        end
        
        frameinfo.X = knownfr.X;
        frameinfo.dataL = knownfr.dataL;
        frameinfo.dataGL = knownfr.dataGL;
        frameinfo.initboundy = [];
        frameinfo.outboundy = kftr.boundy;
        frameinfo.regs = kftr.regs;
        
        meta.typeevol = 'Normal';
        meta.acopts = acopt;
        meta.framet = framet;
        meta.fname = filenames{framet};
        
        save(fullfile(handlesdir.pathtodir, outfolder, ...
            sprintf('%s%d.mat',outtrackname,framet)),...
            'frameinfo', 'meta');
        try
            for tk=1:(size(thispath,1)-1)
                frametplusT = thispath.timeframe(tk+1);
                [ukfr] = getCommonVariablesPerFrame(handles, thispath, wuc, ...
                    filenames{frametplusT}, frametplusT);
                [newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
                %miniscript;
                
                frameinfo.X = knownfr.X;
                frameinfo.dataL = knownfr.dataL;
                frameinfo.dataGL = knownfr.dataGL;
                frameinfo.initboundy = newfr.movedboundy;
                frameinfo.outboundy = kftr.boundy;
                frameinfo.regs = kftr.regs;
                
                meta.typeevol = 'Normal';
                meta.acopts = acopt;
                meta.framet = frametplusT;
                meta.fname = filenames{frametplusT};
                
                save(fullfile(handlesdir.pathtodir, outfolder, ...
                    sprintf('%s%d.mat',outtrackname,frametplusT)),...
                    'frameinfo', 'meta');
            end
        catch e
            fid = fopen('fails.txt', 'a');
            fprintf(fid,'\nYa vali� barriga, Sr. V...:\n%s\n',...
                sprintf('err:%s\nflab%d, path%d, tk+1=%d',...
                e.message, wuc, jx, frametplusT));
            fclose(fid);
        end
    end
end


%% CHOOSE ONE TRACK AND SEPARATE INTO MANY SINGLE PATHS (TRACK >> PATH)
% MINISCRIPT (Changing options)
clc;
fid = fopen('fails.txt', 'a');
fprintf(fid,'\n\n\nERRORS FOR AC OPTIONS\n');
fclose(fid);

%ix=1;
for ix=1:length(flabs)
    wuc=flabs(ix);
    trackinfo=alltracks{ix};
    
    [allpaths, wendys] = getpathsperlabel(wuc, trackinfo);
    
    outfolder = sprintf('%s_mat_TRACKS_lab%d-ACOPTIONS',handlesdir.data, wuc);
    if ~isdir(fullfile(handlesdir.pathtodir, outfolder))
        fprintf('%s: Creating folder %s.\n', mfilename, outfolder);
        mkdir(fullfile(handlesdir.pathtodir, outfolder));
    end
    outtrackname = sprintf('label%dtracks-knwonfr', wuc);
    
    % from here, just choose a path and check the evolutions
    acopt=acoptions('grow');
    for jx=1:length(allpaths)
        fprintf('\n%s: Analysing path=%d/%d from TRACK=%d\n',...
            mfilename, jx, length(allpaths), wuc);
        
        thispath = allpaths{jx};
        framet = thispath.timeframe(1);
        [knownfr] = getCommonVariablesPerFrame(handles, thispath, wuc, ...
            filenames{framet}, framet);
        [kftr] = getKnownTracksVariables(knownfr, thispath, clumplab, 1);
        
        frameinfo.X = knownfr.X;
        frameinfo.dataL = knownfr.dataL;
        frameinfo.dataGL = knownfr.dataGL;
        frameinfo.initboundy = [];
        frameinfo.outboundy = kftr.boundy;
        frameinfo.regs = kftr.regs;
        
        meta.typeevol = 'AreaCtrl';
        meta.acopts = acopt;
        meta.framet = framet;
        meta.fname = filenames{framet};
        
        save(fullfile(handlesdir.pathtodir, outfolder, ...
            sprintf('%s%d.mat',outtrackname,framet)),...
            'frameinfo', 'meta');
        
        try
            for tk=1:(size(thispath,1)-1)
                frametplusT = thispath.timeframe(tk+1);
                [ukfr] = getCommonVariablesPerFrame(handles, thispath, wuc, ...
                    filenames{frametplusT}, frametplusT);
                %[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
                miniscript;
                
                [knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab);
                
                frameinfo.X = knownfr.X;
                frameinfo.tk = tk+1;
                frameinfo.dataL = knownfr.dataL;
                frameinfo.dataGL = knownfr.dataGL;
                frameinfo.initboundy = newfr.movedboundy;
                frameinfo.outboundy = kftr.boundy;
                frameinfo.regs = kftr.regs;
                
                meta.typeevol = 'AreaCtrl';
                meta.acopts = acopt;
                meta.framet = frametplusT;
                meta.fname = filenames{frametplusT};
                
                save(fullfile(handlesdir.pathtodir, outfolder, ...
                    sprintf('%s%d.mat',outtrackname,frametplusT)),...
                    'frameinfo', 'meta');
            end
        catch e
            fid = fopen('fails.txt', 'a');
            fprintf(fid,'\nYa vali� barriga, Sr. V...:\n%s\n',...
                sprintf('err:%s\nflab%d, path%d, tk+1=%d',...
                e.message, wuc, jx, frametplusT));
            fclose(fid);
        end
    end
end