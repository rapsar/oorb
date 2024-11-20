function ff = fffabcnet_slow(v,prm)
%FFFABCNET Find FireFlies Adaptive Background Compensation
%   Remove background and identify bright objects in foreground.
%   Input:  v -- video object, called from v = VideoReader('...')
%           bwth -- binarize threshold, typically 0.1 (0.07 - 0.15)  
%   Ouput:  ff -- firefly structure, see code for details
%
% Raphael Sarfati, 06/2023
% raphael.sarfati@aya.yale.edu

%% processing parameters
% blurring radius for frame processing (default = 1)
blurRadius = 0; %prm.trk.blurRadiusPxl;

% railing background window size, in seconds (default = 1)
bkgrWinWidthSec = prm.trk.bkgrStackSec; 

% threshold for image binarization
bwThr = prm.trk.bwThr;

% Size for batch processing of patches
patchBatch = 1000;

%% intrinsic variables
frameRate = prm.mov.frameRate;
bkgrWinSize = round(bkgrWinWidthSec*frameRate);
invBkgrWinSize = 1/bkgrWinSize;
patchSize = prm.trk.ffnet.Layers(1).InputSize;
frameDim = prm.mov.frameDim;
numPixels = frameDim(1) * frameDim(2);

alpha = 1/30;

%% if v is video object -- might not be needed
if isobject(v)
    v{1} = v;
end

%% number of movies
numberMovies = length(v);

%% global frame counter
frameGlobalIdx = 1;

%% initialize first movie
w = VideoReader(v{1});

%% initial background stack
% create background stack or use from previous movie

bkgrStack = single(zeros(numPixels, bkgrWinSize));

if nargin == 2
    
    % build initial background stack
    while frameGlobalIdx <= bkgrWinSize
        
        % read frame
        frame = readFrame(w);
        
        % use only green channel
        frame = frame(:,:,2);
        
        % use single precision, for speed
        frame = single(frame);
        
        % add to background stack
        %bkgrStack(:,:,frameGlobalIdx) = frame;
        bkgrStack(:,frameGlobalIdx) = frame(:);
        
        % update frame counter
        frameGlobalIdx = frameGlobalIdx+1;
        
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
%bkgr = mean(bkgrStack,3);
bkgr = mean(bkgrStack,2);

%bkgr = reshape(bkgr, [frameDim(2) frameDim(1)]);
bkgr = frame;

% initialize output
ff.xyt = [];

%% loop through all movies

