%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% f4_load_forward_data.m                                              %%%
%%% Load the forward data associated to a dipole if it exists           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear Ptot;
try
    forward_path =fullfile(dipole_folder, ...
        strcat(patno,'_',model_name,'_',dipole_name,'_forwardsolution_p.mat'));
    fprintf("Attempting to load: %s\n",forward_path);
    load(forward_path);
catch
    error("The forward solution data does not exist. Please make sure to run the full sequence of forward simulation scripts.")
end
disp("Done!");