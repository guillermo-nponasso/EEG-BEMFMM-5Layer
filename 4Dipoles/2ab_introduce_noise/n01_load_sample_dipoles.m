%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% n01_load_sample_dipoles.m -- Load sample dipole information for the %%%
%%% selected patient.                                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if the meshes come from the headreco or FreeSurfer segmentations

modelname_split = split(model_name,{'_'});
is_headreco = length(modelname_split)>1 && strcmp(modelname_split{2},'headreco');

if(is_headreco)
    disp("Headreco model detected, loading headreco dipole positions..")
    load(fullfile(patient_path, 'mesh_data', strcat(patno,'_random_dip_pos_headreco.mat')));
else
    disp("FreeSurfer model detected, using FreeSurfer dipole positions..")
    load(fullfile(patient_path, 'mesh_data', strcat(patno,'_random_dip_pos.mat')));
end