function [intersect_bool, d, intersection,t,u,v] = ut_MTRayIntersect(point, dir, P, t)
    vert1 = P(t(:, 1),:);
    vert2 = P(t(:, 2),:);
    vert3 = P(t(:, 3),:);

    pp = repmat(point,size(vert1,1),1);
    dd = repmat(dir, size(vert1,1),1);
    e1 = vert2-vert1;
    e2 = vert3-vert1;
    e3 = pp-vert1;
    P = cross(dd,e2);
    Q = cross(e3,e1);

    system_det = dot(P,e1);
    sys_det_inv= system_det.^(-1);
    t = -dot(Q,e1) .* sys_det_inv;
    u = dot(P,e3) .* sys_det_inv;
    v = dot(Q,dd) .* sys_det_inv;

    head(system_det)
    intersect_bool = system_det ~= 0 & t>=0 & u>=0 & v>=0 & u+v<=1;
    
    intersection = (1-u-v).*vert1 + u.*vert2+v.*vert3;
    d = dist(intersection,point');
    
    %[intersect, distances, ~,~, coords] =TriangleRayIntersection(point, dir, vert1,vert2,vert3);
    
end