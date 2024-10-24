solnNoAdapt = load(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_output_charge_solution')));
solnAdapt=load(fullfile(patient_path,'dipoles',dipole_name, ...
    strcat(patno,'_',model_name,'_',dipole_name,'_charge_solution_adapt')));

for j = 1:length(solnAdapt.tissue)
    
    disp(['Processing refinement rate for tissue: ' solnAdapt.tissue{j}]);
    idxNoAdapt = find(solnNoAdapt.Indicator(:, 1) == j);
    idxAdapt = find(solnAdapt.Indicator(:, 1) == j);
    
    centerNoAdapt = solnNoAdapt.Center(idxNoAdapt, :);
    centerAdapt = solnAdapt.Center(idxAdapt, :);
    tNoAdapt = solnNoAdapt.t(idxNoAdapt, :);
    tAdapt = solnAdapt.t(idxAdapt, :);
 
    
    % Calculate parent triangles' average edge lengths
    edge1 = solnNoAdapt.P(tNoAdapt(:, 2), :) - solnNoAdapt.P(tNoAdapt(:, 1), :);
    edge2 = solnNoAdapt.P(tNoAdapt(:, 3), :) - solnNoAdapt.P(tNoAdapt(:, 2), :);
    edge3 = solnNoAdapt.P(tNoAdapt(:, 1), :) - solnNoAdapt.P(tNoAdapt(:, 3), :);
    
    edge1Len = vecnorm(edge1, 2, 2);
    edge2Len = vecnorm(edge2, 2, 2);
    edge3Len = vecnorm(edge3, 2, 2);
    avgEdgeLengthParent = (edge1Len + edge2Len + edge3Len)/3;
    
    % Calculate child triangles' average edge lengths
    edge1 = solnAdapt.P(tAdapt(:, 2), :) - solnAdapt.P(tAdapt(:, 1), :);
    edge2 = solnAdapt.P(tAdapt(:, 3), :) - solnAdapt.P(tAdapt(:, 2), :);
    edge3 = solnAdapt.P(tAdapt(:, 1), :) - solnAdapt.P(tAdapt(:, 3), :);
    
    edge1Len = vecnorm(edge1, 2, 2);
    edge2Len = vecnorm(edge2, 2, 2);
    edge3Len = vecnorm(edge3, 2, 2);
    avgEdgeLengthChild = (edge1Len + edge2Len + edge3Len)/3;
    
    %% Match child triangles to parent triangles
    candidateTriIndices = knnsearch(centerNoAdapt, centerAdapt, 'k', 12);
    legalIndices = true(size(candidateTriIndices));
    
    for k = 1:size(candidateTriIndices, 2)
        for m = 1:3
            vtx1 = solnNoAdapt.P(tNoAdapt(candidateTriIndices(:, k), m), :);
            temp = tNoAdapt(candidateTriIndices(:, k), m~=1:3);
            vtx2 = solnNoAdapt.P(temp(:, 1), :);
            vtx3 = solnNoAdapt.P(temp(:, 2), :);
            
            v1 = centerAdapt - vtx1; % vector from triangle vertex 1 to tiny triangle's centroid
            v2 = vtx2 - vtx1;        % vector from triangle vertex 1 to triangle vertex 2
            v3 = vtx3 - vtx1;        % vector from triangle vertex 1 to triangle vertex 3
            
            
            v1 = v1./repmat(vecnorm(v1, 2, 2), 1, 3);
            v2 = v2./repmat(vecnorm(v2, 2, 2), 1, 3);
            v3 = v3./repmat(vecnorm(v3, 2, 2), 1, 3);
            
            cross1 = cross(v2, v1, 2);
            cross2 = cross(v3, v1, 2);
            
            cross1 = cross1./repmat(vecnorm(cross1, 2, 2), 1, 3);
            cross2 = cross2./repmat(vecnorm(cross2, 2, 2), 1, 3);
            
            dot1 = dot(cross1, cross2, 2);
            
            legalIndices(dot1 > 0, k) = false;
            
        end
    end
    parentTriangles = zeros(size(centerAdapt, 1), 1);

    disp(['    There are ' num2str(sum(legalIndices, 'all') - length(parentTriangles)) ' excess triangles of ' num2str(length(parentTriangles)) ' required']);
    for k = 1:length(parentTriangles)
        temp = find(legalIndices(k, :), 1);
        if ~isempty(temp)
            parentTriangles(k) = candidateTriIndices(k, temp);
        end
    end

    % For each subtriangle, parentTriangles contains the index of the triangle that is the parent of that subtriangle.
    orphanSubtriangles = find(parentTriangles == 0);
    disp(['    Deleting ' num2str(length(orphanSubtriangles)) ' orphaned subtriangles of ' num2str(size(avgEdgeLengthChild, 1)) ' subtriangles total']);
    
    tAdapt(orphanSubtriangles, :) = [];
    avgEdgeLengthChild(orphanSubtriangles, :) = [];
    parentTriangles(orphanSubtriangles, :) = []; % delete zero entries
    
    edgeLenRatio = avgEdgeLengthParent(parentTriangles)./avgEdgeLengthChild;
    
    edgeLenRatio_plot = log(edgeLenRatio)./log(2);
    figure;
    bemf2_graphics_surf_field_default(solnAdapt.P, tAdapt, edgeLenRatio_plot, ones(size(edgeLenRatio)), 1);
    colormap jet;
    title(['Number of subdivisions per facet: ' newline solnAdapt.tissue{j}]);
    view(250, 65);
    camzoom(2);
    ax = gca;
    if max(ax.CLim) < 4
        ax.CLim = [0 4];
    end
    drawnow;
    saveas(gcf, fullfile('../data/images',patno, ...
        strcat(patno,'_',model_name,'_',dipole_name,'_mesh_refinement_',solnAdapt.tissue{j})));
end

