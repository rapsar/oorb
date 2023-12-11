function sff = Trajectorize(sff)
%TRAJECTORIZE 
%   
% RS, 05/2022

disp([datestr(now,31) ' -- Trajectorizing started...'])

% streaks
sff = trj.addstrk(sff);
sff.prm.flag.stk = 1;

% trajectories
sff = trj.addtraj(sff);
sff.prm.flag.trj = 1;

disp([datestr(now,31) ' -- Processing completed.'])


end

