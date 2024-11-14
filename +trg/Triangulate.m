function orb = Triangulate(orb)
%TRIANGULATE calibrate and triangulate
% input and output: Orbit object

%% calibration

if ~orb.prm.flag.clb

    disp([char(datetime("now")) ' -- Calibration started...'])

    % time calibration
    orb = trg.calibrateFrame(orb);

    % space calibration
    orb = trg.calibrateSpace(orb);

    % flag; return to workspace
    orb.prm.flag.clb = true;
    assignin('base','orb0',orb)
    disp([char(datetime("now")) ' -- Calibration completed.'])

end


%% triangulation

if ~orb.prm.flag.trg

    disp([char(datetime("now")) ' -- Triangulation started...'])

    orb = trg.getMatchedPoints(orb); 
    orb = trg.alpha2world(orb); 

    % flag; return to workspace
    orb.prm.flag.trg = true;
    assignin('base','orb0',orb)
    disp([char(datetime("now")) ' -- Triangulation completed.'])    

end
 

end

