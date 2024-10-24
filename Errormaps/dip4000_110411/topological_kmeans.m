%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% topological_kmeans_vectorized.m                                     %%%
%%% Authors: P. Lai GN Ponasso A Cook (2024)                            %%%
%%% Input:  P -- mesh points (N x 3)                                    %%%
%%%         t -- mesh triangle list (2(N-2) x 3)                        %%%
%%%         k -- number of clusters                                     %%%
%%%         tolerance -- scalar to control stopping criteria            %%%
%%%         alpha -- scalar between 0 and 1                             %%%
%%%         beta -- power scalar either 1 or 2                          %%%
%%%         k_initial_clusters -- initial clusters (k x 3)              %%%
%%% Output: index     -- array with N vector index representing         %%%
%%%                     cluster ID of the corresponding triangle        %%%
%%%         % Tclusters -- cell with k entries representing k clusters  %%%
%%%                     as triangle lists.                              %%%
%%%         % cluster_centers -- array with k x 3 entries representing  %%%
%%%                     k cluster centers                               %%%
%%%         % cluster_normals -- array with k x 3 entries representing  %%%
%%%                     k cluster normals                               %%%
%%% ------------------------------------------------------------------- %%%
%%% Details:                                                            %%%
%%%          At each iteration, we store the partition results using    %%%
%%%          indicator matrix (N x k) whose (i,j)-entry is 1 only       %%%
%%%          if i-mesh triangle partitioned into cluster j.             %%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [index, iteration] = topological_kmeans(P, t, k, tolerance, alpha, beta, k_initial_clusters)

    N                = size(t, 1);         % number of mesh triangles
    temp_centers     = zeros(k,3);                         

    % calculate centers and normals of mesh triangles
    triangle_centers = meshtricenter(P,t); 
    triangle_normals = meshnormals(P,t);   
    
    %% initialize cluster_centers and cluster_normals
    if nargin == 6
        initial_indices  = randsample(N, k);
        cluster_centers = triangle_centers(initial_indices,:);   
        cluster_normals = triangle_normals(initial_indices,:);   % corresponding ones
    else
        cluster_centers = k_initial_clusters;                   % assign initial clusters
        cluster_normals = triangle_normals(randsample(N, k),:); % randam sampling ones
    end
  
    %% Recurse until there is no changes of each cluster center
    iteration = 0;
    %printf("iteration 0. cost: %d\n", norm(rmmissing(cluster_centers-temp_centers)));
    while(norm(rmmissing(cluster_centers - temp_centers)) > tolerance) 
   
        temp_centers = cluster_centers; 
        iteration    = iteration + 1;

        % Pre-computed topological distance matrix (N x k) 
        normal_devs  = triangle_normals * cluster_normals';            % giving dot products
        tri_cluster_distances = dist(triangle_centers, temp_centers'); % giving Euclidean-distances
        distance_matrix = tri_cluster_distances./((1 + alpha.*normal_devs).^beta); % giving proposed distances

        % Assign each point to its nearest cluster center
        [~, index] = min(distance_matrix,[],2);
        indicator = sparse(1:N, index, ones(1,N));      % indicator matrix storing partition results

        % Update cluster_normals and cluster_centers via updated indicator matrix
        cluster_normals = indicator'*triangle_normals; 
        cluster_normals = cluster_normals./vecnorm(cluster_normals,2,2); % normalise cluster_normals here 
        cluster_sizes = sum(indicator,1);
        cluster_centers = indicator'*triangle_centers./repmat(cluster_sizes',1,3); 
        
        clear indicator;
        disp(['iteration cost: ', num2str(norm(rmmissing(cluster_centers - temp_centers)))]);
    end
    
    %% optionally display information
    % disp(['Computation time: ', num2str(toc)]);
    % disp(['Number of iteration: ', num2str(iteration)]);
    % disp(['Effective number of clusters: ', num2str(size(rmmissing(cluster_centers), 1))]);
    
    %% Uncomment if would like to output Tclusters, Tcenters, Tnormals
    % Tclusters         = cell(k, 1);     % clusters k-cell: arrays of triangles in a cluster   
    % for j = 1:k
    %     Tclusters{j}  = find(index==j);
    % end
end