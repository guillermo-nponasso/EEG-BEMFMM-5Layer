%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% step5_load_dipole_data.m                                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~skip_user_prompts
    [dipole_name, dipole_path] = uigetfile(fullfile(patient_path,'dipoles','*.txt'),'Please select a dipole');
else
    %dipole_name='dip1.txt'; % this is now substituted by the current
    %dipole file.
    dipole_path=fullfile(patient_path,'dipoles');
end
dipole_fullpath = fullfile(dipole_path,dipole_name);
fprintf("Processing dipole position %s..\n", dipole_fullpath);
format_split = split(dipole_name,'.');
dipole_name = format_split{1};
clear format_split;

dipole_folder = fullfile(dipole_path,dipole_name);

fprintf("Loading dipole: %s\n", dipole_name);
load(fullfile(dipole_folder, strcat(patno,'_',dipole_name,'_data.mat')));

clear data_file data_dir