% projected_thickness_plot.m
% calculate skull thickness, and interpolate the projection of this metric
% over some tissue.

%% clear and load engine

restoredefaultpath;
clear all;
addpath(fullfile('Engine'));

%% load meshes

file_INNER = fullfile('data/110411_wm_headreco.stl');
file_OUTER = fullfile('data/110411_gm_headreco.stl');

fprintf("Reading Skin tissue. Please wait..\n");
OUT = stlread(file_OUTER);
fprintf("Done!\n");

P_O = OUT.Points;
t_O = OUT.ConnectivityList;
centers_O = meshtricenter(P_O,t_O);

% tissue where to plot
file_TARGET = fullfile('data/110411_gm_headreco.stl');

%[Normals_OT, Dist_OT, VNodes] = meshsurfcreator(file_OUTER, file_TARGET);
%P_T = VNodes + Normals_OT.*Dist_OT*0.8;
%t_T = t_O;


fprintf("Loading target tissue. Please wait..\n");
TARGET = stlread(file_TARGET);
P_T = TARGET.Points;
t_T = TARGET.ConnectivityList;
Ntri = length(t_T);
centers_T = meshtricenter(P_T, t_T);
normals_T = meshnormals(P_T, t_T);
fprintf("Done!\n");

%% obtain nodes and distances between nodes

disp("Calculating thickness..")
[~, VDist, VNodes] = meshsurfcreator(file_OUTER, file_INNER);
disp("Done!");


%% METHOD 1: project outer tissue nodes on target centers
%disp("Projecting on target tissue..")
%idx = knnsearch(VNodes, centers_T, 'k', 1);
%disp('Done!');
%VALUES = VDist(idx);

%% METHOD 2: interpolating values
fprintf("Interpolating solution. Please wait..\n");
i_radius=5;
tic
VALUES = zeros(Ntri,1);
for m = 1:Ntri
    tri = centers_T(m,:);
    D = dist(tri, VNodes');
    idx = find(D<=i_radius);
    if isempty(idx)
        VALUES(m) = NaN;
    else
        N_neighbors = size(idx,2);
        hsum = sum(1./D(idx)); % harmonic sum of distances
        weights = 1./(D(idx)*hsum);
        VALUES(m) = sum(weights .* VDist(idx)');
    end
end
interpolation_time = toc;
fprintf("Interpolation time: %d\n", interpolation_time);

%% define red to green colormap

% Define RGB values for red and green
red = [1, 0, 0];   % RGB: [R, G, B]
green = [0, 1, 0]; % RGB: [R, G, B]

% Number of colors in the colormap (adjust as needed)
n_colors = 256;

% Create colormap gradient from red to green
redgreen = zeros(n_colors, 3);  % Initialize colormap matrix

% Generate intermediate colors using linspace
for i = 1:n_colors
    redgreen(i, :) = (1 - (i - 1) / (n_colors - 1)) * red + ((i - 1) / (n_colors - 1)) * green;
end

%% plot the thickness
figure;
patch('faces', t_T, 'vertices', P_T, 'FaceVertexCData', VALUES, 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 1.0);                   
%cmap = hot(256);
cmap = redgreen;
inverted_cmap = flip(cmap,1);
colormap(inverted_cmap);
%colormap(gca, 'jet');
colormap("parula");
%caxis([nanmin(PSkin(:)), nanmax(PSkin(:))]);
%cmap = colormap;
%cmap(1, :) = [0 0 0];  % Set the first row of colormap to black
%colormap(gca, cmap);
colorbar;
%clim([min(ErrWM) 0.7*max(ErrWM)])
clim([0 8]);
axis 'equal';  axis 'tight';      
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
