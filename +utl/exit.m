function exit(sff)
% exits by plotting 3D points and saving xyzt as .csv files

figure,
scatter3(sff.xyzt(:,1),sff.xyzt(:,2),sff.xyzt(:,3),10,sff.xyzt(:,4),'filled')
axis equal
xlim([-10 10]), xlabel('x (m)')
ylim([-10 10]), ylabel('y (m)')
zlim([-10 10]), zlabel('z (m)')

% save main output as csv file
if ~isfile('xyztkj.csv')
    csvname = 'xyztkj.csv';
else
    % avoids overwriting previous file
    csvname = strcat('xyztkj','_',datestr(now,30),'.csv');
end
writematrix(sff.xyztkj,csvname)

%wrap up and blink
utl.blink

end

