function traj = strk2traj(strk,prm)
%STRK2TRAJ distance-based linkage based on (sparse) adjacency matrix
% strk -- strk structure returned by xyzt2strk
% prm -- parameter structure
%    .trajLinkRadiusMtr : max distance between streaks (meters)
%    .trajLinkMinLagFrm : min delay between streaks (frames)
%    .trajLinkMaxLagFrm : max delay between streaks (frames)
%
% Raphael Sarfati
% raphael.sarfati@aya.yale.edu
%
% rev: -05/22
%      -06/23
%      -11/24

% build adjacency matrix
trajKernel = determineTrajKernel(strk);
adj = buildSparseTrajAdj(strk,trajKernel,prm.trj.linkRadiusMtr,prm.trj.linkMinLagFrm,prm.trj.linkMaxLagFrm);

% adjacency matrix to graph
dg = digraph(adj);
trajID = conncomp(dg,'type','weak');

% Find unique trajectory IDs and process each trajectory
traj = arrayfun(@(j) ...
    padarray(sortrows(vertcat(strk.k{trajID == j}), 4), [0, 1], j, 'post'), ...
    1:max(trajID), 'UniformOutput', false);

% % graph connected streaks, ie trajectories
% nTraj = max(trajID);
% traj = cell(nTraj,1);

% for j = 1:nTraj
% 
%     % concatenate streaks
%     traj{j} = vertcat(strk.k{trajID == j});
% 
%     % sort by increasing time
%     traj{j} = sortrows(traj{j},4);
% 
%     % add traj number
%     traj{j} = padarray(traj{j},[0 1],j,'post');
% 
% end

%traj.nTraj = nTraj;
%traj.stat.trajLength = cellfun(@(x) size(x,1), traj.j);
%traj.stat.nStreaks = cellfun(@(x) size(unique(x(:,5)),1), traj.j);

end



function adj = buildSparseTrajAdj(strk,trajKernel,trajLinkRadius,trajLinkMinLagFrm,trajLinkMaxLagFrm)
% builds adjacency matrix (sparse, to avoid memory overload)

%% build sparse matrix
nStreaks = length(strk.k); 
sp = spdiags(ones(nStreaks,2*trajKernel+1),-trajKernel:trajKernel,nStreaks,nStreaks);
[row,col] = find(sp);

%% flash delays
dt = sparse(row, col, strk.stat.ti(row)-strk.stat.tf(col));
dt = dt';

%% flash distances
dx = sparse(row, col, strk.stat.ri(row,1)-strk.stat.rf(col,1));
dy = sparse(row, col, strk.stat.ri(row,2)-strk.stat.rf(col,2));
dz = sparse(row, col, strk.stat.ri(row,3)-strk.stat.rf(col,3));
dr = sqrt(dx.^2+dy.^2+dz.^2);
dr = dr';


%% distance-based linkage (distance-adjacency matrix)
adjtm = dt > trajLinkMinLagFrm;
adjtM = spfun(@(S) S-trajLinkMaxLagFrm,dt) < 0;
adjrM = spfun(@(S) S-trajLinkRadius,dr) < 0;
adj = adjtm & adjtM & adjrM;

end



function trajKernel = determineTrajKernel(strk)

trajKernel = 100;

end



