
%% general options
elec_path = fullfile(patient_path,'dipoles',strcat(patno,'_',model_name,'_', ...
                                          dipole_name,'_electrodes.mat'));


%% load BEM-FMM Engine
addpath(fullfile('../engines/bem_fmm_engine'));


%% load skin shell
skin_id            = find(strcmp(tissue,'Skin'));
V_skin          = Ptot(Indicator==skin_id);

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

%%  Determine electrode positions
load(fullfile(patient_path,'mesh_data',strcat(patno,'_elec_realigned', suffix,'.mat')));
TARGET = elec_realigned.elecpos;

%%
Q = size(TARGET, 1);
%   Project targets exactly to the skin surface
SkinNeighbor     = knnsearch(mesh_skin.Center, TARGET, 'k', 1);   %   all in mm
TARGET           = mesh_skin.Center(SkinNeighbor, :);

%%   Determine electrode numbers/positions/radii   
NOE                             = Q;                        %   number of active electrodes 
RadE                            = 5.0;                      %   electrode radius in mm (at least 3 triangles along the diameter)
strge.NumberOfElectrodes        = NOE; 
strge.RadiusOfElectrodes        = RadE*ones(1, NOE);%   in mm here

%% Save the data
ElectrodeVoltages  = V_skin(SkinNeighbor);
ElectrodePositions = TARGET;
ElectrodeLabels    = elec_realigned.label;
