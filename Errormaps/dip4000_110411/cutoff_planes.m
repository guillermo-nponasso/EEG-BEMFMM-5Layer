%%% cutoff_planes.m
%%% helper script to determine angles and offsets of the cutoff planes

%% clear and load engine
restoredefaultpath;
clear all;
addpath('Engine');

%% define subject variables

subject = '110411'; % MODIFY ACCORDING TO THE SUBJECT!!
mesh_folder = fullfile('data');

SKIN_file = fullfile(mesh_folder,sprintf("%s_skin_headreco.stl",subject));
BONE_file = fullfile(mesh_folder,sprintf("%s_bone_headreco.stl",subject));
CSF_file  = fullfile(mesh_folder,sprintf("%s_csf_headreco.stl",subject));
GM_file   = fullfile(mesh_folder,sprintf("%s_gm_headreco.stl",subject));
WM_file   = fullfile(mesh_folder,sprintf("%s_wm_headreco.stl",subject));


% %% compute thickness (IGNORE FOR NOW)
% disp("Computing Skin Thickness..");
% [~, thick_SB, SNodes] = meshsurfcreator(BONE_file, SKIN_file);
% disp("Computing Bone Thickness..");
% [~, thick_BC, BNodes] = meshsurfcreator(CSF_file, BONE_file);
% disp("Computing CSF Thickness..");
% [~, thick_CG, CNodes] = meshsurfcreator(GM_file, CSF_file);
% disp("Computing GM Thickness..");
% [~, thick_GW, GNodes] = meshsurfcreator(WM_file, GM_file);
% disp("Done!")

%% read tissues

disp("Reading skin..")
SKIN = stlread(SKIN_file);
disp("Reading bone..")
BONE = stlread(BONE_file);
disp("Reading CSF..")
CSF  = stlread(CSF_file);
disp("Reading GM..")
GM   = stlread(GM_file);
disp("Done!")

SK_P = SKIN.Points;
SK_t = SKIN.ConnectivityList;
BN_P = BONE.Points;
BN_t = BONE.ConnectivityList;
CS_P = CSF.Points;
CS_t = CSF.ConnectivityList;
GM_P = GM.Points;
GM_t = GM.ConnectivityList;


%% cutoff GM brain stem plane (this is to be used to compute means of error plots)
% please use 110411 as reference and find the right cutoff, and x_deg values
% check that the normal vector (in red) points upward

% modify  according to patient ----------------
cutoff = -52; % cutoff offset for plane
x_deg = -15;  % rotation angle in degrees

L = 200; %square length (for visualization)
scale = 150; % scale of normal vector arrow (for visualization)
%----------------------------------------------

planeVertices = [
    -L/2,-L/2, 0;
    -L/2,+L/2, 0;
    +L/2,+L/2, 0;
    +L/2,-L/2, 0
];

x_rad = 2*pi/360 * x_deg; % rotation angle along x-axis in radians
rx = [1 0 0; 0 cos(x_rad) -sin(x_rad); 0 sin(x_rad) cos(x_rad)];

