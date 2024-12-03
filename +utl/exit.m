function exit(orb)
%EXIT plot 3D points and save xyzt as .csv files

% plot xyzt
orb.plot3

% save as csv
csvname = strcat('xyztkj','_',datestr(now,30),'.csv');
writematrix(orb.xyzt,csvname)

% wrap up and blink
utl.blink

end

