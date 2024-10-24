%   Create coordinates of intersection contours and intersection edges
tissues = length(tissue);
PofXZ = cell(tissues, 1);   %   intersection nodes for a tissue
EofXZ = cell(tissues, 1);   %   edges formed by intersection nodes for a tissue
TofXZ = cell(tissues, 1);   %   intersected triangles
NofXZ = cell(tissues, 1);   %   normal vectors of intersected triangles
count = [];   %   number of every tissue present in the slice
for m = 1:tissues 
    [Pi, ti, polymask, flag] = meshplaneintXZ(PS{m}, tS{m}, eS{m}, TriPS{m}, TriMS{m}, Y);
    if flag % intersection found                
        count               = [count m];
        PofXZ{m}            = Pi;               %   intersection nodes
        EofXZ{m}            = polymask;         %   edges formed by intersection nodes
        TofXZ{m}            = ti;               %   intersected triangles
        NofXZ{m}            = nS{m}(ti, :);     %   normal vectors of intersected triangles        
    end
end
%   Display the contours    
for m = count
    edges           = EofXZ{m};              %   this is for the contour
    points          = [];
    points(:, 1)    = +PofXZ{m}(:, 1);       %   this is for the contour  
    points(:, 2)    = +PofXZ{m}(:, 3);       %   this is for the contour
    patch('Faces', edges, 'Vertices', points, 'EdgeColor', color(m, :), 'LineWidth', 3.0);    %   this is contour plot
end
title( strcat('Coronal cross-section at y =', num2str(Y), ' mm'));
xlabel('x, mm'); ylabel('z, mm');
axis 'equal';  axis 'tight'; 
set(gcf,'Color','White');
