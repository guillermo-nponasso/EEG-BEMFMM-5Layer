%%  Setup path to engine
addpath(fullfile('../Engine'));

%%  Create mid-surface
tic
filename1 = fullfile('../data','110411_gm_headreco.stl');  
filename2 = fullfile('../data','110411_wm_headreco.stl');
[Vnormals, Vdist, Vnodes] = meshsurfcreator(filename1, filename2);
MidSurfaceTime = toc

save midsurface Vnormals Vdist Vnodes