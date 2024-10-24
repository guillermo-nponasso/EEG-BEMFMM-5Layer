%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% f12_charge_engine_lu.m -- Using FMM-LU, simulate an event given by  %%%
%%% a source dipole. The signal to noise ratio is varied from 0 to a    %%%
%%% maximum value, and from the maximum back to 0, in an                %%%
%%% inverse-quadratic manner.                                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set random seed
rng(314);
clear Ptot_noise Btotal_noise c Ptot_source Btotal_source c_source Ptot
%%
clear ElectrodePositions ElectrodeVoltages ElectrodeLabels
%% general options
noise_computed=true;
dipole_length = 0.4;           % dipole length in (mm) for random dipoles
I0 = 10e-5;                    % maximum current for dipole source
I1 = 10e-5;                    % maximum current for noise dipoles
R = 0.007;                     % Radius of the enclosing sphere 
max_s2n = 2;
%s2n_vec = max_s2n*[0:2/(Ntime_samples-(1+mod(Ntime_samples,2))):1, 1:-2/(Ntime_samples-1):0].^2;
N_strengths = 5;
strength_factor = 9;
min_factor = 3;
strength_powers = min_factor:N_strengths+min_factor;
snr_vec = strength_factor.^strength_powers;
N_simulations = 2;
%%  Add paths for FMM-LU
addpath(fullfile('../engines/bem_fmm_engine/'));
addpath(fullfile("../engines/bem_fmm_engine/flattri_lap_quad-main/src/"));
addpath(fullfile('../3_create_electrode_data'));
%run(fullfile("../engines/bem_fmm_engine/FLAM-master/startup.m"));
run(fullfile("../engines/bem_fmm_engine/strong-skel-master/startup.m"));

%% magnetometer
tissue_to_plot = 'Skin';
objectnumber = find(strcmp(tissue, tissue_to_plot));    
Points = Center(Indicator==objectnumber, :); 
Normals = normals(Indicator==objectnumber, :); 
d = 10e-3; % Magnetometer distance from skin surface
obsPtsMag = Points + d*Normals; % Observation points for magnetic field

%% Load noise dipoles

modelname_split = split(model_name,{'_'});
is_headreco = length(modelname_split)>1 && strcmp(modelname_split{2},'headreco');

if is_headreco
    load(fullfile(patient_path, 'mesh_data', strcat(patno,'_random_dip_pos_headreco.mat')));
else
    load(fullfile(patient_path, 'mesh_data', strcat(patno,'_random_dip_pos.mat')));
end

%%

N_randdip = length(gm_sample_pos);  % number of random dipoles around grey matter

% the first dipole is the source dipole, the rest are noise
% bem-fmm requires the lengths to be in (m), we convert the random dipole 
% coordinates to meters.

% positive positions
dip_plus(1,:)=strdipolePplus;
dip_plus(2:1+N_randdip,:) = 1e-3*(gm_sample_pos + (dipole_length/2)*gm_sample_normals);

% negative positions
dip_min(1,:) =strdipolePminus;
dip_min(2:1+N_randdip,:)  = 1e-3*(gm_sample_pos - (dipole_length/2)*gm_sample_normals);

% dipole centers (these may need to be computed differently, see original code)
strdipolemvector = strdipolePplus - strdipolePminus;
dip_cent(1,:) = strdipolePminus+(1e-3*dipole_length)*(strdipolemvector)/2;
dip_cent(2:N_randdip+1,:) = gm_sample_pos;

% dipole directions
dip_vec(1,:) = strdipolemvector;
dip_vec(2:N_randdip+1,:) = dip_plus(2:N_randdip+1,:)-dip_min(2:N_randdip+1,:);

% dipole current initialization
dip_curr = zeros(2*(N_randdip+1),1);

%% noiseless  simulation
tic
%   Gaussian integration is used here
%gaussRadius     = 2*R; % Incident fields at triangles within gaussRadius of the center of the dipole cluster will be evaluated using Gaussian subdivision
[Einc, Pinc]    = bemf3_inc_field_electric_plain(strdipolePplus, strdipolePminus, ...
              strdipolesig, strdipoleCurrent, Center);
              %P, t, Center);%, dip_cent(m, :), gaussRadius);
b               = 2*(contrast.*sum(normals.*Einc, 2));                         %  Right-hand side of the matrix equation
IncFieldTime = toc;
fprintf("Incident E-field time: %d\n", IncFieldTime);
%  Solve using factorization of inv(A)
tic;
c_source = solve_fds(F, b, Area); 
SolutionTime = toc;
fprintf("Solution using inv(A) time: %.2f\n",SolutionTime);
%   Find and save surface electric potential
tic
Padd     = bemf4_surface_field_potential_accurate(c_source, Center, Area, PC);
Ptot_source     = Pinc + Padd;     %   Continuous total electric potential at interfaces
PotentialTime = toc;
fprintf("Time to compute potential: %.2f\n",PotentialTime);
%   Compute the B-field
tic
Bpri            = bemf3_inc_field_magnetic(strdipolemvector, strdipolemcenter, strdipolemstrength, obsPtsMag, mu0);
BFieldTimeInc   = toc;
fprintf("Time to compute incident B-field: %.2f\n",BFieldTimeInc);
difference      = condin - condout;
Bsec            = bemf5_volume_field_magnetic(obsPtsMag, Ptot_source, P, t, Center, Area, normals, difference, mu0, 0, 0);
Btotal_source          = Bpri + Bsec;
temp            = abs(sqrt(dot(Btotal_source, Btotal_source, 2)));
BFieldTimeSec = toc;
fprintf("Time to compute secondary B-field: %.2f\n", BFieldTimeSec);

