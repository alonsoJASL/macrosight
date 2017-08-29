# Iterative Shape Evolution (Leak-prevention)
This log file follows the development described in the
[`shapeevolution-iterative.md`](./shapeevolution-iterative.md) file.
The script file
[`script_iterevolve-vs-leaking.m`](../script_iterevolve-vs-leaking.m)
is described in this case, which is a condensed version of
[`script_iterevolve.m`](../script_iterevolve.m)
that allows to make the detection and handling of leaking segmentation
more straightforward.
## The problem so far:
The following image makes the problem explicit:

![cl11010-1to35-failed](../figs/clump11010-frames1to35-iterfollowing-imopen.gif)

The code so far can handle easy clumps, but in some cases, the segmentation
leaks and takes another cell. In this log (and `.m`) file(s) the priority
falls into detecting

## The code in its normal form
The code developed in [`script_iterevolve.m`](../script_iterevolve.m)
is displayed, in a condensed form. All of the functions used are part of the
@macrosight package.
```Matlab
% 1. Load known frame
tk=1;
framet = trackinfo.timeframe(tk);
[knownfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{framet}, framet);
% 2. Compute the tracks' variables in the known frame
[kftr] = getKnownTracksVariables(knownfr, trackinfo, clumplab, tk);

%% 3.1 Load the unknown frame
tkp1 = tk+1;
frametplusT = trackinfo.timeframe(tkp1);
[ukfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{frametplusT}, frametplusT);
% 3.2 Evolve
acopt.method = 'Chan-Vese';
acopt.iter = 50;
acopt.smoothf = 1.5;
acopt.contractionbias = -0.1;
acopt.erodenum = 5;
[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);

% 3.4 Update
% 3.4.1 Update knownfr
[knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab);
if ukfr.hasclump == true && false % change to true for updating info to disk
    update2disk(handles, knownfr, newfr, wuc);
end
framet = frametplusT;
tk = tk+1;
```
