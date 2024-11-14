function orb = alpha2world(orb)
%ALPHA2WORLD triangulate pairs of alpha positions

% triangulate
%[worldPoints,err] = trg.triangulate360(sff.trg.matchedAlpha1t,sff.trg.matchedAlpha2t,sff.clb.stereo360Params);
frameDim = orb.prm.mov.frameDim;
p1 = orb.xyt1(orb.xyt1(:,6)>0,:);
p1 = sortrows(p1,6);
p2 = orb.xyt2(orb.xyt2(:,6)>0,:);
p2 = sortrows(p2,6);
% matchedAlpha1t = sff.xyzt(:,11:14);
% matchedAlpha2t = sff.xyzt(:,21:24);
matchedAlpha1t = trg.fmx.xy2alpha(p1(:,1:4),frameDim);
matchedAlpha2t = trg.fmx.xy2alpha(p2(:,1:4),frameDim);
[worldPoints,err] = trg.triangulate360(matchedAlpha1t,matchedAlpha2t,orb.prm.res.stereo360Params);

% rescale and translate
worldPoints = worldPoints*orb.prm.world.horzMtr + orb.prm.world.vertMtr;

xyzt(:,1:4) = [worldPoints matchedAlpha1t(:,4)];
%xyzs = [worldPoints sff.trg.matchedAlpha1t(:,4)/sff.prm.mov.frameRate];

%xyz = mat2cell(xyzt(:,1:4),accumarray(xyzt(:,4),xyzt(:,4),[],@numel));

%sff.trg.xyz = xyz;
%sff.trg.err = err;

%sff.trg.xyzt = xyzt;
%sff.trg.r = vecnorm(xyzt(:,1:3),2,2);

r = vecnorm(xyzt(:,1:3),2,2);
% removes far-away points
closeEnough = (r < orb.prm.trg.distThresholdMtr);

orb.xyzt = xyzt(closeEnough,:);
%sff.xyzs = xyzs(closeEnough,:);

end




