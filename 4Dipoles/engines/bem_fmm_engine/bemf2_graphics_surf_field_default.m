function [ ] = bemf2_graphics_surf_field_default(P, t, FQ, Indicator, objectnumber) 
%   Surface field graphics:  plot a field quantity FQ at the surface of a
%   brain compartment with the number "tissuenumber". Interpolates over
%   triangles
%
%   Copyright SNM 2017-2021

    t0 = t(Indicator(:, 1) == objectnumber, :);
    %%  Plot
%     patch(X, Y, Z, C, 'FaceAlpha', 1.0, 'EdgeColor', 'none', 'FaceLighting', 'flat'); 
    patch('faces', t0, 'vertices', P, 'FaceVertexCData', FQ, 'FaceColor', 'flat', 'FaceLighting', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 1.0);
    colorbar;
    colormap hsv;
    camlight('headlight');
    lighting flat;
    axis 'equal';  axis 'tight'; 
    xlabel('x, m'); ylabel('y, m'); zlabel('z, m');
    set(gcf,'Color','White'); 
end