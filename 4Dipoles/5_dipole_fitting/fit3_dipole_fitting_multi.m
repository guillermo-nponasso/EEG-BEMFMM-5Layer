%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% fit1_dipole_fitting.m                                               %%%
%%% Fit a dipole for the selected model and raw data                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load Fieldtrip
restoredefaultpath;
root_dir = fullfile('../engines/fieldtrip'); % full file gives the path for any OS
io_dir = fullfile(root_dir,'fileio'); % input-output module
util_dir = fullfile(root_dir,'utilities'); % FieldTrip utilities module
plot_dir = fullfile(root_dir,'plotting'); % plotting module
forward_dir = fullfile(root_dir,'forward');
inverse_dir = fullfile(root_dir,'inverse');
addpath(root_dir);
addpath(io_dir);
addpath(util_dir);
addpath(plot_dir);
addpath(forward_dir);
addpath(inverse_dir);

%% general options
do_grid_fit = false;
grid_res = 15;  %mm
Ntime_samples = 10;

%% load 3-shell electrode positions for the patient

elec_3shell = load(fullfile('../data/patients', patno, 'mesh_data', strcat(patno,'_elec_realigned_remesh.mat')));

%% create orig dipole info

dip0.dip.pos = 1e3*strdipolemcenter;
dip0.vec = strdipolePplus-strdipolePminus;
dip0.dip.mom = dip0.vec/norm(dip0.vec);

%% prepare sourcemodel for grid fit
disp("Preparing source model. Please wait..")
cfg=[];
cfg.method = 'basedonresolution';
cfg.resolution = grid_res;
cfg.headmodel = head_model;
cfg.unit='mm';

source_model = ft_prepare_sourcemodel(cfg);

disp("Done!")
%% initialize data table

data_cell = cell(1+N_strengths*N_simulations,6);

%% start fits

disp("Dipole fits started. Please wait..");
for strength_ix = 1:N_strengths
    fprintf("Dipole fitting for noisy data with SNR = %d\n", snr_vec(strength_ix));
    for simulation_ix = 1:N_simulations
        fprintf("Dipole fitting for simulation %d/%d\n", simulation_ix, N_simulations);
        clear elec raw;
        %% CREATE RAW ELECTRODE DATA
        elec = [];
        elec.label = elec_3shell.elec_realigned.label;
        elec.chanpos = elec_3shell.elec_realigned.elecpos;
        elec.elecpos = elec_3shell.elec_realigned.elecpos;
        %% FILL IN VOLTAGES
        raw = [];
        raw.datatype = 'raw';
        raw.time={zeros(1,1)};
        raw.iseeg='yes';
        raw.label=elec_3shell.elec_realigned.label;
        raw.trial={repmat(ElectrodeVoltages(:,strength_ix,simulation_ix),1,Ntime_samples)};
        for i = 0:(Ntime_samples-1)
        raw.time{1}(i+1)=i/Ntime_samples;
        end

        %% DIPOLE FIT WITH GRID SEARCH
        fprintf("Computing grid dipole fit, with %dmm of resolution\n", grid_res);
        cfg = [];
        cfg.numdipoles = 1;
        cfg.gridsearch = 'yes';
        cfg.sourcemodel = source_model;
        cfg.headmodel = head_model;
        cfg.elec=elec;
        cfg.dipfit.optimfun='fminunc';
        
        dip_grid = ft_dipolefitting(cfg, raw);
        disp("Grid dipole fit completed!")

        dip_grid_distance = norm(dip_grid.dip.pos-dip0.dip.pos);
        cos_angle_dip_grid = dot((dip_grid.dip.mom(:,1)/norm(dip_grid.dip.mom(:,1))),dip0.dip.mom);
        angle_dip_grid = rad2deg(acos(cos_angle_dip_grid));
        fprintf("Distance (mm) to grid dipole fit: %.4f\n", dip_grid_distance);
        fprintf("degrees of angle to grid dipole fit: %.2f\n", angle_dip_grid);

        %% DIPOLE FIT FROM ORIGINAL POSITION

        disp("Dipole fit with real initial value")
        cfg = [];
        cfg.numdipoles = 1;
        cfg.gridsearch = 'no';
        cfg.headmodel = head_model;
        cfg.dip.pos = dip0.dip.pos;
        cfg.elec=elec;
        
        dip = ft_dipolefitting(cfg, raw);
        disp("Dipole fit completed!")

        dip_distance = norm(dip.dip.pos-dip0.dip.pos);
        cos_angle_dip = dot((dip.dip.mom(:,1)/norm(dip.dip.mom(:,1))),dip0.dip.mom);
        angle_dip = rad2deg(acos(cos_angle_dip));
        fprintf("Distance (mm) to source dipole fit: %.4f\n", norm(dip.dip.pos-dip0.dip.pos));
        fprintf("degrees of angle to source dipole fit: %.2f\n", rad2deg(acos(cos_angle_dip)));

        if dip_grid_distance < dip_distance
            dip = dip_grid;
        end
        
        data_cell((strength_ix-1)*(N_simulations)+simulation_ix,:) = ...
        {strength_ix,snr_vec(strength_ix),snr_values(strength_ix,simulation_ix), ...
        dip_distance, angle_dip,dip.dip.rv(1)};
    end
