% script file: TEST Processing
%
% CAUTION. Some of the (helper) functions used here are not available in
% the package. They are specified.
%

tidy;

try
    % function not available in package
    whichmacro = 1;
    [dn,ds] = loadnames('macros', chooseplatform,whichmacro);
    
    handlesdir = getMatFolders(fullfile(dn,ds));
catch e
    fprintf('%s: Function loadnames not supported, add your own [dn, ds] pair.\n',...
        mfilename);
    
    dn = '/Volumes/DATA/MACROPHAGES/';
    ds = 'MACROS2/';
    dred = 'MACROS_RED/';
end

%% REDUCE DATA
if ~isempty(handlesdir.dataHa)
    fprintf('%s: Loading handles structure...\n',...
        mfilename);
    load(fullfile(handlesdir.pathtodir, handlesdir.dataHa));
end

if isempty(handlesdir.dataRe)
    fprintf('%s: Folder dataRe not found. Creating it...\n',...
        mfilename);
    options.methodUsed = 'reduce';
    options.parameters = 0;
    options.foldername = 'Re';
    
    handles = rgbdataprocessing(fullfile(dn,ds), options);
    if ~isdir(strcat(handlesdir.pathtodir,'_mat_Ha'))
        mkdir(strcat(handlesdir.pathtodir,'_mat_Ha'));
    end
    save(fullfile(strcat(handlesdir.pathtodir,'_mat_Ha'), 'handles.mat'),...
        'handles');
end

if isempty(handlesdir.dataLa)
    fprintf('%s: Folder dataLa not found. Creating it...\n',...
        mfilename);
    options.methodUsed = 'clump';
    options.parameters = [];
    options.foldername = 'La';
    
    hhla = rgbdataprocessing(fullfile(handles.dataRe), options);
else
    hhla = handlesdir;
    fprintf('%s: Folder dataLa found. Moving on...\n',...
        mfilename);
    
end