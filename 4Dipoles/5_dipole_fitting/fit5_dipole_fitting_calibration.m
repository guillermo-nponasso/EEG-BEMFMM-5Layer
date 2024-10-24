%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% fit1_dipole_fitting.m                                               %%%
%%% Fit a dipole for the selected model and raw data                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% general options
do_grid_fit = true;
grid_res = 5e-3;  %m

%% create orig dipole info
orig_dip = load(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',dipole_name,'_data.mat')));

dip0.dip.pos = (orig_dip.strdipolePplus+orig_dip.strdipolePminus)/2;
dip0.vec = orig_dip.strdipolePplus-orig_dip.strdipolePminus;
dip0.dip.mom = dip0.vec/norm(dip0.vec);

fprintf("PROCESSING 3-SHELL NON-AMR DIPOLE FITTING FOR DIPOLE %s. PLEASE WAIT..",dipole_name);
disp(".......................................................");

%% attempt a dipole fitting starting from the original position

% convert units to m (SI)
elec=ft_convert_units(elec,'m');

disp("Dipole fit with real initial value")
cfg = [];
cfg.numdipoles = 1;
cfg.gridsearch = 'no';
cfg.headmodel = head_model;
cfg.dip.pos = dip0.dip.pos;
cfg.elec=elec;

dip = ft_dipolefitting(cfg, raw);
disp("Dipole fit completed!")

%% grid search fit

if do_grid_fit
    fprintf("Computing grid dipole fit, with %dmm of resolution\n", grid_res);
    cfg=[];
    cfg.method = 'basedonresolution';
    cfg.resolution = grid_res;
    cfg.headmodel = head_model;
    cfg.unit='m';
    
    source_model = ft_prepare_sourcemodel(cfg);
    
    cfg = [];
    cfg.numdipoles = 1;
    cfg.gridsearch = 'yes';
    cfg.sourcemodel = source_model;
    cfg.headmodel = head_model;
    cfg.elec=elec;
    cfg.dipfit.optimfun='fminunc';
    
    dip_grid = ft_dipolefitting(cfg, raw);
    disp("Grid dipole fit completed!")

end

%% print stats

dist_dip = 1e3*norm(dip.dip.pos-dip0.dip.pos); % display errror in mm
fprintf("Distance (mm) to source dipole fit: %.4f\n", dist_dip);
cos_angle_dip = dot((dip.dip.mom(:,1)/norm(dip.dip.mom(:,1))),dip0.dip.mom);
fprintf("degrees of angle to source dipole fit: %.2f\n", rad2deg(acos(cos_angle_dip)));

fit_angle = rad2deg(acos(cos_angle_dip));
is_grid=0;
dip_equal=0;
if do_grid_fit
    dist_grid = 1e3*norm(dip_grid.dip.pos-dip0.dip.pos); % display error in mm
    fprintf("Distance (mm) to grid dipole fit: %.4f\n", dist_grid);
    cos_angle_grid = dot((dip_grid.dip.mom(:,1)/norm(dip_grid.dip.mom(:,1))),dip0.dip.mom);
    fprintf("degrees of angle to grid dipole fit: %.2f\n", rad2deg(acos(cos_angle_grid)));
    dip_equal = (round(dist_grid,4)==round(dist_dip,4));
     if(dip_grid.dip.rv<dip.dip.rv)
        dip=dip_grid;
        dist_dip=dist_grid;
        fit_angle = rad2deg(acos(cos_angle_grid));
        is_grid=1;
    end
    if(strcmp(dip.dip.unit,'mm'))
        rescale_m = 1e-3;
    else
        rescale_m = 1;
    end
    dip_mom = rescale_m*norm(dip.dip.mom(:,1));
    original_moment = orig_dip.I0*orig_dip.dipole_length;
    strength_re=abs(dip_mom-original_moment)/original_moment;
end

variable_names = {'Patient','Model','Dipole','Dist_mm','Angle_deg', 'Moment','Str_RE', ...
    'Residual_Variance', 'Is_Grid', 'Grid_eq_Source', 'Total_AMR_steps'};
data_cell = cell(1,length(variable_names));
data_cell(1,1:end)={patno,model_name,dipole_name,dist_dip, fit_angle, dip_mom, strength_re, ...
    dip.dip.rv(1),is_grid, dip_equal, 0};

data_table_folder = fullfile('../data/tables');
if ~isfolder(data_table_folder)
    mkdir(data_table_folder);
end
patient_table_folder =fullfile('../data/tables',patno);
if ~isfolder(patient_table_folder)
    mkdir(patient_table_folder);
end

data_table = cell2table(data_cell,'VariableNames',variable_names);
writetable(data_table, ...
    fullfile(patient_table_folder, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_table.csv')),'WriteMode','overwrite');


if do_grid_fit
    save(fullfile(patient_path,'dipoles',dipole_name,strcat(patno,'_',model_name,'_',dipole_name,'_fitting.mat')), ...
        'dip0','dip','dip_grid','do_grid_fit');
else
    save(fullfile(patient_path,'dipoles',dipole_name,strcat(patno,'_',model_name,'_',dipole_name,'_fitting.mat')), ...
        'dip0','dip','do_grid_fit');
end
