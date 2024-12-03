function ff = fffabcnet(v,prm)
%FFFABCNET Find FireFlies Adaptive Background Compensation + firefleyeNET
%   Remove background and identify bright objects in foreground with ffnet
%   Input:  v -- VideoReader object or cellarray of videofile paths
%           prm -- structure of parameters  
%   Ouput:  ff -- firefly structure

%% processing parameters
% blurring radius for frame processing (default = 1)
blurRadius = prm.blurRadiusPxl; 

% threshold for image binarization
bwThr = prm.bwThr;

% Size for batch processing of patches
patchBatch = 1000;


%% intrinsic variables
frameRate = prm.frameRate;
patchSize = prm.ffnet.Layers(1).InputSize;

% alpha for EWMA
alpha = 1/prm.bkgrStackFrm; %1/30 or 1/60, typically

%% number of movies
numberMovies = length(v);

%% global frame counter
frameGlobalIdx = 1;

%% initialize output
ff.xyt = [];

%% loop through all movies

for i=1:numberMovies

    % start time of processing
    fprintf('\n')
    disp(datetime("now"))
    disp(['movie ' num2str(i) ' of ' num2str(numberMovies)])
    
    % load movie
    if isobject(v)
        w = v;
    else
        w = VideoReader(v{i});
    end

    nFramesApprox = w.Duration*frameRate;

    % initialization
    frameLocalIdx = 1;
    patches = [];
    xyt = [];

    % initialize background
    frame = readFrame(w);
    bkgr = single(frame(:,:,2));

    % update frame counter
    frameGlobalIdx = frameGlobalIdx+1;
    frameLocalIdx = frameLocalIdx+1;


    %% processing movie

    % process each frame
    while hasFrame(w)

        % read frame
        frame = readFrame(w);

        % use only green channel
        newFrame = frame(:,:,2);

        % use single precision, for speed
        newFrame = single(newFrame);

        % calculate foreground
        frgr = uint8(newFrame - bkgr);

        % update background (EWMA)
        bkgr = (1-alpha)*bkgr + alpha*newFrame;
        
        % blurs, if necessary (alternative: dilate bw?)
        if blurRadius > 0.2
            frgr = imgaussfilt(frgr,blurRadius); %slow
        end

        % binarize foreground and analyze connected components
        bw = imbinarize(frgr,bwThr);
        rp = regionprops(bw,newFrame,'Centroid'); %,'Area','Eccentricity','MeanIntensity');
        
        % collect positions
        xy = [vertcat(rp.Centroid) repmat(frameGlobalIdx,length(rp),1)];
        xy = round(xy); 
        xyt = vertcat(xyt,xy); 
        
        % extract patches
        if ~isempty(xy)
            patches = extractPatches(frame,xy,patches,patchSize);
        end
        
        % classify patches by batches
        if size(patches,4) > patchBatch
            %classify
            xytOut = classifyPatches(xyt,patches,prm.ffnet);
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
        %wb = utl.fastwaitbar(frameLocalIdx/nFramesApprox);
        utl.fastwaitbar(frameLocalIdx/nFramesApprox,'Processing frames...');

        % update frame counter
        frameGlobalIdx = frameGlobalIdx+1;
        frameLocalIdx = frameLocalIdx+1; 

    end
    
    xytOut = classifyPatches(xyt,patches,prm.ffnet);
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





