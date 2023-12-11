function sff = Triangulate(sff)
%TRIANGULATE calibrate and triangulate
% input and output: sff structure
%
% Raphael Sarfati
% raphael.sarfati@aya.yale.edu


%% launch calibration

if ~sff.prm.flag.clb

    disp([char(datetime("now")) ' -- Calibration started...'])

    % time calibration
    sff = trg.dk(sff);

    % space calibration
    sff = trg.calibrate(sff);

    % flag; return to workspace
    sff.prm.flag.clb = 1;
    assignin('base','sff0',sff)
    disp([char(datetime("now")) ' -- Calibration completed.'])

end


%% launch triangulation

if ~sff.prm.flag.trg

    disp([char(datetime("now")) ' -- Triangulation started...'])

    sff = trg.getMatchedPoints(sff); 
    sff = trg.xy2world(sff); 

    % flag; return to workspace
    sff.prm.flag.trg = 1;
    assignin('base','sff0',sff)
    disp([char(datetime("now")) ' -- Triangulation completed.'])    

end
 

end

