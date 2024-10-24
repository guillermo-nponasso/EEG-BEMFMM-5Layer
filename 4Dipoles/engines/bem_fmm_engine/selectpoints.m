function [in] = selectpoints(POL, ObsPoints, Pof, Eof, Plane) 
%   Select indexes "in" of ObsPoints within multiple tissue(s) cross-sections
%   defined by vector POL 
%   SNM 2024

    if isempty(POL) %   nothing selected
        Points = ObsPoints;
        return;
    end

    %%  Initialize
    Points = [];

    %%  Convert everything to 2D
    if Plane == 1
        points = ObsPoints(:, [1 2]);
        for m = 1:length(POL)
            tissue = POL(m);
            if ~isempty(Pof{tissue})
                NodesContour{m} = Pof{tissue}(:, [1 2]);
                EdgesContour{m} = Eof{tissue};
            else
                NodesContour{m} = [];
            end    
        end
    end
    if Plane == 2
        points = ObsPoints(:, [1 3]);
        for m = 1:length(POL)
            tissue = POL(m);
            if ~isempty(Pof{tissue})
                NodesContour{m} = Pof{tissue}(:, [1 3]);
                EdgesContour{m} = Eof{tissue};
            else
                NodesContour{m} = [];
            end    
        end
    end
    if Plane == 3
        points = ObsPoints(:, [2 3]);
        for m = 1:length(POL)
            tissue = POL(m);
            if ~isempty(Pof{tissue})
                NodesContour{m} = Pof{tissue}(:, [2 3]);
                EdgesContour{m} = Eof{tissue};
            else
                NodesContour{m} = [];
            end    
        end
    end

    %%  Main loop over all requested tissues
    for m = 1:length(POL)
        if isempty(NodesContour{m})
            PointsC = [];
            continue;
        end
        NC = NodesContour{m};
        EC = EdgesContour{m};
        MIN = min(NC);
        MAX = max(NC);
        %  Find bounding rectangle
        index1  = points(:, 1)>MIN(1)&points(:, 2)>MIN(2)&points(:, 1)<MAX(1)&points(:, 2)<MAX(2);
        pointsB = points(index1, :);
        %  Construct XY1 (contours) as an N1x4 matrix
        clear XY11 XY12 XY1
        XY11 = NC(EC(:, 1), :);
        XY12 = NC(EC(:, 2), :);
        XY1(:, 1:2)  = XY11;
        XY1(:, 3:4)  = XY12;
        %  Construct XY2 (arb segments) as an N2x4 matrix
        clear XY21 XY22 XY2
        XY21 = pointsB;
        XY22 = pointsB + 10*max(max(abs(MIN)), max(abs(MAX)));   %   shift
        XY2(:, 1:2)  = XY21;
        XY2(:, 3:4)  = XY22;
        %  Find intersection
        out = lineSegmentIntersect(XY1, XY2);
        INT = out.intAdjacencyMatrix;
        indexkeep = [];
        for m = 1:size(INT, 2)
            temp = sum(INT(:, m));
            if mod(temp, 2) % not 0, 2, 4 intersections - point is out
                indexkeep = [indexkeep m];
            end
        end
        Points = [Points; pointsB(indexkeep, :)];
    end
    %   Restore 3D nodes
    if Plane == 1
        Points(:, 3) = ObsPoints(1, 3);
    end
    if Plane == 2
        temp = Points;
        clear Points;
        Points(:, 1) = temp(:, 1);
        Points(:, 2) = ObsPoints(1, 2);
        Points(:, 3) = temp(:, 2);
    end
    if Plane == 3
        temp = Points;
        clear Points;
        Points(:, 2) = temp(:, 1);
        Points(:, 3) = temp(:, 2);
        Points(:, 1) = ObsPoints(1, 1);      
    end
    [~, in, ~] = intersect(ObsPoints, Points, 'rows', 'stable');
end









