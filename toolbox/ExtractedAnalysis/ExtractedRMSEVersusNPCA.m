function ExtractedRMSEVersusNPCA(doIt,decodeInfo,theData)
% ExtractedRMSEVersusNPCA(doIt,decodeInfo,theData)
%
% Study decoding performance as a function of number of PCA dimensions
%
% 3/29/16  dhb  Pulled it out.
% 4/5/16   dhb  Cleaned up to use new conventions.

%% Are we doing it?
%
% Rename buggy filename if it exists
switch (doIt)
    case 'always'
    case 'never'
        return;
    case 'ifmissing'
        if (exist(fullfile(decodeInfo.writeDataDir,'extRMSEVersusNPCA.mat'),'file'))
            return;
        end
end

%% Get info about what to do
%nUnitsToUseList = unique([1 2 round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy))]);


%% Set up needed parameters
clear decodeSave
decodeSave.verbose = decodeInfo.verbose;
decodeSave.nUnits = decodeInfo.nUnits;
decodeSave.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeSave.nNUnitsToStudy = decodeInfo.nNUnitsToStudy;
decodeSave.nRepeatsPerNUnits = decodeInfo.nRepeatsPerNUnits;
decodeSave.decodeJoint = 'both';
decodeSave.type = 'aff';
decodeSave.decodeLOOType = decodeInfo.decodeLOOType;
decodeSave.decodeNFolds = decodeInfo.decodeNFolds;
decodeSave.trialShuffleType = 'none';
decodeSave.paintShadowShuffleType = 'none';

%% Shuffle if desired
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% We want to do the PCA on means responses for each stimulus
%
% The idea is not to have the PCA output driven by noise.
for dc = 1:length(decodeInfo.uniqueIntensities)
    theIntensity = decodeInfo.uniqueIntensities(dc);
    paintIndex = find(theData.paintIntensities == theIntensity);
    shadowIndex = find(theData.shadowIntensities == theIntensity);
    meanPaintResponses(dc,:) = mean(theData.paintResponses(paintIndex,:),1);
    meanShadowResponses(dc,:) = mean(theData.shadowResponses(shadowIndex,:),1);
end

%% Get PCA info based on both paint and shadow mean responses
clear decodeInfoPCA
decodeInfoPCA.pcaType = 'ml';
[~,~,pcaBasis,meanResponse] = PaintShadowPCA(decodeInfoPCA,meanPaintResponses,meanShadowResponses);

% The form returned by PCATransform has the mean subtracted off.
paintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,pcaBasis,meanResponse);
shadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,pcaBasis,meanResponse);
meanPaintPCAResponses = PCATransform(decodeInfoPCA,meanPaintResponses,pcaBasis,meanResponse);
meanShadowPCAResponses = PCATransform(decodeInfoPCA,meanShadowResponses,pcaBasis,meanResponse);

%% Get RMSE based on guessing mean intensity
%
% Should not do worse than these for any serious estimator
temp = mean([theData.paintIntensities(:) ; theData.shadowIntensities(:)])*ones(size([theData.paintIntensities(:) ; theData.shadowIntensities(:)]));
nullRMSE = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-temp(:)).^2));
temp = mean(theData.paintIntensities(:))*ones(size(theData.paintIntensities));
nullRMSEPaint = sqrt(mean((theData.paintIntensities(:)-temp(:)).^2));
temp = mean(theData.shadowIntensities(:))*ones(size(theData.shadowIntensities));
nullRMSEShadow = sqrt(mean((theData.shadowIntensities(:)-temp(:)).^2));

%% Decide which PCA dimensions to study
%
% Because we're doing PCA on mean responses, we're bounded by the
% number of 
uniqueNUnitsToStudy = size(pcaBasis,2);
nUnitsToUseList = 1:uniqueNUnitsToStudy;

%% Get RMSE as a function of number of PCA components
decodeSave.theUnits = zeros(uniqueNUnitsToStudy,1);
decodeSave.theRMSE = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    decodeInfo.nUnitsToUse = nUnitsToUseList(uu);
    decodeSave.theUnits(uu) = nUnitsToUseList(uu);
    
    [~,~,paintPCAPreds,shadowPCAPreds] = PaintShadowDecode(decodeSave, ...
        paintIntensities,paintPCAResponses(:,1:decodeInfo.nUnitsToUse),shadowIntensities,shadowPCAResponses(:,1:decodeInfo.nUnitsToUse));
    decodeSave.theRMSE(uu) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPCAPreds(:) ; shadowPCAPreds(:)]).^2));
