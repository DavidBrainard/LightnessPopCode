function decodeInfo = ExtractedRMSEVersusNPCA(decodeInfo,theData)
% decodeInfo = ExtractedRMSEVersusNPCA(decodeInfo,theData)
%
% Study decoding performance as a function of number of PCA dimensions
%
% 3/29/16  dhb  Pulled it out.
% 4/5/16   dhb  Cleaned up to use new conventions.  Not debugged.

%% Get info about what to do
nUnitsToUseList = unique([1 2 round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy))]);
uniqueNUnitsToStudy = length(nUnitsToUseList);

%% Set up needed parameters
clear decodeInfoRMSEVersusNPCA
decodeInfoRMSEVersusNPCA.verbose = decodeInfo.verbose;
decodeInfoRMSEVersusNPCA.nUnits = decodeInfo.nUnits;
decodeInfoRMSEVersusNPCA.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoRMSEVersusNPCA.nNUnitsToStudy = decodeInfo.nNUnitsToStudy;
decodeInfoRMSEVersusNPCA.nRepeatsPerNUnits = decodeInfo.nRepeatsPerNUnits;
decodeInfoRMSEVersusNPCA.decodeJoint = 'both';
decodeInfoRMSEVersusNPCA.type = 'aff';
decodeInfoRMSEVersusNPCA.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoRMSEVersusNPCA.trialShuffleType = 'none';
decodeInfoRMSEVersusNPCA.paintShadowShuffleType = 'none';

%% Shuffle if desired
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% Get PCA
dataForPCA = [paintResponses ; shadowResponses];
meanDataForPCA = mean(dataForPCA,1);
[pcaBasis,paintShadowPCAResponsesTrans] = pca(dataForPCA,'NumComponents',decodeInfo.nUnits);
paintPCAResponses = (pcaBasis\(paintResponses-meanDataForPCA(ones(size(paintResponses,1),1),:))')';
shadowPCAResponses = (pcaBasis\(shadowResponses-meanDataForPCA(ones(size(shadowResponses,1),1),:))')';

% Get RMSE as a function of number of PCA components
decodeInfoRMSEVersusNPCA.theUnits = zeros(uniqueNUnitsToStudy,1);
decodeInfoRMSEVersusNPCA.theRMSE = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    decodeInfo.nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintPCAPreds,shadowPCAPreds] = PaintShadowDecode(decodeInfoRMSEVersusNPCA, ...
        paintIntensities,paintPCAResponses(:,1:decodeInfo.nUnitsToUse),shadowIntensities,shadowPCAResponses(:,1:decodeInfo.nUnitsToUse));
    decodeInfoRMSEVersusNPCA.theRMSE(uu) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPCAPreds(:) ; shadowPCAPreds(:)]).^2));
    decodeInfoRMSEVersusNPCA.theUnits(uu) = decodeInfo.nUnitsToUse;
end

% Fit an exponential
a0 = max(decodeInfoRMSEVersusNPCA.theRMSE); b0 = 5; c0 = min(decodeInfoRMSEVersusNPCA.theRMSE);
index = find(decodeInfoRMSEVersusNPCA.theUnits <= decodeInfo.nFitMaxUnits);
decodeInfoRMSEVersusNPCA.fit = fit(decodeInfoRMSEVersusNPCA.theUnits(index),decodeInfoRMSEVersusNPCA.theRMSE(index),'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfoRMSEVersusNPCA.rmse = c0;
decodeInfoRMSEVersusNPCA.fitScale = decodeInfoRMSEVersusNPCA.fit.b;
decodeInfoRMSEVersusNPCA.fitAsymp = decodeInfoRMSEVersusNPCA.fit.c;

% PLOT: RMSE versus number of PCA components used to decode
RMSEVersusNPCAfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeInfoRMSEVersusNPCA.fit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
h = plot(decodeInfoRMSEVersusNPCA.theUnits,decodeInfoRMSEVersusNPCA.theRMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(decodeInfoRMSEVersusNPCA.fitScale,decodeInfoRMSEVersusNPCA.fit(decodeInfoRMSEVersusNPCA.fitScale),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,0.5]);
axis square
figName = [decodeInfo.figNameRoot '_extRmseVersusNPCA'];
drawnow;
FigureSave(figName,RMSEVersusNPCAfig,decodeInfo.figType);

% PLOT: paint/shadow mean responses on PCA 1 and 2, where we compute
% the PCA on the mean responses.
%
% I am not sure whether this is a useful figure, and if it is whether
% the pca should be computed on the mean responses or the raw responses.
for dc = 1:length(decodeInfo.uniqueIntensities)
    theIntensity = decodeInfo.uniqueIntensities(dc);
    paintIndex = find(theData.paintIntensities == theIntensity);
    shadowIndex = find(theData.shadowIntensities == theIntensity);
    meanPaintResponses(dc,:) = mean(theData.paintResponses(paintIndex,:),1);
    meanShadowResponses(dc,:) = mean(theData.shadowResponses(shadowIndex,:),1);
end
dataForPCA = [meanPaintResponses ; meanShadowResponses];
meanDataForPCA = mean(dataForPCA,1);
pcaBasis = pca(dataForPCA,'NumComponents',decodeInfo.nUnits);
decodeInfoRMSEVersusNPCA.meanPaintPCAResponses = (pcaBasis\(meanPaintResponses-meanDataForPCA(ones(size(meanPaintResponses,1),1),:))')';
decodeInfoRMSEVersusNPCA.meanShadowPCAResponses = (pcaBasis\(meanShadowResponses-meanDataForPCA(ones(size(meanShadowResponses,1),1),:))')';

paintShadowOnPCAFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
theGrays = linspace(.4,1,length(decodeInfo.uniqueIntensities));
for dc = 1:length(decodeInfo.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(mean(decodeInfoRMSEVersusNPCA.meanPaintPCAResponses(dc,1)),mean(decodeInfoRMSEVersusNPCA.meanPaintPCAResponses(dc,2)),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mean(decodeInfoRMSEVersusNPCA.meanShadowPCAResponses(dc,1)),mean(decodeInfoRMSEVersusNPCA.meanShadowPCAResponses(dc,2)),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end
xlabel('PCA Component 1 Wgt','FontSize',decodeInfo.labelFontSize);
ylabel('PCA Component 2 Wgt','FontSize',decodeInfo.labelFontSize);
decodeInfo.titleStr = decodeInfo.titleStr;
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfo.legendFontSize,'Location','SouthWest');
drawnow;
figName = [decodeInfo.figNameRoot '_extPaintShadowOnMeanPCA'];
FigureSave(figName,paintShadowOnPCAFig,decodeInfo.figType);

%% Store the data for return
decodeInfo.RMSEVersusNPCA = decodeInfoRMSEVersusNPCA;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extRMSEVersusNPCA '),'decodeInfoRMSEVersusNPCA','-v7.3');