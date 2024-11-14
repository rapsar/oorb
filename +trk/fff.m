function orb = fff(orb)
%FFF Orbit wrapper for fffabcnet

v1 = orb.prm.mov.v1; 
v2 = orb.prm.mov.v2;
prm = orb.prm;

%% process gp1
% display start time
disp('cam1')

% process
ff1 = trk.fffabcnet(v1,prm);
orb.xyt1 = ff1.xyt;

% display finish time
fprintf('\n'), disp(char(datetime("now")))

%% process gp2
% display start time
disp('cam2')

% process
%sff.gp2 = trk.fffabcnet(v2,prm);
ff2 = trk.fffabcnet(v2,prm);
orb.xyt2 = ff2.xyt;

% display finish time
fprintf('\n'), disp(char(datetime("now")))

end


