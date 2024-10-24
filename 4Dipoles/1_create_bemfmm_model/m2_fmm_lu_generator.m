%   This script does FMM-LU

load(fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh.mat')));
load(fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh_p.mat')));
weight = 0.5;

%%  Add paths for FMM-LU
run(fullfile('../engines/bem_fmm_engine/FLAM-master/startup.m'));
run(fullfile('../engines/bem_fmm_engine/strong-skel-master/startup.m'));
addpath('../engines/bem_fmm_engine/flattri_lap_quad-main/src');

%%  Obtain factorization of inv(A)
tic
F = get_factorization(Center, Area, normals, EC, contrast, weight);
FMM_LU_Time = toc

%% save
disp('Saving FMM-LU data..');
current_dir = pwd;
cd(fullfile(model_path));
save(strcat(patno,'_',model_name,'_fmm_lu.mat'),'F', '-v7.3');
cd(current_dir);
clear current_dir;
disp('Done!');