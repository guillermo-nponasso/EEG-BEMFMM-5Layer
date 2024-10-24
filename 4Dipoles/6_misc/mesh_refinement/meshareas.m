function A = meshareas(P, t) 
%   This function returns areas of all triangles in the mesh in array A
%
%   Copyright SNM 2017-2018
%   The Athinoula A. Martinos Center for Biomedical Imaging, Massachusetts General
%   Hospital & ECE Dept., Worcester Polytechnic Inst.

    d12     = P(t(:,2),:)-P(t(:,1),:);
    d13     = P(t(:,3),:)-P(t(:,1),:);
    temp    = cross(d12, d13, 2);
    A       = 0.5*sqrt(dot(temp, temp, 2));
end
   
    