end

%% Fit an exponential
a0 = nullRMSE; b0 = 5; c0 = min(decodeSave.theRMSE);
ftype = fittype('(a-c)*exp(-(x)/(b)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[a0 2 0],'Upper',[a0 200 5]);
index = find(decodeSave.theUnits <= decodeInfo.nFitMaxUnits);
decodeSave.fit = fit(decodeSave.theUnits(index),decodeSave.theRMSE(index),ftype,foptions);
decodeSave.bestRMSE = c0;
decodeSave.nullRMSE = nullRMSE;
decodeSave.fitScale = decodeSave.fit.b;
decodeSave.fitAsymp = decodeSave.fit.c;

%% Do PCA on paint only, and decode both paint and shadow in the PCA basis
[~,~,paintOnlyPCABasis,paintOnlyMeanResponse] = PaintShadowPCA(decodeInfoPCA,meanPaintResponses,[]);
paintOnlyPaintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,paintOnlyPCABasis,paintOnlyMeanResponse);
paintOnlyShadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,paintOnlyPCABasis,paintOnlyMeanResponse);
meanPaintOnlyPaintPCAResponses = PCATransform(decodeInfoPCA,meanPaintResponses,pcaBasis,paintOnlyMeanResponse);
meanPaintOnlyShadowPCAResponses = PCATransform(decodeInfoPCA,meanShadowResponses,pcaBasis,paintOnlyMeanResponse);

uniqueNUnitsToStudy = size(paintOnlyPCABasis,2);
nUnitsToUseList = 1:uniqueNUnitsToStudy;
decodeSave.thePaintOnlyUnits = zeros(uniqueNUnitsToStudy,1);
decodeSave.thePaintOnlyPaintRMSE = zeros(uniqueNUnitsToStudy,1);
decodeSave.thePaintOnlyShadowRMSE = zeros(uniqueNUnitsToStudy,1);
decodeSave.thePaintOnlyOrthPaintRMSE = zeros(uniqueNUnitsToStudy,1);
decodeSave.thePaintOnlyOrthShadowRMSE = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    decodeInfo.nUnitsToUse = nUnitsToUseList(uu);
    decodeSave.thePaintOnlyUnits(uu) = nUnitsToUseList(uu);

    % Decode paint and shadow on 1:N PCA components
    [~,~,paintPCAPreds,shadowPCAPreds] = PaintShadowDecode(decodeSave, ...
        paintIntensities,paintOnlyPaintPCAResponses(:,1:decodeInfo.nUnitsToUse),shadowIntensities,paintOnlyShadowPCAResponses(:,1:decodeInfo.nUnitsToUse));
    decodeSave.thePaintOnlyPaintRMSE(uu) = sqrt(mean((theData.paintIntensities(:)-paintPCAPreds(:)).^2));
    decodeSave.thePaintOnlyShadowRMSE(uu) = sqrt(mean((theData.shadowIntensities(:)-shadowPCAPreds(:)).^2));
end

% Fit exponentials to paint only decodings
a0 = nullRMSEPaint; b0 = 5; c0 = min(decodeSave.thePaintOnlyPaintRMSE);
ftype = fittype('(a-c)*exp(-(x)/(b)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[a0 2 0],'Upper',[a0 200 5]);
index = find(decodeSave.thePaintOnlyUnits <= decodeInfo.nFitMaxUnits);
decodeSave.paintOnlyPaintFit = fit(decodeSave.thePaintOnlyUnits(index),decodeSave.thePaintOnlyPaintRMSE(index),ftype,foptions);
decodeSave.paintOnlyPaintBestRMSE = c0;
decodeSave.paintOnlyPaintNullRMSE = nullRMSEPaint;
decodeSave.paintOnlyPaintFitScale = decodeSave.paintOnlyPaintFit.b;
decodeSave.paintOnlyPaintFitAsymp = decodeSave.paintOnlyPaintFit.c;

a0 = nullRMSEShadow; b0 = 5; c0 = min(decodeSave.thePaintOnlyShadowRMSE);
ftype = fittype('(a-c)*exp(-(x)/(b)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[a0 2 0],'Upper',[a0 200 5]);
index = find(decodeSave.thePaintOnlyUnits <= decodeInfo.nFitMaxUnits);
decodeSave.paintOnlyShadowFit = fit(decodeSave.thePaintOnlyUnits(index),decodeSave.thePaintOnlyShadowRMSE(index),ftype,foptions);
decodeSave.paintOnlyShadowBestRMSE = c0;
decodeSave.paintOnlyShadowNullRMSE = nullRMSEShadow;
decodeSave.paintOnlyShadowFitScale = decodeSave.paintOnlyShadowFit.b;
decodeSave.paintOnlyShadowFitAsymp = decodeSave.paintOnlyShadowFit.c;

%% Do PCA on shadow only, and decode both paint and shadow in the PCA basis
% and the orthogonal basis.
[~,~,shadowOnlyPCABasis,shadowOnlyMeanResponse] = PaintShadowPCA(decodeInfoPCA,meanShadowResponses,[]);
shadowOnlyPaintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,shadowOnlyPCABasis,shadowOnlyMeanResponse);
shadowOnlyShadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,shadowOnlyPCABasis,shadowOnlyMeanResponse);

