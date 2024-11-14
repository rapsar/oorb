function orb = calibrateSpace(orb)
%CALIBRATESPACE Estimates camera pose directly from the data 

% Extract calibration sets
orb = trg.extractCalibrationTrajectories(orb);

% Extract calibration points
isCal1 = logical(orb.xyt1(:,5));
p1 = orb.xyt1(isCal1,:);

isCal2 = logical(orb.xyt2(:,5));
p2 = orb.xyt2(isCal2,:);

% Converts to alpha
calAlpha1 = trg.fmx.xy2alpha(p1,orb.prm.mov.frameDim);
calAlpha2 = trg.fmx.xy2alpha(p2,orb.prm.mov.frameDim);

% Estimates stereo360 parameters
orb.prm.res.stereo360ParamsRANSAC = trg.estimate360CameraParameters(calAlpha1(:,1:3),calAlpha2(:,1:3),'RANSAC');
orb.prm.res.stereo360Params = trg.estimate360CameraParameters(calAlpha1(:,1:3),calAlpha2(:,1:3),orb.prm.clb.estMethod,orb);


% sff.clb.stereo360ParamsRANSAC = trg.estimate360CameraParameters(calAlpha1(:,1:3),calAlpha2(:,1:3),'RANSAC');
% sff.clb.stereo360Params = trg.estimate360CameraParameters(calAlpha1(:,1:3),calAlpha2(:,1:3),sff.prm.clb.estMethod,sff);
%sff.stereo360Params.t = -sff.stereo360Params.t; %%%%%%%%%%%%%%% why


end


