clear all; close all;
%   SYNTAX 
%   example_global_smoothing_lumped_laplace
%   DESCRIPTION 
%   This script performs global (or local) iterative Laplacian mesh
%   smoothing using the lumped-smoothing algorithm. The smoothing improves
%   triangle quality and increases min edge length but deforms the mesh
%
%   Low-Frequency Electromagnetic Modeling for Electrical and Biological
%   Systems Using MATLAB, Sergey N. Makarov, Gregory M. Noetscher, and Ara
%   Nazarian, Wiley, New York, 2015, 1st ed.

[FileName, PathName] = uigetfile('*.mat','Select the mesh file');
load(FileName);
M = 3;
%   Parameter alpha (use small numbers)
alpha = 0.5;

for m = 1:M
    m
    nodes = 1:size(P, 1);
    [P] = meshlaplace3Dlumped(P, t, nodes, alpha);    
end

%%   Recomputing normal vectors
% Finding vertices of the triangle
vert1 = P(t(:, 1),:);
vert2 = P(t(:, 2),:);
vert3 = P(t(:, 3),:);
% Finding edges
edge1 = vert2 - vert1;
edge2 = vert3 - vert1;

normal = cross(edge1, edge2, 2);                                 % Calculating the normal of the triangle
length = sqrt(normal(:,1).^2+normal(:,2).^2+normal(:,3).^2);     % Calculating length of the normal
unitnormals= normal./(repmat(length,size(normal,3),3));          % Normalization of the normal vector

%   Checking directions
for m = 1:size(t, 1)
    unitnormals(m, :) = unitnormals(m, :)*sign(dot(unitnormals(m, :), normals(m, :)));
end
normals = unitnormals;

save(strcat(FileName(1:end-4),'_mod'), 'P', 't', 'normals');