uniqueNUnitsToStudy = size(shadowOnlyPCABasis,2);
nUnitsToUseList = 1:uniqueNUnitsToStudy;
decodeSave.theShadowOnlyUnits = zeros(uniqueNUnitsToStudy,1);
decodeSave.theShadowOnlyPaintRMSE = zeros(uniqueNUnitsToStudy,1);
decodeSave.theShadowOnlyShadowRMSE = zeros(uniqueNUnitsToStudy,1);
decodeSave.theShadowOnlyOrthPaintRMSE = zeros(uniqueNUnitsToStudy,1);
decodeSave.theShadowOnlyOrthShadowRMSE = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    decodeInfo.nUnitsToUse = nUnitsToUseList(uu);
    decodeSave.theShadowOnlyUnits(uu) = nUnitsToUseList(uu);

    % Decode paint and shadow on 1:N PCA components
    [~,~,paintPCAPreds,shadowPCAPreds] = PaintShadowDecode(decodeSave, ...
        paintIntensities,shadowOnlyPaintPCAResponses(:,1:decodeInfo.nUnitsToUse),shadowIntensities,shadowOnlyShadowPCAResponses(:,1:decodeInfo.nUnitsToUse));
    decodeSave.theShadowOnlyPaintRMSE(uu) = sqrt(mean((theData.paintIntensities(:)-paintPCAPreds(:)).^2));
    decodeSave.theShadowOnlyShadowRMSE(uu) = sqrt(mean((theData.shadowIntensities(:)-shadowPCAPreds(:)).^2));
end

