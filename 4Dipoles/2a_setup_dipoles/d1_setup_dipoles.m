%   This script runs over the cortical dipole layer (multiple dipoles)
%
%   Copyright SNM/WAW 2018-2023
close all hidden

%% load bem-fmm engine
addpath('../engines/bem_fmm_engine/');

%%  Dipoles are within GM

has_wm = isscalar(find(contains(tissue,'WM')));
has_gm = isscalar(find(contains(tissue,'GM')));
if(~has_wm || ~has_gm)
    error("The selected model is missing white matter or grey matter shells. Please select a model that contains both.");
end
clear has_wm has_gm

if(~isfolder(fullfile(patient_path,'dipoles')))
    mkdir(fullfile(patient_path,'dipoles'));
end
if ~skip_user_prompts
    [dipole_name, dipole_path] = uigetfile(fullfile(patient_path,'dipoles','*.txt'),'Please select a dipole');
else
    dipole_path=fullfile(patient_path,'dipoles');
end

dipole_fullpath = fullfile(dipole_path,dipole_name);
fprintf("Processing dipole position %s..\n", dipole_fullpath);
format_split = split(dipole_name,'.');
dipole_name = format_split{1};
clear format_split;

fid = fopen(dipole_fullpath); 
Ctr = fscanf(fid, '%f')';
Ctr = 1e-3 * Ctr;
fprintf("The dipole is located in the position: (%d, %d, %d) (m)\n", ...
    Ctr(1),Ctr(2),Ctr(3));
fclose(fid);

%   Process GM facets
dipole_tissue       = 'GM';   %   dipoles are always within the gray matter
gm_tissue_id    = find(strcmp(tissue, dipole_tissue));

GM.normals          = normals(Indicator == gm_tissue_id, :);
GM.Center           = meshtricenter(GM.P, GM.t);        %   base for the dipole layer, m

%   Process WM facets
wm_tissue           = 'WM';   %   dipoles are always within the gray matter
wm_tissue_id        = find(strcmp(tissue,wm_tissue));
WM.normals          = normals(Indicator == wm_tissue_id, :);
WM.Center           = meshtricenter(WM.P, WM.t);        

%%   Select dipole data
M=1;
NoDipoles=1;
I0 = 10e-6;                     %   source current, A
d  = 0.4e-3;                    %   finite-dipole length, m
dipole_length = d;

%% choose the closest WM and GM triangle centers and compute the midpoint between them

[~,min_ix_gm]=min(dist(GM.Center,Ctr'));
[~,min_ix_wm]=min(dist(WM.Center,Ctr'));

gm_cent = GM.Center(min_ix_gm,:);
wm_cent = WM.Center(min_ix_wm,:);

wm_to_gm = gm_cent-wm_cent;
wm_to_Ctr= Ctr-wm_cent;

dipole_center = (wm_cent+gm_cent)/2;

[~,sort_indicesGM] = sort(dist(GM.Center,dipole_center'));
N_closestGM = 10;
GMDirection = 0;
for dist_ix = 1:N_closestGM
    GMDirection = GMDirection+GM.normals(sort_indicesGM(dist_ix),:);
end
GMDirection = GMDirection/norm(GMDirection);

s = dist(gm_cent,wm_cent');

R = 3*s;                    %   Radius of the enclosing sphere 


strdipolePplus(1, :)    = dipole_center  - (d/2)*GMDirection;
strdipolePminus(1, :)   = dipole_center  + (d/2)*GMDirection;

strdipoleCurrent(1:M, 1)    = +I0;
strdipoleCurrent(M+1:2*M, 1)= -I0;

dip_cond = 0.33; % we choose this conductivity for the dipole to have the same strength in each case
strdipolesig = repmat(dip_cond, 2*M, 1);
%strdipolesig                = repmat(cond(wm_tissue_id), 2*M, 1);

%%   Magnetic dipole subdivision (optional)
D = 1;                        %   number of smaller subdipoles
strdipolemvector   = zeros(D*M, 3);
strdipolemcenter   = zeros(D*M, 3);
strdipolemstrength = zeros(D*M, 1);
for m = 1:M
    temp = (1/D)*(strdipolePplus(m, :) - strdipolePminus(m, :));
    for d = 1:D 
        arg = d+D*(m-1);
        strdipolemvector(arg, :)     = temp;
        strdipolemcenter(arg, :)     = strdipolePminus(m, :) + (d-1/2)*temp;
        strdipolemstrength(arg, :)   = strdipoleCurrent(m);                  
    end
end

dipole_folder = fullfile(dipole_path,dipole_name);
if(~isfolder(dipole_folder))
    mkdir(dipole_folder);
end


save(fullfile(dipole_folder,strcat(patno,'_',dipole_name,'_data.mat')), ...
'R', 'NoDipoles', 'strdipolePplus', 'strdipolePminus', 'strdipolesig', ...
'strdipoleCurrent', 'strdipolemvector', 'strdipolemcenter', ...
'strdipolemstrength','Ctr','dipole_path', 'dipole_name', 'I0','dipole_length'); 

%%  Plot and check correct position

indexw1 = find( (WM.P(WM.t(:, 1), 1)-Ctr(1)).^2 + (WM.P(WM.t(:, 1), 2)-Ctr(2)).^2 + (WM.P(WM.t(:, 1), 3)-Ctr(3)).^2 < R^2);
indexw2 = find( (WM.P(WM.t(:, 2), 1)-Ctr(1)).^2 + (WM.P(WM.t(:, 2), 2)-Ctr(2)).^2 + (WM.P(WM.t(:, 2), 3)-Ctr(3)).^2 < R^2);
indexw3 = find( (WM.P(WM.t(:, 3), 1)-Ctr(1)).^2 + (WM.P(WM.t(:, 3), 2)-Ctr(2)).^2 + (WM.P(WM.t(:, 3), 3)-Ctr(3)).^2 < R^2);
indexw  = intersect(intersect(indexw1, indexw2), indexw3); 

indexg1 = find( (GM.P(GM.t(:, 1), 1)-Ctr(1)).^2 + (GM.P(GM.t(:, 1), 2)-Ctr(2)).^2 + (GM.P(GM.t(:, 1), 3)-Ctr(3)).^2 < R^2);
indexg2 = find( (GM.P(GM.t(:, 2), 1)-Ctr(1)).^2 + (GM.P(GM.t(:, 2), 2)-Ctr(2)).^2 + (GM.P(GM.t(:, 2), 3)-Ctr(3)).^2 < R^2);
indexg3 = find( (GM.P(GM.t(:, 3), 1)-Ctr(1)).^2 + (GM.P(GM.t(:, 3), 2)-Ctr(2)).^2 + (GM.P(GM.t(:, 3), 3)-Ctr(3)).^2 < R^2);
indexg  = intersect(intersect(indexg1, indexg2), indexg3); 

%% Plot dipole(s) between WM and GM
figure('color', 'w');
str.EdgeColor = 'k'; str.FaceColor = [0 1 1]; str.FaceAlpha = 0.5; 
bemf2_graphics_base(WM.P, WM.t(indexw, :), str);
str.EdgeColor = 'k'; str.FaceColor = [0.7 0.7 0.7]; str.FaceAlpha = 0.5; 
bemf2_graphics_base(GM.P, GM.t(indexg, :), str);
bemf1_graphics_dipole(strdipolePplus, strdipolePminus, strdipoleCurrent, 0);
