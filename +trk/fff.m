function sff = fff(sff)
%FFF wrapper for fffabcnet

v1 = sff.gp1.mov;
v2 = sff.gp2.mov;
prm = sff.prm;

%% process gp1
% display start time
disp('gp1')

% process
sff.gp1 = trk.fffabcnet(v1,prm);

% display finish time
fprintf('\n'), disp(char(datetime("now")))

%% process gp2
% display start time
disp('gp2')

% process
sff.gp2 = trk.fffabcnet(v2,prm);

% display finish time
fprintf('\n'), disp(char(datetime("now")))

end


