function sff = Trajectorize(sff)
%TRAJECTORIZE wrapper to concatenate xyzt coordinates into trajectories
% (with assumptions)
%   
% RS, 05/2022

disp([char(datetime("now")) ' -- Trajectorizing started...'])

% streaks
sff = trj.addstrk(sff);
sff.prm.flag.stk = 1;

% trajectories
sff = trj.addtraj(sff);
sff.prm.flag.trj = 1;

disp([char(datetime("now")) ' -- Trajectorizing completed.'])


end

