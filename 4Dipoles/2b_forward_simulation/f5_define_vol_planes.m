addpath('../engines/bem_fmm_engine/');
addpath('../engines/graphics/')
load(fullfile(model_path,strcat(patno,'_',model_name,'_NIfTIOverlap.mat')));

%% Dipole location in mm
dip_center_pos = (strdipolePplus + strdipolePminus)/2;
X = dip_center_pos(1)*1e3;
Y = dip_center_pos(2)*1e3;
Z = dip_center_pos(3)*1e3;

%% Calculate planes
plot_entire_head=true

if plot_entire_head
    % entire head pat 117122 for coronal and saggital
    delta_skin_bound = 10; % (100 mm)^2 area around dipole
    delta_dip_pos = 10;
    % get outer bounds of skin contour
    [PofXY, ~, ~, ~] = meshplaneintXY(PS{1}, tS{1}, eS{1}, TriPS{1}, TriMS{1}, Z);
    [PofXZ, ~, ~, ~] = meshplaneintXZ(PS{1}, tS{1}, eS{1}, TriPS{1}, TriMS{1}, Y);
    [PofYZ, ~, ~, ~] = meshplaneintYZ(PS{1}, tS{1}, eS{1}, TriPS{1}, TriMS{1}, X);
    skin_bounds_max = max([max(PofXY); max(PofXZ); max(PofYZ)]);
    skin_bounds_min = min([min(PofXY); min(PofXZ); min(PofYZ)]);

    xmax = skin_bounds_max(1) + delta_skin_bound;
    ymax = skin_bounds_max(2) + delta_skin_bound;
    zmax = skin_bounds_max(3) + delta_skin_bound;
    xmin = skin_bounds_min(1) - delta_skin_bound;
    ymin = skin_bounds_min(2) - delta_skin_bound;
    zmin = skin_bounds_min(3) - delta_skin_bound;
else
    delta_skin_bound=20;
    delta_dip_pos = 20; % (20 mm)^2 area around dipole
    xmax = X + delta_dip_pos;
    ymax = Y + delta_dip_pos;
    zmax = Z + delta_dip_pos;
    xmin = X - delta_dip_pos;
    ymin = Y - delta_dip_pos;
    zmin = Z - delta_dip_pos;
end


%% Load tissue data
load(fullfile(model_path,strcat(patno,'_',model_name,'_NIfTIOverlap.mat')));
load(fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh.mat')));

%% Assign tissue colors
color(1, :) = [1 0 0];          %   Skin r
color(2, :) = [1 1 0];          %   Skull g
color(3, :) = [0 0 1];          %   CSF b
color(4, :) = [1 0 1];          %   GM m
color(5, :) = [0 1 1];          %   WM y
color(6, :) = [0 .7 1];          %   Cerebellum c
color(7, :) = [1 0.75 0.65];    %   Ventricles pale

%% Transverse cross-section
figure;
XY;
legend(tissue(count), 'FontSize', 12, 'Location', 'northeastoutside');
axis([xmin xmax ymin ymax]);
%% Coronal cross-section
figure;
XZ;
legend(tissue(count), 'FontSize', 12, 'Location', 'northeastoutside');
axis([xmin xmax zmin zmax]);
%% Sagittal cross-section
figure;
YZ;
legend(tissue(count), 'FontSize', 12, 'Location', 'northeastoutside');
axis([ymin ymax zmin zmax]);
