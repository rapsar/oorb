function sff = Track(sff)
%TRACK track and clean
% input and output: sff structure
%  
% Raphael Sarfati
% raphael.sarfati@aya.yale.edu


%% launch tracking

if ~sff.prm.flag.trk

    disp([char(datetime("now")) ' -- Tracking started...'])

    sff = trk.fff(sff);

    % flag; return to workspace
    sff.prm.flag.trk = 1;
    assignin('base','sff0',sff)
    disp([char(datetime("now")) ' -- Tracking completed.'])
    
end


%% launch cleaning

if ~sff.prm.flag.cln

    disp([char(datetime("now")) ' -- Cleaning started...'])

    sff = trk.sff_clean(sff);

    % flag; return to workspace
    sff.prm.flag.cln = 1;
    assignin('base','sff0',sff)
    disp([char(datetime("now")) ' -- Cleaning completed.'])

end


end

