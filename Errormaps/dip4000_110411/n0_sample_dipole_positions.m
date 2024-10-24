%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% n0_sample_dipole_positions.m -- Uniform sample (without repetition) %%% 
%%% of random dipoles, perpendicular to the grey matter shell           %%% 
%%% of the patient.                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TODO: Implement an option to select only triangles whose center has %%%
%%% a z-value greater than or equal to some given threshold.            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general options 

rng(314);             % set random seed
Nsamples      = 1000; % number of dipole samples
normal_offset = .8;   % distance in mm from the grey matter triangle center to the dipole position
plot_samples  = true; % switch to true to plot the random dipole positions over the white matter
max_zhull     = -10;  % max z-coordinate to compute convex hull in the directioning step
bottom_offset = 20;   % distance in mm to avoid at the back of the brain in dipole positioning

%% load bem-fmm engine

addpath(fullfile('../engines/bem_fmm_engine'));

%% read grey matter patient STL

% check if the meshes come from the headreco or FreeSurfer segmentations

modelname_split = split(model_name,{'_'});
is_headreco = length(modelname_split)>1 && strcmp(modelname_split{2},'headreco');

if(is_headreco)
    disp("Headreco model detected, using headreco grey matter..")
    grey_matter_file = fullfile(patient_path,'mesh_data',strcat(patno,'_gm_headreco.stl'));
else
    disp("FreeSurfer model detected, using FreeSurfer grey matter..")
    grey_matter_file = fullfile(patient_path,'mesh_data',strcat(patno,'_gm.stl'));
end

try
    disp("Reading patient's grey matter shell");
    mesh_gm = stlread(grey_matter_file);
    disp("Done!");
catch
    error("Error reading grey matter shell. Please make sure it is present in the patient's mesh_data folder");
end

P_GM = mesh_gm.Points;
t_GM = mesh_gm.ConnectivityList;
[P_GM,t_GM] = fixmesh(P_GM,t_GM);

n_triangles = length(t_GM);
fprintf("There are %d triangles in the mesh. Sampling %d triangles (without repetition) uniformly at random..\n", n_triangles, Nsamples);
%% tangent plane computation
% idea 1: Compute the convex hull of points below the minimum z-coord
if(~is_headreco)
    disp("Computing appropriate directions for dipole locations..")
    smallz_points = P_GM(P_GM(:,3)<max_zhull,:);
    conv_hull_z = convhull(smallz_points);
    convh_areas = meshareas(smallz_points,conv_hull_z);
    sorted_areas = sort(convh_areas,"descend");
    
    % a good normal direction should be given in a triangle with large area
    % in the convex hull, pointing in the "right direction"
    
    % we search the normals of the largest triangles until we find a
    % negative value of the y-coord of the normal, and a negative value of the
    % z-coordinate of the normal.
    
    found_candidate = false;
    current_area = 0;
    while ~found_candidate
        current_area = current_area + 1;
        triangle_index = find(~(convh_areas-sorted_areas(current_area)));
        candidate_normal = meshnormals(smallz_points,conv_hull_z(triangle_index,:));
        if(candidate_normal(2)<0 && candidate_normal(3)<0)
            found_candidate=true;
        end
    end
    
    % we compute the intercept for the plane
    candidate_intercept = dot(smallz_points(conv_hull_z(triangle_index,1),:),candidate_normal);
    
    %inspect convex hull
    %trimesh(conv_hull_z,smallz_points(:,1),smallz_points(:,2),smallz_points(:,3))
    disp("Done!")
else
    try
        load(fullfile(patient_path,'mesh_data',strcat(patno,'_random_dip_pos.mat')))
    catch
        error("Please run this script for a FreeSurfer model before using the headreco model.")
    end
end

%% triangle sampling step
% We sample triangles from the mesh
n_sampled = 0;
triangle_samples = zeros(1,Nsamples);

