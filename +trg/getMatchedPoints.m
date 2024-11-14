function orb = getMatchedPoints(orb)
%GETMATCHEDPOINTS Orbit wrapper for matchPoints 

xyt1 = orb.good(1);
xyt2 = orb.good(2);
dk = orb.prm.res.dk;
frameDim = orb.prm.mov.frameDim;
stereo360Params = orb.prm.res.stereo360Params;
distThresh = orb.prm.trg.matchPointsThrChord;

% match points
[matchedAlpha1t,matchedAlpha2t] = trg.matchPoints(xyt1,xyt2,dk,frameDim,stereo360Params,distThresh);

% return
%sff.trg.matchedAlpha1t = matchedAlpha1t;
%sff.trg.matchedAlpha2t = matchedAlpha2t;

%sff.xyzt(:,11:14) = matchedAlpha1t;
%sff.xyzt(:,21:24) = matchedAlpha2t;

orb.xyt1(:,6) = 0;
orb.xyt2(:,6) = 0;

n = size(matchedAlpha1t,1);

orb.xyt1(matchedAlpha1t(:,end),6) = 1:n;
orb.xyt2(matchedAlpha2t(:,end),6) = 1:n;


end

