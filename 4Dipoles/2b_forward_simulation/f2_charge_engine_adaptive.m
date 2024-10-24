%   This script computes the induced surface charge density for an
%   inhomogeneous multi-tissue object given the primary excitation, with
%   accurate neighbor integration
%
%   SNM 2022

%% load bem-fmm engine
addpath(fullfile('../engines/bem_fmm_engine'));

% attempt to avoid repeated crashes in the parallel pool
%myCluster = parcluster('Processes')
%delete(myCluster.Jobs)

%% start parallel pool
tic
numThreads      = 12;   %   number of cores to be used
ppool           = gcp('nocreate');
if isempty(ppool)
    parpool(numThreads);
end
disp([newline 'Started parallel pool in ' num2str(toc) ' s']);
  
%% define options

ADAPT           = 16;                        %   number of adaptive passes
alpha           = 0.0;                      %   mesh smoothing at every pass
refinement      = 0.01;                     %   refinement rate
maxRefSteps     = 30;                       %   Maximum number of adaptive refinement passes permitted
refQuitTol      = 0.01;                     %   Terminate adaptive refinement when E-field error is smaller than this tolerance
RnumberE        = 4;
RnumberP        = 4;
iter            = 50;                       %   maximum possible number of iterations in the solution 
relres          = 1e-5;                     %   minimum acceptable relative residual 
prec            = 1e-6;
weight          = 1/2;                      %   current conservation law in the weak form

%% load skin shell for electrode placement
skin_id            = find(strcmp(tissue,'Skin'));
skin_file          = tissue_files(skin_id);
skin_fullfile      = fullfile(patient_path,'mesh_data',skin_file);
TR_skin            = stlread(skin_fullfile{1});
mesh_skin.P        = TR_skin.Points;
mesh_skin.t        = TR_skin.ConnectivityList;
mesh_skin.normals  = meshnormals(mesh_skin.P, mesh_skin.t);
mesh_skin.Center   = meshtricenter(mesh_skin.P, mesh_skin.t);
%% start AMR loop

for adapt = 1:maxRefSteps
    disp(['Starting adaptive pass ' num2str(adapt)]);
    Conv.Facets(adapt)          = size(t, 1);
    
    % call electrode positioning with the current solution
    cd ..;
    cd(fullfile('3_create_electrode_data'));
    run('set_electrodes_amr.m');
    cd ..;
    cd(fullfile('2b_forward_simulation'));

    Vold = ElectrodeVoltages;
    %   Interpolate solution
        tic
        [cinterp, P, t, normals, Center, Area, Indicator, percentage] ...
                                    = meshadapt(c, P, t, normals, Area, Indicator, tissue, refinement, alpha);
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

        % Calculate primary field
        if(n_shells>3)
            disp("More than 3-shells present. Using global Gauss selective..")
            [Einc, Pinc] = bemf3_inc_field_electric_gauss_selective_dipoles...
            (strdipolePplus, strdipolePminus, strdipolesig, strdipoleCurrent, P, t, Center, Ctr, gaussRadius);
        else
            disp("3-shells or less present. Using Gauss..")
            [Einc, Pinc]    = bemf3_inc_field_electric_gauss_dipoles(strdipolePplus, strdipolePminus, ...
            strdipolesig, strdipoleCurrent, P,t);
        end

        MeshAdaptTime               = toc
        Conv.percentage(adapt, :)   = percentage;
    %   Compute accurate integration for electric field/electric potential on all neighbor facets
        tic
        ineighborE      = knnsearch(Center, Center, 'k', RnumberE)';   % [1:N, 1:RnumberE]
        ineighborP      = knnsearch(Center, Center, 'k', RnumberP)';   % [1:N, 1:RnumberP]
        % Neighbor integrals
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
        MeshNeighborTime               = toc
    %   GMRES solution
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
        % call electrode positioning with the current solution
        cd ..;
        cd(fullfile('3_create_electrode_data'));
        run('set_electrodes_amr.m');
        cd ..;
        cd(fullfile('2b_forward_simulation'));

        V = ElectrodeVoltages;
        %   End of recompute solution
        Conv.ErrorC(adapt)      = norm(c - cinterp)/norm(cinterp);
        Conv.ErrorV(adapt)      = norm(V - Vold)/norm(Vold);
        Conv.Its(adapt)         = its(2);
        Conv.VAll{adapt} = V;
        Conv.PTotAll{adapt} = Ptot;
        Conv.cAll{adapt} = c;
        disp(Conv)
        close all hidden;
        if ~isreal(c)
            error('Recompute! c is complex');
        end
        
        
    if Conv.ErrorV(adapt) < refQuitTol
        disp('Terminating because target error threshold was reached');
        break;
    end
end

total_adapt_steps = adapt;

% For consistency
Ppri = Pinc;
Psec = Padd;

save(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_charge_solution_adapt')), ...
    'Einc', 'c', 'Conv', 'P', 't', 'normals', 'Area', 'Center', ...
    'Indicator', 'tissue', 'total_adapt_steps', '-v7.3');

save(fullfile(patient_path,'dipoles', dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_potentials_adapt')), ...
    'Ppri', 'Psec', 'Ptot');
