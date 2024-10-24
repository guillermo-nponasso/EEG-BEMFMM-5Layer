function [bool_int, d, coords] = ut_RayIntersect(point, dir, P, t)

    % using metres does not seem to work, probably because of some 
    % tolerance parameters in TriangleRayIntersection
    % We convert everything to mm, and then reconvert
    pp = repmat(1e3*point,size(t,1),1);
    dd = repmat(dir, size(t,1),1);

    head(pp)

    v1 = 1e3*P(t(:,1),:);
    v2 = 1e3*P(t(:,2),:);
    v3 = 1e3*P(t(:,3),:);

    head(v1)
    [bool_int,~,~,~,coords]=TriangleRayIntersection(pp,dd,v1,v2,v3,'border','inclusive');
    %intersections = coords(bool_int,:);
    %[d,ix_min] = min(dist(intersections,point'));
    %coords = 1e-3*intersections(ix_min,:);
    %d=1e-3*d;
    d=NaN
end