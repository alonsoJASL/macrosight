% LOAD TRACK SCRIPT

try
    rootdir = handlesdir.pathtodir;
    
    a = dir(fullfile(rootdir,[handlesdir.data '_mat_TRACKS_*']));
    a={a.name};
    a(contains(a,'NOTHING')) = [];
    
    whichTrackIdx = find(contains(a, sprintf('lab%d-', whichtrack)));
    b = dir(fullfile(rootdir, a{whichTrackIdx}, '*.mat'));
    b={b.name};
    vect = zeros(length(b),1);
    for ix=1:length(b)
        c = b{ix}(end-6:end-4);
        d = str2num(c);
        jx=1;
        while isempty(d)
            jx=jx+1;
            d=str2num(c(jx:end));
        end
        vect(ix) = d;
    end
    clear ix jx c d;
    
    [frnumbers, bx] = sort(vect);
    b = b(bx);
    
catch e
    disp('ERROR')
end