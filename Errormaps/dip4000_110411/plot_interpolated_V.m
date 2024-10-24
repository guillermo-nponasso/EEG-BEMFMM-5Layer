%%% Interpolated skin voltage plot
%%% Author GNP 2024
%%% Given the electrode indices and electrode potentials interpolate the 
%%% skin potential by taking a weighed average, and plot it.

%% read voltages and indices
ix = 11;
LFM = load(fullfile('data/LFM/LeadField_matrix4000.mat')).LeadField_matrix;
% take voltage differences with respect to the reference electrode
LFM(:, 2:end) = LFM(:, 2:end) - LFM(:,1);
% remove the reference electrode
LFM(:, 1) = [];
Voltage = LFM(ix,:)';
%Voltage = V.V;
%Voltage = R_LFM' * estimated_strengths;
%Voltage = LFM(centeridx,:)';
Elec_Idx = load('data\110411_elec_tri_ix.mat').Idx;
%Elec_Idx = load('sm04_experiment_mo224.mat','Idx').Idx;

Voltage = [0; Voltage]; % include the reference electrode

%% read skin
fprintf("Loading skin STL..\n");
SK = stlread(fullfile('data/110411_skin_headreco.stl'));
fprintf("Done!\n");

SK_P = SK.Points;
SK_t = SK.ConnectivityList;

Ntri = size(SK_t,1);
SK_cent = meshtricenter(SK_P,SK_t);

elec_cent = SK_cent(Elec_Idx,:);

%% interpolate

i_radius = 50; % radius (mm) for the interpolation

PSkin = zeros(Ntri,1);
for m = 1:Ntri
    tri = SK_cent(m,:);
    D = dist(tri, elec_cent');
    idx = find(D<=i_radius);
    if isempty(idx)
        PSkin(m) = NaN;
    else
        N_neighbors = size(idx,2);
        hsum = sum(1./D(idx)); % harmonic sum of distances
        weights = 1./(D(idx)*hsum);
        PSkin(m) = sum(weights .* Voltage(idx)');
    end
end

%% plot the skin voltages
figure;
patch('faces', SK_t, 'vertices', SK_P, 'FaceVertexCData', PSkin, 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 1.0);                   
colormap(gca, 'jet');
%caxis([nanmin(PSkin(:)), nanmax(PSkin(:))]);
%cmap = colormap;
%cmap(1, :) = [0 0 0];  % Set the first row of colormap to black
%colormap(gca, cmap);
axis 'equal';  axis 'tight';      
xlabel('x, mm'); ylabel('y, mm'); zlabel('z, mm');

