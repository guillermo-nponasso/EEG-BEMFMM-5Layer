%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% bem3_save_forwardp.m                                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% process
if n_shells~=3
    error("This script is meant to be used only by 3-shell models!");
end
tissue_to_plot = 'Skin';
objectnumber   = find(strcmp(tissue, tissue_to_plot));
LR = [];
LR.P           = P(Indicator==objectnumber,:);
LR.t           = t(Indicator==objectnumber,:);
LR.temp        = Ptot(Indicator==objectnumber);
LR.normals     = meshnormals(LR.P, LR.t);
LR.Center      = meshtricenter(LR.P,LR.t);
%tempCenter     = Center(Indicator==objectnumber, :);

save(fullfile(patient_path,'dipoles', dipole_name, strcat(patno,'_',model_name,'_',dipole_name,'_forwardsolution_3shell_p')),'LR');

