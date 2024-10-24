%   This is an electrode processor script: it imprints an arbitrary number
%   of electrodes. 
%
%   Copyright SNM GCNP 2012-2024

elec_path = fullfile(dipole_folder,strcat(patno,'_',model_name,'_', ...
                                          dipole_name,'_electrodes.mat'));

%% load BEM-FMM Engine
addpath(fullfile('../engines/bem_fmm_engine'));

% THIS FOLLOWS interpolate in 2_forward folder
%% load data

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

%% START ELEC CODE

LR.P = 1e3*LR.P;
LR.Center = 1e3*LR.Center;

%%  Determine electrode positions
load(fullfile(patient_path,'mesh_data',strcat(patno,"_elec_realigned_remesh.mat")));
TARGET = elec_realigned.elecpos;

%%
Q = size(TARGET, 1);
%   Project targets exactly to the skin surface
SkinNeighbor     = knnsearch(LR.Center, TARGET, 'k', 1);   %   all in mm
TARGET           = LR.Center(SkinNeighbor, :);

%%   Determine electrode numbers/positions/radii   
NOE                             = Q;                        %   number of active electrodes 
RadE                            = 5.0;                      %   electrode radius in mm (at least 3 triangles along the diameter)
strge.NumberOfElectrodes        = NOE; 
strge.RadiusOfElectrodes        = RadE*ones(1, NOE);%   in mm here

%% Save the data
ElectrodeVoltages   = LR.temp(SkinNeighbor);
ElectrodePositions = TARGET;
ElectrodeLabels = elec_realigned.label;
save(elec_path, 'ElectrodePositions', 'ElectrodeVoltages', 'ElectrodeLabels');
    
%%  Display electrode positions/voltages
figure
p = patch('vertices', LR.P, 'faces', LR.t);
p.FaceColor = [0.8 0.8 0.8];
p.EdgeColor = 'none';
p.FaceAlpha = 1.0;
S = load(fullfile('../data','sphere.mat'));
n = length(S.P);
scale = 8*1e3;
for m = 1:Q
    p = patch('vertices', scale*S.P+repmat(TARGET(m, :), n, 1), 'faces', S.t);
    p.FaceColor = 'b';
%     if m ==1
%         p.FaceColor = 'r';
%     end
    p.EdgeColor = 'none';
    p.FaceAlpha = 1.0;
    vector      = TARGET(m, :) + 10*TARGET(m, :)/norm(TARGET(m, :));    
    text(vector(1), vector(2), vector(3), sprintf('%.2f', 1e6*ElectrodeVoltages(m)), 'color', 'w');
end
bemf2_graphics_surf_field_gen(LR.P, LR.t, LR.temp);
daspect([1 1 1]);
%camlight; lighting phong;
xlabel('x'); ylabel('y'); zlabel('z');
view(-130, 50);
title('assembly with reference electrode')
colormap jet
