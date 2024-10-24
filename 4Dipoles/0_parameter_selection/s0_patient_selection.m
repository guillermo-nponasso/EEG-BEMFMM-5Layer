%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% s0_patient_selection.m                                              %%%
%%% Select a patient and record relevant information                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clear all
restoredefaultpath;

%% global variables
Ntime_samples = 10;             %   Number of time samples to simulate
eps0        = 8.85418782e-012;  %   Dielectric permittivity of vacuum(~air)
mu0         = 1.25663706e-006;  %   Magnetic permeability of vacuum(~air)

if ~exist('skip_user_prompts','var') || ~skip_user_prompts
    clear all;
    clc;
    skip_user_prompts=false;
end

%% select patient
if ~skip_user_prompts
    patient_path  = uigetdir(fullfile('../data/patients'), ...
        'Please select a patient directory');
else
    patient_path = fullfile('../data/patients',patno);
end

final_dir     = split(patient_path,{'\','/'});
final_dir     = final_dir{end};
final_split   = split(final_dir,'_');

mesh_path     = fullfile(patient_path,'mesh_data');
if(~isfolder(mesh_path))
    mkdir(mesh_path);
end
fprintf("Processing directory: %s\n", final_dir);
patno = final_split{1}; % patient number, or name
