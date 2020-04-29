function [labelsinvector] = getlabelsfromcode(clumpcode)
%

if clumpcode==0
    fprintf('%s: no labels associated to code.\n', mfilename);
    labelsinvector = [];
else
    code2str = int2str(clumpcode);
    numlabels = ceil(length(code2str)/3);
    labelsinvector=zeros(numlabels,1);
    
    for kx=1:numlabels
        try
            if ~strcmp(code2str(end-2:end),'000')
                labelsinvector(kx) = str2double(code2str(end-2:end));
            end
            code2str(end-2:end)=[];
        catch
            labelsinvector(kx) = str2double(code2str);
        end
    end
end
