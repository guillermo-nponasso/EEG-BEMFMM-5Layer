addpath(fullfile('Engine'));
subject='110411';
elec_file = fullfile('data', sprintf('%s_elec_realigned_headreco.mat',subject));
elec = load(elec_file).elec_realigned;

skin_file = fullfile('data', sprintf('%s_skin_headreco.stl', subject));
fprintf("Loading skin mesh of subject: %s. Please wait..\n", subject);
SKIN = stlread(skin_file);
disp("Done!");

Idx = elec2tri_ix(elec, SKIN.Points, SKIN.ConnectivityList);

save(fullfile('data', sprintf('%s_elec_tri_ix.mat', subject)), 'Idx');
rmpath(fullfile('Engine'));