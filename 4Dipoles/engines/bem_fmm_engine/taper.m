function [Taper] = taper(P, Z, taperwidth)
%   Creates cosine-shaped taper (from 0 to 1) vs Z=z1*Y + z2    
%   SNM 2022
    Taper       = zeros(size(P, 1), 1);
    for m = 1:size(P, 1)   
        argument = 1;
        liner = P(m, 3) - Z.z1*P(m, 2) -Z.z2;
        if liner<0
              argument = 0;
        end
        if (liner > 0)&&(liner < taperwidth)
              argument = (taperwidth-liner)/taperwidth;
        end 
        Taper(m) = (1 - cos(pi*argument))/2;
    end
end