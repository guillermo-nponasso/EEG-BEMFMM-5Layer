%   Create coordinates of intersection contours and intersection edges
tissues = length(tissue);
PofXY = cell(tissues, 1);   %   intersection nodes for a tissue
EofXY = cell(tissues, 1);   %   edges formed by intersection nodes for a tissue
TofXY = cell(tissues, 1);   %   intersected triangles
NofXY = cell(tissues, 1);   %   normal vectors of intersected triangles
count = [];   %   number of every tissue present in the slice
for m = 1:tissues 
    [Pi, ti, polymask, flag] = meshplaneintXY(PS{m}, tS{m}, eS{m}, TriPS{m}, TriMS{m}, Z);
    if flag % intersection found                
        count               = [count m];
        PofXY{m}            = Pi;               %   intersection nodes
        EofXY{m}            = polymask;         %   edges formed by intersection nodes
        TofXY{m}            = ti;               %   intersected triangles
        NofXY{m}            = nS{m}(ti, :);     %   normal vectors of intersected triangles        
    end
end
%   Display the contours    
for m = count
    edges           = EofXY{m};              %   this is for the contour
    points          = [];
    points(:, 1)    = +PofXY{m}(:, 1);       %   this is for the contour  
    points(:, 2)    = +PofXY{m}(:, 2);       %   this is for the contour
    ecenter         = (points(:, 1) + points(:, 2))/2;
    patch('Faces', edges, 'Vertices', points, 'EdgeColor', color(m, :), 'LineWidth', 3.0);    %   this is contour plot
end
title( strcat('Transverse cross-section at z =', num2str(Z), ' mm'));
xlabel('x, mm'); ylabel('y, mm');
axis 'equal';  axis 'tight'; 
set(gcf,'Color','White')