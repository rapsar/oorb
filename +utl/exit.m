function exit(orb)
%EXIT plot 3D points and save xyzt as .csv files

% plot
figure,
scatter3(orb.xyzt(:,1),orb.xyzt(:,2),orb.xyzt(:,3),10,orb.xyzt(:,4),'filled')
axis equal
xlim([-10 10]), xlabel('x (m)')
ylim([-10 10]), ylabel('y (m)')
zlim([-10 10]), zlabel('z (m)')

% save as csv
csvname = strcat('xyztkj','_',datestr(now,30),'.csv');
writematrix(orb.xyzt,csvname)

% wrap up and blink
utl.blink

end

