%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% wrapper_full_calibration.m -- A wrapper for the calibration runtime. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function []=wrapper_3shell(pat_ix, model, inverse_model)

pat_cell = {'110411','117122','120111','122317','122620','124422','128632','130013','131722','138534','149337','149539','151627','160123','198451'};
fprintf("pat_ix=%s" ,pat_ix);
pat_ix = str2num(pat_ix);
patno  = pat_cell{pat_ix};
fprintf("Processing patient %s..\n",patno);


%% go to root
cd ..; % 6_misc
cd ..; % root

if ~isfolder(fullfile('data/images'))
    mkdir(fullfile('data/images'));
end

if ~isfolder(fullfile('data/images',patno))
    mkdir(fullfile('data/images',patno));
end

%% global options (change this according to the node)
conductivity_file = sprintf("%s.txt",model);
inverse_conductivity = inverse_model;
skip_user_prompts = true; % do not change this option

skip_FMM_LU_creation = false;  % select true to load FMM-LU solution instead
NDipoles=4;

%% select patient
for dip_ix = 1:NDipoles
    dipole_name = sprintf('dip%d.txt',dip_ix);
    %% 00 PATIENT SELECTION
    fprintf("Processing patient %s\n", patno);
    tic
    cd(fullfile('0_parameter_selection'));
    run('s0_patient_selection.m');
    cd ..;
    %% 01 CONDUCTIVITY SELECTION: SWISS7
    skip_user_prompts=true;      
    cd(fullfile('0_parameter_selection'));
    run('s1_parameter_selection.m');
    cd ..;

    %% 10 CREATE BEM-FMM MODEL
    cd(fullfile('1_create_bemfmm_model'));
    disp("Creating BEM-FMM model..");
    run('m1_load_meshmodel.m');
    disp("BEM-FMM model created!");
    cd ..;

    %% 20 INTRODUCE SOURCE DIPOLE
    disp("Placing source dipole..");
    cd(fullfile('2a_setup_dipoles'));
    run('d5_load_dipole_data.m')
    cd ..;
    disp("Done!")
    
    %% 30 FORWARD NON-AMR
    disp("RUNNING FORWARD ADAPTATIVE SOLUTION.. Please wait");
    cd(fullfile('2b_forward_simulation'));
    run('f1_charge_engine.m');
    run('f2_surface_field_p.m');
    run('f2_surface_field_b.m');
    run('f3_save_forwardp_3shellonly.m');
    cd ..;
    disp("FINISHED FORWARD SOLUTION!");
    
    %% SETUP FIELDTRIP
    cd(fullfile('6_misc'));
    run('fieldtrip_setup.m');
    cd ..;


    %% 32 GETTING ELECTRODE DATA
    cd(fullfile('2b_forward_simulation'));
    cd ..;
    cd (fullfile('3_create_electrode_data'));
    run('e0_set_electrodes.m');
    run('e1_prepare_raw_data.m');
    cd ..;

    %% 40 LOAD FIELDTRIP INVERSE MODEL
    fprintf("Loading FieldTrip model: %s. Please wait..\n", inverse_conductivity);
    cd(fullfile('4_create_fieldtrip_model'));
    run('ft1_load_model.m');
    cd ..;
    disp("FieldTrip model loaded succesfully!");

    %% 50 OBTAIN DIPOLE FITS
    disp("Obtaining dipole fits. Please wait..");
    cd(fullfile('5_dipole_fitting'));
    run('fit5_dipole_fitting_calibration.m');
    cd ..;
    disp("Done!")

    %% END -- OUTPUT 
    total_patient_time = toc;
    fprintf("Finished processing %s! The total elapsed time is: %d\n", patno, total_patient_time);
end
