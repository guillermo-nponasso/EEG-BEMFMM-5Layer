% fitting_wrapper.m
% carry dipole fitting using FieldTrip for every dipole taken from clusters
% of subject 110411.

%% initialize FieldTrip Engine
clear all;
restoredefaultpath;
addpath(fullfile('fieldtrip'));
ft_defaults;

%% prepare leadfield matrix
LFM = load(fullfile('data/LFM/LeadField_matrix4000.mat')).LeadField_matrix;
% take voltage differences with respect to the reference electrode
LFM(:, 2:end) = LFM(:, 2:end) - LFM(:,1);
% remove the reference electrode
LFM(:, 1) = [];

%% load fieldtrip headmodel
disp("Loading headmodel. Please wait..");
load('data\fieldtrip_headmodel.mat');
disp("Done!");

%% load cluster centers for dipole locations
cluster_centers=load('data/cluster_4000.mat').cl_centers;

%% prepare electrode data
elec=load(fullfile('data/110411_elec_realigned_remesh.mat')).elec_realigned;

% remove reference electrode
elec.chanpos = elec.chanpos(2:end,:);
elec.elecpos = elec.elecpos(2:end,:);
elec.chantype = elec.chantype(2:end);
elec.chanunit = elec.chanunit(2:end);
elec.label  = elec.label(2:end);
if ft_datatype(elec,'elec')
    disp("Electrode data loaded succesfully!");
end
elec = ft_convert_units(elec,'m');
%% loop over rows and fit dipoles

lower_bound = 1625;
upper_bound = 1750;

indices   = zeros(upper_bound-lower_bound+1,1);
distances = zeros(upper_bound-lower_bound+1,1);
resvars   = zeros(upper_bound-lower_bound+1,1);

for ix = lower_bound:upper_bound
    indices(ix-lower_bound+1) = ix;

    V = LFM(ix,:)';
    source = 1e-3*cluster_centers(ix,:);

    % create fieldtrip-readable data from voltages
    raw = [];
    raw.datatype = 'raw';
    raw.time={0};
    raw.iseeg='yes';
    raw.label=elec.label;
    raw.chanunit='V';
    raw.senstype='eeg';
    raw.trial = {V};    
    
    % fit the dipole starting from source
    cfg = [];
    cfg.numdipoles = 1;
    cfg.gridsearch = 'no';
    cfg.headmodel = head_model;
    cfg.dip.pos = source;
    cfg.elec=elec;
    dip = ft_dipolefitting(cfg, raw);
    disp("Dipole fit completed!")

    distances(ix-lower_bound+1) = 1e3*dist(dip.dip.pos,source');
    resvars(ix-lower_bound+1)   = dip.dip.rv;
end

%% prepare data table and write it
if ~isfolder(fullfile('data\tables'))
    mkdir(fullfile('data/tables'));
end

table_file = fullfile('data/tables', sprintf("table_%d_%d.csv",...
    lower_bound, upper_bound));

variable_names = {'Dipole','Dist-mm','Residual-Variance'};
data_cell = cell(length(indices),length(variable_names));
data_cell(:,1) = num2cell(indices);
data_cell(:,2) = num2cell(distances);
data_cell(:,3) = num2cell(resvars);
data_table = cell2table(data_cell,'VariableNames',variable_names);

writetable(data_table, table_file, 'WriteMode','overwrite');




