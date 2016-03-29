% MakeCraikCornsweet
%
% Generate some dynamic stimuli.
%
% 4/15/12 dhd  Started.

%% Clear
clear; close all;

%% Parameters
imageRows = 400;
imageCols = 800;
inset = 150;
steadyRows = imageRows-inset;
steadyCols = imageCols-inset;
centerRow = round(imageRows/2);
backgroundColor = 0;
incrementColor = 0.75;
incrementSize = 50;
incrementColOffset = 50;
steadyColor = 0.7;
edgeContrast = 0.1;
edgeSdPixels = 50;
p = 1;

%% Start to fill in
theImage = backgroundColor*ones(imageRows,imageCols);
steadyRowEdge = (imageRows-steadyRows)/2;
steadyColEdge = (imageCols-steadyCols)/2;
theImage(steadyRowEdge:imageRows-steadyRowEdge,steadyColEdge:imageCols-steadyColEdge) = steadyColor;

%% Make the magic edge in a loop over contrasts
basicStep = 20;
theContrasts = [linspace(0,edgeContrast,basicStep) linspace(edgeContrast,-edgeContrast,2*basicStep) linspace(-edgeContrast,0,basicStep)];
movieFigure = figure; clf;

axes('Position',[0 0 1 1],'Visible','Off'); hold on
mov = moviein(length(theContrasts));
fprintf('Making movie\n');
for i = 1:length(theContrasts)
    useContrast = theContrasts(i);
    edgeLow = -useContrast/2 + steadyColor;
    edgeHigh = useContrast/2 + steadyColor;
    if (edgeLow < 0 || edgeHigh > 1)
        error('Oops.  Bad edge contrast chosen, given value of steadyColor');
    end
    edgeCenter = round(imageCols/2);
    y1 = lappdf((steadyColEdge:edgeCenter)-edgeCenter,p,edgeSdPixels^2);
    y1 = steadyColor + (edgeHigh-steadyColor)*y1/max(y1);
    y2 = lappdf((edgeCenter+1:imageCols-steadyColEdge)-edgeCenter,p,edgeSdPixels^2);
    y2 = steadyColor + (edgeLow-steadyColor)*y2/max(y2);
    y = [y1 y2];
    theImage(steadyRowEdge:imageRows-steadyRowEdge,steadyColEdge:imageCols-steadyColEdge) = ...
        y(ones(length(steadyRowEdge:imageRows-steadyRowEdge),1),:);
    
    % Pop in increments
    theImage(centerRow-incrementSize/2:centerRow+incrementSize/2, ...
        inset/2+incrementColOffset:inset/2+incrementColOffset+incrementSize) = incrementColor;
    theImage(centerRow-incrementSize/2:centerRow+incrementSize/2, ...
        imageCols-inset/2-incrementColOffset-incrementSize:imageCols-inset/2-incrementColOffset) = incrementColor;
    
    % Plot frame profile
    figure(cutFigure); clf; hold on
    plot(y);
    plot(theImage(round(imageRows/2),steadyColEdge:imageCols-steadyColEdge),'r:');
    ylim([0 1]);
    
    
    % Show the image and grab the frame
    figure(movieFigure);
    imshow(sqrt(theImage));
    mov(i) = getframe;
    fprintf('\tFrame %d of %d\n',i,length(theContrasts));
    
end

%% Write out the movie
cyclesPerSecond = 0.1;
framesPerSecond = length(theContrasts)*cyclesPerSecond;
vidObj = VideoWriter('CraikCornsweet.avi','Uncompressed AVI');
vidObj.FrameRate = framesPerSecond;
open(vidObj);
for i = 1:length(mov)
    writeVideo(vidObj,mov(i));
end
close(vidObj);