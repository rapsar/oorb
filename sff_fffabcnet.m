function sff = sff_fffabcnet(sff)
%SFF_FFFABCNET sff wrapper for fffabcnet

v1 = sff.gp1.mov;
v2 = sff.gp2.mov;
prm = sff.prm;

%% process gp1
% display start time
disp('gp1')

% process
sff.gp1 = fffabcnet(v1,prm);

% display finish time
fprintf('\n'), disp(datestr(now,31))

%% process gp2
% display start time
disp('gp2')

% process
sff.gp2 = fffabcnet(v2,prm);

% display finish time
fprintf('\n'), disp(datestr(now,31))

end


%% track
function ff = fffabcnet(v,prm)
%FFFABCNET Find FireFlies Adaptive Background Compensation
%   Remove background and identify bright objects in foreground.
%   Input:  v -- video object, called from v = VideoReader('...')
%           bwth -- binarize threshold, typically 0.1 (0.07 - 0.15)  
%   Ouput:  ff -- firefly structure, see code for details
%
% Raphael Sarfati, 06/2023
% raphael.sarfati@aya.yale.edu

%% processing parameters, can be changed
% blurring radius for frame processing (default = 1)
blurRadius = prm.trk.blurRadiusPxl;

% railing background window size, in seconds (default = 1)
bkgrWinWidthSec = prm.trk.bkgrStackSec; 

% threshold for image binarization
bwThr = prm.trk.bwThr;

%% additional intrinsic variables
frameRate = prm.mov.frameRate;
bkgrWinSize = bkgrWinWidthSec*frameRate;

%% if v is video object -- might not be needed
if isobject(v)
    v{1} = v;
end

%% number of movies
nmov = length(v);

%% frame counter
frmidx = 1;

%% initialize first movie
w = VideoReader(v{1});

%% initial background stack
% create background stack or use from previous movie
if nargin == 2
    
    % build initial background stack
    while frmidx <= bkgrWinSize
        
        % read frame
        frame = readFrame(w);
        
        % use only green channel
        frame = frame(:,:,2);
        
        % use single precision, for speed
        frame = single(frame);
        
        % add to background stack
        bkgrStack(:,:,frmidx) = frame;
        
        % update frame counter
        frmidx = frmidx+1;
        
    end
    
    % frame index within the stack
    bkgrIdx = 1:bkgrWinSize;
    
elseif nargin == 3
    
    % use stack from previous movie
    bkgrStack = ffprior.bkgrStack;
    bkgrIdx = ffprior.bkgrIdx - max(ffprior.bkgrIdx);
    
else
    error('incorrect number of input arguments')
    
end

% initial background frame
bkgr = mean(bkgrStack,3);

%% loop through all movies

for i=1:nmov

% start time of processing
fprintf('\n')
disp(datestr(now,31))
disp(['movie ' num2str(i) ' of ' num2str(nmov)])

% re-initialize waitbar
rswaitbar reset


%% re-initialize movie since using readFrame
if i>1
    w = VideoReader(v{i});    
end

nFramesApprox = w.Duration*frameRate;
frmlocidx = 1;

%% processing movie

% process each frame
while hasFrame(w)
    
    % read frame
    frame = readFrame(w);
    
    % use only green channel
    newFrame = frame(:,:,2);
    
    % use single precision, for speed
    newFrame = single(newFrame);
    
    % calculate new bkgr from old and differential earliest/latest frames (for speed) 
    [~,m] = min(bkgrIdx);
    bkgr = bkgr + (newFrame - bkgrStack(:,:,m))/bkgrWinSize;
    
    % update stack with new frame replacing earliest frame
    bkgrStack(:,:,m) = newFrame;
    bkgrIdx(m) = frmidx;
    
    % grab current frame from stack
    currentFrameIdx = frmidx;
    f = (bkgrIdx == currentFrameIdx);
    currentFrame = bkgrStack(:,:,f);     
    
    % calculate foreground
    frgr = (currentFrame - bkgr);
    frgr = uint8(frgr);
    frgr = imgaussfilt(frgr,blurRadius);
    
    % binarize foreground and analyze connected components
    bw = imbinarize(frgr,bwThr);
    rp = regionprops(bw,newFrame,'Centroid','Area','Eccentricity','MeanIntensity');
    
    n = length(rp);

    xy = [vertcat(rp.Centroid) repmat(currentFrameIdx,n,1)];
    if ~isempty(xy)
        ff.xy{currentFrameIdx} = ffnetFilterFrame(frame,xy,prm.trk.ffnet);
    end

    %ff.aei{currentFrameIdx} = [vertcat(rp.Area) vertcat(rp.Eccentricity) vertcat(rp.MeanIntensity) repmat(currentFrameIdx,n,1)];
    ff.i(currentFrameIdx) = mean(newFrame,'all'); %
    
    % progress
    wb = rswaitbar(frmlocidx/nFramesApprox);
    
    % update frame counter
    frmidx = frmidx+1;
    frmlocidx = frmlocidx+1;
       
