function sff = sff_xyzt2strk(sff)
%SFF_XYZT2STRK sff wrapper for xyzt2strk
%   
% Raphael Sarfati
% raphael.sarfati@aya.yale.edu

xyzt = vertcat(sff.trg.xyz{:});
linkRadius = sff.prm.stk.linkRadiusMtr;

sff.stk = xyzt2strk(xyzt,linkRadius);

end


function strk = xyzt2strk(xyzt,linkRadius)

% build adjacency matrix
strkKernel = determineStrkKernel(xyzt);
adj = buildSparseStrkAdj(xyzt,strkKernel,linkRadius);

% adjacency matrix to graph
dg = digraph(adj);

% graph connected components, i.e. streaks
[strkID,strkDuration] = conncomp(dg,'type','weak');

%xyzt streakID
xyzti = [xyzt strkID(:)];
xyzti = sortrows(xyzti,[5 4]);

% streaks in cell format
xyzts = mat2cell(xyzti,strkDuration(:));

%% stats
% streak number of frames
stat.nf = cellfun(@(x) size(x,1), xyzts);

% streak first and last frames
stat.ti = cellfun(@(x) x(1,4), xyzts);
stat.tf = cellfun(@(x) x(end,4), xyzts);

% streak first and last positions
stat.ri = cell2mat(cellfun(@(x) x(1,1:3), xyzts,'UniformOutput',false));
stat.rf = cell2mat(cellfun(@(x) x(end,1:3), xyzts,'UniformOutput',false));

% streak average velocity (not in m/s yet)
stat.v = cellfun(@(x) mean(vecnorm(diff(x(:,1:3),1,1),2,2)), xyzts);

% streak average height
stat.z = cellfun(@(x) mean(x(:,3)), xyzts);

% streak vertical displacement
stat.dz = cellfun(@(x) x(end,3)-x(1,3), xyzts);

% streak horizontal displacement
stat.dxy = cellfun(@(x) vecnorm(x(end,1:2)-x(1,1:2)), xyzts);

% streak distance from reference camera
stat.q = cellfun(@(x) mean(vecnorm(x(:,1:3),2,2)), xyzts);

%% out
%strk.xyzti = xyzti;
strk.k = xyzts;
strk.stat = stat;

% strk.stat.nf = nf;
% strk.stat.v = v; % not in m/s yet
% strk.stat.ti = ti;
% strk.stat.tf = tf;
% strk.stat.ri = ri;
% strk.stat.rf = rf;
% %strk.nStreaks = max(strkID);
% strk.stat.z = z;
% strk.stat.dz = dz;
% strk.stat.dxy = dxy;
% strk.stat.q = q;

end


function adj = buildSparseStrkAdj(xyzt,strkKernel,strkLinkRadius)
%% number of adjacent streaks to probe for match
x = xyzt(:,1);
y = xyzt(:,2);
z = xyzt(:,3);
t = xyzt(:,4);
p = length(t);

%% build sparse matrix
sp = spdiags(ones(p,2*strkKernel+1),-strkKernel:strkKernel,p,p);
[row,col] = find(sp);

%% flash delays
dt = sparse(row, col, abs(t(row)-t(col)));

%% flash distances
dx = sparse(row, col, x(row)-x(col)+eps); % +eps necessary to avoid numeric zero equated to sparse zero 
dy = sparse(row, col, y(row)-y(col)+eps);
dz = sparse(row, col, z(row)-z(col)+eps);
dr = sqrt(dx.^2+dy.^2+dz.^2);


%% distance-based linkage (distance-adjacency matrix)
adjt = (dt == 1);
adjr = (spfun(@(S) S-strkLinkRadius,dr) < 0);
adj = adjt & adjr;

end

function strkKernel = determineStrkKernel(xyzt)

% simply the maximum number of flashes in a frame
t = xyzt(:,4);
n = histcounts(t,0.5:max(t)+0.5);

strkKernel = max(n);

end