disp("Sampling started..")
while n_sampled < Nsamples
    rand_tri = randi(n_triangles);
    found_indices = find(~(triangle_samples-rand_tri));
    rand_pos = meshtricenter(P_GM,t_GM(rand_tri,:)) - normal_offset*meshnormals(P_GM,t_GM(rand_tri,:));
    rand_pos_dot = dot(rand_pos,candidate_normal);
    long_fiss_offset = 5; % (mm) distance along the longitudinal fissure to avoid dipoles 
     % check if the triangle is new, and avoids the bottom of the brain
    if  isempty(found_indices) && rand_pos_dot < candidate_intercept-bottom_offset %&& abs(rand_pos(1))>=long_fiss_offset
        n_sampled = n_sampled+1;
        triangle_samples(n_sampled) = rand_tri;
    end
end
disp("Sampling completed!")
%% compute dipole positions
disp("Computing dipole positions from samples..")
gm_sample_centers = meshtricenter(P_GM, t_GM(triangle_samples,:));
gm_sample_normals = meshnormals  (P_GM, t_GM(triangle_samples,:)); 

%assuming outward normals
gm_sample_pos     = gm_sample_centers - normal_offset * gm_sample_normals;
disp("Done!")

%% save dipole positions
disp("Saving random dipole data into patient's mesh data..");
if(is_headreco)
    save(fullfile(patient_path, 'mesh_data', strcat(patno,'_random_dip_pos_headreco.mat')), ...
        'gm_sample_pos','gm_sample_normals', 'triangle_samples','candidate_normal', ...
        'candidate_intercept');
else
    save(fullfile(patient_path, 'mesh_data', strcat(patno,'_random_dip_pos.mat')), ...
        'gm_sample_pos','gm_sample_normals', 'triangle_samples', 'candidate_normal', ...
        'candidate_intercept');
end
disp("Done!");
noise_computed = true;
%% plotting 

if(plot_samples)
    disp("Plotting samples option chosen -- processing..")
    if(is_headreco)
        disp("Headreco model detected, using headreco white matter..")
        white_matter_file = fullfile(patient_path,'mesh_data',strcat(patno,'_wm_headreco.stl'));
    else
        disp("FreeSurfer model detected, using FreeSurfer white matter..")
        white_matter_file = fullfile(patient_path,'mesh_data',strcat(patno,'_wm.stl'));
    end
    try
        disp("Reading white matter shell..")
        mesh_wm = stlread(white_matter_file);
    catch
        error("Error reading white matter shell. Please make sure it is present in the patient's mesh_data folder")
    end
    P_WM           = mesh_wm.Points;
    t_WM           = mesh_wm.ConnectivityList;
    wm_normals  = meshnormals(P_WM, t_WM);

    dipole_plus = gm_sample_pos + .5*gm_sample_normals; 
    dipole_min  = gm_sample_pos - .5*gm_sample_normals;
    
    % %   If you also want to display normal vectors, uncomment this block 
    % Center = meshtricenter(P, t);
    % quiver3(Center(:,1),Center(:,2),Center(:,3), ...
    %              normals(:,1),normals(:,2),normals(:,3), 0.5*sqrt(size(t, 1)/500), 'color', 'r');
    
    figure
    p = patch('vertices', P_WM, 'faces', t_WM);
    p.FaceColor = [1 0.75 0.65];
    p.EdgeColor = 'none';
    p.FaceAlpha = 1.0;
    daspect([1 1 1]);
    camlight; lighting phong;
    xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
    bemf1_graphics_dipole(dipole_plus,dipole_min,1,0);
        
    Mesh.Q      = min(simpqual(P_WM, t_WM));
    edges       = meshconnee(t_WM);
    temp        = P_WM(edges(:, 1), :) - P_WM(edges(:, 2), :);
    Mesh.AvgEdgeLength = mean(sqrt(dot(temp, temp, 2)));
    
    Mesh.NumberOfNodes           = size(P_WM, 1);
    Mesh.NumberOfFacets          = size(t_WM, 1);
    DimX = max(P_WM(:, 1)) - min(P_WM(:, 1))
    DimY = max(P_WM(:, 2)) - min(P_WM(:, 2))
    DimZ = max(P_WM(:, 3)) - min(P_WM(:, 3))
    
    Mesh.AreaTotal               = sum(meshareas(P_WM, t_WM));     
    Mesh.MeshDensityNodes_mm2    = Mesh.NumberOfNodes/Mesh.AreaTotal;
    Mesh

end
