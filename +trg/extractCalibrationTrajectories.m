function orb = extractCalibrationTrajectories(orb)
%EXTRACTCALIBRATIONTRAJECTORIES 

xyt1 = orb.good(1);
xyt2 = orb.good(2);
dk = orb.prm.res.dk;
frameDim = orb.prm.mov.frameDim;

calPoints = extractCalibrationPoints(xyt1,xyt2,dk,frameDim);
%sff.clb.calPoints = spreadCalPoints(sff.clb.calPoints,1000,sff.prm.mov.frameDim);
calPoints = spreadCalPoints(calPoints,1000,frameDim);

calIdx = ismember(orb.xyt1,calPoints.p1,"rows");
orb.xyt1(:,end+1) = calIdx;

calIdx = ismember(orb.xyt2,calPoints.p2,"rows");
orb.xyt2(:,end+1) = calIdx;

end


function calPoints = extractCalibrationPoints(xyt1,xyt2,dk,frameDim)
%EXTRACTCALIBRATIONTRAJECTORIES Extracts calibration trajectories by
% finding synchronized frames with only one flash detected.

% unique flashes in cam1
rp = regionprops(xyt1(:,3));
a1 = vertcat(rp.Area);

% unique flashes in cam2
rp = regionprops(xyt2(:,3)-dk);
a2 = vertcat(rp.Area);

f1 = find(a1==1);
f2 = find(a2==1);

f = intersect(f1,f2);

%
% [~,D] = knnsearch(f,f,'K',2);
% k = find(D(:,2)==1);
% f = f(k);
%

idx1 = ismember(xyt1(:,3),f);
idx2 = ismember(xyt2(:,3)-dk,f);

calPoints.p1 = xyt1(idx1,:);
calPoints.p2 = xyt2(idx2,:);

%
%f = calPoints.p1(:,2) > 1000 & calPoints.p2(:,2) > 1000;
frameWidth = frameDim(1);
frameHeight = frameDim(2);
f = calPoints.p1(:,1) < 0.9*frameWidth ... %not sure why/maybe remove?
    & calPoints.p2(:,1) < 0.9*frameWidth ... %not sure why
    & calPoints.p1(:,2) > 0.2*frameHeight ...
    & calPoints.p2(:,2) > 0.2*frameHeight ...
    & calPoints.p1(:,2) < 0.8*frameHeight ...
    & calPoints.p2(:,2) < 0.8*frameHeight;
calPoints.p1 = calPoints.p1(f,:);
calPoints.p2 = calPoints.p2(f,:);
%

end


function calPointsOut = spreadCalPoints(calPointsIn,N,frameDim)
%SPREADCALPOINTS Downsample calibration points  

% don't do anything
if N==Inf 
    calPointsOut = calPointsIn;
    return
end

n = length(calPointsIn.p1);

if n < N
    warning('not enough points to downsample')
    calPointsOut = calPointsIn;
else
    %q1 = KAZEPoints(calPointsIn.p1(:,1:2));
    q1 = ORBPoints(calPointsIn.p1(:,1:2));
    u1 = selectUniform(q1,N,frameDim);

    %[~,f] = ismember(u1.Location,calPointsIn.p1(:,1:2),'rows');
    [~,f] = ismember(u1.Location,q1.Location,'rows');

    f = sort(f);

    %calPointsOut.p1 = double([u1.Location calPointsIn.p1(f,3)]);
    calPointsOut.p1 = calPointsIn.p1(f,:);
    calPointsOut.p2 = calPointsIn.p2(f,:);

end

end