end

end


%% records all parameters
ff.n = cellfun(@(x) size(x,1),ff.xy);
%ff.xyt = vertcat(ff.xy{:}); %xyt coordinates
%ff.aeit = vertcat(ff.aei{:}); %area & eccentricity for each flash
ff.processed = datestr(now); %date & time processed
%ff.mov = get(v{1});
%ff.bkgrStack = bkgrStack;
%ff.bkgrIdx = bkgrIdx;
ff.code = fileread([mfilename('fullpath') '.m']);



end


%%
function xyOut = ffnetFilterFrame(frame, xy, ffnet)
% Extract local patches around possible flash locations and classify them using a feedforward neural network

patchSize = 65;
numChannels = size(frame, 3);
numXY = size(xy, 1);

halfPatchSize = floor(patchSize/2);

% % Reshape frame into a 2D array where each column represents a pixel
% pixelData = reshape(frame, [], numChannels)';

% Preallocate array for patches
patches = zeros(patchSize,patchSize,numChannels,numXY,'uint8');

% Round coordinates
xy = round(xy);

% Loop over possible flash locations and extract patches
for i = 1:numXY
    x = xy(i, 1);
    y = xy(i, 2);
    
    try
    % Extract local patch around flash location
    xmin = x - halfPatchSize;
    xmax = x + halfPatchSize;
    ymin = y - halfPatchSize;
    ymax = y + halfPatchSize;
    patches(:,:,:,i) = frame(ymin:ymax, xmin:xmax, :);
    %patch = reshape(patch, [], numChannels)';
    end
    
%     % Store patch in array
%     patches(:, i) = patch(:);
end

% Classify all patches using feedforward neural network
pred = classify(ffnet, patches);

% Find indices of patches classified as firefly flashes
fireflyIndices = str2num(char(pred));
fireflyIndices = logical(fireflyIndices);

% Map indices back to xy coordinates
xyOut = xy(fireflyIndices, :);

end




%% fast waitbar
function out = rswaitbar(fraction, text)
%   Modified by RS, based on progress.m from Matlab FEX
%   Goal is to be much faster than Matlab's waitbar.
%   Use in a loop just like waitbar:
%       insert: rswaitbar reset at beginning of function
%       insert: w = rswaitbar(f) in the loop (don't drop "w = ")
%       do not "close(w)" at the end
%
% Writes a text progress bar to the console
%
% Syntax: nb = progress(fraction, text)
%
% Input:
%  - fraction: number between 0 and 1 (where 1 means the process has ended)
%  - text (optional): label to display beside the progress bar
%
% Output:
%  - out: number of bytes printed, can be used to delete the progress bar
%         with fprintf(repmat('\b', 1, out));
% 
% Usage:
%  - in a for loop, write progress(j/maxiter, 'text') to display a progress
%  bar:
%  >> j = 2; maxiter = 10; progress(j/maxiter);
%  [====                ] 20.0%
%
%  - subsequent calls to the progress bar will delete the last `out' bytes,
%    if something else has been printed to stdout this will delete that and
%    not the progress bar
%  - avoid this by typing `progress reset'

global nb
if ischar(fraction) || isstring(fraction)
	if strcmp(fraction, 'reset')
		nb = 0;
		return;
	else
		error('Input 1 must either be a scalar or the string "reset"');
	end
end
if isempty(nb)
	nb = 0;
end
if ~exist('text', 'var')
	text = '';
elseif ~isempty(text)
	text = [strtrim(char(text)), ' '];
end

fprintf(repmat('\b', 1, nb));
nb = fprintf('%s %.2f%%', text, 100*fraction);
out = nb;
if fraction == 1
	fprintf('\n');
	nb = 0;	
end
end

