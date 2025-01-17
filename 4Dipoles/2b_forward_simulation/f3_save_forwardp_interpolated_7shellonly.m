%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% bem3_save_forwardp.m                                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if n_shells <= 3
    error("This script is meant to be used with models of more than three shells!");
end
%%
pat_image_file=fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name, ...
    '_forwardp_interpolated.png'));

%% load combined mesh, forward sol. and process
%load(fullfile(model_path, strcat(patno,'_',model_name,'_bemfmm_mesh')));
%load(fullfile(patient_path,'dipoles', dipole_name, strcat(patno,'_',model_name,'_',dipole_name,'_potentials_adaptGlobal')));

%%   Load the low-res shell
addpath(fullfile('../engines/bem_fmm_engine'))
TR          = stlread(fullfile(patient_path,'mesh_data',strcat(patno,'_skin_remesh.stl')));
LR.P        = 1e-3*TR.Points;
LR.t        = TR.ConnectivityList;
LR.normals  = meshnormals(LR.P, LR.t);
LR.Center   = meshtricenter(LR.P, LR.t);

tissue_to_plot = 'Skin';
objectnumber    = find(strcmp(tissue, tissue_to_plot));
temp            = Ptot(Indicator==objectnumber);
tempCenter      = Center(Indicator==objectnumber, :);


%% Interpolate
tic
DIST            = dist(LR.Center, tempCenter');
toc
tic
[~, index]      = min(DIST, [], 2);
toc
LR.temp         = temp(index);

save(fullfile(patient_path, 'dipoles', dipole_name,strcat(patno,'_',model_name,'_',dipole_name,'_forwardsolution_p')),'LR');

%%  Digitize figure
fig=figure
step = 10;
%LR.temp = round(step*LR.temp/max(LR.temp)).*(max(LR.temp))/step;
bemf2_graphics_surf_field_gen(LR.P, LR.t, LR.temp);
title(strcat("Patient: ", patno," Model: ", model_name, ...
    " Interpolated Surface E-field"));
view(-70, 70); colormap jet;

if ~isfolder(fullfile('../data/images',patno))
    mkdir(fullfile('../data/images',patno));
end
saveas(fig,fullfile(pat_image_file),'png');
savefig(fig,fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name, ...
    '_forwardp_interpolated.fig')));
rmpath(fullfile('../engines/bem_fmm_engine'))
