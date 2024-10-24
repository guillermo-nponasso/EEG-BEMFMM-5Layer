% plot the quality of fit in each cluster center using interpolation and 
% angle-based distance

%% load bem-fmm engine
clear all
restoredefaultpath;
addpath('Engine');


subject = '110411';
%% load data table

data_table = readtable('dip_4000.csv');
errors = data_table.Dist_mm;

%% load cluster data

CL = load(fullfile('data/cluster_4000.mat'));

cluster_centers = CL.cl_centers;
cluster_normals = CL.cl_normals;


%% load grey matter STL

fprintf("Loading GM STL..\n");
GM = stlread(fullfile('data',sprintf("%s_gm_headreco.stl",subject)));
fprintf("Done!\n");

GM_P = GM.Points;
GM_t = GM.ConnectivityList;

Ntri = size(GM_t,1);
GM_cent    = meshtricenter(GM_P,GM_t);
GM_normals = meshnormals(GM_P, GM_t);

%% (optional) remove outliers from error data:

cutoff = 100; %mm
N_outliers = sum(errors>cutoff);
errors(errors>cutoff)=NaN;
fprintf("Removed %d outliers.\n", N_outliers);

%% interpolate

i_radius = 20; % radius (mm) for the interpolation

fprintf("Interpolating error results. Please wait..\n");
tic
ErrGM = zeros(Ntri,1);
for m = 1:Ntri
    tri = GM_cent(m,:);
    D = dist(tri, cluster_centers');
    normal_Dev = 1-GM_normals(m,:)*cluster_normals';
    D = D./normal_Dev;
    idx = find(D<=i_radius);
    if isempty(idx)
        ErrGM(m) = NaN;
    else
        N_neighbors = size(idx,2);
        hsum = sum(1./D(idx)); % harmonic sum of distances
        weights = 1./(D(idx)*hsum);
        ErrGM(m) = nansum(weights .* errors(idx)');
    end
end
interpolation_time = toc;
fprintf("Total interpolation time: %d\n", interpolation_time);

save(fullfile('data',sprintf("%s_interpolated_error.mat")),'ErrGM');

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

%% plot the skin voltages
h=figure;
patch('faces', GM_t, 'vertices', GM_P, 'FaceVertexCData', ErrGM, 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 1.0);                   
cmap = hot(256);
%cmap = redgreen;
inverted_cmap = flip(cmap,1);
colormap(inverted_cmap);
%colormap(gca, 'jet');

colorbar;
clim([1 20]);
axis 'equal';  axis 'tight';      
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');

if ~isfolder(fullfile('data','figures'))
    mkdir(fullfile('data','figures'));
end

savefig(h, fullfile('data','figures',sprintf("%s_fit_plot.fig",subject)));