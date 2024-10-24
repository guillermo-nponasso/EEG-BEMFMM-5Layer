
%% general options
elec_path = fullfile(patient_path,'dipoles',strcat(patno,'_',model_name,'_', ...
                                          dipole_name,'_electrodes.mat'));


%% load BEM-FMM Engine
addpath(fullfile('../engines/bem_fmm_engine'));

%% load data
V_skin          = Ptot(Indicator==skin_id,strength_ix,simulation_ix);

%% find skin file

skin_id = find(strcmp(tissue,'Skin'));
skin_file = tissue_files(skin_id);

%% compute suffix for the skin file
dot_split = split(skin_file,'.');
skin_filename = dot_split{1};
underscore_split = split(skin_filename,'_');
suffix = underscore_split{end};

if strcmp(suffix,'skin')
    suffix = '';
else
    suffix = strcat('_',suffix);
end

%%  Determine electrode positions
load(fullfile(patient_path,'mesh_data',strcat(patno,'_elec_realigned', suffix,'.mat')));
TARGET = elec_realigned.elecpos;

%%
Q = size(TARGET, 1);
%   Project targets exactly to the skin surface
SkinNeighbor     = knnsearch(mesh_skin.Center, TARGET, 'k', 1);   %   all in mm
TARGET           = mesh_skin.Center(SkinNeighbor, :);

%%   Determine electrode numbers/positions/radii   
NOE                             = Q;                        %   number of active electrodes 
RadE                            = 5.0;                      %   electrode radius in mm (at least 3 triangles along the diameter)
strge.NumberOfElectrodes        = NOE; 
strge.RadiusOfElectrodes        = RadE*ones(1, NOE);%   in mm here

%% Save the data
if exist('ElectrodeVoltages','var')
    ElectrodeVoltages(:,strength_ix,simulation_ix)   = V_skin(SkinNeighbor);
else
    ElectrodeVoltages=zeros(Q,N_strengths,N_simulations);
    ElectrodeVoltages(:,strength_ix,simulation_ix)   = V_skin(SkinNeighbor);
end
if exist('ElectrodePositions','var')
    ElectrodePositions(:,:,strength_ix,simulation_ix) = TARGET;
else
    ElectrodePositions = zeros(Q,3,N_strengths,N_simulations);
    ElectrodePositions(:,:,strength_ix,simulation_ix) = TARGET;
end
if exist('ElectrodeLabels','var')
    ElectrodeLabels(:,strength_ix,simulation_ix) = elec_realigned.label;
else
    ElectrodeLabels = cell(Q,N_strengths,N_simulations);
    for label_ix = 1:Q
        ElectrodeLabels{label_ix,strength_ix,simulation_ix} = elec_realigned.label{label_ix};
    end
end
    
%%  Display electrode positions/voltages
if plot_electrodes
    figure
    p = patch('vertices', mesh_skin.P, 'faces', mesh_skin.t);
    p.FaceColor = [0.8 0.8 0.8];
    p.EdgeColor = 'none';
    p.FaceAlpha = 1.0;
    S = load(fullfile('../data','sphere.mat'));
    n = length(S.P);
    scale = 8*1e3;
    for m = 1:Q
        p = patch('vertices', scale*S.P+repmat(TARGET(m, :), n, 1), 'faces', S.t);
        p.FaceColor = 'b';
    %     if m ==1
    %         p.FaceColor = 'r';
    %     end
        p.EdgeColor = 'none';
        p.FaceAlpha = 1.0;
        vector      = TARGET(m, :) + 10*TARGET(m, :)/norm(TARGET(m, :));    
        text(vector(1), vector(2), vector(3), sprintf('%.2f', 1e6*ElectrodeVoltages(m)), 'color', 'w');
    end
    bemf2_graphics_surf_field_gen(mesh_skin.P, mesh_skin.t, V_skin);
    daspect([1 1 1]);
    %camlight; lighting phong;
    xlabel('x'); ylabel('y'); zlabel('z');
    view(-130, 50);
    title('assembly with reference electrode')
    colormap jet
end
