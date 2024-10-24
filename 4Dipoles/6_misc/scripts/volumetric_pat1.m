function volumetric_pat1(dip_num)
	patno='117122'
	model='german7_refined'
	inverse_model='german3'
	skip_user_prompts=true;
	dipole_name=sprintf("dip%s.txt",dip_num);

	conductivity_file = sprintf("%s.txt",model);
	inverse_conductivity = inverse_model;
	
	fprintf("Processing dipole %s..\n",dipole_name);
	% go to root
	cd ..;
	cd ..;

	%% 00 PATIENT SELECTION
	fprintf("Processing patient %s\n", patno);
	tic
	cd(fullfile('0_parameter_selection'));
	run('s0_patient_selection.m');
	cd ..;
	%% 01 CONDUCTIVITY SELECTION: SWISS7
	cd(fullfile('0_parameter_selection'));
	run('s1_parameter_selection.m');
	cd ..;

	%% 10 CREATE BEM-FMM MODEL
	cd(fullfile('1_create_bemfmm_model'));
	disp("Loading BEM-FMM model..");
	run('m1_load_meshmodel.m');
	disp("BEM-FMM model created!");
	cd ..;

	%% 20 INTRODUCE SOURCE DIPOLE
	disp("Placing source dipole..");
	cd(fullfile('2a_setup_dipoles'));
	run('d1_setup_dipoles.m');
	cd ..;
	disp("Done!")

	%% 30 FORWARD AMR
	disp("RUNNING FORWARD ADAPTATIVE SOLUTION.. Please wait");
	cd(fullfile('2b_forward_simulation'));
	%run('f1_charge_engine.m');
	%run('f2_charge_engine_adaptive.m');
	%run('f2a_final_global_subdiv.m');
	run('f5_define_vol_planes.m');
	run('f6_volume_plots_XY.m');
	run('f6_volume_plots_XZ.m');
	run('f6_volume_plots_YZ.m');
	cd ..;
	disp("FINISHED FORWARD SOLUTION!");
