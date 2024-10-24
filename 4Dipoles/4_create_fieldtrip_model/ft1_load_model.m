%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ft1_load_model.m                                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if skip_user_prompts
    hm_file = strcat(patno,'_',inverse_conductivity,'_headmodel.mat');
    hm_dir = fullfile(patient_path,'models',inverse_conductivity);
else
    [hm_file,hm_dir] = uigetfile(fullfile(patient_path,'models/*_headmodel.mat'));
end

disp("Loading head model, please wait..");
load(fullfile(hm_dir,hm_file));
disp("Done!")