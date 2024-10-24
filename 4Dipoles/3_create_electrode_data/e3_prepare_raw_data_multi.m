%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% e1_prepare_raw_data_multi.m                                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_data_path = fullfile(dipole_folder, ...
                         strcat(patno,'_',model_name,'_',dipole_name, ...
                         '_rawdata.mat'));

%% general options
% NOTE: In the static case the option below should make no difference
%       but it is already been implemented in this way.

%below is deprecated, now using Ntime_samples as a global variable
%Ntime_samples = 10; % edit this to change the sample length for the simulated data

%% include fieldtrip
restoredefaultpath;
root_dir = fullfile('../engines/fieldtrip'); % full file gives the path for any OS
io_dir = fullfile(root_dir,'fileio'); % input-output module
util_dir = fullfile(root_dir,'utilities'); % FieldTrip utilities module
plot_dir = fullfile(root_dir,'plotting'); % plotting module
addpath(root_dir);
addpath(io_dir);
addpath(util_dir);
addpath(plot_dir);

%% load electrode file and create labels
load(elec_path);

disp("Creating channel labels");
labels = ElectrodeLabels;
disp("Done!");

%% obtain electrode positions/voltages

disp("Reading electrode data..")
elec = [];
elec.label = labels;
elec.chanpos = ElectrodePositions;
elec.elecpos = ElectrodePositions;

if ft_datatype(elec,'elec')
    disp("Electrode data created succesfully.");
end

%% create raw data from voltages
% fields: label, trial
disp("Reading voltage data..")

raw = [];
raw.datatype = 'raw';
raw.time={zeros(1,Ntime_samples)};
raw.iseeg='yes';
raw.label=labels;
raw.trial = {repmat(ElectrodeVoltages,1,Ntime_samples)};

for i = 0:(Ntime_samples-1)
    raw.time{1}(i+1)=i/Ntime_samples;
end

if ft_datatype(raw,'raw')
    disp("Raw data created succesfully.")
end

%raw.elec = elec;
raw.info.patno = patno;
raw.info.path = raw_data_path;
raw.info.dipole_name = dipole_name;
raw.info.dipole_folder = dipole_folder;
save(raw_data_path, 'raw', 'elec','dipole_name');