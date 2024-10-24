% plot the quality of fit in each cluster center using interpolation and 
% angle-based distance

%% load bem-fmm engine
clear all
restoredefaultpath;
addpath('Engine');

%% load data table

data_table = readtable('dip_4000.csv');
errors = data_table.Dist_mm;

%% load cluster data

CL = load(fullfile('data/cluster_4000.mat'));

cluster_centers = CL.cl_centers;
cluster_normals = CL.cl_normals;


%% load grey matter STL

fprintf("Loading WM STL..\n");
WM = stlread(fullfile('data/110411_wm_headreco.stl'));
fprintf("Done!\n");

WM_P = WM.Points;
WM_t = WM.ConnectivityList;

Ntri = size(WM_t,1);
WM_cent    = meshtricenter(WM_P,WM_t);
WM_normals = meshnormals(WM_P, WM_t);

%% interpolate

i_radius = 20; % radius (mm) for the interpolation
tic
ErrWM = zeros(Ntri,1);
for m = 1:Ntri
    tri = WM_cent(m,:);
    D = dist(tri, cluster_centers');
    normal_Dev = 1-WM_normals(m,:)*cluster_normals';
    D = D./normal_Dev;
    idx = find(D<=i_radius);
    if isempty(idx)
        ErrWM(m) = NaN;
    else
        N_neighbors = size(idx,2);
        hsum = sum(1./D(idx)); % harmonic sum of distances
        weights = 1./(D(idx)*hsum);
        ErrWM(m) = sum(weights .* errors(idx)');
    end
end
interpolation_time = toc;
fprintf("Total interpolation time: %d\n", interpolation_time);

%% red to gree colormap

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

%% plot the skin voltages
figure;
patch('faces', WM_t, 'vertices', WM_P, 'FaceVertexCData', ErrWM, 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 1.0);                   
%cmap = hot(256);
cmap = redgreen;
inverted_cmap = flip(cmap,1);
colormap(inverted_cmap);
%colormap(gca, 'jet');
%caxis([nanmin(PSkin(:)), nanmax(PSkin(:))]);
%cmap = colormap;
%cmap(1, :) = [0 0 0];  % Set the first row of colormap to black
%colormap(gca, cmap);
colorbar;
%clim([min(ErrWM) 0.4*max(ErrWM)])
clim([1 20]);
axis 'equal';  axis 'tight';      
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');