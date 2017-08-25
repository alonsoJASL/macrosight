function [ticompressed] = tablecompression(trackinfo, clumplab)
% TABLE COMPRESSION BASED ON A CLUMP BEING ANALYSED. Be sure to use only a
% table (trackinfo) that has already been reduced to show a particular pair
% of cells that eventually form a clump.
%
% USAGE: [ticompressed] = tablecompression(trackinfo)
% 

aa = table2struct(trackinfo(1:length(clumplab):end,:));
jx=1:length(clumplab):size(trackinfo,1);
fields = {'X','Y','seglabel','track','finalLabel'};

for ix=1:length(jx)
    for kx=1:length(fields)
        auxvect = zeros(1,length(clumplab));
        for qx=1:length(clumplab)
            auxvect(qx) =  trackinfo(jx(ix)+(qx-1),:).(fields{kx});
        end
        aa(ix).(fields{kx}) = auxvect;
    end
    aa(ix).clumpseglabel = aa(ix).seglabel(1)*(aa(ix).clumpcode>0);
end

ticompressed = struct2table(aa);