%% setup fieldtrip
restoredefaultpath;
addpath(fullfile('fieldtrip'));

clear ft_hastoolbox;
addpath(fullfile('../engines/fieldtrip'));
ft_defaults;

%% read STLs

csf_file = fullfile('data/110411_csf_remesh.stl');
skull_file = fullfile('data/110411_skull_remesh.stl');
skin_file = fullfile('data/110411_skin_remesh.stl');

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

addpath(fullfile('Engine'));
disp("Fixing meshes..");
[mesh_csf.pos, mesh_csf.tri] = fixmesh(mesh_csf.pos, mesh_csf.tri);
[mesh_skull.pos, mesh_skull.tri] = fixmesh(mesh_skull.pos, mesh_skull.tri);
[mesh_skin.pos, mesh_skin.tri] = fixmesh(mesh_skin.pos, mesh_skin.tri);
disp("Done!"); 
rmpath(fullfile('Engine'));

%% create headmodel

mesh_csf   = ft_convert_units(mesh_csf,'m');
mesh_skull = ft_convert_units(mesh_skull,'m');
mesh_skin  = ft_convert_units(mesh_skin,'m');
mesh(1) = mesh_csf;
mesh(2) = mesh_skull;
mesh(3) = mesh_skin;

% SimNIBS3 conductivity values
scalp_cond = 0.4650;
skull_cond = 0.0100;
brain_cond = 0.3300;

cfg=[];
cfg.method = 'bemcp';
cfg.tissue = {'brain', 'skull', 'scalp'};
cfg.unit ='m';
cfg.conductivity = [brain_cond skull_cond scalp_cond];

disp("The conductivities being used [BRAIN SKULL SKIN] are:");
disp(cfg.conductivity);
    

head_model = ft_prepare_headmodel(cfg, mesh);
disp("Done!");

disp("Saving head model..");
model_file = fullfile('data/fieldtrip_headmodel.mat');
save(model_file, 'head_model');
disp("Done!");
