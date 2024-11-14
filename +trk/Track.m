function orb = Track(orb)
%TRACK track and clean
% input and output: Orbit object

%% tracking

if ~orb.prm.flag.trk

    disp([char(datetime("now")) ' -- Tracking started...'])
    orb = trk.fff(orb);

    % flag; return to workspace
    orb.prm.flag.trk = true;
    assignin('base','orb0',orb)
    disp([char(datetime("now")) ' -- Tracking completed.'])
    
end


%% cleaning

if ~orb.prm.flag.cln

    disp([char(datetime("now")) ' -- Cleaning started...'])

    orb = trk.clean(orb);

    % flag; return to workspace
    orb.prm.flag.cln = true;
    assignin('base','orb0',orb)
    disp([char(datetime("now")) ' -- Cleaning completed.'])

end


end

