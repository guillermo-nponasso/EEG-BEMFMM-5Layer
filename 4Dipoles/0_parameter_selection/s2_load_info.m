%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% s3_load_info.m                                                      %%%
%%% load the patient metadata                                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clear
clear all
clc;

[data_file, data_dir] = uigetfile(fullfile('../data/patients/*_metadata.mat'),'Please select a metadata file');
load(strcat(data_dir,data_file));

clear data_file data_dir
