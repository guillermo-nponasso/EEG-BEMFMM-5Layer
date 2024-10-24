clear c resvec its;
load(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_charge_solution_adapt')));
load(fullfile(patient_path,'dipoles', dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_potentials_adapt')));

%% load additional colormaps

addpath(fullfile("../engines/Colormaps"));

%% XY transverse cross section
%  Prepare plane data
planeABCD = [0 0 1 -Z];             % Equation of the plane of the cross-section (Ax + By + Cz + D = 0)(meters) for neighbor triangle search acceleration
component   = 4;                    % Field component to be plotted (1, 2, 3 or x, y, z, or 4 - total) 
temp        = ['x' 'y' 'z' 't'];
label       = temp(component);

%  Define observation points in the cross-section (MsxMs observation points)   
if plot_entire_head
    if n_shells > 3
        Ms = 1000;
    else
        Ms = 600;
    end
else
    Ms = 800;
end
x = linspace(xmin, xmax, Ms);
y = linspace(ymin, ymax, Ms);
[X0, Y0]  = meshgrid(x, y);
clear pointsXY;
pointsXY(:, 1) = reshape(X0, 1, Ms^2);
pointsXY(:, 2) = reshape(Y0, 1, Ms^2);  
pointsXY(:, 3) = Z*ones(1, Ms^2);

%   Set up enclosing tissues (optional: suppresses visualization of saturated E-field/current outside the selected tissue)
% 1 - Skin; 2 - Skull; 3 - CSF; 4 - GM; 5 - Cerebellum; 6 - WM; 7 - Ventricles;
if n_shells>3
    POL = [1 2 3 4 5 6 7];
elseif n_shells==3
    POL = [1 2 3];
end

Plane = 1;
in = selectpoints(POL, pointsXY, PofXY, EofXY, Plane);

%  Find the potential at each observation point in the cross-section
tic
R = 5;         % Distance threshold (dimensionless, scaled to triangle size) that determines whether to use precise integration
[Epri, Ppri]   = bemf3_inc_field_electric_plain(strdipolePplus, strdipolePminus, strdipolesig, strdipoleCurrent, pointsXY*1e-3); % Primary potential
Psec           = bemf5_volume_field_potential(pointsXY*1e-3, c, P, t, Center, Area, normals, R, planeABCD); % Secondary potential
Pot_total      = Ppri + Psec;   
fieldPlaneTime = toc   

% configure thresholds and levels for contour log plot

if n_shells>3
    gm_ix = find(strcmp(tissue,'GM'));
    normalizing_cond = cond(gm_ix); % conductivity of grey matter
elseif  n_shells == 3
    brain_ix = find(strcmp(tissue,'Brain'));
    normalizing_cond = cond(brain_ix); % conductivity of BRAIN shell
else
    error("The model does not contain BRAIN or Grey matter shell. Please check the model conductivity file.");
end

if plot_entire_head
    div_factor = 2000;
    levels = 50;
else
    div_factor = 200;
    levels = 30;
end

temp   = Pot_total;
% temp   = temp*normalizing_cond;   % renormalizing the potential
%temp = temp/max(abs(temp));
th1    = max(temp)/div_factor;
th2    = min(temp)/div_factor;           % in V/m

%% plot volume potential in log
fig=figure;
bemf2_graphics_vol_field_log(temp, th1, th2, levels, x, y);

% plot the dipole
hold on;
bemf1_graphics_dipole(strdipolePplus*1e3, strdipolePminus*1e3, strdipoleCurrent, 1);

%% plot the perpendicular line to the dipole
dip_normal_XY = 1e3*[-strdipolemvector(2), strdipolemvector(1)];
dipole_center_XY = 1e3*[strdipolemcenter(1),strdipolemcenter(2)];
dip_dir_XY = 1e3*strdipolemvector([1 2]);
dd = 3*max(xmax-xmin, ymax-ymin);
line_extremes_XY = [dipole_center_XY - dd*delta_dip_pos*dip_dir_XY; dipole_center_XY + dd*delta_dip_pos*dip_dir_XY];
perp_line_extremes_XY = [dipole_center_XY - dd*delta_dip_pos*dip_normal_XY; dipole_center_XY + dd*delta_dip_pos*dip_normal_XY];
line(perp_line_extremes_XY(:,1),perp_line_extremes_XY(:,2),'LineWidth',2.5,'Color','w','LineStyle','--')
line(line_extremes_XY(:,1),line_extremes_XY(:,2),'LineWidth',2.5,'Color','w','LineStyle','--')
xlim([xmin xmax])
ylim([ymin ymax])
%%  Layover tissue cross sections
XY;
xlabel('Distance x, mm');
ylabel('Distance y, mm');
model_underscore_split = split(model_name,'_');
printable_name = '';
for i=1:length(model_underscore_split)
    printable_name = strcat(printable_name,'-',model_underscore_split{i});
end
title(strcat('patient: ', patno, '. model: ',printable_name, ...
    '. Normalized potential $\phi/\max(|\phi|)$, ', ...
    'in the transverse plane.'), 'Interpreter', 'latex');

% E-field plot:  General settings 
axis 'equal';  axis 'tight';     
colormap hsv;
axis([xmin xmax ymin ymax]);
grid on; set(gcf,'Color','White');

if plot_entire_head
    saveas(fig, fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name,'_volume_p_full_transverse.png')),'png');
    savefig(fig, fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name,'_volume_p_full_transverse.fig')));
else
    saveas(fig, fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name,'_volume_p_transverse.png')),'png');
    savefig(fig, fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name,'_volume_p_transverse.fig')));
end