save(fullfile('../data/patients',patno,'dipoles',dipole_name,strcat(patno,'_',model_name,'_', ...
    dipole_name,'_forwardsolution_source.mat')),'c_source','Ptot_source','Btotal_source');

%% conductivity
if n_shells == 3
    cond_id = find(strcmp(tissue,'Brain'));
else
    cond_id = find(strcmp(tissue,'GM'));
end
dipole_cond  = cond(cond_id);
dip_sig      = repmat(dipole_cond,2*(1+N_randdip),1);
c            = zeros(length(t),N_strengths, N_simulations);
Ptot_noise   = zeros(length(t),N_strengths, N_simulations);
Ptot         = zeros(length(t),N_strengths, N_simulations);
Btotal_noise = zeros(length(Points),3, N_strengths, N_simulations);
Btotal       = zeros(length(Points),3, N_strengths, N_simulations);
snr_values   = zeros(N_strengths, N_simulations);

%% load skin shell
skin_id            = find(strcmp(tissue,'Skin'));
skin_file          = tissue_files(skin_id);
skin_fullfile      = fullfile(patient_path,'mesh_data',skin_file);
TR_skin            = stlread(skin_fullfile{1});
mesh_skin.P        = TR_skin.Points;
mesh_skin.t        = TR_skin.ConnectivityList;
mesh_skin.normals  = meshnormals(mesh_skin.P, mesh_skin.t);
mesh_skin.Center   = meshtricenter(mesh_skin.P, mesh_skin.t);

%% test electrode placement for source dipoles
Ptot(:,1,1) = Ptot_source;
strength_ix = 1;
simulation_ix = 1;
plot_electrodes = true;
set_electrodes_general;

ElectrodeVoltages_source = ElectrodeVoltages(:,1,1);
ElectrodePositions_source = ElectrodePositions(:,:,1,1);
ElectrodeLabels_source = ElectrodeLabels(:,1,1);

%% repeated 
tic
for strength_ix = 1:N_strengths
    target_snr = snr_vec(strength_ix);
    for simulation_ix = 1:N_simulations
        fprintf("Computing simulation %d/%d. Target SNR: %d. Please wait..\n", simulation_ix, N_simulations, target_snr);
        rand_current = I1*randn(1,N_randdip);
        % compute dipole currents
        % source dipole
        dip_curr(1,:) = +I0;
        dip_curr(N_randdip+2,:) = -I0;
        % random dipoles
        dip_curr(2:N_randdip+1,:) = +rand_current;
        dip_curr(N_randdip+3:2*(N_randdip+1),:)= -rand_current;

        tic
        %   Gaussian integration is used here
        %gaussRadius     = 2*R; % Incident fields at triangles within gaussRadius of the center of the dipole cluster will be evaluated using Gaussian subdivision
        [Einc, Pinc]    = bemf3_inc_field_electric_plain(dip_plus, dip_min, ...
                          dip_sig, dip_curr, Center);
                          %P, t, Center);%, dip_cent(m, :), gaussRadius);
        b               = 2*(contrast.*sum(normals.*Einc, 2));                         %  Right-hand side of the matrix equation
        IncFieldTime = toc;
        fprintf("Incident E-field time: %d\n", IncFieldTime);
        %  Solve using factorization of inv(A)
        tic;
        c(:,strength_ix,simulation_ix) = solve_fds(F, b, Area); 
        SolutionTime = toc;
        fprintf("Solution using inv(A) time: %.2f\n",SolutionTime);
        %   Find and save surface electric potential
        tic
        Padd          = bemf4_surface_field_potential_accurate(c(:,strength_ix,simulation_ix), Center, Area, PC);
        Ptot_noise(:,strength_ix,simulation_ix)     = Pinc + Padd;     %   Continuous total electric potential at interfaces
        PotentialTime = toc;
        fprintf("Time to compute potential: %.2f\n",PotentialTime);

        Ptot(:,strength_ix,simulation_ix) = Ptot_source + Ptot_noise(:,strength_ix,simulation_ix);
        % place dipoles and obtain voltages
        plot_electrodes = false;
        set_electrodes_general;
        % calculate the current SNR
        std_noise  = std(ElectrodeVoltages(:,strength_ix,simulation_ix));
        max_signal = max(abs(ElectrodeVoltages(:,strength_ix,simulation_ix)));
        fprintf("Done! The resulting SNR is: %d\n", max_signal/std_noise);

        % modify the potential to obtain the target SNR
        noise_multiplier = std_noise*target_snr/max_signal;
        Ptot(:,strength_ix,simulation_ix) = Ptot_source + Ptot_noise(:,strength_ix,simulation_ix)/noise_multiplier;
        set_electrodes_general; % set electrodes with modified potential
        max_signal_adjusted = max(abs(ElectrodeVoltages(:,strength_ix,simulation_ix)));
        std_noise_adjusted  = std(ElectrodeVoltages(:,strength_ix,simulation_ix)/noise_multiplier);
        snr_adjusted        = max_signal_adjusted/std_noise_adjusted;
        snr_values(strength_ix,simulation_ix) = snr_adjusted;
        fprintf("Done! The adjusted SNR is : %d\n", max_signal_adjusted/(std_noise_adjusted));
        fprintf("SNR with original Ptot: %d\n", max_signal/(std_noise/noise_multiplier));
    end