GM_PlaneVertices = (rx * planeVertices')' + cutoff*repmat(rx(:,3)', 4, 1); 

cc = mean(GM_PlaneVertices);  % center of normal vector to be plotted
dd = scale*rx(:,3); % direction of the normal to be plotted

figure;
patch('faces', GM_t, 'vertices', GM_P, 'FaceColor', [0.3 0.8 0.5], 'EdgeColor', 'none', 'FaceAlpha', 1.0);  
patch('faces', [1 2 3 4], 'Vertices', GM_PlaneVertices, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.5);

daspect([1 1 1]);
%axis tight;
lighting phong;
light('Position', [1 1 1], 'Style', 'infinite');
material dull;

hold on 
quiver3(cc(1), cc(2), cc(3), dd(1), dd(2), dd(3), 'LineWidth', 2, 'Color','red');
hold off

%% cutoff brain stem CSF plane (THIS SHOULD BE THE SAME AS GM. JUST CHECK!)
% please use 110411 as reference and find the right cutoff, and x_deg values
% check that the normal vector (in red) points upward

% modify  according to patient ----------------
cutoff = -52; % cutoff offset for plane
x_deg = -15;  % rotation angle in degrees

L = 200; %square length (for visualization)
scale = 150; % scale of normal vector arrow (for visualization)
%----------------------------------------------

planeVertices = [
    -L/2,-L/2, 0;
    -L/2,+L/2, 0;
    +L/2,+L/2, 0;
    +L/2,-L/2, 0
];

x_rad = 2*pi/360 * x_deg; % rotation angle along x-axis in radians
rx = [1 0 0; 0 cos(x_rad) -sin(x_rad); 0 sin(x_rad) cos(x_rad)];

GM_PlaneVertices = (rx * planeVertices')' + cutoff*repmat(rx(:,3)', 4, 1); 

cc = mean(GM_PlaneVertices);  % center of normal vector to be plotted
dd = scale*rx(:,3); % direction of the normal to be plotted

figure;
patch('faces', CS_t, 'vertices', CS_P, 'FaceColor', [0.3 0.3 0.8], 'EdgeColor', 'none', 'FaceAlpha', 1.0);  
patch('faces', [1 2 3 4], 'Vertices', GM_PlaneVertices, 'FaceColor', 'green', 'EdgeColor', 'none', 'FaceAlpha', 0.5);

daspect([1 1 1]);
%axis tight;
lighting phong;
light('Position', [0 -1 0], 'Style', 'infinite');
material dull;

hold on 
quiver3(cc(1), cc(2), cc(3), dd(1), dd(2), dd(3), 'LineWidth', 2, 'Color','yellow');
hold off

%% cutoff skull plane
% please use 110411 as reference and find the right cutoff, and x_deg values
% check that the normal vector (in blue) points upward

% modify  according to patient ----------------
cutoff = -60; % cutoff offset for plane
x_deg = 15;  % rotation angle in degrees

L = 250; %square length (for visualization)
scale = 200; % scale of normal vector arrow (for visualization)
%----------------------------------------------

planeVertices = [
    -L/2,-L/2, 0;
    -L/2,+L/2, 0;
    +L/2,+L/2, 0;
    +L/2,-L/2, 0
];

x_rad = 2*pi/360 * x_deg; % rotation angle along x-axis in radians
rx = [1 0 0; 0 cos(x_rad) -sin(x_rad); 0 sin(x_rad) cos(x_rad)];

BN_PlaneVertices = (rx * planeVertices')' + cutoff*repmat(rx(:,3)', 4, 1); 

cc = mean(GM_PlaneVertices);  % center of normal vector to be plotted
dd = scale*rx(:,3); % direction of the normal to be plotted

figure;
patch('faces', BN_t, 'vertices', BN_P, 'FaceColor', [0.9 0.8 0.9], 'EdgeColor', 'none', 'FaceAlpha', 1.0);  
patch('faces', [1 2 3 4], 'Vertices', BN_PlaneVertices, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.5);

daspect([1 1 1]);
%axis tight;
lighting phong;
light('Position', [1 1 1], 'Style', 'infinite');
material dull;

hold on 
quiver3(cc(1), cc(2), cc(3), dd(1), dd(2), dd(3), 'LineWidth', 2, 'Color','blue');
hold off

%% (optional) plot plane on the skin
figure;
patch('faces', SK_t, 'vertices', SK_P, 'FaceColor', [0.7 0.8 0.5], 'EdgeColor', 'none', 'FaceAlpha', 1.0);  
patch('faces', [1 2 3 4], 'Vertices', GM_PlaneVertices, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
patch('faces', [1 2 3 4], 'Vertices', BN_PlaneVertices, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
daspect([1 1 1]);
%axis tight;
lighting phong;
light('Position', [1 1 1], 'Style', 'infinite');
material dull;

