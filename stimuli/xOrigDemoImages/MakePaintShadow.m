% MakePaintShadow
%
% Generate some dynamic stimuli.
%
% The basic 2D checkboard generation is written in a somewhat
% convoluted manner, because I started with the idea that I might not
% always do squares.  But, I'm keeping it this way
% for now because there may be someday that parallelgrams
% are in fact of interest, and this code provides
% a template.   Setting the paraTheta parameter to zero gives
% squares.
%
% 4/15/12 dhd  Started.

%% Clear
clear; close all;

%% Parameters
imageRows = 1500;
imageCols = imageRows;
nChecks = 6;
checkSquareSize = 250;
paraTheta = 0;

% Check reflecance
whiteRefl = 0.95;
blackRefl = 0.3;
backgroundRefl = 0.5;

% Shadow steepness
shadowSteepness = 4;

% Illumination.  Dark light is chosen
% to equate key squares.  The steepness
% parameter controls the size of the
% illumination blur across the diagonal
% edge.
brightLight = 1;
darkLight = brightLight*blackRefl/whiteRefl;
fprintf('\nBright light = %0.2f, dark light = %0.2f\n',brightLight,darkLight);

% Probe
BLOB = 0;
nSteps = 2;
blobSd = 10;
probeDiam = 100;
CONTRAST = 1;
if (~CONTRAST)
    probeMiddle = brightLight*blackRefl;
    probeColorsLow = brightLight*blackRefl-0.15;
    probeColorsHigh = brightLight*blackRefl+0.15;
    probeColors = [linspace(probeMiddle,probeColorsHigh,nSteps) linspace(probeColorsHigh,probeColorsLow,2*nSteps) linspace(probeColorsLow,probeMiddle,nSteps)];
    probeConstrasts = (probeColors-brightLight*blackRefl)/(brightLight*blackRefl);
    mixFactors = [linspace(0,1,2*nSteps) linspace(1,0,2*nSteps)];
else
    probeContrasts = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
    probeColors = brightLight*blackRefl+(probeContrasts/100)*brightLight*blackRefl;
    probeColorsHigh = max(probeColors);
    probeColorsLow = min(probeColors);
    mixFactors = linspace(0,1,length(probeColors));
end

%% Some computed geometric parameters.
colSize = checkSquareSize;
colParaDelta = round(checkSquareSize*sin((pi/180)*paraTheta));
rowSize = round(checkSquareSize*cos((pi/180)*paraTheta));
steadyCols = nChecks*colSize;
steadyRows = nChecks*rowSize;
rowOffset = round((imageRows-steadyRows)/2);
colOffset = round((imageCols-steadyCols)/2);

%% Make shadow illumination image
fprintf('Making shadow illumination image\n');
theShadowIllumImage = brightLight*ones(imageRows,imageCols);
critRow = rowSize;
critCol = colSize;
for theRow = 1:imageRows
    effectiveRow = theRow-rowOffset;
    for theCol = 1:imageCols
        effectiveCol = theCol-colOffset;
        
        % This first conditional makes sure we are within the checkerboard itself
        if (theRow >= rowOffset && theCol >= colOffset && theRow <= imageRows-rowOffset && theCol <= imageCols - colOffset)
            
            % This checks if we are in the central part, which is always the darker illuminant
            if (effectiveRow < critRow + effectiveCol && effectiveRow >= -critRow + effectiveCol)
                theShadowIllumImage(theRow,theCol) = darkLight;
                
                % Lower diagonal below center.  Allocate bright/dark according to distance along diagonal.
            elseif (effectiveRow < 2*critRow + effectiveCol && effectiveRow >= critRow + effectiveCol)
                
                distance = (2*critRow-effectiveRow + effectiveCol)/rowSize;
                effDistance = betacdf(distance,shadowSteepness,shadowSteepness);
                theShadowIllumImage(theRow,theCol) =  (1-effDistance)*brightLight + effDistance*darkLight;
                
                % Upper diagonal above center.  Same idea as lower.
            elseif (effectiveRow < -critRow + effectiveCol && effectiveRow >= -2*critRow + effectiveCol)
                distance = 1 - (-effectiveRow + effectiveCol-colSize)/colSize;
                effDistance = betacdf(distance,shadowSteepness,shadowSteepness);
                theShadowIllumImage(theRow,theCol) =  (1-effDistance)*brightLight + effDistance*darkLight;
            end
            
        end
    end
end

