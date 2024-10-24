%%  Setup path to engine
addpath(fullfile('Engine'));

%%  Setup parallel port
numThreads      = 24;      %   number of cores to be used
tic
ppool           = gcp('nocreate');
if isempty(ppool)
    tic
    parpool(numThreads);
    disp([newline 'Started parallel pool in ' num2str(toc) ' s']);
end

%%  Load/process base geometry with dipoles (a mesh with dipoles located at tri centers)
%FileName    = uigetfile('*.stl','Select the tissue mesh file to open');
subject     = 'Subject04';
FileName    = fullfile('data', sprintf('%s_gm_headreco.stl',subject));
TR          = stlread(FileName);
P           = TR.Points;  %  only if the original data were in mm!
t           = TR.ConnectivityList;

GM_centers  = meshtricenter(P, t);
GM_normals  = meshnormals(P,t);

%% Tuning Parameters 
alpha         = 1;    % scalar between 0 and 1  
K           = 8000;     % number of clusters
tolerance   = 0.5;        % value of tolerance in while loop ending criteria 
beta        = 2;        % value of power, either 1 or 2

%%  Random seeds
rng(15);                % to fix the random seed

%%  Main: Perform mesh clustering on triangle centers (Topological-kmeans: unsupervised machine learning)
tic
[index_int, iterations] = topological_kmeans(P, t, K, tolerance, alpha, beta);

Ntri = size(index_int,1);
indicator = sparse(1:Ntri, index_int, ones(1,Ntri));

cl_centers = indicator' * GM_centers;
cl_centers = cl_centers./sum(indicator,1)';

cl_normals = indicator' * GM_normals;
cl_normals = cl_normals./repmat(vecnorm(cl_normals,2,2),1,3);

ClusterNodes = cell(1, K);
for m = 1:K
    temp = repmat(t(index_int==m, :), 1, 3*sum(index_int==m));
    temp = unique(temp);
    ClusterNodes{m} = temp;
end


%%%%%%%ENd of topolical k means loop code
ClusteringTime  = toc

%%  Display the clustered mesh with integration dipoles and obs points
clf; % clear previous figure
h=figure;
patch('faces', t(:, :), 'vertices', P, 'FaceVertexCData', index_int(:), 'FaceColor', 'flat', 'FaceAlpha', 1.0);
axis 'equal';  axis 'tight'; grid on; xlabel('x'), ylabel('y'), zlabel('z'); view(52, 12);
colormap jet

%% save 

label = 'GM';
save(fullfile('data','clusters',sprintf('%s_cluster_%d.mat',subject,K)), 'index_int','indicator','cl_centers', 'cl_normals', 'ClusterNodes', 'label', 'subject');
