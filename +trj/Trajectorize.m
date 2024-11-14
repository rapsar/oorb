function orb = Trajectorize(orb)
%TRAJECTORIZE Orbit wrapper to concatenate xyzt coordinates into streaks and trajectories

disp([char(datetime("now")) ' -- Trajectorizing started...'])

% streaks
orb = trj.addstrk(orb);
orb.prm.flag.stk = true;

% trajectories
orb = trj.addtraj(orb);
orb.prm.flag.trj = true;

disp([char(datetime("now")) ' -- Trajectorizing completed.'])


end

