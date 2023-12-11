function sff = addtraj(sff)
%TRAJ wrapper for strk2traj

sff.trj = trj.strk2traj(sff.stk,sff.prm);

%sff.xyztkj = sff.trj.j(:,[1 2 3 4 5 6]);
sff.xyztkj = vertcat(sff.trj.j{:});
sff.xyztkj(:,4) = sff.xyztkj(:,4)/sff.prm.mov.frameRate; %time in seconds

end


