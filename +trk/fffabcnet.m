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

% initialize output
ff.xyt = [];

%% loop through all movies

for i=1:nmov

    % start time of processing
    fprintf('\n')
    disp(datetime("now"))
    disp(['movie ' num2str(i) ' of ' num2str(nmov)])

    % re-initialize waitbar
    %utl.fastwaitbar reset


    %% re-initialize movie since using readFrame
    if i>1
        w = VideoReader(v{i});
    end

    nFramesApprox = w.Duration*frameRate;
    frmlocidx = 1;
    
    % initialize patches array
    patches = []; %zeros(65,65,3,'uint8');
    xyt = [];

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
        %frgr = imgaussfilt(frgr,blurRadius);

        % binarize foreground and analyze connected components
        bw = imbinarize(frgr,bwThr);
        rp = regionprops(bw,newFrame,'Centroid','Area','Eccentricity','MeanIntensity');

        n = length(rp);

        xy = [vertcat(rp.Centroid) repmat(currentFrameIdx,n,1)];
        xy = round(xy); %new
        xyt = vertcat(xyt,xy); %new
        if ~isempty(xy)
            %ff.xy{currentFrameIdx} = ffnetFilterFrame(frame,xy,prm.trk.ffnet);
            patches = extractPatches(frame,xy,patches); %new
        end

        %ff.aei{currentFrameIdx} = [vertcat(rp.Area) vertcat(rp.Eccentricity) vertcat(rp.MeanIntensity) repmat(currentFrameIdx,n,1)];
        ff.i(currentFrameIdx) = mean(newFrame,'all'); %

        % progress
        wb = utl.fastwaitbar(frmlocidx/nFramesApprox);

        % update frame counter
        frmidx = frmidx+1;
        frmlocidx = frmlocidx+1; %if frmlocidx > 1000, break; end % new

    end
    
    % new
    % Batch classify all patches
    pred = classify(prm.trk.ffnet, patches);
    % Find indices of patches classified as firefly flashes
    fireflyIndices = logical(double(pred) == 1);  % assuming '1' indicates a positive classification
    % Map indices back to xy coordinates
    xyOut = xyt(fireflyIndices, :);
    % add to list
    ff.xyt = vertcat(ff.xyt,xyOut);

    

end


% %% records all parameters
% ff.n = cellfun(@(x) size(x,1),ff.xy);
% %ff.xyt = vertcat(ff.xy{:}); %xyt coordinates
% %ff.aeit = vertcat(ff.aei{:}); %area & eccentricity for each flash
% ff.log.processed = datetime("now"); %date & time processed
% %ff.mov = get(v{1});
% %ff.bkgrStack = bkgrStack;
% %ff.bkgrIdx = bkgrIdx;
% ff.log.code = fileread([mfilename('fullpath') '.m']);



end


%%
function xyOut = ffnetFilterFrameNO(frame, xy, ffnet)
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

function xyOut = ffnetFilterFrame(frame, xy, ffnet)
% Optimized function to extract local patches and classify using CNN

patchSize = 65;
halfPatchSize = floor(patchSize / 2);

% Ensure coordinates are integers
xy = round(xy);

% Convert frame to single precision for compatibility with CNN and reduce memory
frame = single(frame);

% Preallocate the patch array in single precision
numXY = size(xy, 1);
patches = zeros(patchSize, patchSize, size(frame, 3), numXY, 'single');

% Vectorized extraction of patches using indexing
for i = 1:numXY
    x = xy(i, 1);
    y = xy(i, 2);
    
    % Define patch boundaries with clamping to image size
    xmin = max(1, x - halfPatchSize);
    xmax = min(size(frame, 2), x + halfPatchSize);
    ymin = max(1, y - halfPatchSize);
    ymax = min(size(frame, 1), y + halfPatchSize);
    
    % Extract patch and place it in the preallocated array
    patches(1:(ymax-ymin+1), 1:(xmax-xmin+1), :, i) = frame(ymin:ymax, xmin:xmax, :);
end

% Batch classify all patches
pred = classify(ffnet, patches);

% Find indices of patches classified as firefly flashes
fireflyIndices = strcmp(pred, '1');  % assuming '1' indicates a positive classification

% Map indices back to xy coordinates
xyOut = xy(fireflyIndices, :);

end

function patchesOut = extractPatches(frame,xy,patchesIn)

patchSize = 65;
halfPatchSize = floor(patchSize / 2);

% Ensure coordinates are integers
xy = round(xy);

% Convert frame to single precision for compatibility with CNN and reduce memory
%frame = single(frame);

% Preallocate the patch array in single precision
numXY = size(xy, 1);
%patches = zeros(patchSize, patchSize, size(frame, 3), numXY, 'single');
patches = zeros(patchSize, patchSize, size(frame, 3), numXY, 'uint8');

% Vectorized extraction of patches using indexing
for i = 1:numXY
    x = xy(i, 1);
    y = xy(i, 2);
    
    % Define patch boundaries with clamping to image size
    xmin = max(1, x - halfPatchSize);
    xmax = min(size(frame, 2), x + halfPatchSize);
    ymin = max(1, y - halfPatchSize);
    ymax = min(size(frame, 1), y + halfPatchSize);
    
    % Extract patch and place it in the preallocated array
    patches(1:(ymax-ymin+1), 1:(xmax-xmin+1), :, i) = frame(ymin:ymax, xmin:xmax, :);
end

patchesOut = cat(4,patchesIn,patches);


end