% Fit exponentials to shadow only decodings
a0 = nullRMSEPaint; b0 = 5; c0 = min(decodeSave.theShadowOnlyPaintRMSE);
ftype = fittype('(a-c)*exp(-(x)/(b)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[a0 2 0],'Upper',[a0 200 5]);
index = find(decodeSave.theShadowOnlyUnits <= decodeInfo.nFitMaxUnits);
decodeSave.shadowOnlyPaintFit = fit(decodeSave.theShadowOnlyUnits(index),decodeSave.theShadowOnlyPaintRMSE(index),ftype,foptions);
decodeSave.shadowOnlyPaintBestRMSE = c0;
decodeSave.shadowOnlyPaintNullRMSE = nullRMSEPaint;
decodeSave.shadowOnlyPaintFitScale = decodeSave.shadowOnlyPaintFit.b;
decodeSave.shadowOnlyPaintFitAsymp = decodeSave.shadowOnlyPaintFit.c;

a0 = nullRMSEShadow; b0 = 5; c0 = min(decodeSave.theShadowOnlyShadowRMSE);
ftype = fittype('(a-c)*exp(-(x)/(b)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[a0 2 0],'Upper',[a0 200 5]);
index = find(decodeSave.theShadowOnlyUnits <= decodeInfo.nFitMaxUnits);
decodeSave.shadowOnlyShadowFit = fit(decodeSave.theShadowOnlyUnits(index),decodeSave.theShadowOnlyShadowRMSE(index),ftype,foptions);
decodeSave.shadowOnlyShadowBestRMSE = c0;
decodeSave.shadowOnlyShadowNullRMSE = nullRMSEShadow;
decodeSave.shadowOnlyShadowFitScale = decodeSave.shadowOnlyShadowFit.b;
decodeSave.shadowOnlyShadowFitAsymp = decodeSave.shadowOnlyShadowFit.c;

%% PLOT: RMSE versus number of PCA components used to decode
RMSEVersusNPCAfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
smoothX = (0:decodeInfo.nUnits)';
plot(smoothX,decodeSave.fit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
plot(decodeSave.theUnits,decodeSave.theRMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
plot(decodeSave.fitScale,decodeSave.fit(decodeSave.fitScale),'go','MarkerFaceColor','g','MarkerSize',8);
plot(smoothX,nullRMSE*ones(size(smoothX)),':','LineWidth',2,'Color',[0.5 0.5 0.5]);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,max(decodeSave.theUnits)]);
ylim([0,0.5]);
axis square
figName = [decodeInfo.figNameRoot '_extRMSEVersusNPCA'];
drawnow;
FigureSave(figName,RMSEVersusNPCAfig,decodeInfo.figType);

%% PLOT: RMSE versus number of PCA components used to decode for the
% paintOnly and shadowOnly PCA cases.
RMSEVersusPaintOnlyNPCAfig = figure; clf;
set(gcf,'Position',[100 100 1200 700]);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(1,2,1); hold on;
plot(decodeSave.thePaintOnlyUnits,decodeSave.thePaintOnlyPaintRMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
plot(decodeSave.theShadowOnlyUnits,decodeSave.theShadowOnlyPaintRMSE,'ko','MarkerFaceColor','k','MarkerSize',4);
smoothX = (0:length(decodeSave.thePaintOnlyUnits))';
plot(smoothX,decodeSave.paintOnlyPaintFit(smoothX),'r','LineWidth',decodeInfo.lineWidth-1);
plot(decodeSave.paintOnlyPaintFitScale,decodeSave.paintOnlyPaintFit(decodeSave.paintOnlyPaintFitScale),'ro','MarkerFaceColor','r','MarkerSize',8);
smoothX = (0:length(decodeSave.theShadowOnlyUnits))';
plot(smoothX,decodeSave.shadowOnlyPaintFit(smoothX),'k','LineWidth',decodeInfo.lineWidth-1);
plot(decodeSave.shadowOnlyPaintFitScale,decodeSave.shadowOnlyPaintFit(decodeSave.shadowOnlyPaintFitScale),'ko','MarkerFaceColor','k','MarkerSize',8);
plot(smoothX,nullRMSEPaint*ones(size(smoothX)),':','LineWidth',2,'Color',[0.5 0.5 0.5]);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Paint RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,max([decodeSave.thePaintOnlyUnits ; decodeSave.theShadowOnlyUnits])]);
ylim([0,0.5]);
axis square
legend({'Paint Only PCA','Shadow Only PCA'});

subplot(1,2,2); hold on;
plot(decodeSave.thePaintOnlyUnits,decodeSave.thePaintOnlyShadowRMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
plot(decodeSave.theShadowOnlyUnits,decodeSave.theShadowOnlyShadowRMSE,'ko','MarkerFaceColor','k','MarkerSize',4);
smoothX = (0:length(decodeSave.thePaintOnlyUnits))';
plot(smoothX,decodeSave.paintOnlyShadowFit(smoothX),'r','LineWidth',decodeInfo.lineWidth-1);
plot(decodeSave.paintOnlyShadowFitScale,decodeSave.paintOnlyShadowFit(decodeSave.paintOnlyShadowFitScale),'ro','MarkerFaceColor','r','MarkerSize',8);
smoothX = (0:length(decodeSave.theShadowOnlyUnits))';
plot(smoothX,decodeSave.shadowOnlyShadowFit(smoothX),'k','LineWidth',decodeInfo.lineWidth-1);
plot(decodeSave.shadowOnlyShadowFitScale,decodeSave.shadowOnlyShadowFit(decodeSave.shadowOnlyShadowFitScale),'ko','MarkerFaceColor','k','MarkerSize',8)
plot(smoothX,nullRMSEShadow*ones(size(smoothX)),':','LineWidth',2,'Color',[0.5 0.5 0.5]);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Shadow RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,max([decodeSave.thePaintOnlyUnits ; decodeSave.theShadowOnlyUnits])]);
ylim([0,0.5]);
axis square
legend({'Paint Only PCA','Shadow Only PCA'});
figName = [decodeInfo.figNameRoot '_extRMSEVersusOneOnlyNPCA'];
drawnow;
FigureSave(figName,RMSEVersusPaintOnlyNPCAfig,decodeInfo.figType);

