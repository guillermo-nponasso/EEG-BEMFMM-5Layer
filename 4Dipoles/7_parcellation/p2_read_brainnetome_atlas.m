% recall field trip_setup.m file
cd ..;
cd(fullfile('6_misc'));
run("fieldtrip_setup.m");
cd ..;
cd(fullfile('7_parcellation'));

% read The Brainnetome Atlas
brainnetome = ft_read_atlas(fullfile('../engines/fieldtrip', ...
    'template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii'));

imagesc(brainnetome.tissue(:,:,68));
