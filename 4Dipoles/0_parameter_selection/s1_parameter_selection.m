%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% s1_conductivity_selection.m                                        %%%
%%% Choose a conductivity set.                                         %%%
%%% This script will generate a model folder and tissue file for the   %%%
%%% selected patient and conductivity set.                             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~skip_user_prompts
    [conductivity_file, cond_dir] = uigetfile(fullfile('../data/conductivity_sets/*.txt'), ...
        'Select a conductivity file');
else
    cond_dir=fullfile('../data/conductivity_sets');
end

cond_sp = split(conductivity_file, '.');
model_name = cond_sp{1};

infile = fopen(fullfile(cond_dir,conductivity_file), 'r');
model_path = fullfile(patient_path,'models',model_name);

if(~isfolder(fullfile(patient_path,'models')))
    mkdir(fullfile(patient_path,'models'));
end
if(~isfolder(model_path))
    mkdir(model_path);
else
    warning("This model folder existed previously! Make sure that the data is saved. Proceeding anyway..");
end

tissue_index = fullfile(model_path, strcat(model_name,'_tissue.txt'));
outfile = fopen(tissue_index, "w");

fprintf(outfile, "%% This tissue file has been automatically generated from %s\n", conductivity_file);
fprintf(outfile, "%% See s1_parameter_selection.m for more details\n\n");

current_line = '';
n_shells = 0;
while(~feof(infile))
    current_line = fgetl(infile);
    current_line = strrep(current_line, ' ', '');
    try
        if current_line(1) ~= '>'
        continue;
        end
    catch
        continue;
    end
    colon_split = split(current_line, {':'});
    if ~isempty(colon_split)
        n_shells = n_shells+1;
        t_name = strcat(patno,'_',colon_split{2},'.stl');
        tissue_files{n_shells} = t_name;
        tissue_names{n_shells} = colon_split{2};
        conductivity_vals(n_shells)=str2double(colon_split{3});
        new_line = strcat(colon_split{1}," : ", ...
                          tissue_files{n_shells}, ...
                          " : ", colon_split{3}, ...
                          " : ", colon_split{4});
    end
    disp(new_line);
    fprintf(outfile,"%s\n",new_line);
end
fclose(outfile);
fclose(infile);
noise_computed=false;

save(fullfile(model_path,strcat(patno,'_metadata')), 'patno', 'model_name', ...
    'patient_path', 'model_path', 'mesh_path', ...
    'tissue_index', 'tissue_files','tissue_names','conductivity_vals','n_shells');
