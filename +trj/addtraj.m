function orb = addtraj(orb)
%ADDTRAJ Orbit wrapper for strk2traj

% strk structure
strk = trj.xyzt2strk(orb.xyzt(:,1:4),orb.prm.stk.linkRadiusMtr);

% trajectory cell array
traj = trj.strk2traj(strk,orb.prm);

% trajectory array
orb.xyzt = vertcat(traj{:});

% add time units from frames to seconds in col 7
orb.xyzt(:,7) = orb.xyzt(:,4)*orb.prm.world.frame2second;

end


