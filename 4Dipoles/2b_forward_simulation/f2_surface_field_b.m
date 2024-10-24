%   This script computes and plots the incident magnetic field magnitude
%   (or any of the components) for any brain compartment surface/interface
%   (plots the surface field + optionally coil geometry) 
%
%   Copyright SNM/WAW 2017-2023


eps0        = 8.85418782e-012;  %   Dielectric permittivity of vacuum(~air)
mu0         = 1.25663706e-006;  %   Magnetic permeability of vacuum(~air)

%%   Compute the B-field for all surfaces/interfaces
tissue_to_plot = 'Skin';
objectnumber = find(strcmp(tissue, tissue_to_plot));    
Points = Center(Indicator==objectnumber, :); 
Normals = normals(Indicator==objectnumber, :); 

d = 10e-3; % Magnetometer distance from skin surface
obsPtsMag = Points + d*Normals; % Observation points for magnetic field

tic
difference      = condin - condout;
Bpri            = bemf3_inc_field_magnetic(strdipolemvector, strdipolemcenter, strdipolemstrength, obsPtsMag, mu0);   
Bsec            = bemf5_volume_field_magnetic(obsPtsMag, Ptot, P, t, Center, Area, normals, difference, mu0, 0, 0);
Btotal          = Bpri + Bsec;
temp            = abs(sqrt(dot(Btotal, Btotal, 2)));
BTime = toc

%%  Digitize figure
fig=figure
step = 20;
temp = round(step*temp/max(temp)).*(max(temp))/step;
bemf2_graphics_surf_field(P, t, temp, Indicator, objectnumber);

title(strcat("Patient: ",patno," Model: ",model_name, ...
      " Magnetic field in T at 10 mm for: ", tissue{objectnumber}));
view(-70, 70); colormap jet;
pat_image_path = fullfile('../data/images',patno);
if(~isfolder(pat_image_path))
    mkdir(pat_image_path);
end
saveas(fig,fullfile(pat_image_path,strcat(patno,'_',model_name,'_forwardb')),'png')
savefig(fig,fullfile(pat_image_path,strcat(patno,'_',model_name,'_forwardb.fig')))