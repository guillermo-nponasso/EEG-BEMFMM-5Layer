%   This script displays a mesh from a *.mat P-t file and reports the
%   number of triangles, minimum triangle quality, and minimum edge length

%   Copyright SNM 2012-2018
%   The Athinoula A. Martinos Center for Biomedical Imaging, Massachusetts General
%   Hospital & ECE Dept., Worcester Polytechnic Inst.

s = pwd; addpath(strcat(s(1:end-6), '\Engine'));

FileName = uigetfile('*.mat','Select the tissue mesh file to open'); load(FileName, '-mat');

% %If you also want to display normal vectors, uncomment this block 
% Center = meshtricenter(P, t);
% quiver3(Center(:,1),Center(:,2),Center(:,3), ...
%              normals(:,1),normals(:,2),normals(:,3), 0.5*sqrt(size(t, 1)/500), 'color', 'r');

p = patch('vertices', P, 'faces', t);
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'none';
p.FaceAlpha = 1.0;
daspect([1 1 1])
camlight; lighting flat;
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');
    
NumberOfTirangles = size(t, 1)
Q = min(simpqual(P, t))
edges = meshconnee(t);
temp = P(edges(:, 1), :) - P(edges(:, 2), :);
avgedgelength = mean(sqrt(dot(temp, temp, 2)))


    





