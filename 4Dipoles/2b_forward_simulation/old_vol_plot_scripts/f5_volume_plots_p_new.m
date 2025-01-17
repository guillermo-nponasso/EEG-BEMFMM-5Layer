load(fullfile(dipole_folder, strcat(patno,'_',model_name,'_',dipole_name, ...
    '_output_charge_solution')));

%% load additional colormaps

addpath(fullfile("../engines/Colormaps"));

%% XY transverse cross section
%  Prepare plane data
planeABCD = [0 0 1 -Z];             % Equation of the plane of the cross-section (Ax + By + Cz + D = 0)(meters) for neighbor triangle search acceleration
component   = 4;                    % Field component to be plotted (1, 2, 3 or x, y, z, or 4 - total) 
temp        = ['x' 'y' 'z' 't'];
label       = temp(component);

%  Define observation points in the cross-section (MsxMs observation points)   
Ms = 1000;
x = linspace(xmin, xmax, Ms);
y = linspace(ymin, ymax, Ms);
[X0, Y0]  = meshgrid(x, y);
clear pointsXY;
pointsXY(:, 1) = reshape(X0, 1, Ms^2);
pointsXY(:, 2) = reshape(Y0, 1, Ms^2);  
pointsXY(:, 3) = Z*ones(1, Ms^2);

%   Set up enclosing tissues (optional: suppresses visualization of saturated E-field/current outside the selected tissue)
% 1 - skin; 2 - skull; 3 - cerebellum; 4 external cerebrum; 5 medulla; 6 olfactory bulbs; 7 rest of the brain; 8 striatum;
%   Do not select non-manifold skull mesh (do not select 2)
POL = [1 2 3 4 5 6 7];
Plane = 1;
in = selectpoints(POL, pointsXY, PofXY, EofXY, Plane);

%  Find the E-field at each observation point in the cross-section
tic
R = 5;         % Distance threshold (dimensionless, scaled to triangle size) that determines whether to use precise integration
Psec           = zeros(Ms*Ms, 3);
%Esec           = bemf5_volume_field_electric(pointsXY*1e-3, c, P, t, Center, Area, normals, R, planeABCD);
Psec           = bemf5_volume_field_potential(pointsXY*1e-3, c, P, t, Center, Area, normals, R, planeABCD);
[Epri, Ppri]   = bemf3_inc_field_electric_plain(strdipolePplus, strdipolePminus, strdipolesig, strdipoleCurrent, pointsXY*1e-3);
Pot_total         = Ppri + Psec;   
fieldPlaneTime = toc   

%  Plot the E-field in the cross-section
figure;
% E-field plot: contour plot
%if component == 4
%    temp      = abs(sqrt(dot(Pot_total, Pot_total, 2)));
%else
%    temp      = abs(Pot_total(:, component));
%end
temp = Pot_total;
% temp = 1e3*temp;                %   in V/m
% th1 = 1.0*max(temp);            %   in V/m
% th1 = 0.1*max(temp);
th1 = max(temp)/100;
th2 = min(temp)/100;                        %   in V/m
levels      = 30;
%% bemf2_graphics_vol_field(temp, th1, th2, levels, x, y);
fig=figure;
bemf2_graphics_vol_field_log(temp, th1, th2, levels, x, y);

% plot the dipole
hold on;
bemf1_graphics_dipole(strdipolePplus*1e3, strdipolePminus*1e3, strdipoleCurrent, 1);

%% plot the perpendicular line to the dipole

dip_normal_XY = 1e3*[-strdipolemvector(2), strdipolemvector(1)];
dipole_center_XY = 1e3*[strdipolemcenter(1),strdipolemcenter(2)];
line_extremes_XY = [dipole_center_XY - 3*delta_dip_pos*dip_normal_XY; dipole_center_XY + 3*delta_dip_pos*dip_normal_XY];
line(line_extremes_XY(:,1),line_extremes_XY(:,2),'LineWidth',2.5,'Color','w','LineStyle','--')
xlim([xmin xmax])
ylim([ymin ymax])

%%  E-field cross-section plot
XY;
xlabel('Distance x, mm');
ylabel('Distance y, mm');
title(strcat('Potential V/m, ', label, 'in the transverse plane.'));
% legend(tissue(count), 'FontSize', 12, 'Location', 'northeastoutside');

% E-field plot:  General settings 
axis 'equal';  axis 'tight';     
colormap hsv;
axis([xmin xmax ymin ymax]);
grid on; set(gcf,'Color','White');
saveas(fig, fullfile('../data/images',patno,strcat(patno,'_',model_name,'_',dipole_name,'_volume_p_transverse.png')),'png');

