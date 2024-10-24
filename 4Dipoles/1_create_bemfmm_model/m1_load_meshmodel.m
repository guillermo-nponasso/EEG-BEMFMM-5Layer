%   This script loads mesh data into the MATLAB workspace. The data include
%   surface meshes and the potential integrals. It also loads the previous
%   solution (if exists)
%
%   Copyright SNM/WAW 2018-2020

%%  Define EM constants
eps0        = 8.85418782e-012;  %   Dielectric permittivity of vacuum(~air)
mu0         = 1.25663706e-006;  %   Magnetic permeability of vacuum(~air)

%%  Import geometry and electrode data. Create useful sparse matrices. Import existing solution (if any)
tic
h   = waitbar(0.5, 'Please wait - loading model data and existing solution (if any)'); 
load(fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh.mat')));
load(fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh_p.mat')));
close(h);
LoadTime = toc