%% PLOT: RMSE for paint and shadow, compared with paintOnly and shadowOnly PCA
RMSEPaintOnlyShadowOnlyScatterFig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h = plot(decodeSave.thePaintOnlyPaintRMSE,decodeSave.theShadowOnlyPaintRMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(decodeSave.thePaintOnlyShadowRMSE,decodeSave.theShadowOnlyShadowRMSE,'ko','MarkerFaceColor','k','MarkerSize',4);
xlabel('Paint Only PCA RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Shadow Only PCA RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
legend({'Paint Trials','Shadow Trials'},'Location','NorthWest');
xlim([0,0.5]);
ylim([0,0.5]);
plot([0 0.5],[0 0.5],'k:','LineWidth',1);
axis square
figName = [decodeInfo.figNameRoot '_extRMSEPaintOnlyShadowOnlyScatter'];
drawnow;
FigureSave(figName,RMSEPaintOnlyShadowOnlyScatterFig,decodeInfo.figType);

%% PLOT: paint/shadow mean responses on PCA 1 and 2.
%
% PCA from both paint and shadow mean responses
clear decodeInfoPCA
decodeInfoPCA.pcaType = 'ml';
decodeSave.meanPaintPCAResponses = meanPaintPCAResponses;
decodeSave.meanShadowPCAResponses = meanShadowPCAResponses;

paintShadowOnPCAFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
theGrays = linspace(.4,0.9,length(decodeInfo.uniqueIntensities));
for dc = 1:length(decodeInfo.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(decodeSave.meanPaintPCAResponses(dc,1),decodeSave.meanPaintPCAResponses(dc,2),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(decodeSave.meanShadowPCAResponses(dc,1),decodeSave.meanShadowPCAResponses(dc,2),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end

% Connect by lines to match what Marlene does
plot(decodeSave.meanPaintPCAResponses(:,1),decodeSave.meanPaintPCAResponses(:,2),'-','Color',[0 0.5 0])
plot(decodeSave.meanShadowPCAResponses(:,1),decodeSave.meanShadowPCAResponses(:,2),'-','Color',[0.5 0.5 0.5]);
    
xlabel('Both PCA Component 1 Wgt','FontSize',decodeInfo.labelFontSize);
ylabel('Both PCA Component 2 Wgt','FontSize',decodeInfo.labelFontSize);
decodeInfo.titleStr = decodeInfo.titleStr;
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfo.legendFontSize,'Location','SouthWest');
drawnow;
figName = [decodeInfo.figNameRoot '_extRMSEVersusNPCAPaintShadowMeanOnPCABoth1_2'];
FigureSave(figName,paintShadowOnPCAFig,decodeInfo.figType);

%% PLOT: Version of above but use PCA from mean paint responses
clear decodeInfoPCA
decodeInfoPCA.pcaType = 'ml';
decodeSave.meanPaintOnlyPaintPCAResponses = meanPaintOnlyPaintPCAResponses;
decodeSave.meanPaintOnlyShadowPCAResponses = meanPaintOnlyShadowPCAResponses;

paintShadowOnPCAFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
theGrays = linspace(.4,0.9,length(decodeInfo.uniqueIntensities));
for dc = 1:length(decodeInfo.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(decodeSave.meanPaintOnlyPaintPCAResponses(dc,1),decodeSave.meanPaintOnlyPaintPCAResponses(dc,2),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(decodeSave.meanPaintOnlyShadowPCAResponses(dc,1),decodeSave.meanPaintOnlyShadowPCAResponses(dc,2),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end

% Connect by lines to match what Marlene does
plot(decodeSave.meanPaintOnlyPaintPCAResponses(:,1),decodeSave.meanPaintOnlyPaintPCAResponses(:,2),'-','Color',[0 0.5 0])
plot(decodeSave.meanPaintOnlyShadowPCAResponses(:,1),decodeSave.meanPaintOnlyShadowPCAResponses(:,2),'-','Color',[0.5 0.5 0.5]);
    
xlabel('Paint Only PCA Component 1 Wgt','FontSize',decodeInfo.labelFontSize);
ylabel('Paint Only PCA Component 2 Wgt','FontSize',decodeInfo.labelFontSize);
decodeInfo.titleStr = decodeInfo.titleStr;
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfo.legendFontSize,'Location','SouthWest');
drawnow;
figName = [decodeInfo.figNameRoot '_extRMSEVersusNPCAPaintShadowMeanOnPCAPaintOnly1_2'];
FigureSave(figName,paintShadowOnPCAFig,decodeInfo.figType);

%% Store the data for return
decodeInfo.RMSEVersusNPCA = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extRMSEVersusNPCA'),'decodeSave','-v7.3');