% %% XZ coronal cross section
% %  Prepare plane data
% planeABCD = [0 0 1 -Y];             % Equation of the plane of the cross-section (Ax + By + Cz + D = 0)(meters) for neighbor triangle search acceleration
% component   = 4;                    % Field component to be plotted (1, 2, 3 or x, y, z, or 4 - total) 
% temp        = ['x' 'y' 'z' 't'];
% label       = temp(component);
% 
% %  Define observation points in the cross-section (MsxMs observation points)   
% Ms = 200;
% x = linspace(xmin, xmax, Ms);
% z = linspace(zmin, zmax, Ms);
% [X0, Z0]  = meshgrid(x, z);
% clear pointsXZ;
% pointsXZ(:, 1) = reshape(X0, 1, Ms^2);
% pointsXZ(:, 3) = reshape(Z0, 1, Ms^2);  
% pointsXZ(:, 2) = Y*ones(1, Ms^2);
% 
% %   Set up enclosing tissues (optional: suppresses visualization of saturated E-field/current outside the selected tissue)
% % 1 - skin; 2 - skull; 3 - cerebellum; 4 external cerebrum; 5 medulla; 6 olfactory bulbs; 7 rest of the brain; 8 striatum;
% %   Do not select non-manifold skull mesh (do not select 2)
% POL = [1 2 3 4 5 6 7];
% Plane = 2;
% in = selectpoints(POL, pointsXZ, PofXZ, EofXZ, Plane);
% 
% %  Find the E-field at each observation point in the cross-section
% tic
% R = 5;         %  Distance threshold (dimensionless, scaled to triangle size) that determines whether to use precise integration
% Esec            = zeros(Ms*Ms, 3);
% Psec            = bemf5_volume_field_potential(pointsXZ*1e-3, c, P, t, Center, Area, normals, R, planeABCD);
% [Epri, Ppri]    = bemf3_inc_field_electric_plain(strdipolePplus, strdipolePminus, strdipolesig, strdipoleCurrent, pointsXZ*1e-3);
% %Esec(in, :)     = bemf5_volume_field_electric(pointsXZ(in, :)*1e-3, c, P, t, Center, Area, normals, R, planeABCD);
% Pot_total       = Ppri+Psec;   
% fieldPlaneTime  = toc   
% 
% %  Plot the E-field in the cross-section
% figure;
% % E-field plot: contour plot
% % if component == 4
% %     temp      = abs(sqrt(dot(Etotal, Etotal, 2)));
% % else
% %     temp      = abs(Etotal(:, component));
% % end
% % temp = 1e3*temp;                %   in V/m
% th1 = max(temp)/30;                %   in V/m
% th2 = 0;                        %   in V/m
% levels      = 20;
% bemf2_graphics_vol_field_log(temp, th1, th2, levels, x, z);
% 
% %  E-field plot cross-section
% XZ;
% xlabel('Distance x, mm');
% ylabel('Distance z, mm');
% title(strcat('E-field V/m, ', label, '-component in the coronal plane.'));
% 
% 
% % E-field plot:  General settings 
% axis 'equal';  axis 'tight';     
% colormap parula;
% axis([xmin xmax zmin zmax]);
% grid on; set(gcf,'Color','White');
% 
% 
% 
% %% YZ sagittal cross section
% %  Prepare plane data
% planeABCD = [0 0 1 -X];             % Equation of the plane of the cross-section (Ax + By + Cz + D = 0)(meters) for neighbor triangle search acceleration
% component   = 4;                    % Field component to be plotted (1, 2, 3 or x, y, z, or 4 - total) 
% temp        = ['x' 'y' 'z' 't'];
% label       = temp(component);
% 
% %  Define observation points in the cross-section (MsxMs observation points)   
% Ms = 200;
% y = linspace(ymin, ymax, Ms);
% z = linspace(zmin, zmax, Ms);
% [Y0, Z0]  = meshgrid(y, z);
% clear pointsYZ;
% pointsYZ(:, 2) = reshape(Y0, 1, Ms^2);
% pointsYZ(:, 3) = reshape(Z0, 1, Ms^2);  
% pointsYZ(:, 1) = X*ones(1, Ms^2);
% 
% %   Set up enclosing tissues (optional: suppresses visualization of saturated E-field/current outside the selected tissue)
% % 1 - skin; 2 - skull; 3 - cerebellum; 4 external cerebrum; 5 medulla; 6 olfactory bulbs; 7 rest of the brain; 8 striatum;
% %   Do not select non-manifold skull mesh (do not select 2)
% POL = [1 2 3 4 5 6 7];
% Plane = 3;
% in = selectpoints(POL, pointsYZ, PofYZ, EofYZ, Plane);
% 
% %  Find the E-field at each observation point in the cross-section
% tic
% R = 5;         %  Distance threshold (dimensionless, scaled to triangle size) that determines whether to use precise integration
% Esec           = zeros(Ms*Ms, 3);
% [Epri, Ppri]   = bemf3_inc_field_electric_plain(strdipolePplus, strdipolePminus, strdipolesig, strdipoleCurrent, pointsYZ*1e-3);
% Psec(in, :)    = bemf5_volume_field_potential(pointsYZ(in, :)*1e-3, c, P, t, Center, Area, normals, R, planeABCD);
% Pot_total         = Ppri+Psec;   
% fieldPlaneTime = toc   
% 
% %  Plot the E-field in the cross-section
% figure;
% % E-field plot: contour plot
% %if component == 4
% %    temp      = abs(sqrt(dot(Etotal, Etotal, 2)));
% %else
% %    temp      = abs(Etotal(:, component));
% %end
% temp=Pot_total;
% 
% % temp = 1e3*temp;                %   in V/m
% th1 =  max(temp)/15;            %   in V/m
% th2 = 0;                        %   in V/m
% levels      = 20;
% bemf2_graphics_vol_field_log(temp, th1, th2, levels, y, z);
% 
% %  E-field plot cross-section
% YZ;
% xlabel('Distance y, mm');
% ylabel('Distance z, mm');
% title(strcat('E-field V/m, ', label, '-component in the sagittal plane.'));
% 
% % E-field plot:  General settings 
% axis 'equal';  axis 'tight';     
% colormap parula;
% axis([ymin ymax zmin zmax]);
% grid on; set(gcf,'Color','White');