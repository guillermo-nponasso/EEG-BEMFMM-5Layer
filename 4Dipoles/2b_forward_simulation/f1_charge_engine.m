%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% step1_charge_engine.m                                               %%%
%%% Perform the forward field computation for the selected dipole       %%%
%%% Please make sure that the patient, model, and dipole are loaded     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(noise_computed)
    error("Noise has been added to the model. You should prepare and use FMM-LU instead of regular FMM.")
end
%%
restoredefaultpath;
addpath('../engines/bem_fmm_engine/');

underscore_split = split(model_name,'_');
if strcmp(underscore_split{end},'refined')
    is_refined = true;
else
    is_refined = false;
end

%%  Parameters of the iterative solution
iter       = 30;              %    Maximum possible number of iterations in the solution 
relres     = 1e-5;            %    Minimum acceptable relative residual 

weight     = 1/2;             %    Weight of the charge conservation law to be added (empirically found)

%%  Right-hand side b of the matrix equation Zc = b
%   Surface charge density is normalized by eps0: real charge density is eps0*c
tic
%   Gaussian integration is used here
disp("Calculating incident field..");
gaussRadius = 2*R; % Incident fields at triangles within gaussRadius of the center of the dipole cluster will be evaluated using Gaussian subdivision
if(n_shells>3)
    disp("More than 3-shells present. Using global Gauss selective..")
    [Einc, Pinc] = bemf3_inc_field_electric_gauss_selective_dipoles...
    (strdipolePplus, strdipolePminus, strdipolesig, strdipoleCurrent, P, t, Center, Ctr, gaussRadius);
else
    disp("3-shells or less present. Using Gauss..")
    [Einc, Pinc]    = bemf3_inc_field_electric_gauss_dipoles(strdipolePplus, strdipolePminus, ...
              strdipolesig, strdipoleCurrent, P,t);
end
IncFieldTime = toc
disp("Success!");
b        = 2*(contrast.*sum(normals.*Einc, 2));                         %  Right-hand side of the matrix equation

%%  GMRES iterative solution
h           = waitbar(0.5, 'Please wait - Running MATLAB GMRES');  
%   MATVEC is the user-defined function of c equal to the left-hand side of the matrix equation LHS(c) = b
tic
MATVEC = @(c) bemf4_surface_field_lhs(c, Center, Area, contrast, normals, weight, EC);     
[c, its, resvec] = fgmres(MATVEC, b, relres, 'max_iters', 1, 'restart', iter, 'x0', b, 'tol_exit', relres);
close(h);

%%  Plot convergence history
figure; 
semilogy(resvec(1:its(2)), '-o'); grid on;
title('Relative residual of the iterative solution');
xlabel('Iteration number');
ylabel('Relative residual');


%%  Check charge conservation law (optional)
conservation_law_error = sum(c.*Area)/sum(abs(c).*Area)

%%   Topological low-pass solution filtering (repeat if necessary)
% c = (c.*Area + sum(c(tneighbor).*Area(tneighbor), 2))./(Area + sum(Area(tneighbor), 2));

%% create dipole folder if it does not exist

if(~isfolder(fullfile(patient_path,'dipoles',dipole_name)))
    mkdir(fullfile(patient_path,'dipoles',dipole_name));
end

%%  Save solution data (surface charge density, principal value of surface field)

%%   Find and save surface electric potential
Padd = bemf4_surface_field_potential_accurate(c, Center, Area, PC);
Ptot = Pinc + Padd;     %   Continuous total electric potential at interfaces

save(fullfile(patient_path,'dipoles', dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    '_output_charge_solution')), 'c', 'resvec', 'its','Einc', 'P', 't',...
    'normals', 'Center', 'Area', 'Indicator', 'tissue', 'Ptot', '-v7.3');

save(fullfile(patient_path,'dipoles', dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    '_output_efield_solution')), 'Ptot');
