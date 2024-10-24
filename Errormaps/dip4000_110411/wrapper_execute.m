clear all; %#ok<CLALL>

%%  Setup path to engine
addpath(fullfile('Engine'));
addpath(fullfile('Model'));
addpath(fullfile('data'));

%% options
NC = 4000;
subject='110411';
Cl = load(sprintf('%s_cluster_%d.mat', subject, NC));
Ntri = size(Cl.index_int,1);
indicator_mat = sparse(1:Ntri,Cl.index_int, ones(1,Ntri));

%%  Load mid-surface
load('midsurface.mat');

%%  Load partitioning
%Cl      = load('CD_subject04_gm_headreco.stl_8000_1.mat');
%NC       = Cl.FinalNoClusters;

%%  Run main loop
for main = 1:1
    fprintf("Iteration: %d\n", main);
    tic
    bem0_setup_dipoles;
    strdipolePplus      = 1e-3*strdipolePplus0; 
    strdipolePminus     = 1e-3*strdipolePminus0; 
    Ctr                 = 1e-3*Ctr0;
    strdipolemvector    = 1e-3*strdipolemvector0;
    ClusterCenter       = mean(Ctr, 1);
    cd Model\
        model1_setup_base_model;
        model2_add_AMR;
    cd ..\
    bem1_setup_solution;
    bem2_setup_integrals;
    bem3_charge_engine;
    close all hidden;
    bem3_surface_field_p;
    %bem3_surface_field_b;
    time = toc;
    fprintf("Elapsed Time: %d\n", time);
end
