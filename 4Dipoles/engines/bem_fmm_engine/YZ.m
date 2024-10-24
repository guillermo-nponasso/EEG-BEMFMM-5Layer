%   Create coordinates of intersection contours and intersection edges
tissues = length(tissue);
PofYZ = cell(tissues, 1);   %   intersection nodes for a tissue
EofYZ = cell(tissues, 1);   %   edges formed by intersection nodes for a tissue
TofYZ = cell(tissues, 1);   %   intersected triangles
NofYZ = cell(tissues, 1);   %   normal vectors of intersected triangles
count = [];   %   number of every tissue present in the slice
for m = 1:tissues
    [Pi, ti, polymask, flag] = meshplaneintYZ(PS{m}, tS{m}, eS{m}, TriPS{m}, TriMS{m}, X);
    if flag % intersection found                
        count               = [count m];
        PofYZ{m}            = Pi;               %   intersection nodes
        EofYZ{m}            = polymask;         %   edges formed by intersection nodes
        TofYZ{m}            = ti;               %   intersected triangles
        NofYZ{m}            = nS{m}(ti, :);     %   normal vectors of intersected triangles        
    end
end
%   Display the contours    
for m = count
    edges           = EofYZ{m};              %   this is for the contour
    points          = [];
    points(:, 1)    = +PofYZ{m}(:, 2);       %   this is for the contour  
    points(:, 2)    = +PofYZ{m}(:, 3);       %   this is for the contour
    patch('Faces', edges, 'Vertices', points, 'EdgeColor', color(m, :), 'LineWidth', 3.0);    %   this is contour plot
end
title( strcat('Sagittal cross-section at x =', num2str(X), ' mm'));
xlabel('y, mm'); ylabel('z, mm');
axis 'equal';  axis 'tight'; 
set(gcf,'Color','White');
