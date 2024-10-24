
%% load adaptative solution
load(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_charge_solution_adapt')));

%% create figures
figure;
semilogy(100*Conv.ErrorC, '-o'); grid on; title('Error percentage - global C');
xlabel('Adaptive pass number'); ylabel('% change')
savefig(fullfile('../data/images',patno, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    'convergenceC_Error')));

figure;
semilogy(100*Conv.ErrorV, '-o'); grid on; title('Error percentage - Electrode voltages');
xlabel('Adaptive pass number'); ylabel('% change')
savefig(fullfile('../data/images',patno, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    'convergenceP_Error')));

figure
plot(Conv.Its, '-o'); grid on; title('Number of GMRES iterations at every adaptive step');
savefig(fullfile('../data/images',patno, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    'convergenceGMRESIters')));

xlabel('Adaptive pass number'); ylabel('Number of GMRES iterations');


figure
plot(Conv.Facets, '-o'); grid on; title('Model size at every adaptive step');
savefig(fullfile('../data/images',patno, ...
    strcat(patno,'_',model_name,'_',dipole_name, ...
    'convergenceModelSizes')));
xlabel('Adaptive pass number'); ylabel('Number of facets in model');
