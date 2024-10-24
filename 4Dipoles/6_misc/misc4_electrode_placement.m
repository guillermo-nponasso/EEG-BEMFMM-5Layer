%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% step_1_fitting.m                                                    %%%
%%% Fit the electrodes to each patient skin mesh.                       %%%
%%% ------------------------------------------------------------------- %%%
%%% Ryan: Run this script for ALL patients.                             %%%
%%% NOTE: Set the <override> option to <true> to retry and existing fit %%%
%%% The first step is interactive, please do your best to have elec-    %%%
%%% -trodes placed on the left and right mastoid, and to have the front %%%
%%% electrodes close to the eyebrows. Also make sure not to have elec-  %%%
%%% -trodes places over the ears, or the eyes.                          %%%
%%% After the first step is carried. The script will do its best to fit %%%
%%% the user-defined positions to the skin.                             %%%
%%% (c) Guillermo N. Ponasso 2024 email: gcnunez@wpi.edu                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clear
restoredefaultpath;

%% load FieldTrip Modules
root_dir = fullfile('../engines/fieldtrip'); % fieldtrip root
io_dir = fullfile('../engines/fieldtrip/fileio'); % input-output module
util_dir = fullfile('../engines/fieldtrip/utilities'); % FieldTrip utilities module
plot_dir = fullfile('../engines/fieldtrip/plotting'); % plotting module
forward_dir = fullfile('../engines/fieldtrip/forward');
addpath(root_dir);
addpath(io_dir);
addpath(util_dir);
addpath(plot_dir);
addpath(forward_dir);

%% select directory and get info
[skin_file, skin_dir] = uigetfile(fullfile(patient_path,'mesh_data','*.stl'));
skin_fullfile = strcat(skin_dir,skin_file);
skin_fullfile

%% compute suffix for the skin file
dot_split = split(skin_file,'.');
skin_filename = dot_split{1};
underscore_split = split(skin_filename,'_');
suffix = underscore_split{end};

if strcmp(suffix,'skin')
    suffix = '';
else
    suffix = strcat('_',suffix);
end

%% general options
override=true; % change this to true to replace existing electrode fit of patient
out_elec=fullfile(patient_path,'mesh_data', ...
    strcat(patno,'_elec_realigned',suffix,'.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% read generic electrode data
elec_file = fullfile('../data/eeg_data','standard_waveguard256_duke.elc');
elec=ft_read_sens(elec_file,'fileformat', 'asa_elc');

%% read skin mesh
try
    disp('Reading mesh file..');
    skin_mesh = ft_read_headshape(skin_fullfile, 'format', 'stl');
    disp('Done!');
catch  
    error("Error reading decimated skin file!\nPlease make sure you ran Step 0 on the patient first.\nAborting.");
end

%% align electrodes to skin mesh interactively

if(~isfile(out_elec) || override)
    cfg = [];
    cfg.method = 'interactive';
    cfg.headshape = skin_mesh;
    elec_realigned_ia = ft_electroderealign(cfg, elec);
else
    fprintf("Electrode repositioning already exists for patient %s, and override option not chosen\n",patno);
    disp("Skipping interactive repositioning");
    load(out_elec);
end

%% complete with a k-nearest neighbors adjustment

if(~isfile(out_elec) || override)
    cfg = [];
    cfg.method = 'project';
    cfg.headshape = skin_mesh;
    elec_realigned = ft_electroderealign(cfg,elec_realigned_ia);
else
    disp("Skipping nearest neighbors fit.")
end

%% save new electrode position
if(~isfile(out_elec) || override)
    disp("Writing new electrode position..");
    save(out_elec, 'elec_realigned');
    disp("Done!");
else
    disp("File already exists and override option has not been chosen.");
    disp("Skipping saving step.");
end


%% plot skin together with fitted electrodes

hold on
fig=figure('Name','Skin');
ft_plot_mesh(skin_mesh, 'facecolor', 'skin', 'edgecolor', 'none', ...
    'facealpha', 1);
lgt=camlight(-15,65);
material dull;

ft_plot_sens(elec_realigned, 'elec', 'true', 'elecshape', 'sphere', ...
    'elecsize', 10);
view(-150,15)
saveas(fig,fullfile('../data/images',patno,strcat(patno,'_elec')),'png');