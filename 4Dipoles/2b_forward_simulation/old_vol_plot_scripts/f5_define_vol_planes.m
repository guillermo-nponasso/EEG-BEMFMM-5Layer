addpath('../engines/bem_fmm_engine/');

%% Dipole location in mm
dip_center_pos = (strdipolePplus + strdipolePminus)/2;
X = dip_center_pos(1)*1000;
Y = dip_center_pos(2)*1000;
Z = dip_center_pos(3)*1000;

%% Load skin mesh
skin_file   = fullfile(patient_path,'mesh_data',strcat(patno,'_skin_remesh.stl'));
TR_skin          = stlread(skin_file);
P_skin           = TR_skin.Points;
t_skin           = TR_skin.ConnectivityList;

%% Prepare cross-sections
% find limits of skin vertices to determine plane sizes
% maxPos = max(P_skin .* (P_skin > 0), [], 1);
% minPos = -1*max(-1*P_skin .* (P_skin < 0), [], 1);
% deltaPos = 0.1*(maxPos - minPos); % max plane (10 + 10)% larger than limits

% calculate plane limits to surround skin mesh
% maxPos = maxPos + deltaPos;
% xmax = maxPos(1);
% ymax = maxPos(2);
% zmax = maxPos(3);
% minPos = minPos - deltaPos;
% xmin = minPos(1);
% ymin = minPos(2);
% zmin = minPos(3);

% calculate limits to surround dipole
delta_dip_pos = 20e-3;
xmax = X + delta_dip_pos;
ymax = Y + delta_dip_pos;
zmax = Z + delta_dip_pos;
xmin = X - delta_dip_pos;
ymin = Y - delta_dip_pos;
zmin = Z - delta_dip_pos;


% %%  Figure with planes
% figure;
% patch([xmin xmin xmax xmax], [ymin ymax ymax ymin], [Z Z Z Z], 'c', 'FaceAlpha', 0.35);
% patch([xmin xmin xmax xmax], [Y Y Y Y],  [zmin zmax zmax zmin], 'c', 'FaceAlpha', 0.35);
% patch([X X X X], [ymin ymin ymax ymax], [zmin zmax zmax zmin], 'c', 'FaceAlpha', 0.35);
% % t0 = t(Indicator==find(strcmp(tissue, 'Skin')), :);
% str.EdgeColor = 'none'; str.FaceColor = [1 0.75 0.65]; str.FaceAlpha = 1.0; 
% bemf2_graphics_base(P_skin, t_skin, str);
% % bemf1_graphics_electrodes(P, t, IndicatorElectrodes, electrodeVoltages, 0);
% axis 'equal';  axis 'tight';   
% daspect([1 1 1]);
% set(gcf,'Color','White');
% camlight; lighting phong;
% view(160, 60);

%% Extract tissue data
% m_max   = length(tissue);
% tS      = cell(m_max, 1);
% nS      = tS; %  Reuse this empty cell array for other initialization
% eS      = tS;
% TriPS   = tS;
% TriMS   = tS;
% PS      = tS;
% 
% for m = 1:length(tissue)
%     TR_tissues              = stlread(fullfile(mesh_path, tissue_files{m}));
%     P_tissues               = TR_tissues.Points;
%     t_tissues               = TR_tissues.ConnectivityList;
%     [P_tissues, t_tissues]          = fixmesh(P_tissues, t_tissues);
%     normals_tissues         = meshnormals(P_tissues, t_tissues); 
%     t_tissues               = meshreorient(P_tissues, t_tissues, normals);
%     % tt = [tt; t+size(PP, 1)];
%     % PP = [PP; P];
%     % nnormals = [nnormals; normals];    
%     % Indicator= [Indicator; repmat(m, size(t, 1), 1)];
%     PS{m}                       = P_tissues;  %  only if the original data were in mm!
%     tS{m}                       = t_tissues;
%     nS{m}                       = normals_tissues;
%     [eS{m}, TriPS{m}, TriMS{m}] = mt(tS{m});
%     disp(['Successfully loaded file [' name{m} ']']);
% end

load(fullfile(model_path,strcat(patno,'_',model_name,'_NIfTIOverlap.mat')));
load(fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh.mat')));

%% Assign tissue colors
color(1, :) = [1 0 0];          %   Skin r 
color(2, :) = [0 1 0];          %   Skull g
color(3, :) = [0 0 1];          %   CSF b
color(4, :) = [1 0 1];          %   GM m
color(5, :) = [1 1 0];          %   WM y
color(6, :) = [0 1 1];          %   Cerebellum c 
color(7, :) = [1 0.75 0.65];    %   Ventricles pale

%% Transverse cross-section
figure;
XY;
legend(tissue(count), 'FontSize', 12, 'Location', 'northeastoutside');
%axis([xmin xmax ymin ymax]);
%% Coronal cross-section
figure;
XZ;
legend(tissue(count), 'FontSize', 12, 'Location', 'northeastoutside');
%axis([xmin xmax zmin zmax]);
%% Sagittal cross-section
figure;
YZ;
legend(tissue(count), 'FontSize', 12, 'Location', 'northeastoutside');
%axis([ymin ymax zmin zmax]);