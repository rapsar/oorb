function sff = oorb(varargin)
% OORB calibration-free 3D reconstruction of firefly spherical videos  
%
% Raphael Sarfati
% raphael.sarfati@aya.yale.edu
% github.com/rapsar/oorb
%
% oorb(sff)
% oorb(cyber2world)
%   
%
% 05/2022 -v0.1
% 07/2022 -v0.9
% 06/2023 -v2.0
% 06/2023 -v2.1

% initialize parameters, select movies
sff = utl.init(varargin);

% track flashes
sff = trk.Track(sff);

% calibrate and triangulate flash locations
sff = trg.Triangulate(sff);

% concatenate locations into streaks and trajectories
sff = trj.Trajectorize(sff);

% returns and plots
utl.exit(sff);

end


