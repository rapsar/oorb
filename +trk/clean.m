% function orb = clean(orb)
% %CLEAN Removes anomalous coordinates, if necessary  
% 
% %sff.gp1.cln = ffClean(sff.gp1,sff.prm);
% %sff.gp2.cln = ffClean(sff.gp2,sff.prm);
% orb.xyt1(:,4) = 1;
% orb.xyt2(:,4) = 1;
% 
% end

function orb = clean(orb)

orb.xyt1(:,4) = 1; %all good for now
orb.xyt2(:,4) = 1;

switch orb.prm.cln.type
    case 'none'
        return

    case 'nmax'
        rm1 = rm_large_n(orb.n1,orb.xyt1,orb.prm.cln.nMax);
        rm2 = rm_large_n(orb.n2,orb.xyt2,orb.prm.cln.nMax);

    case 'bins'
        rm1 = rm_large_bin(orb.xyt1,orb.prm.cln.xybinsMaxPrb);
        rm2 = rm_large_bin(orb.xyt2,orb.prm.cln.xybinsMaxPrb);

    case 'area'
        rm1 = rm_large_area(orb.n1,orb.xyt1,orb.prm.cln.areaOutlierThr);
        rm2 = rm_large_area(orb.n2,orb.xyt2,orb.prm.cln.areaOutlierThr);

end

orb.xyt1(rm1,4) = 0;
orb.xyt2(rm2,4) = 0;

end


function rm = rm_large_n(n,xyt,nmax)
% removes flashes in frames that have too many flashes
% pros: removes transient artifacts
% cons: difficult to find a proper maxn

tOut = find(n > nmax);
rm = ismember(xyt(:,3),tOut);

% %% xyt2
% tOut = find(orb.n2 > orb.prm.cln.maxn);
% rm = ismember(orb.xyt2(:,3),tOut);
% orb.xyt2(rm,4) = 0;
    
end

function rm = rm_large_bin(xyt,maxProbability)
% removes flashes in anomalous bins
% pros: useful when some parts of the field of view get too many flashes
% cons: could remove stationary fireflies

nbins = 256;
[n,~,~,binX,binY] = histcounts2(xyt(:,1),xyt(:,2),nbins,'Normalization','probability');
[row,col] = find(n > maxProbability); %0.001
rm = ismember([binX binY],[row,col],'rows');

% %% xyt2
% [n,~,~,binX,binY] = histcounts2(orb.xyt2(:,1),orb.xyt2(:,2),nbins,'Normalization','probability');
% [row,col] = find(n > prm.cln.xybinsMaxPrb); %0.001
% rm = ismember([binX binY],[row,col],'rows');
% orb.xyt2(rm,4) = 0;

end

function rm = rm_large_area(n,xyt,areaOutlierThreshold)
% removes flashes in frames that are part of an anomalous cluster
% eg: n = [ 0 1 0 1 0 1 2 0 0 0 2 4 5 7 4 1 0 0 2 0 1 0 1 1 0] (rm 2 4 5 7 4 1)
% pros: removes bright & transient light pollution, such as flashlights
% cons: could remove long-lasting flashes

rp = regionprops(n>0,n,'Area','MeanIntensity','PixelList');

s = vertcat(rp.Area);
i = vertcat(rp.MeanIntensity);
a = s.*i;       % chunk area (under the n-curve)

aOut = isoutlier(log(a),'mean','ThresholdFactor',areaOutlierThreshold);
tOut = vertcat(rp(aOut).PixelList);

if ~isempty(tOut)
    rm = ismember(xyt(:,3),tOut(:,1));
else
    rm = [];
end

% %% xyt2
% n = orb.n2;
% nn = n>0;
% rp = regionprops(nn,n,'Area','MeanIntensity','PixelList');
% 
% s = vertcat(rp.Area);
% i = vertcat(rp.MeanIntensity);
% a = s.*i;       % chunk area (under the n-curve)
% 
% aOut = isoutlier(log(a),'mean','ThresholdFactor',orb.prm.cln.areaOutlierThr);
% tOut = vertcat(rp(aOut).PixelList);
% 
% if ~isempty(tOut)
%     rm = ismember(orb.xyt2(:,3),tOut(:,1));
%     orb.xyt2(rm,4) = 0;
% end

end



function ffo = ffClean(ffi,prm)
% clean detected flashes by removing clusters


%% pass and keep raw data
%ffo = ffi;
ffo.n = ffi.n;
ffo.xyt = vertcat(ffi.xy{:});
%ffo.aeit = ffi.aeit;
%ffo.xy = ffi.xy;
%ffo.aei = ffi.aei;


%% truncate beginning and end
N = length(ffi.n);

t = ffo.xyt(:,3);
rmt = (t <= prm.cln.initlBufferFrm | t >= (N-prm.cln.finalBufferFrm+1));

ffo.xyt(rmt,:) = [];
%ffo.aeit(rmt,:) = [];


% %% remove too dark
% isDark = (ffo.aeit(:,3) < prm.cln.flashMinBrightUI8); % parametrize etc.
% 
% ffo.xyt(isDark,:) = [];
% ffo.aeit(isDark,:) = [];

% %%%
% for i=1:N
%     f = find(ffo.xyt(:,3) == i);
%     if length(f) > 3
%         [~,d] = knnsearch(ffo.xyt(f,1:2),ffo.xyt(f,1:2),'K',2);
%         d = d(:,2);
%         ff = find(d<100);
%         ffo.xyt(f(ff),:) = [];
%         ffo.aeit(f(ff),:) = [];
%     end
% end
% 
% %%%
% 
% %% remove too frequent bins
% [n,~,~,binX,binY] = histcounts2(ffo.xyt(:,1),ffo.xyt(:,2),100,'Normalization','probability');
% [row,col] = find(n>0.001);
% isTooMany = ismember([binX binY],[row,col],'rows');
% ffo.xyt(isTooMany,:) = [];
% ffo.aeit(isTooMany,:) = [];


%% returns n, xy{} and aei{} from xyt
ffo.n = histcounts(ffo.xyt(:,3),0.5:N+0.5);
ffo.xy = mat2cell(ffo.xyt(:,1:3),ffo.n(:));
%ffo.aei = mat2cell(ffo.aeit(:,1:2),ffo.n(:));


%% determine size of clusters to remove

n = ffo.n;
nn = n>0;

rp = regionprops(nn,n,'Area','MeanIntensity','PixelList');

s = vertcat(rp.Area);
i = vertcat(rp.MeanIntensity);

% chunk area (under the N-curve)
a = s.*i;

isOut = isoutlier(log(a),'mean','ThresholdFactor',prm.cln.areaOutlierThr);
tOut = vertcat(rp(isOut).PixelList);
if ~isempty(tOut)
    tOut = tOut(:,1);
end

ffo.n(tOut) = 0;
ffo.xy(tOut) = cell(length(tOut),1);
% ffo.aei(tOut) = cell(length(tOut),1);
% t = ffo.xyt(:,3);
% ffo.xyt(ismember(t,tOut),:) = [];
% ffo.aeit(ismember(t,tOut),:) = [];

% shows removed clusters
ffo.isOut = isOut;
ffo.tOut = tOut;
ffo.nOut = 0*ffo.n;
ffo.nOut(isOut) = n(isOut);

% save processing code
ffo.code = fileread([mfilename('fullpath') '.m']);

end