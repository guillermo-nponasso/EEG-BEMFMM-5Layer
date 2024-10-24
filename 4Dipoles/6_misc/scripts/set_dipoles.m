%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% wrapper_full_calibration.m -- A wrapper for the calibration runtime. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function []=set_dipoles(pat_ix)
model = 'german7';
inverse_model = 'german3';
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
    %% 01 CONDUCTIVITY SELECTION: GERMAN7
    skip_user_prompts=true;      % this must be activated to skip user prompt
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
    run('d1_setup_dipoles.m');
    run('d2_load_nifti.m');
    run('d3_inspectXY.m');
    run('d3_inspectXY_zoom.m');
    run('d4_inspectYZ.m');
    run('d4_inspectYZ_zoom.m');
    run('d5_inspectXZ.m');
    run('d5_inspectXZ_zoom.m');
    cd ..;
    disp("Done!");

    %% END -- OUTPUT 
    total_patient_time = toc;
    fprintf("Finished processing %s! The total elapsed time is: %d\n", patno, total_patient_time);
end
