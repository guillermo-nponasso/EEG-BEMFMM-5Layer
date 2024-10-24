function [] = utils_display_dipole(dip_plus,dip_minus, linecolor)
%UTILS_DISPLAY_DIPOLE Summary of this function goes here
%   Detailed explanation goes here

x0 = dip_minus(1); x1 = dip_plus(1);
y0 = dip_minus(2); y1 = dip_plus(2);
z0 = dip_minus(3); z1 = dip_plus(3);

circle_size = 25;
hold on
scatter3(x0,y0,z0,circle_size, 'MarkerEdgeColor',[0 0 0],...
                               'MarkerFaceColor',[0 0 1],...
                               'LineWidth',1.5);

scatter3(x1,y1,z1,circle_size, 'MarkerEdgeColor',[0 0 0],...
                               'MarkerFaceColor',[1 0 0],...
                               'LineWidth',1.5);
line([x0,x1],[y0,y1],[z0,z1],'LineWidth', 2, 'Color', linecolor);
end