%% Fill in the reflectance and paint illumination images.
%
% The paint illumination image for each square is the mean of the
% shadow illumination image for the same square.
fprintf('Making reflectance and paint illumination images\n');
theReflImage = backgroundRefl*ones(imageRows,imageCols);
thePaintIllumImage = brightLight*ones(imageRows,imageCols);
rowStart = rowOffset;
colStart = colOffset;
[x,y] = meshgrid(1:imageCols,1:imageRows);
X = [x(:)  y(:)];
for theRow = 1:nChecks
    if (rem(theRow,2) == 0)
        checkPolarity = 1;
    else
        checkPolarity = 0;
    end
    colStart = colOffset + (theRow-1)*colParaDelta;
    for theCol = 1:nChecks;
        if (checkPolarity == 0)
            checkRefl = whiteRefl;
            checkPolarity = 1;
        else
            checkRefl = blackRefl;
            checkPolarity = 0;
        end
        colTopLeft = colStart; colTopRight = colTopLeft+colSize;
        colBottomLeft = colTopLeft+colParaDelta; colBottomRight = colBottomLeft+colSize;
        TRI = DelaunayTri([[colTopLeft rowStart]',[colTopRight rowStart]',[colBottomLeft,rowStart+rowSize]',[colBottomRight,rowStart+rowSize]']');
        index = ~isnan(pointLocation(TRI,X));
        theReflImage(index) = checkRefl;
        thePaintIllumImage(index) = mean(theShadowIllumImage(index));
        colStart = colStart + colSize;
    end
    rowStart = rowStart + rowSize;
end

%% Image is illumination times reflectance
thePaintImage = thePaintIllumImage .* theReflImage;
theShadowImage = theShadowIllumImage .* theReflImage;

%% Compute means of the two images
paintImageMean = mean(thePaintImage(:));
shadowImageMean = mean(theShadowImage(:));
fprintf('Paint image mean = %0.3f, shadow image mean = %0.3f\n',paintImageMean,shadowImageMean);

%% Make the half image
index2 = find(x(:) >= imageRows+1-y(:));
theHalfImage = thePaintImage;
theHalfImage(index2) = theShadowImage(index2);

%% Add the probe circles
paintFig = figure; clf;
paintMov = moviein(length(probeColors));
thePaintImages = cell(length(probeColors),1);
imPaintData = cell(length(probeColors),1);
shadowFig = figure; clf;
shadowMov = moviein(length(probeColors));
theShadowImages = cell(length(probeColors),1);
imShadowData = cell(length(probeColors),1);
halfFig = figure; clf;
halfMov = moviein(length(probeColors));
theHalfImages = cell(length(probeColors),1);
imHalfData = cell(length(probeColors),1);
shadowPaintFig = figure; clf;
shadowPaintMov = moviein(length(probeColors));
theShadowPaint = cell(length(probeColors),1);
imShadowPint = cell(length(probeColors),1);

for k = 1:length(probeColors)
    probeColor = probeColors(k);
    thePaintImages{k} = thePaintImage;
    theShadowImages{k} = theShadowImage;
    theHalfImages{k} = theHalfImage;
    theShadowPaint{k} = mixFactors(k)*thePaintImage + (1-mixFactors(k))*theShadowImage;
    
    %% Save images at no probe.  These are not rotated, so if rotation
    % is set thay won't match the ones saved with the high probe.
    if (probeColor == probeColorsHigh)
        imwrite(sqrt(thePaintImages{k}), 'Paint.tiff', 'tiff');
        imwrite(sqrt(theShadowImages{k}), 'Shadow.tiff', 'tiff');
        imwrite(sqrt(theHalfImages{k}), 'HalfHalf.tiff', 'tiff');
        
        imageNames = {'Quarter11', 'Quarter12', 'Quarter21', 'Quarter22'};
        for ii = 1:length(imageNames)
            % This trims off background borders.  This is obviously dependent
            % on the format of the images being used.  Would be a lot cooler
            % with a general solution.
            switch imageNames{ii}
                case 'Quarter11'
                    stimImage = theHalfImages{k}(1:imageRows/2,1:imageRows/2);
                    %stimImage = stimImage(rowExtract1, colExtract1);
                    
                case 'Quarter12'
                    stimImage = theHalfImages{k}(1:imageRows/2,imageRows/2+1:end);
                    %stimImage = stimImage(rowExtract1, colExtract2);
                    
                case 'Quarter21'
                    stimImage = theHalfImages{k}(imageRows/2+1:end,1:imageRows/2);
                    %stimImage = stimImage(rowExtract2, colExtract1);
                    
                case 'Quarter22'
                    stimImage = theHalfImages{k}(imageRows/2+1:end,imageRows/2+1:end);
                    %stimImage = stimImage(rowExtract2, colExtract2);
            end
            
            % Save the .tiff.
            imwrite(sqrt(stimImage), sprintf('%s.tiff', imageNames{ii}), 'tiff');
            
            % Save the .mat.
            save(imageNames{ii}, 'stimImage');
        end
    end
    
    % Add the probe circles.  We put two on most of the images
    % and four on the half/half image.
    probeRowCenter = rowOffset + 4.5*rowSize;
    probeColCenter = colOffset + 1.5*colSize;
    probeDelta = X - ones(size(X,1),1)*[probeColCenter probeRowCenter];
    for i = 1:size(X,1)
        if (norm(probeDelta(i,:)) < probeDiam/2)
            if (~BLOB)
                theShadowPaint{k}(i) = probeColorsHigh;
                thePaintImages{k}(i) = probeColor;
                theShadowImages{k}(i) = probeColor;
                theHalfImages{k}(i) = probeColor;
            else
                bgColor = theShadowPaint{k}(i);
                theShadowPaint{k}(i) = bgColor + (probeColorsHigh-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
                
                bgColor = thePaintImages{k}(i);
                thePaintImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
                
                bgColor = theShadowImages{k}(i);
                theShadowImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
                
                bgColor = theHalfImages{k}(i);
                theHalfImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
            end
        end
    end
    
    probeRowCenter = rowOffset + 4.5*rowSize;
    probeColCenter = colOffset + 4.5*colSize;
    probeDelta = X - ones(size(X,1),1)*[probeColCenter probeRowCenter];
    for i = 1:size(X,1)
        if (norm(probeDelta(i,:)) < probeDiam/2)
            if (~BLOB)
                theShadowPaint{k}(i) = probeColorsHigh;
                thePaintImages{k}(i) = probeColor;
                theShadowImages{k}(i) = probeColor;
                theHalfImages{k}(i) = probeColor;
            else
                bgColor = theShadowPaint{k}(i);
                theShadowPaint{k}(i) = bgColor + (probeColorsHigh-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
                
                bgColor = thePaintImages{k}(i);
                thePaintImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
                
                bgColor = theShadowImages{k}(i);
                theShadowImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
                
                bgColor = theHalfImages{k}(i);
                theHalfImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
            end
        end
    end
    
    probeRowCenter = rowOffset + 1.5*rowSize;
    probeColCenter = colOffset + 1.5*colSize;
    probeDelta = X - ones(size(X,1),1)*[probeColCenter probeRowCenter];
    for i = 1:size(X,1)
        if (norm(probeDelta(i,:)) < probeDiam/2)
            if (~BLOB)
                theHalfImages{k}(i) = probeColor;
            else
                bgColor = theHalfImages{k}(i);
                theHalfImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
            end
        end
    end
    
    probeRowCenter = rowOffset + 1.5*rowSize;
    probeColCenter = colOffset + 4.5*colSize;
    probeDelta = X - ones(size(X,1),1)*[probeColCenter probeRowCenter];
    for i = 1:size(X,1)
        if (norm(probeDelta(i,:)) < probeDiam/2)
            if (~BLOB)
                theHalfImages{k}(i) = probeColor;
            else
                bgColor = theHalfImages{k}(i);
                theHalfImages{k}(i) = bgColor + (probeColor-bgColor)*exp(-0.5*(probeDelta(i,:))*inv(diag([blobSd.^2 blobSd.^2]))*(probeDelta(i,:)'));
            end
        end
    end
    
    % Use OpenGL/MGL magic to rotate/translate the checkerboard
    %rotationDeg = 70;
    rotationDeg = 0;
    if (rotationDeg ~= 0)
        rotationAxis = [-1 0 0];                    % x, y, z
        sceneDims = [48 30];			            % Dimensions of the rendered scene.  These are generic widescreen dimensions.
        screenDist = 40;                            % Distance from the image.
        objectDims = [25 25];                       % Size of the image plane.
        imPaintData{k} = RenderRotatedImage(sqrt(thePaintImages{k}(end:-1:1,:)), rotationDeg, rotationAxis, screenDist, sceneDims, objectDims);
        imShadowData{k} = RenderRotatedImage(sqrt(theShadowImages{k}(end:-1:1,:)), rotationDeg, rotationAxis, screenDist, sceneDims, objectDims);
        imHalfData{k} = RenderRotatedImage(sqrt(theHalfImages{k}(end:-1:1,:)), rotationDeg, rotationAxis, screenDist, sceneDims, objectDims);
        imShadowPaint{k} = RenderRotatedImage(sqrt(theShadowPaint{k}(end:-1:1,:)), rotationDeg, rotationAxis, screenDist, sceneDims, objectDims);
    else
        imPaintData{k} = sqrt(thePaintImages{k});
        imShadowData{k} = sqrt(theShadowImages{k});
        imHalfData{k} = sqrt(theHalfImages{k});
        imShadowPaint{k} = sqrt(theShadowPaint{k});
    end
    
    %% Save images at max probe
    if (probeColor == probeColorsHigh)
        imwrite(imPaintData{k},'PaintWithProbe.tiff','tiff');
        imwrite(imShadowData{k},'ShadowWithProbe.tiff','tiff');
        imwrite(imHalfData{k},'HalfHalfWithProbe.tiff','tiff');
        imwrite(imHalfData{k}(1:imageRows/2,1:imageRows/2),'Quarter11WithProbe.tiff','tiff');
        imwrite(imHalfData{k}(1:imageRows/2,imageRows/2+1:end),'Quarter12WithProbe.tiff','tiff');
        imwrite(imHalfData{k}(imageRows/2+1:end,1:imageRows/2),'Quarter21WithProbe.tiff','tiff');
        imwrite(imHalfData{k}(imageRows/2+1:end,imageRows/2+1:end),'Quarter22WithProbe.tiff','tiff');
    end
    
    %% Save un gamma corrected stimulus images for experimetns with Marlene
    cd('CohenImages');
    imwrite(imHalfData{k}(1:imageRows/2-1,1:imageRows/2-1).^2,sprintf('Paint_Con%d.tiff',probeContrasts(k)),'tiff');
    imwrite(imHalfData{k}(imageRows/2+2:end,imageRows/2+2:end).^2,sprintf('Shadow_Con%d.tiff',probeContrasts(k)),'tiff');
    imwrite(imHalfData{k}(1:imageRows/2-1,1:imageRows/2-1),sprintf('PaintSqrt_Con%d.tiff',probeContrasts(k)),'tiff');
    imwrite(imHalfData{k}(imageRows/2+2:end,imageRows/2+2:end),sprintf('ShadowSqrt_Con%d.tiff',probeContrasts(k)),'tiff');
    theImage = imHalfData{k}(1:imageRows/2-1,1:imageRows/2-1).^2;
    save(sprintf('Paint_Con%d',probeContrasts(k)),'theImage');
    theImage = imHalfData{k}(imageRows/2+2:end,imageRows/2+2:end).^2;
    save(sprintf('Shadow_Con%d',probeContrasts(k)),'theImage');
    theImage = imHalfData{k}(1:imageRows/2-1,1:imageRows/2-1);
    save(sprintf('PaintSqrt_Con%d',probeContrasts(k)),'theImage');
    theImage = imHalfData{k}(imageRows/2+2:end,imageRows/2+2:end);
    save(sprintf('ShadowSqrt_Con%d',probeContrasts(k)),'theImage'); 
    cd('..');

    %% Show the image of the rotated checkboard
    figure(paintFig);
    imshow(imPaintData{k}); drawnow;
    paintMov(k) = getframe;
    fprintf('\tPaint frame %d of %d\n',k,length(probeColors));
    
    figure(shadowFig);
    imshow(imShadowData{k}); drawnow;
    shadowMov(k) = getframe;
    fprintf('\tShadow frame %d of %d\n',k,length(probeColors));
    
    figure(halfFig);
    imshow(imHalfData{k}); drawnow;
    halfMov(k) = getframe;
    fprintf('\tHalf frame %d of %d\n',k,length(probeColors));
    
    figure(shadowPaintFig);
    imshow(imShadowPaint{k}); drawnow;
    shadowPaintMov(k) = getframe;
    fprintf('\tShadow/paint frame %d of %d\n',k,length(probeColors));
end

%% Write out the movies
cyclesPerSecond = 0.1;
framesPerSecond = length(probeColors)*cyclesPerSecond;
vidObj = VideoWriter('PaintWithProbe.avi','Uncompressed AVI');
vidObj.FrameRate = framesPerSecond;
open(vidObj);
for k = 1:length(paintMov)
    writeVideo(vidObj,paintMov(k));
end
close(vidObj);

clear vidObj;
vidObj = VideoWriter('ShadowWithProbe.avi','Uncompressed AVI');
vidObj.FrameRate = framesPerSecond;
open(vidObj);
for k = 1:length(shadowMov)
    writeVideo(vidObj,shadowMov(k));
end
close(vidObj);

clear vidObj;
vidObj = VideoWriter('HalfHalfWithProbe.avi','Uncompressed AVI');
vidObj.FrameRate = framesPerSecond;
open(vidObj);
for k = 1:length(halfMov)
    writeVideo(vidObj,halfMov(k));
end
close(vidObj);

clear vidObj;
vidObj = VideoWriter('ShadowPaint.avi','Uncompressed AVI');
vidObj.FrameRate = framesPerSecond;
open(vidObj);
for k = 1:length(shadowPaintMov)
    writeVideo(vidObj,shadowPaintMov(k));
end
close(vidObj);
