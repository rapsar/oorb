function sff = getMatchedPoints(sff)
%GETMATCHEDPOINTS wrapper for matchPoints 
%   
% Raphael Sarfati, 05/2022

% grab inpits
xyt1 = vertcat(sff.gp1.cln.xy{:});
xyt2 = vertcat(sff.gp2.cln.xy{:});
dk = sff.clb.dk;
frameDim = sff.prm.mov.frameDim;
stereo360Params = sff.clb.stereo360Params;
distThresh = sff.prm.trg.matchPointsThrChord;

% match points
[matchedAlpha1t,matchedAlpha2t] = trg.matchPoints(xyt1,xyt2,dk,frameDim,stereo360Params,distThresh);

% return
sff.trg.matchedAlpha1t = matchedAlpha1t;
sff.trg.matchedAlpha2t = matchedAlpha2t;


end

