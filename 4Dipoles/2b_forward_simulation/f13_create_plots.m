%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% f13_create_plots -- Create the surface potential, and surface magne- %%
%%% -tic field plots for the dipole source with no noise.                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eps0        = 8.85418782e-012;  %   Dielectric permittivity of vacuum(~air)
mu0         = 1.25663706e-006;  %   Magnetic permeability of vacuum(~air)

%% load bem-fmm engine

addpath(fullfile('../engines/bem_fmm_engine'));

%%   Graphics
tissue_to_plot = 'Skin';
objectnumber    = find(strcmp(tissue, tissue_to_plot));

%% Surface potential
fig=figure;
step = 10;
temp            = Ptot_source(Indicator==objectnumber);
%temp = round(step*temp/max(temp)).*(max(temp))/step;
bemf2_graphics_surf_field(P, t, temp, Indicator, objectnumber);
title(strcat("Patient: ",patno," Model: ",model_name, ...
" Electric potential in V for: ", tissue{objectnumber}));
view(-70, 70); colormap jet;

pat_image_path = fullfile('../data/images',patno);
if(~isfolder(pat_image_path))
mkdir(pat_image_path);
end
saveas(fig,fullfile(pat_image_path,strcat(patno,'_',model_name,'_forwardp')),'png')

%% Surface magnetic field

temp = abs(sqrt(dot(Btotal_source, Btotal_source, 2)));
fig=figure;
step = 20;
%temp = round(step*temp/max(temp)).*(max(temp))/step;
bemf2_graphics_surf_field(P, t, temp, Indicator, objectnumber);

title(strcat("Patient: ",patno," Model: ",model_name, ...
      " Magnetic field in T at 10 mm for: ", tissue{objectnumber}));
view(-70, 70); colormap jet;
pat_image_path = fullfile('../data/images',patno);
if(~isfolder(pat_image_path))
    mkdir(pat_image_path);
end
saveas(fig,fullfile(pat_image_path,strcat(patno,'_',model_name,'_forwardb')),'png')