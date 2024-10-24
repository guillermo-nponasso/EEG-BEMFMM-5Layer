clear P t
%   This script performs mesh refinement in a selected domain using
%   barycentric triangle subdivision (1:4). The input mesh must be 2 manifold
%   Copyright SNM 2012-2018
%   The Athinoula A. Martinos Center for Biomedical Imaging, Massachusetts General
%   Hospital & ECE Dept., Worcester Polytechnic Inst.

%   Load mesh
[FileName, PathName] = uigetfile('*.mat','Select the mesh file');
load(FileName);
[P t] = fixmesh(P, t);
t = sort(t, 2);

%   Define the box where the mesh is refined
box = [-Inf Inf -Inf Inf -Inf Inf];

%   Index into edges to be refined
edges = meshconnee(t);
AttachedTriangles = meshconnet(t, edges, 'manifold');

center  = 1/2*(P(edges(:, 1), :) + P(edges(:, 2), :));  
index1  = find(box(1)<center(:, 1)&center(:, 1)<box(2));
index2  = find(box(3)<center(:, 2)&center(:, 2)<box(4));
index3  = find(box(5)<center(:, 3)&center(:, 3)<box(6));
index   = intersect(index1, index2);
index   = intersect(index,  index3);
%   Nodes to be added up front
Nodes = center(index, :);
P = [Nodes; P];
t       = t + size(Nodes, 1);
edges   = edges + size(Nodes, 1);
%   Edges attached to every triangle
se      = meshconnte(t, edges);

%   Triangles/normal vectors to be added/removed
remove      = [];
add         = [];
normalsadd  = [];
for m = 1:size(t, 1)
    temp1 = find(index==se(m, 1));
    temp2 = find(index==se(m, 2));
    temp3 = find(index==se(m, 3));
    node1 = intersect(edges(se(m, 1), :), edges(se(m, 3), :));
    node2 = intersect(edges(se(m, 1), :), edges(se(m, 2), :));
    node3 = intersect(edges(se(m, 2), :), edges(se(m, 3), :));
    if ~isempty(temp1)|~isempty(temp2)|~isempty(temp3)
        remove = [remove m];
        if temp1&temp2&temp3            
            add = [ [temp1 temp2 temp3];...
                    [temp1 temp2 node2];...
                    [temp1 temp3 node1];...               
                    [temp2 temp3 node3];...
                    add];
            normalsadd = [ normals(m, :);...
                           normals(m, :);...
                           normals(m, :);...
                           normals(m, :);...
                           normalsadd];
        end
        if temp1&temp2&(isempty(temp3))
            add = [ [temp1 temp2 node2];...
                    [temp1 temp2 node1];...               
                    [temp2 node1 node3];...
                    add];
            normalsadd = [ normals(m, :);...
                           normals(m, :);...
                           normals(m, :);...                          
                           normalsadd]; 
        end
        if temp1&temp3&(isempty(temp2))
            add = [ [temp1 temp3 node1];...
                    [temp1 temp3 node3];...               
                    [temp1 node2 node3];...
                    add];
            normalsadd = [ normals(m, :);...
                           normals(m, :);...
                           normals(m, :);...                          
                           normalsadd]; 
        end
        if temp2&temp3&(isempty(temp1))
            add = [ [temp2 temp3 node3];...
                    [temp2 temp3 node1];...               
                    [temp2 node1 node2];...
                    add];
            normalsadd = [ normals(m, :);...
                           normals(m, :);...
                           normals(m, :);...                          
                           normalsadd];                 
        end
        if temp1&(isempty(temp2))&(isempty(temp3))
            add = [ [temp1 node1 node3];...    
                    [temp1 node2 node3];...
                    add];
            normalsadd = [ normals(m, :);...
                           normals(m, :);...            
                           normalsadd];           
        end
        if temp2&(isempty(temp1))&(isempty(temp3))
            add = [ [temp2 node1 node2];...    
                    [temp2 node1 node3];...
                    add];
            normalsadd = [ normals(m, :);...
                           normals(m, :);...            
                           normalsadd]; 
        end
        if temp3&(isempty(temp1))&(isempty(temp2))
            add = [ [temp3 node1 node2];...    
                    [temp3 node2 node3];...
                    add];   
            normalsadd = [ normals(m, :);...
                           normals(m, :);...            
                           normalsadd];                 
        end        
    end
end

t(remove, :)    = [];
t               = [t; add];
t               = sort(t, 2);

normals(remove, :) = [];
normals            = [normals; normalsadd];

save(strcat(FileName(1:end-4),'_mod'), 'P', 't', 'normals');







