
% Initial electrode voltages prior to final subdivision step
cd ..;
cd(fullfile('3_create_electrode_data'));
run('set_electrodes_amr.m');
cd ..;
cd(fullfile('2b_forward_simulation'));

Vold = ElectrodeVoltages;
%% Global subdivision

tic
[cinterp, P, t, normals, Center, Area, Indicator, percentage] ...
    = meshadapt(c, P, t, normals, Area, Indicator, tissue, 1.0, 0.0);
meshFullSubdivTime = toc

%% Recompute solution

%   Assign new conductivity contrasts for all interfaces
contrast    = zeros(size(t, 1), 1);
condin      = zeros(size(t, 1), 1);
condout     = zeros(size(t, 1), 1);
for m = 1:length(tissue)
    contrast(Indicator==m)  = (condinner(m) - condouter(m))/(condinner(m) + condouter(m));
    condin(Indicator==m)    = condinner(m);
    condout(Indicator==m)   = condouter(m);
    if meshcut(m)
        temp    = Center(Indicator==m, :);
        Taper   = taper(temp, Zcut, 1e-3*taperwidth);
        contrast(Indicator==m) = contrast(Indicator==m).*Taper;
    end 
end


%   Compute accurate integration for electric field/electric potential on all neighbor facets
tic
ineighborE      = knnsearch(Center, Center, 'k', RnumberE)';   % [1:N, 1:RnumberE]
ineighborP      = knnsearch(Center, Center, 'k', RnumberP)';   % [1:N, 1:RnumberP]
%% Neighbor integrals
warning off
tic
EC                  = meshneighborints_En_parallel(P, t, normals, Area, Center, RnumberE, ineighborE, numThreads);
Neighbor.EnTime = toc;
tic
[PC, integralpd]    = meshneighborints_Pn_parallel(P, t, normals, Area, Center, RnumberP, ineighborP, Indicator, numThreads);
Neighbor.Ptime = toc;
disp(Neighbor)
warning on

%   Normalize sparse matrix EC by variable contrast (for speed up)
N   = size(Center, 1);
ii  = ineighborE;
jj  = repmat(1:N, RnumberE, 1); 
CO  = sparse(ii, jj, contrast(ineighborE));
EC  = CO.*EC;
MeshNeighborTime = toc

% Incident E-field
[Einc, Pinc] = bemf3_inc_field_electric_gauss_dipoles(strdipolePplus, strdipolePminus, strdipolesig, strdipoleCurrent, P, t);
% NOTE: The above seems to be valid for both 3-shell and 7-shell models

% GMRES solution
b        = 2*(contrast.*sum(normals.*Einc, 2));                         %  Right-hand side of the matrix equation
MATVEC = @(c) bemf4_surface_field_lhs(c, Center, Area, contrast, normals, weight, EC);     
ind                             = 1;                %   Will re-run gmres if NaN
while ind                   
    [c, its, resvec]                = fgmres(MATVEC, b, relres, 'max_iters', 1, 'restart', iter, 'x0', cinterp, 'tol_exit', relres);
    if ~isnan(resvec(end)); ind = 0; end
end

%   Find surface electric potential/electrode voltages
Padd                    = bemf4_surface_field_potential_accurate(c, Center, Area, PC);
Ptot                    = Pinc + Padd;     %   Continuous total electric potential at interfaces 

cd ..;
cd(fullfile('3_create_electrode_data'));
run('set_electrodes_amr.m');
cd ..;
cd(fullfile('2b_forward_simulation'));

V = ElectrodeVoltages;
%   End of recompute solution
ErrorCFinal      = norm(c - cinterp)/norm(cinterp);
ErrorVFinal      = norm(V - Vold)/norm(Vold);
ItsFinal         = its(2);

close all hidden;
if ~isreal(c)
    error('Recompute! c is complex');
end

% For consistency
Ppri = Pinc;
Psec = Padd;

save(fullfile(patient_path,'dipoles',dipole_name, ...
strcat(patno,'_',model_name,'_',dipole_name,'_charge_solution_adaptGlobal')), ...
    'Einc', 'c', 'P', 't', 'normals', 'Area', 'Center', ...
    'Indicator', 'tissue', '-v7.3');
save(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_potentials_adaptGlobal')), ...
    'Ppri', 'Psec', 'Ptot');
save( fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_errors_adaptGlobal')), ...
    'ErrorCFinal', 'ErrorVFinal');
