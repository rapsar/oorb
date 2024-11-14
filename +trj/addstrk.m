function orb = addstrk(orb)
%ADDSTRK Orbit wrapper for xyzt2strk

xyzt = orb.xyzt(:,1:4);
linkRadius = orb.prm.stk.linkRadiusMtr;

% returns streak structure
strk = trj.xyzt2strk(xyzt,linkRadius);
orb.xyzt = strk.xyzti;

end