end

disp("Done!");

%% fit the source dipole
disp("Fitting source dipole");
clear elec raw;
%% CREATE RAW ELECTRODE DATA
elec = [];
elec.label = elec_3shell.elec_realigned.label;
elec.chanpos = elec_3shell.elec_realigned.elecpos;
elec.elecpos = elec_3shell.elec_realigned.elecpos;
%% FILL IN VOLTAGES
raw = [];
raw.datatype = 'raw';
raw.time={zeros(1,1)};
raw.iseeg='yes';
raw.label=elec_3shell.elec_realigned.label;
raw.trial={repmat(ElectrodeVoltages_source,1,Ntime_samples)};
for i = 0:(Ntime_samples-1)
raw.time{1}(i+1)=i/Ntime_samples;
end

%% DIPOLE FIT FROM ORIGINAL POSITION

disp("Dipole fit with real initial value")
cfg = [];
cfg.numdipoles = 1;
cfg.gridsearch = 'no';
cfg.headmodel = head_model;
cfg.dip.pos = dip0.dip.pos;
cfg.elec=elec;

dip = ft_dipolefitting(cfg, raw);
disp("Dipole fit completed!")

dip_distance = norm(dip.dip.pos-dip0.dip.pos);
cos_angle_dip = dot((dip.dip.mom(:,1)/norm(dip.dip.mom(:,1))),dip0.dip.mom);
angle_dip = rad2deg(acos(cos_angle_dip));
fprintf("Distance (mm) to source dipole fit: %.4f\n", norm(dip.dip.pos-dip0.dip.pos));
fprintf("degrees of angle to source dipole fit: %.2f\n", rad2deg(acos(cos_angle_dip)));

data_cell(end,:)={'Inf', 'Inf', 'Inf', dip_distance, angle_dip,dip.dip.rv(1)};

%% data cell to CSV

variable_names = {'SNR_Index', 'Target_SNR','Real_SNR', 'Dist_mm', 'Angle_deg', 'Residual_Variance'};
data_table = cell2table(data_cell,'VariableNames',variable_names);

data_table_folder = fullfile('../data/tables');
if ~isfolder(data_table_folder)
    mkdir(data_table_folder);
end
patient_table_folder =fullfile('../data/tables',patno);
if ~isfolder(patient_table_folder)
    mkdir(patient_table_folder);
end

disp("Writing results..");
writetable(data_table,fullfile(patient_table_folder,strcat(patno,'_',model_name,'_table.csv')),'WriteMode','overwrite');
disp("Done!");

