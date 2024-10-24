%   This script plots mesh cross-sections and NIfTI data when availble
%;
%   Copyright SNM/WAW 2018-2023

%
addpath('../engines/graphics');

VT = VT1;
f = figure('WindowState','maximized');

%% below is XY-code
z = Z(1);
%  Display NIFTI slice
I = round(z/d1d2d3(3) + N1N2N3(3)/2);
S = VT(:, :, I)';      %   choose the Z cross-section
S = S(:, end:-1:1);    
image([-DimensionX/2 +DimensionX/2], [-DimensionY/2 +DimensionY/2], S, 'CDataMapping', 'scaled');
colormap bone; brighten(0.3);
set(gca, 'YDir', 'normal');    
%%   Create coordinates of intersection contours and intersection edges
tissues = length(tissue);
PofXY = cell(tissues, 1);   %   intersection nodes for a tissue
EofXY = cell(tissues, 1);   %   edges formed by intersection nodes for a tissue
TofXY = cell(tissues, 1);   %   intersected triangles
NofXY = cell(tissues, 1);   %   normal vectors of intersected triangles
count = [];   %   number of every tissue present in the slice
for m = 1:tissues 
[Pi, ti, polymask, flag] = meshplaneintXY(PS{m}, tS{m}, eS{m}, TriPS{m}, TriMS{m}, z);    
if flag % intersection found                
    count               = [count m];
    PofXY{m}            = Pi;               %   intersection nodes
    EofXY{m}            = polymask;         %   edges formed by intersection nodes
    TofXY{m}            = ti;               %   intersected triangles
    NofXY{m}            = nS{m}(ti, :);     %   normal vectors of intersected triangles        
end
end

%%   Display the contours    
for m = count
    edges           = EofXY{m};             %   this is for the contour
    points          = [];
    points(:, 1)    = +PofXY{m}(:, 1);       %   this is for the contour  
    points(:, 2)    = +PofXY{m}(:, 2);       %   this is for the contour
    ecenter         = (points(:, 1) + points(:, 2))/2;
    patch('Faces', edges, 'Vertices', points, 'EdgeColor', color(m, :), 'LineWidth', 1.5);    %   this is contour plot
end
%%   Draw dipole
hold on
bemf1_graphics_dipole_zoom(1e3*strdipolePplus, 1e3*strdipolePminus, strdipoleCurrent, 1);
% title( strcat(patno, ' Transverse cross-section at z =', num2str(z), ' mm'));
% xlabel('x, mm'); ylabel('y, mm');
axis 'equal';  axis 'tight'; 
axis off;
set(gcf,'Color','White');
drawnow

% Zoom in on dipole
ax = gca;
zoomFactor = 6;

xlims = get(ax, 'XLim');
ylims = get(ax, 'YLim');

xWidth = (xlims(2) - xlims(1)) / zoomFactor;
yWidth = (ylims(2) - ylims(1)) / zoomFactor;

newXlims = [1e3*strdipolePplus(1) - xWidth/2, 1e3*strdipolePplus(1) + xWidth/2];
newYlims = [1e3*strdipolePplus(2) - yWidth/2, 1e3*strdipolePplus(2) + yWidth/2];

set(ax, 'XLim', newXlims, 'YLim', newYlims);

if(~isfolder(fullfile('../data/images',patno)))
    mkdir(fullfile('../data/images',patno));
end

savefig(f,fullfile('../data/images',patno, ...
        strcat(patno,'_',dipole_name,'_placement_transverse_zoom.fig')))
% pause(0.25)

