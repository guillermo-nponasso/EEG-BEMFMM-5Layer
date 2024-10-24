%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% fieldtrip_setup.m -- Set up the minimal %%
%%% FieldTrip path and settings.            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restoredefaultpath;
clear ft_hastoolbox;
addpath(fullfile('../engines/fieldtrip'));
ft_defaults;