for i=1:numberMovies

    % start time of processing
    fprintf('\n')
    disp(datetime("now"))
    disp(['movie ' num2str(i) ' of ' num2str(numberMovies)])

    % re-initialize waitbar
    %utl.fastwaitbar reset


    %% re-initialize movie since using readFrame
    if i>1
        w = VideoReader(v{i});
    end

    nFramesApprox = w.Duration*frameRate;
    frameLocalIdx = 1;
    
    % initialize patches array
    patches = [];
    xyt = [];
    %patches = zeros(65,65,3,1000,'uint8');
    %xyt = zeros(1000,3);

    %% processing movie

    % process each frame
    while hasFrame(w)

        % read frame
        frame = readFrame(w);

        % use only green channel
        newFrame = frame(:,:,2);

        % use single precision, for speed
        newFrame = single(newFrame);
        %newFrameVec = newFrame(:);

        % calculate new bkgr from old and differential earliest/latest frames (for speed)
        %[~,m] = min(bkgrIdx);
        %oldFrame = bkgrStack(:,:,m);
        %oldFrame = bkgrStack(:,m);
        %bkgr = bkgr + (newFrameVec - oldFrame)*invBkgrWinSize; %%%slowest line (30%), optimize
        

        % update stack with new frame replacing earliest frame
        %bkgrStack(:,:,m) = newFrame;
        %bkgrStack(:,m) = newFrameVec;
        %bkgrIdx(m) = frameGlobalIdx;

        % grab current frame from stack
        %currentFrameIdx = frameGlobalIdx;
        %f = (bkgrIdx == currentFrameIdx);
        %currentFrame = bkgrStack(:,:,f);
        %currentFrame = bkgrStack(:,f);

        % calculate foreground
        %frgr = (currentFrame - bkgr);
        frgr = (newFrame - bkgr);
        frgr = uint8(frgr);
        %frgr = uint8(reshape(frgr, [frameDim(2) frameDim(1)]));
        if blurRadius > 0.2
            frgr = imgaussfilt(frgr,blurRadius); %slow
        end

        % binarize foreground and analyze connected components
        bw = imbinarize(frgr,bwThr);
        rp = regionprops(bw,newFrame,'Centroid'); %,'Area','Eccentricity','MeanIntensity');

        bkgr = (1-alpha)*bkgr + alpha*newFrame;

        n = length(rp);

        %xy = [vertcat(rp.Centroid) repmat(currentFrameIdx,n,1)];
        xy = [vertcat(rp.Centroid) repmat(frameGlobalIdx,n,1)];
        xy = round(xy); 
        xyt = vertcat(xyt,xy); 
        if ~isempty(xy)
            patches = extractPatches(frame,xy,patches,patchSize);
        end
        
        % classify patches once enough have been extracted
        if size(patches,4) > patchBatch
            %classify
            xytOut = classifyPatches(xyt,patches,prm.trk.ffnet);
            ff.xyt = vertcat(ff.xyt,xytOut);            
            % re-initialize arrays
            patches = [];
            xyt = [];
        end
    
        % additional metrics
        % ff.aei{currentFrameIdx} = [vertcat(rp.Area)...
        %     vertcat(rp.Eccentricity)...
        %     vertcat(rp.MeanIntensity)...
        %     repmat(currentFrameIdx,n,1)];
        %ff.i(currentFrameIdx) = mean(newFrame,'all');
        ff.i(frameGlobalIdx) = mean(newFrame,'all');

        % progress
        wb = utl.fastwaitbar(frameLocalIdx/nFramesApprox);

        % update frame counter
        frameGlobalIdx = frameGlobalIdx+1;
        frameLocalIdx = frameLocalIdx+1; 

    end
    
    xytOut = classifyPatches(xyt,patches,prm.trk.ffnet);
    ff.xyt = vertcat(ff.xyt,xytOut);

    
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

function patchesOut = extractPatches(frame,xy,patchesIn,patchSize)
% extract patches and add to the stack

halfPatchSize = floor(patchSize(1) / 2);

% Ensure coordinates are integers
xy = round(xy);
numXY = size(xy, 1);

% Convert frame to single precision for compatibility with CNN and reduce memory
%frame = single(frame);

% Preallocate the patch array
patches = zeros([patchSize numXY], 'uint8');

% Vectorized extraction of patches using indexing
for i = 1:numXY
    x = xy(i, 1);
    y = xy(i, 2);
    
    % % Define patch boundaries with clamping to image size
    % xmin = max(1, x - halfPatchSize);
    % xmax = min(size(frame, 2), x + halfPatchSize);
    % ymin = max(1, y - halfPatchSize);
    % ymax = min(size(frame, 1), y + halfPatchSize);
    % 
    % % Extract patch and place it in the preallocated array
    % patches(1:(ymax-ymin+1), 1:(xmax-xmin+1), :, i) = frame(ymin:ymax, xmin:xmax, :);

    % Define xi and yi ranges, accounting for 360-degree wrapping on x-axis
    xi = x-halfPatchSize : x+halfPatchSize;
    yi = y-halfPatchSize : y+halfPatchSize;

    % Adjust x indices (repeat edge pixels)
    xi(xi < 1) = 1;
    xi(xi > size(frame, 1)) = size(frame, 1);

    % Adjust y indices for 360-degree wraparound
    yi(yi < 1) = yi(yi < 1) + size(frame, 2);
    yi(yi > size(frame, 2)) = yi(yi > size(frame, 2)) - size(frame, 2);

    % extract patches
    patches(:,:,:,i) = frame(xi, yi, :);
end

patchesOut = cat(4,patchesIn,patches);

end


function xytOut = classifyPatches(xyt,patches,ffnet)

% Batch classify all patches
pred = classify(ffnet, patches);
% Find indices of patches classified as firefly flashes
fireflyIndices = logical(double(pred) == 1);
% Map indices back to xy coordinates
xytOut = xyt(fireflyIndices, :);

end





