function []=create_ft_model(pat_ix, model)
	pat_cell = {'110411','117122','120111','122317','122620','124422','128632','130013','131722','138534','149337','149539','151627','160123','198451'};
	pat_cell
	fprintf("pat_ix=%s" ,pat_ix);
	pat_ix = str2num(pat_ix);
	patno  = pat_cell{pat_ix};
	% select patient
	cd ..;
	cd ..;
	skip_user_prompts = true;
	cd(fullfile('0_parameter_selection'));
	run('s0_patient_selection.m');

	% select conductivity
	conductivity_file = sprintf("%s.txt",model);
	run('s1_parameter_selection.m');
	cd ..;

	% setup fieldtrip
	cd(fullfile('6_misc'));
	run('fieldtrip_setup.m');
	cd ..;

	% create FT model
	cd(fullfile('4_create_fieldtrip_model'));
	run('ft0_create_model.m');
    cd ..;
    
