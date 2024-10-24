%   Copyright SNM 2012-2024

%%  Cluster number
if ~exist('main', 'var')
    main    = 1;        %   Cluster number
end

%%   Define dipoles in the cluster 
d     = 0.4;  %   dipole length in mm
%Idx   = Cl.ClusterNodes{main};    %   true indexes into cluster nodes

cluster_center = Cl.cl_centers(main,:);
Idx = knnsearch(Vnodes,cluster_center, 'k', 1);
DipoleCenter    = Vnodes(Idx, :) - 0.5*repmat(Vdist(Idx), 1, 3).*Vnormals(Idx, :);
DipoleVector    = Vnormals(Idx, :);
strdipolesig        = 0.33*ones(2*length(Idx), 1);
strdipoleCurrent    = repmat([+1e-5; -1e-5], length(Idx), 1);
strdipolePplus0     = DipoleCenter - d/2*DipoleVector; 
strdipolePminus0    = DipoleCenter + d/2*DipoleVector; 
Ctr0                = DipoleCenter;   
strdipolemvector0   = strdipolePplus0 - strdipolePminus0;

FileName    = fullfile('data',sprintf('%s_gm_headreco.stl',subject));
TR          = stlread(FileName);
P           = TR.Points;
t           = TR.ConnectivityList;
normals     = meshnormals(P, t);
Center      = meshtricenter(P, t);

Idx = Cl.index_int==main;

index = find(Idx);
Facets = length(index);
Distances = zeros(Facets, Facets);
for m = 1:Facets
    for n = 1:Facets
        Distances(m, n) = norm(Center(index(m), :)-Center(index(n), :))/(1 + sum(normals(index(m), :).*normals(index(n), :)));
    end
end

figure;
p = patch('vertices', P, 'faces', t(Idx, :));
p.FaceColor = 'c';
p.EdgeColor = 'k';
p.FaceAlpha = 1.0;

bemf1_graphics_dipole(strdipolePplus0, strdipolePminus0, strdipoleCurrent, 0);

%   If you also want to display normal vectors, uncomment this block 
% Center = meshtricenter(P, t);
% quiver3(Center(Idx, 1),Center(Idx, 2),Center(Idx, 3), ...
%              normals(Idx, 1),normals(Idx, 2),normals(Idx, 3), 0.5*sqrt(size(t(Idx, :), 1)/500), 'color', 'r');
% 
% daspect([1 1 1]);
% camlight; lighting phong;
% xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
% 



