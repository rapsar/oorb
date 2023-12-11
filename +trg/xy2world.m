function sff = xy2world(sff)
%XY2WORLD 
%   
% Raphael Sarfati, 05/2022

% triangulate
[worldPoints,err] = trg.triangulate360(sff.trg.matchedAlpha1t,sff.trg.matchedAlpha2t,sff.clb.stereo360Params);

% rescale and translate
worldPoints = worldPoints*sff.prm.world.horzMtr + sff.prm.world.vertMtr;

xyzt = [worldPoints sff.trg.matchedAlpha1t(:,4)];
xyzs = [worldPoints sff.trg.matchedAlpha1t(:,4)/sff.prm.mov.frameRate];

xyz = mat2cell(xyzt(:,1:4),accumarray(xyzt(:,4),xyzt(:,4),[],@numel));

sff.trg.xyz = xyz;
sff.trg.err = err;

sff.trg.xyzt = xyzt;
sff.trg.r = vecnorm(xyzt(:,1:3),2,2);

% removes far-away points
closeEnough = (sff.trg.r < sff.prm.trg.distThresholdMtr);

sff.xyzt = xyzt(closeEnough,:);
sff.xyzs = xyzs(closeEnough,:);

end




