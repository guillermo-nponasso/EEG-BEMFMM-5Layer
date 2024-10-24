%%

addpath('../engines/bem_fmm_engine/');

[f1,f2] = uigetfile(fullfile(patient_path,"mesh_data","*.stl"));
FileName = strcat(f2,f1)
TR          = stlread(FileName);
P           = TR.Points;
t           = TR.ConnectivityList;
normals     = meshnormals(P, t);

% %   If you also want to display normal vectors, uncomment this block 
% Center = meshtricenter(P, t);
% quiver3(Center(:,1),Center(:,2),Center(:,3), ...
%              normals(:,1),normals(:,2),normals(:,3), 0.5*sqrt(size(t, 1)/500), 'color', 'r');

p = patch('vertices', P, 'faces', t);
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'none';
p.FaceAlpha = 1.0;
daspect([1 1 1]);
camlight; lighting phong;
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
view(-145,25)
%set(gca,'color','k') %black background
    
Mesh.Q      = min(simpqual(P, t));
edges       = meshconnee(t);
temp        = P(edges(:, 1), :) - P(edges(:, 2), :);
Mesh.AvgEdgeLength = mean(sqrt(dot(temp, temp, 2)));

Mesh.NumberOfNodes           = size(P, 1);
Mesh.NumberOfFacets          = size(t, 1);
DimX = max(P(:, 1)) - min(P(:, 1))
DimY = max(P(:, 2)) - min(P(:, 2))
DimZ = max(P(:, 3)) - min(P(:, 3))

Mesh.AreaTotal               = sum(meshareas(P, t));     
Mesh.MeshDensityNodes_mm2    = Mesh.NumberOfNodes/Mesh.AreaTotal;
Mesh