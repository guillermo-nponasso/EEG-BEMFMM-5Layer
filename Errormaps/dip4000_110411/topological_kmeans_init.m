%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% topological_kmeans_init.m                                           %%%
%%% Author: GN Ponasso (2024)                                           %%%
%%% Calculate a well-spaced initial set of cluster centers for k-means  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [k_initial] = topological_kmeans_init(P, t, k, alpha, beta, initial_set)
    centers = meshtricenter(P,t);
    normals = meshnormals(P,t);
    N       = size(t,1);
    prob    = 1/N * ones(1,N); % start with a uniform probability        

    k_initial = zeros(k,1);

    if(nargin == 6)
        l = size(initial_set,1);
        if(l>k)
            k_initial(1:l)=initial_set;
        else
            k_initial = initial_set(1:k);
            return;
        end
    else
        l=1;
    end

    for m = l:k
        fprintf('Processing center: %d/%d\r', m, k);
        k_initial(m) = randsample(N,1, true, prob);

        k_centers = centers(k_initial(1:m),:);
        k_normals = normals(k_initial(1:m),:);

        % create distance matrix
        normal_dev  = normals * k_normals';
        center_dist = dist(centers, k_centers');
        D =  center_dist./((1 + alpha.*normal_dev).^beta); % distance matrix

        % calculate minimum distance to initial points and update
        % probabilities
        [min_dist, ~] = min(D,[],2);
        total_weight = sum(min_dist.^2);
        prob         = min_dist./total_weight;
        prob(k_initial(1:m)) = 0;
    end
end

