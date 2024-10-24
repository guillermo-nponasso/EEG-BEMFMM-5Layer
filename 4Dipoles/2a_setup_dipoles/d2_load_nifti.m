%   This script loads model and NIfTI data when availble
%   It can be used as a starting point
%
%   Copyright SNM 2017-2022

%%
restoredefaultpath;
addpath(fullfile('../engines/bem_fmm_engine/'));

%%

load(fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh.mat')));
%load('CombinedMesh');       %   load precomputed geometry
load(fullfile(model_path,strcat(patno,'_',model_name,'_NIfTIOverlap.mat')));
%load('NIfTIOverlap')

%   Load NIfTI data
%   This block is optional (only if NIfTI data are available)
tic
nifti_filepath = fullfile(patient_path,'mesh_data/T1w.nii');
if exist(nifti_filepath, 'file')
    VT1         = niftiread(nifti_filepath);
    info        = niftiinfo(nifti_filepath);
    N1N2N3      = info.ImageSize;
    d1d2d3      = info.PixelDimensions;
    DimensionX  = d1d2d3(1)*N1N2N3(1);
    DimensionY  = d1d2d3(2)*N1N2N3(2);
    DimensionZ  = d1d2d3(3)*N1N2N3(3);
else
    warning('No T1 NIfTI data are available');
end

nifti_filepath = fullfile(patient_path,'mesh_data/T2w.nii');
if exist(nifti_filepath, 'file')
    VT2         = niftiread(nifti_filepath);
    info        = niftiinfo(nifti_filepath);
    N1N2N3      = info.ImageSize;
    d1d2d3      = info.PixelDimensions;
    DimensionX  = d1d2d3(1)*N1N2N3(1);
    DimensionY  = d1d2d3(2)*N1N2N3(2);
    DimensionZ  = d1d2d3(3)*N1N2N3(3);
else
    warning('No T1 NIfTI data are available');
end
NIFTILoadTime = toc

%   SKIN
i = 1; 
color(i, :) = [1 1 1]; 

%   BONE
i = 2; 
color(i, :) = [0 1 1]; 

%   CSF
i = 3; 
color(i, :) = [1 0.5 0.0]; 

%   GM
i = 4;
color(i, :) = [1 0.75 0.65];

%   WM
i = 5;
color(i, :) = [1 1 1];

%   VENTRICLES
i = 6; 
color(i, :) = [1 0.75 0.65]; 

%   EYES
i = 7; 
color(i, :) = [1 0.75 0.65];

%   Load dipole data
%load('dipole_data.mat');
load(fullfile('../data/patients',patno,'dipoles',dipole_name,strcat(patno,'_',dipole_name,'_data.mat')));
X = 1e3*0.5*(strdipolePplus(1) + strdipolePminus(1));
Y = 1e3*0.5*(strdipolePplus(2) + strdipolePminus(2));
Z = 1e3*0.5*(strdipolePplus(3) + strdipolePminus(3));


