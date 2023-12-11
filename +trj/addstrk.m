function sff = addstrk(sff)
%ADDSTRK wrapper for xyzt2strk

xyzt = vertcat(sff.trg.xyz{:});
linkRadius = sff.prm.stk.linkRadiusMtr;

sff.stk = trj.xyzt2strk(xyzt,linkRadius);

end