end
total_time = toc;
fprintf("Done!\n")
fprintf("Total computation time: %d\n", total_time);
%% timecourse simulation
% %parpool(Ntime_samples)
% 
% for time_index=1:Ntime_samples % one simulation for each time sample
%     fprintf("Computing time sample %d/%d. Please wait..\n",time_index,Ntime_samples);
%     s2n_ratio = s2n_vec(time_index);
%     fprintf("The target signal-to-noise ratio is: %.4f\n", s2n_ratio);
%     rand_current = +min(I0,2*I0/s2n_ratio)*rand(1,N_randdip);
% 
%     % compute dipole currents
%     % source dipole
%     dip_curr(1,:) = +(I0*s2n_ratio/2);%*s2n_ratio;
%     dip_curr(N_randdip+2,:) = -(I0*s2n_ratio/2);%*s2n_ratio;
%     % random dipoles
%     dip_curr(2:N_randdip+1,:) = +rand_current;
%     dip_curr(N_randdip+3:2*(N_randdip+1),:)= -rand_current;
% 
%     fprintf("The signal-to-noise ratio is: %.4f\n", dip_curr(1,:)/mean(dip_curr(2:N_randdip+1,:)));
%     fprintf("The source dipole strength is: %d\n", dip_curr(1,:));
%     fprintf("The average random dipole strength is: %d\n", mean(dip_curr(2:N_randdip+1,:)));
% 
%     % begin computation
%     tic
%     %   Gaussian integration is used here
%     %gaussRadius     = 2*R; % Incident fields at triangles within gaussRadius of the center of the dipole cluster will be evaluated using Gaussian subdivision
%     [Einc, Pinc]    = bemf3_inc_field_electric_plain(dip_plus, dip_min, ...
%                       dip_sig, dip_curr, Center);
%                       %P, t, Center);%, dip_cent(m, :), gaussRadius);
%     b               = 2*(contrast.*sum(normals.*Einc, 2));                         %  Right-hand side of the matrix equation
%     IncFieldTime = toc;
%     fprintf("Incident E-field time: %d\n", IncFieldTime);
%     %  Solve using factorization of inv(A)
%     tic;
%     c = solve_fds(F, b, Area); 
%     SolutionTime = toc;
%     fprintf("Solution using inv(A) time: %.2f\n",SolutionTime);
%     %   Find and save surface electric potential
%     tic
%     Padd          = bemf4_surface_field_potential_accurate(c, Center, Area, PC);
%     Ptot(:,time_index)     = Pinc + Padd;     %   Continuous total electric potential at interfaces
%     PotentialTime = toc;
%     fprintf("Time to compute potential: %.2f\n",PotentialTime);
%     %   Compute the B-field
%     tic
%     Bpri            = bemf3_inc_field_magnetic(dip_vec, dip_cent, dip_curr(1:N_randdip+1,:), obsPtsMag, mu0);
%     BFieldTimeInc   = toc;
%     fprintf("Time to compute incident B-field: %.2f\n",BFieldTimeInc);
%     difference      = condin - condout;
%     Bsec            = bemf5_volume_field_magnetic(obsPtsMag, Ptot(:,time_index), P, t, Center, Area, normals, difference, mu0, 0, 0);
%     Btotal(:,:,time_index)     = Bpri + Bsec;
%     temp            = abs(sqrt(dot(Btotal, Btotal, 2)));
%     BFieldTimeSec = toc;
%     fprintf("Time to compute secondary B-field: %.2f\n", BFieldTimeSec);
% 
% end
% fprintf("Done!\n")
%% save solution
fprintf("Saving solution..\n");
save(fullfile(patient_path,'dipoles', dipole_name, strcat(patno,'_',model_name,'_',dipole_name, ...
    '_output_efield_solution_noise')), 'Ptot_noise', 'Ptot', 'ElectrodeVoltages', 'ElectrodeLabels','ElectrodePositions','-v7.3');
fprintf("Done!\n");