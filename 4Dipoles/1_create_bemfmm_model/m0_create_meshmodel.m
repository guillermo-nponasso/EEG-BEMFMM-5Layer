%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% step0_create_meshmodel.m                                            %%%
%%% Creates a model for the BEM-FMM forward solution.                   %%%
%%% ------------------------------------------------------------------- %%%
%%% Please make sure that the patient model metadata is loaded          %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   This is a mesh processor script: it computes basis triangle parameters
%   and necessary potential integrals, and constructs a combined mesh of a
%   multi-object structure (for example, a head or a whole body)
%
%   Copyright SNM/WAW 2017-2020

%% clear
restoredefaultpath; 

%% load bem-fmm engine
addpath(fullfile('../engines/bem_fmm_engine'));

%% Load tissue filenames and tissue display names from index file

[name, tissue, cond, enclosingTissueIdx] = tissue_index_read(tissue_index, mesh_path);
tissue_outside = cell(1,length(enclosingTissueIdx(1,:)));
condouter=zeros(length(cond),1);
for i = 1:length(enclosingTissueIdx(1,:))
    if(enclosingTissueIdx(i,1)==0)
        tissue_outside{i}='FreeSpace';
        condouter(i)=0.0;
    else
        tissue_outside{i}=tissue{enclosingTissueIdx(i,1)};
        condouter(i)=cond(enclosingTissueIdx(i,1));
    end
end
condinner=cond';

% meshcut is all zeros in the AMR example. replicating this
meshcut=zeros(1,length(tissue));

%%  Load tissue meshes and combine individual meshes into a single mesh
tic
PP = [];
tt = [];
nnormals = [];
Indicator = [];
m_max   = length(tissue);
tS      = cell(m_max, 1);
nS      = tS; %  Reuse this empty cell array for other initialization
eS      = tS;
TriPS   = tS;
TriMS   = tS;
PS      = tS;

%   Combine individual meshes into a single mesh
GM=[];
WM=[];
for m = 1:length(name)
    TR          = stlread(name{m});
    P           = TR.Points;
    t           = TR.ConnectivityList;
    normals     = meshnormals(P, t); 
    PS{m}       = P;                                        %  only if the original data were in mm!
    tS{m}                       = t;
    nS{m}                       = normals;
    [eS{m}, TriPS{m}, TriMS{m}] = mt(tS{m});
    P = P*1e-3;     %  only if the original data were in mm!
    tt = [tt; t+size(PP, 1)];
    PP = [PP; P];
    nnormals = [nnormals; normals];    
    Indicator= [Indicator; repmat(m, size(t, 1), 1)];
    disp(['Successfully loaded file [' name{m} ']']);
    if strcmp(tissue(m),'WM')
        WM.P = P;
        WM.t = t;
    elseif strcmp(tissue(m),'GM')
        GM.P = P;
        GM.t = t;
    end
end
t = tt;
P = PP;
normals = nnormals;
LoadBaseDataTime = toc


%%   Assign conductivity contrasts for all interfaces
contrast    = zeros(size(t, 1), 1);
condin      = zeros(size(t, 1), 1);
condout     = zeros(size(t, 1), 1);
width = 15;
for m = 1:length(tissue)
    contrast(Indicator==m)  = (condinner(m) - condouter(m))/(condinner(m) + condouter(m));
    condin(Indicator==m)    = condinner(m);
    condout(Indicator==m)   = condouter(m);
    if meshcut(m)
        temp    = Center(Indicator==m, :);
        Taper   = taper(temp, Zcut, 1e-3*width);
        contrast(Indicator==m) = contrast(Indicator==m).*Taper;
    end 
end

%%  Fix triangle orientation (just in case, optional)
tic
t = meshreorient(P, t, normals);

%%   Process other mesh data
Center      = 1/3*(P(t(:, 1), :) + P(t(:, 2), :) + P(t(:, 3), :));  %   face centers
Area        = meshareas(P, t);  
SurfaceNormalTime = toc

%%  Assign facet conductivity information
tic
condambient = 0.0; %   air
[contrast, condin, condout] = assign_initial_conductivities(cond, condambient, Indicator, enclosingTissueIdx);
InitialConductivityAssignmentTime = toc

%%  Check for and process triangles that have coincident centroids
tic
disp('Checking combined mesh for duplicate facets ...');
[P, t, normals, Center, Area, Indicator, condin, condout, contrast] = ...
    clean_coincident_facets(P, t, normals, Center, Area, Indicator, condin, condout, contrast);
disp('Resolved all duplicate facets');
N           = size(t, 1);
DuplicateFacetTime = toc

%%   Find topological neighbors
tic
DT = triangulation(t, P); 
tneighbor = neighbors(DT);
% Fix cases where not all triangles have three neighbors
tneighbor = pad_neighbor_triangles(tneighbor);

%%   Save base data
%FileName = fullfile(mesh_dir,'CombinedMesh.mat');
FileName = fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh.mat'));
save(FileName, 'P', 't', 'normals', 'Area', 'Center', 'Indicator', ...
    'name', 'tissue', 'cond', 'enclosingTissueIdx', 'condinner', 'condouter',...
    'condin', 'condout', 'contrast', 'meshcut', 'GM','WM');
FileName = fullfile(model_path,strcat(patno,'_',model_name,'_NIfTIOverlap.mat'));
save(FileName, 'tissue', 'PS', 'tS', 'eS', 'nS', 'TriPS', 'TriMS'); 
ProcessBaseDataTime = toc

%%   Add accurate integration for electric field/electric potential on neighbor facets
%   Indexes into neighbor triangles
numThreads      = 12;      %   number of cores to be used
RnumberE        = 16;      %   number of neighbor triangles for analytical integration of electric field
RnumberP        = 16;      %   number of neighbor triangles for analytical integration of electric potential
ineighborE      = knnsearch(Center, Center, 'k', RnumberE);   % [1:N, 1:RnumberE]
ineighborP      = knnsearch(Center, Center, 'k', RnumberP);   % [1:N, 1:RnumberP]
ineighborE      = ineighborE';          %   do transpose  
ineighborP      = ineighborP';          %   do transpose  

ppool           = gcp('nocreate');
if isempty(ppool)
    tic
    parpool(numThreads);
    disp([newline 'Started parallel pool in ' num2str(toc) ' s']);
end

EC = meshneighborints_En(P, t, normals, Area, Center, RnumberE, ineighborE);
PC = meshneighborints_P(P, t, normals, Area, Center, RnumberP, ineighborP);


%%   Normalize sparse matrix EC by variable contrast (for speed up)
N   = size(Center, 1);
ii  = ineighborE;
jj  = repmat(1:N, RnumberE, 1); 
CO  = sparse(ii, jj, contrast(ineighborE));
EC  = CO.*EC;

tic
NewName  = fullfile(model_path,strcat(patno,'_',model_name,'_bemfmm_mesh_p.mat'));
save(NewName, 'tneighbor', 'EC', 'PC', '-v7.3');
SaveBigDataTime = toc