%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% wrapper_full_calibration.m -- A wrapper for the calibration runtime. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function []=wrapper_full_calibration(pat_ix, model)

pat_cell = {'110411','117122','120111','122317','122620','124422','128632','130013','131722','138534','149337','149539','151627','160123','198451'};
pat_cell
fprintf("pat_ix=%s" ,pat_ix);
pat_ix = str2num(pat_ix);
patno  = pat_cell{pat_ix};

%% go to root
cd ..; % 6_misc
cd ..; % root

%% global options (change this according to the node)
conductivity_file = sprintf("%s.txt",model);
inverse_conductivity = model;
patient_cell={patno};
skip_user_prompts = true; % do not change this option

skip_FMM_LU_creation = false;  % select true to load FMM-LU solution instead

%% select patient
for patient_ix = 1:length(patient_cell)

    %% 00 PATIENT SELECTION
    patno = patient_cell{patient_ix};
    fprintf("Processing patient %s\n", patno);
    tic
    cd(fullfile('0_parameter_selection'));
    run('s0_patient_selection.m');
    cd ..;
    %% 01 CONDUCTIVITY SELECTION: SWISS7
    skip_user_prompts=true;      % this must be activated to skip user prompt
    cd(fullfile('0_parameter_selection'));
    run('s1_parameter_selection.m');
    cd ..;

    %% 10 CREATE BEM-FMM MODEL
    cd(fullfile('1_create_bemfmm_model'));
    disp("Creating BEM-FMM model..");
    run('m0_create_meshmodel.m');
    disp("BEM-FMM model created!");

    %% 11 CREATE FMM-LU SOLUTION
    disp("Creating FMM-LU solution..")
    if skip_FMM_LU_creation
        disp("Attempting to load pre-existing FMM-LU solution");
        load(fullfile(patient_path,'models',model_name,strcat(patno,'_',model_name,'_fmm_lu.mat')));
        disp("FMM-LU solution loaded succesfully!");
    else
        run('m2_fmm_lu_generator.m');
    end
    disp("FMM-LU solution created!");
    cd ..;

    %% 20 INTRODUCE SOURCE DIPOLE
    disp("Placing source dipole..");
    cd(fullfile('2a_setup_dipoles'));
    run('d5_load_dipole_data.m');
    cd ..;
    disp("Done!")

    %% 21 INTRODUCE NOISE
    cd(fullfile('2ab_introduce_noise'));
    if n_shells == 3
        run('n01_load_sample_dipoles.m');
    else
        run('n0_sample_dipole_positions.m');
    end
    cd ..;
    disp("Done!");
    
    %% 30 FORWARD FMM-LU
    disp("RUNNING SIMULATIONS.. Please wait");
    cd(fullfile('2b_forward_simulation'));
    run('f12_charge_engine_lu.m');
    run('f13_create_plots.m');
    cd ..;
    disp("FINISHED SIMULATIONS!");

    %% 40 LOAD FIELDTRIP INVERSE MODEL
    fprintf("Loading FieldTrip model: %s. Please wait..\n", inverse_conductivity);
    cd(fullfile('4_create_fieldtrip_model'));
    run('ft1_load_model.m');
    cd ..;
    disp("FieldTrip model loaded succesfully!");

    %% 41 OBTAIN DIPOLE FITS
    disp("Obtaining dipole fits. Please wait..");
    cd(fullfile('5_dipole_fitting'));
    run('fit3_dipole_fitting_multi.m');
    cd ..;
    disp("Done!")

    %% END -- OUTPUT 
    total_patient_time = toc;
    fprintf("Finished processing %s! The total elapsed time is: %d\n", patno, total_patient_time);
end
