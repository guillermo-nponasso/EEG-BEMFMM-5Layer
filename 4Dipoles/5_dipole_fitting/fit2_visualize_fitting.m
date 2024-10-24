%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% bem_1_visualize_dipoles.m                                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load BEM-FMM engine and utils
restoredefaultpath;
addpath(fullfile('../engines/bem_fmm_engine'));
addpath(fullfile('../engines/graphics'));

%% load fitting data

load(fullfile(dipole_folder,strcat(patno,'_',model_name,'_',dipole_name,'_fitting.mat')));

%% load skin file
skin_file   = fullfile(patient_path,'mesh_data',strcat(patno,'_skin_remesh.stl'));
TR          = stlread(skin_file);
P           = TR.Points;
t           = TR.ConnectivityList;
normals     = meshnormals(P, t);


position1 = dip0.dip.pos;
moment1 = dip0.dip.mom;

fprintf("Distance (mm) to source dipole fit: %.4f\n", norm(dip.dip.pos-dip0.dip.pos));
cos_angle_dip = dot((dip.dip.mom(:,1)/norm(dip.dip.mom(:,1))),dip0.dip.mom);
fprintf("degrees of angle to source dipole fit: %.2f\n", rad2deg(acos(cos_angle_dip)));


position2 = dip.dip.pos;
moment2   = dip.dip.mom(:,1)'/norm(dip.dip.mom(:,1));

fig=figure
hold on

p = patch('vertices', P, 'faces', t);
p.FaceColor = [1 0.75 0.65];
p.EdgeColor = 'none';
p.FaceAlpha = 0.5;
daspect([1 1 1]);
camlight; lighting phong;
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');

utils_display_dipole(position1+5*moment1, position1-5*moment1, 'c');


view(-150, 15);
set(gca,'color','k')


if do_grid_fit
    position3 = dip.dip.pos;
    moment3   = dip.dip.mom(:,1)'/norm(dip.dip.mom(:,1));

    dist2 = norm(position1-position2);
    dist3 = norm(position1-position3);

    if(dist2<dist3)
        utils_display_dipole(position2+5*moment2, position2-5*moment2, 'm');
    else
        utils_display_dipole(position3+5*moment3, position3-5*moment3, 'y');
    end
    fprintf("Distance (mm) to grid dipole fit: %.4f\n", norm(dip_grid.dip.pos-dip0.dip.pos));
    cos_angle_grid = dot((dip_grid.dip.mom(:,1)/norm(dip_grid.dip.mom(:,1))),dip0.dip.mom);
    fprintf("degrees of angle to grid dipole fit: %.2f\n", rad2deg(acos(cos_angle_grid)));
else
    utils_display_dipole(position2+5*moment2, position2-5*moment2, 'm');
end

if ~isfolder(fullfile('../data/images',patno))
    mkdir(fullfile('../data/images',patno));
end
saveas(fig,fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name,'_fitting.png')),'png');
