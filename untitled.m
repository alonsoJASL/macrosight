%% 

initscript;

load DATASETHOLES;
clumptracktable(ismember(tablenet.timeframe, DATASETHOLES), :)=[];
tablenet(ismember(tablenet.timeframe, DATASETHOLES),:)=[];

rootdir = handlesdir.pathtodir;
%% 

a = dir(fullfile(handlesdir.pathtodir, [handlesdir.data '_mat_TRACKS_lab*']));
a = {a.name};
acnames = a(contains(a,'ACOPTIONS'));

acoutdir = fullfile(rootdir, [handlesdir.data '_mat_ACOPTIONS_FULL']);

if ~isdir(acoutdir)
    mkdir(acoutdir); 
end

for ix = 1:length(acnames)
disp(acnames{ix});

b = dir(fullfile(handlesdir.pathtodir, acnames{ix},'*.mat'));
b = {b.name};

for jx = 1:length(b)
    fprintf('\t%s\n', b{jx});
c = load(fullfile(rootdir, acnames{ix}, b{jx}));

if exist(fullfile(acoutdir, c.meta.fname), 'file')
    load(fullfile(acoutdir, c.meta.fname));
    
    fullfr.initboundy(end+1) = c.frameinfo.initboundy;
    fullfr.outboundy(end+1) = c.frameinfo.outboundy;
    fullfr.newSegm = bitor(fullfr.newSegm, ...
        poly2mask(c.frameinfo.outboundy{1}(:,2), ...
        c.frameinfo.outboundy{1}(:,1), handles.rows, handles.cols));
    fullfr.anglegram{end+1} = computeMultiAnglegram(c.frameinfo.outboundy);
else 
    fullfr.X = c.frameinfo.X;
    fullfr.dataL = c.frameinfo.dataL;
    fullfr.dataGL = c.frameinfo.dataGL;
    fullfr.initboundy = c.frameinfo.initboundy;
    fullfr.outboundy = c.frameinfo.outboundy;
    fullfr.newSegm = poly2mask(c.frameinfo.outboundy{1}(:,2), ...
        c.frameinfo.outboundy{1}(:,1), handles.rows, handles.cols);
    fullfr.anglegram{1} = computeMultiAnglegram(fullfr.outboundy);
end
meta = c.meta;

save(fullfile(acoutdir, c.meta.fname), 'fullfr', 'meta');
end
end