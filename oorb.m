function orb = oorb(varargin)
% OORB calibration-free 3D reconstruction of firefly spherical videos  
%
% Raphael Sarfati
% raphael.sarfati@aya.yale.edu
% github.com/rapsar/oorb
%
% oorb(orb)
% oorb(cyber2world)
% oorb(v1,v2,cyber2world)  
%
% 05/2022 -v0.1
% 07/2022 -v0.9
% 06/2023 -v2.0
% 06/2023 -v2.1
% 11/2024 -v3.0 (class/methods)

% initialize parameters, select movies
orb = utl.init(varargin);

% track flashes
orb = trk.Track(orb);

% calibrate and triangulate flash locations
orb = trg.Triangulate(orb);

% concatenate locations into streaks and trajectories
orb = trj.Trajectorize(orb);

% returns and plots
utl.exit(orb);

end


