function sff = calibrate(sff)
%CALIBRATE Spatial calibration 
%   
% Raphael Sarfati, 05/2022

sff = trg.extractCalibrationTrajectories(sff);

calAlpha1 = trg.fmx.xy2alpha(sff.clb.calPoints.p1,sff.prm.mov.frameDim);
calAlpha2 = trg.fmx.xy2alpha(sff.clb.calPoints.p2,sff.prm.mov.frameDim);

sff.clb.stereo360ParamsRANSAC = trg.estimate360CameraParameters(calAlpha1(:,1:3),calAlpha2(:,1:3),'RANSAC');
sff.clb.stereo360Params = trg.estimate360CameraParameters(calAlpha1(:,1:3),calAlpha2(:,1:3),sff.prm.clb.estMethod,sff);
%sff.stereo360Params.t = -sff.stereo360Params.t; %%%%%%%%%%%%%%% why
end


