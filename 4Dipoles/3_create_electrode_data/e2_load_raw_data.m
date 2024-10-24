%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% e2_load_raw_data.m                                                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[r_file, r_dir] = uigetfile(fullfile(patient_path,'dipoles/*_rawdata.mat'), ...
                         'Please select a raw data file.');
disp("Loading " + strcat(r_dir,r_file));
load(strcat(r_dir,r_file));
disp("Done!")
clear r_dir r_file;