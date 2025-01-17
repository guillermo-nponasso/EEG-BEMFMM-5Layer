%% Set up list of models to evaluate

for j = 1:1
    %% Figure set 1: potential on skin surface
    % Make figure for no-adapt case
    solnNoAdapt = load(fullfile(patient_path,'dipoles', dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    '_output_charge_solution')));
    potNoAdapt = load(fullfile(patient_path,'dipoles', dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    '_output_efield_solution')));
    figure;
    tissueToPlot = 'Skin';
    idxToPlot = solnNoAdapt.Indicator(:, 1) == find(strcmp(solnNoAdapt.tissue, tissueToPlot));
    tempP = potNoAdapt.Ptot(idxToPlot) * 1e6;
    bemf2_graphics_surf_field(solnNoAdapt.P, solnNoAdapt.t, tempP, ones(sum(idxToPlot), 1), 1);
    title(['Non-adaptive solution:' newline 'Electric potential (\muV) on skin surface']);
    view(-60, 35);
    camlight;
    set(gca,'CLim',[min(tempP) max(tempP)]);
    clim([min(tempP) max(tempP)]);
    f1 = gcf;
    axNoAdapt = gca; %colorLims = axNoAdapt.CLim;
    
    % Make figure for adaptive case
    solnAdapt = load(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_charge_solution_adapt')));
    potAdapt = load(fullfile(patient_path,'dipoles', dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_potentials_adapt')));
    figure;
    tissueToPlot = 'Skin';
    idxToPlot = solnAdapt.Indicator(:, 1) == find(strcmp(solnAdapt.tissue, tissueToPlot));
    tempP = potAdapt.Ptot(idxToPlot) * 1e6;
    bemf2_graphics_surf_field(solnAdapt.P, solnAdapt.t, tempP, ones(sum(idxToPlot), 1), 1);
    title(['Adaptive solution:' newline 'Electric potential (\muV) on skin surface']);
    view(-60, 35);
    camlight;
    set(gca,'CLim',[min(tempP) max(tempP)]);
    clim([min(tempP) max(tempP)]);
    f2 = gcf;
    axAdapt = gca;
    
    
    % Make figure for adaptive-plus-global case
    solnAdaptGlobal = load(fullfile(patient_path,'dipoles',dipole_name, ...
strcat(patno,'_',model_name,'_',dipole_name,'_charge_solution_adaptGlobal')));
    potAdaptGlobal = load(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_potentials_adaptGlobal')));
    figure;
    tissueToPlot = 'Skin';
    idxToPlot = solnAdaptGlobal.Indicator(:, 1) == find(strcmp(solnAdaptGlobal.tissue, tissueToPlot));
    tempP = potAdaptGlobal.Ptot(idxToPlot) * 1e6;
    bemf2_graphics_surf_field(solnAdaptGlobal.P, solnAdaptGlobal.t, tempP, ones(sum(idxToPlot), 1), 1);
    title(['Adaptive plus global refinement solution:' newline 'Electric potential (\muV) on skin surface']);
    view(-60, 35);
    camlight;
    set(gca,'CLim',[min(tempP) max(tempP)]);
    clim([min(tempP) max(tempP)]);
    f3 = gcf;
    axAdaptGlobal = gca;
    
    % Update axis limits for consistency
    %allLims = [axNoAdapt.CLim; axAdapt.CLim; axAdaptGlobal.CLim];
    %allLims = [min(allLims(:, 1)) max(allLims(:, 2))];
    %axNoAdapt.CLim = allLims; axAdapt.CLim = allLims; axAdaptGlobal.CLim = allLims;
    
    
    %% Figure set 2: Absolute differences in potential on skin surfaces
        
    % Difference between potentials for nonadaptive case versus adaptive-plus-global case
    figure;
    tissueToPlot = 'Skin';
    idxToPlot = solnNoAdapt.Indicator(:, 1) == find(strcmp(solnNoAdapt.tissue, tissueToPlot));
    tempP1 = potNoAdapt.Ptot(idxToPlot) * 1e6; % Convert to microvolts
    
    idxToPlot = solnAdaptGlobal.Indicator(:, 1) == find(strcmp(solnAdaptGlobal.tissue, tissueToPlot));
    tempP2 = potAdaptGlobal.Ptot(idxToPlot) * 1e6; % Convert to microvolts
    
    tempP = tempP1 - tempP2;
    
    bemf2_graphics_surf_field(solnNoAdapt.P, solnNoAdapt.t, tempP, ones(sum(idxToPlot), 1), 1);
    title(['Difference: nonadaptive solution minus adaptive-plus-global solution.' newline 'Electric potential (\muV) on skin surface']);
    view(-60, 35);
    camlight;
    set(gca,'CLim',[min(tempP) max(tempP)]);
    clim([min(tempP) max(tempP)]);
    f4 = gcf;
    
    % Difference between potentials for nonadaptive case versus adaptive case
    figure;
    tissueToPlot = 'Skin';
    idxToPlot = solnNoAdapt.Indicator(:, 1) == find(strcmp(solnNoAdapt.tissue, tissueToPlot));
    tempP1 = potNoAdapt.Ptot(idxToPlot) * 1e6; % Convert to microvolts
    
    idxToPlot = solnAdapt.Indicator(:, 1) == find(strcmp(solnAdapt.tissue, tissueToPlot));
    tempP2 = potAdapt.Ptot(idxToPlot) * 1e6; % Convert to microvolts
    
    tempP = tempP1 - tempP2;
    
    bemf2_graphics_surf_field(solnNoAdapt.P, solnNoAdapt.t, tempP, ones(sum(idxToPlot), 1), 1);
    title(['Difference: nonadaptive solution minus adaptive solution.' newline 'Electric potential (\muV) on skin surface']);
    view(-60, 35);
    camlight;
    set(gca,'CLim',[min(tempP) max(tempP)]);
    clim([min(tempP) max(tempP)]);
    f5 = gcf;
    
    
    % Difference between potentials for adaptive case versus adaptive-plus-global case
    figure;
    tissueToPlot = 'Skin';
    idxToPlot = solnAdapt.Indicator(:, 1) == find(strcmp(solnAdapt.tissue, tissueToPlot));
    tempP1 = potAdapt.Ptot(idxToPlot) * 1e6; % Convert to microvolts
    
    idxToPlot = solnAdaptGlobal.Indicator(:, 1) == find(strcmp(solnAdaptGlobal.tissue, tissueToPlot));
    tempP2 = potAdaptGlobal.Ptot(idxToPlot) * 1e6; % Convert to microvolts
    
    tempP = tempP1 - tempP2;
    
    bemf2_graphics_surf_field(solnNoAdapt.P, solnNoAdapt.t, tempP, ones(sum(idxToPlot), 1), 1);
    title(['Difference: adaptive solution minus adaptive-plus-global solution.' newline 'Electric potential (\muV) on skin surface']);
    view(-60, 35);
    camlight;
    set(gca,'CLim',[min(tempP) max(tempP)]);
    clim([min(tempP) max(tempP)]);
    f6 = gcf;
    
    
    image_suff  = fullfile('../data/images',patno, ... 
    strcat(patno,'_',model_name,'_',dipole_name,'_PotentialSkin'));

    ps_noadapt              = strcat(image_suff,'_noadapt');
    ps_adapt                = strcat(image_suff,'_adapt'); 
    ps_adaptGlobal          = strcat(image_suff,'_adaptGlobal');
    psd_noadapt_adaptGlobal = strcat(image_suff,'Diff_noadapt_adaptGlobal');
    psd_noadapt_adapt       = strcat(image_suff,'Diff_noadapt_adapt');
    psd_adapt_adaptGlobal   = strcat(image_suff,'Diff_adapt_adaptGlobal');
    drawnow;

    saveas(f1, ps_noadapt);
    saveas(f2, ps_adapt);
    saveas(f3, ps_adaptGlobal);
    saveas(f4, psd_noadapt_adaptGlobal);
    saveas(f5, psd_noadapt_adapt);
    saveas(f6, psd_adapt_adaptGlobal);
end