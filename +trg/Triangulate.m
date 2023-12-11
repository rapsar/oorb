function sff = sffTriangulate(sff)
%SFFTRIANGULATE calibrate and triangulate
% input and output: sff structure
%
% Raphael Sarfati
% raphael.sarfati@aya.yale.edu


%% launch calibration

if ~sff.prm.flag.clb

    disp([datestr(now,31) ' -- Calibration started...'])

    % time calibration
    sff = trg.sff_dk(sff);

    % space calibration
    sff = trg.sff_extractCalibrationTrajectories(sff); 
    sff = trg.sff_estimate360CameraParameters(sff); 

    % flag; return to workspace
    sff.prm.flag.clb = 1;
    assignin('base','sff0',sff)
    disp([datestr(now,31) ' -- Calibration completed.'])

end


%% launch triangulation

if ~sff.prm.flag.trg

    disp([datestr(now,31) ' -- Triangulation started...'])

    sff = trg.sff_matchPoints(sff); 
    sff = trg.sff_triangulate360(sff); 

    % flag; return to workspace
    sff.prm.flag.trg = 1;
    assignin('base','sff0',sff)
    disp([datestr(now,31) ' -- Triangulation completed.'])    

end
 

end

