% script file: SEGMENTATION AND DATA HANDLING
%
% CAUTION. Some of the (helper) functions used here are not available in
% the package. They are specified.
%

try
    % function not available in package
    whichmacro = 2;
    [dn,ds] = loadnames('macros', chooseplatform, whichmacro);

    handlesdir = getMatFolders(fullfile(dn,ds));
catch e
    fprintf('%s: Function loadnames not supported, add your own [dn, ds] pair.\n',...
        mfilename);

    dn = '/Volumes/DATA/MACROPHAGES/';
    ds = 'MACROS2/';
    dred = 'MACROS_RED/';
end

%% SORT OUTPUT FOLDERS FROM handlesdir STRUCTURE

if ~isempty(handlesdir.dataHa)
    fprintf('%s: Loading handles structure...\n',...
        mfilename);
    load(fullfile(handlesdir.pathtodir, handlesdir.dataHa,'handles.mat'));
elseif isempty(handlesdir.dataRe)
    % then there's no handles, but would there be a dataRe/La there??
    fprintf('%s: Folders dataRe & dataLa not found...\n',...
        mfilename);
    options.methodUsed = 'reduce';
    options.parameters = 0;
    options.foldername = 'Re';
    handles = rgbdataprocessing(fullfile(dn,ds), options);

    options.methodUsed = 'clump';
    options.parameters = [];
    options.foldername = 'La';
    hhla = rgbdataprocessing(handles.dataRe, options);
    handles.dataLa = hhla.dataLa;

    handlesdir.dataHa = strcat(handlesdir.pathtodir,handlesdir.data,'_mat_Ha');
    handles.dataHa = strcat(handlesdir.pathtodir,handlesdir.data,'_mat_Ha');

    clear options hhla ;
    if ~isdir(handles.dataHa)
        mkdir(handles.dataHa);
    end
    disp(handles);
    save(fullfile(handles.dataHa,'handlesdir.mat'), 'handles');

elseif isempty(handlesdir.dataLa)
    % there's a dataRe, is there a dataLa?
    fprintf('%s: Folder dataLa not found...\n',...
        mfilename);
    options.methodUsed = 'clump';
    options.parameters = [];
    options.foldername = 'La';
    handles = rgbdataprocessing(fullfile(handlesdir.pathtodir, handlesdir.dataRe), ...
        options);
    handles.dataRe = strcat(handlesdir.pathtodir,handlesdir.dataRe);

    handlesdir.dataHa = strcat(handlesdir.pathtodir,handlesdir.data,'_mat_Ha');
    handles.dataHa = strcat(handlesdir.pathtodir,handlesdir.data,'_mat_Ha');

    if ~isdir(handles.dataHa)
        mkdir(handles.dataHa);
    end
    save(fullfile(handles.dataHa,'handlesdir.mat'), 'handles');

else
    % everything is there, except for the handles folder
    fprintf('%s: Only handles structure not found, creating it...\n',...
        mfilename);
    handles.dataRe = strcat(handlesdir.pathtodir,handlesdir.dataRe);
    handles.dataLa = strcat(handlesdir.pathtodir,handlesdir.dataLa);

    handlesdir.dataHa = strcat(handlesdir.data,'_mat_Ha');
    handles.dataHa = strcat(handlesdir.pathtodir,handlesdir.data,'_mat_Ha');

    if ~isdir(handles.dataHa)
        mkdir(handles.dataHa);
    end
    save(fullfile(handles.dataHa,'handlesdir.mat'), 'handles');
end
