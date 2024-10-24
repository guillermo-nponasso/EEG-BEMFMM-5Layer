%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ft0_create_model.m                                                  %%%
%%% This script creates a volume conduction model for the selected      %%%
%%% conductivity set.                                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% path
restoredefaultpath;
root_dir = fullfile('../engines/fieldtrip'); % full file gives the path for any OS
io_dir = fullfile(root_dir,'fileio'); % input-output module
util_dir = fullfile(root_dir,'utilities'); % FieldTrip utilities module
plot_dir = fullfile(root_dir,'plotting'); % plotting module
forward_dir = fullfile(root_dir,'forward');
bemcp_dir = fullfile(root_dir,'external/bemcp');
addpath(root_dir);
addpath(io_dir);
addpath(util_dir);
addpath(plot_dir);
addpath(forward_dir);
addpath(bemcp_dir);

%% check number of shells
if n_shells ~= 3
    error("Please use a 3-shell model for FieldTrip!")
end

%% read low-res meshes

csf_file = fullfile(patient_path,'mesh_data',strcat(patno,'_csf_remesh.stl'));
skull_file = fullfile(patient_path,'mesh_data',strcat(patno,'_skull_remesh.stl'));
skin_file = fullfile(patient_path,'mesh_data',strcat(patno,'_skin_remesh.stl'));

disp("Reading low-resolution meshes..");
try
    mesh_csf = ft_read_headshape(csf_file, 'format','stl');
    mesh_skull = ft_read_headshape(skull_file,'format','stl');
    mesh_skin = ft_read_headshape(skin_file,'format','stl');
catch
    error("Error reading one of the three low-res meshes. " + ...
        "Please make sure patient mesh data contains brain, skull, and csf remeshed meshes.");
end
disp("Done!");

%% fix meshes

addpath(fullfile('../engines/bem_fmm_engine'));
disp("Fixing meshes..");
[mesh_csf.pos, mesh_csf.tri] = fixmesh(mesh_csf.pos, mesh_csf.tri);
[mesh_skull.pos, mesh_skull.tri] = fixmesh(mesh_skull.pos, mesh_skull.tri);
[mesh_skin.pos, mesh_skin.tri] = fixmesh(mesh_skin.pos, mesh_skin.tri);
disp("Done!"); 
rmpath(fullfile('../engines/bem_fmm_engine'));

%% create volume conduction model

model_file = fullfile(model_path,strcat(patno,'_',model_name,'_headmodel.mat'));

mesh_csf   = ft_convert_units(mesh_csf,'m');
mesh_skull = ft_convert_units(mesh_skull,'m');
mesh_skin  = ft_convert_units(mesh_skin,'m');
mesh(1) = mesh_csf;
mesh(2) = mesh_skull;
mesh(3) = mesh_skin;

for m = 1:3 
    if strcmp(tissue_names{m}, 'skin_remesh')
        skin_cond = conductivity_vals(m);
    end
    if strcmp(tissue_names{m}, 'skull_remesh')
        skull_cond = conductivity_vals(m);
    end
    if strcmp(tissue_names{m}, 'csf_remesh')
        brain_cond = conductivity_vals(m);
    end
end

cfg=[];
cfg.method = 'bemcp';
cfg.tissue = {'brain', 'skull', 'scalp'};
cfg.unit ='m';
cfg.conductivity = [brain_cond skull_cond skin_cond];

disp("The conductivities being used [BRAIN SKULL SKIN] are:");
disp(cfg.conductivity);
    

head_model = ft_prepare_headmodel(cfg, mesh);
disp("Done!");

disp("Saving head model..");
save(model_file, 'head_model');
disp("Done!");
