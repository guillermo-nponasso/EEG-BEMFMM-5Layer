%   This script plots the electric potential of the primary, secondary, or
%   the full field for any brain compartment surface
%
%   Copyright SNM/WAW 2017-2020


eps0        = 8.85418782e-012;  %   Dielectric permittivity of vacuum(~air)
mu0         = 1.25663706e-006;  %   Magnetic permeability of vacuum(~air)

%%   Graphics
tissue_to_plot = 'Skin';
objectnumber    = find(strcmp(tissue, tissue_to_plot));
clear mov

%%  Digitize figure
if noise_computed
    fig = figure;
    fig.Visible = 'off';
    mov(Ntime_samples) = struct('cdata',[],'colormap',[]);
    for tt = 1:Ntime_samples
        step=10;
        temp            = Ptot(Indicator==objectnumber,tt);
        %temp = round(step*temp/max(temp)).*(max(temp))/step;
        bemf2_graphics_surf_field(P,t,temp,Indicator,objectnumber);
        view(-70,70);
        colormap jet;
        drawnow
        mov(tt)=getframe;
        frames{tt} = mov(tt);
    end
    fig.Visible = 'on';
    movie(mov,1,1);
    writeAnimation('movie.gif');

    
    %% save animation as gif
    movie_filename = fullfile('../data/images', patno ,strcat(patno,'_',model_name,'_forwardp_noise.gif'));
    for tt = 1 : Ntime_samples
        [imind_f, cm_f] = rgb2ind(frames{tt}.cdata,256);
        if tt==1
            imwrite(imind_f,cm_f, movie_filename,'gif','LoopCount',inf, 'DelayTime',0.5);
        else
            imwrite(imind_f,cm_f,movie_filename,'gif','WriteMode','append','DelayTime',0.5);
        end
    end

    %writeAnimation(fig,fullfile(pat_image_path,strcat(patno,'_',model_name,'_forwardp_noise.gif')))
    
else
    fig=figure
    step = 10;
    temp            = Ptot(Indicator==objectnumber);
    %temp = round(step*temp/max(temp)).*(max(temp))/step;
    bemf2_graphics_surf_field(P, t, temp, Indicator, objectnumber);
    title(strcat("Patient: ",patno," Model: ",model_name, ...
      " Electric potential in V for: ", tissue{objectnumber}));
    view(-70, 70); colormap jet;

    pat_image_path = fullfile('../data/images',patno);
    if(~isfolder(pat_image_path))
        mkdir(pat_image_path);
    end
    saveas(fig,fullfile(pat_image_path,strcat(patno,'_',model_name,'_forwardp')),'png')
    savefig(fig,fullfile(pat_image_path,strcat(patno,'_',model_name,'_forwardp.fig')))
end