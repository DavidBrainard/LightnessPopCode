function decodeInfo = ExtractedRMSEVersusNPCA(decodeInfo,theData)
% decodeInfo = ExtractedRMSEVersusNPCA(decodeInfo,theData)
%
% Study decoding performance as a function of number of PCA dimensions
%
%
% 3/29/16  dhb  Pulled it out.

%% Get info about what to do
nUnitsToUseList = unique(round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy)));

% Get PCA
dataForPCA = [theData.paintResponses ; theData.shadowResponses];
meanDataForPCA = mean(dataForPCA,1);
[pcaBasis,paintShadowPCAResponsesTrans] = pca(dataForPCA,'NumComponents',decodeInfo.nUnits);
paintPCAResponses = (pcaBasis\(theData.paintResponses-meanDataForPCA(ones(size(theData.paintResponses,1),1),:))')';
shadowPCAResponses = (pcaBasis\(theData.shadowResponses-meanDataForPCA(ones(size(theData.shadowResponses,1),1),:))')';

% Get RMSE as a function of number of PCA components
thePCAUnits = zeros(decodeInfo.nNUnitsToStudy,1);
thePCALOORMSE = zeros(decodeInfo.nNUnitsToStudy,1);
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = decodeInfo.ndecodeLOOType;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
for uu = 1:decodeInfo.nNUnitsToStudy
    decodeInfo.nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintPCAPredsLOO,shadowPCAPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
        theData.paintIntensities,paintPCAResponses(:,1:decodeInfo.nUnitsToUse),theData.shadowIntensities,shadowPCAResponses(:,1:decodeInfo.nUnitsToUse));
    thePCALOORMSE(uu) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPCAPredsLOO(:) ; shadowPCAPredsLOO(:)]).^2));
    thePCAUnits(uu) = decodeInfo.nUnitsToUse;
end

% Fit an exponential
a0 = max(thePCALOORMSE); b0 = 5; c0 = min(thePCALOORMSE);
decodeInfo.rmseVersusNPCAFit = fit(thePCAUnits,thePCALOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.rmseVersusNPCAFitScale = decodeInfo.rmseVersusNPCAFit.b;
decodeInfo.rmseVersusNPCAFitAsymp = decodeInfo.rmseVersusNPCAFit.c;

% PLOT: RMSE versus number of PCA components used to decode
rmseVersusNPCAfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeInfo.rmseVersusNPCAFit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
h = plot(thePCAUnits,thePCALOORMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(decodeInfo.rmseVersusNPCAFitScale,decodeInfo.rmseVersusNPCAFit(decodeInfo.rmseVersusNPCAFitScale),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,0.5]);
axis square
figName = [decodeInfo.figNameRoot '_extRmseVersusNPCA'];
drawnow;
FigureSave(figName,rmseVersusNPCAfig,decodeInfo.figType);

% PLOT: paint/shadow mean responses on PCA 1 and 2, where we compute
% the PCA on the mean responses
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
decodeInfo.meanPaintPCAResponses = (pcaBasis\(meanPaintResponses-meanDataForPCA(ones(size(meanPaintResponses,1),1),:))')';
decodeInfo.meanShadowPCAResponses = (pcaBasis\(meanShadowResponses-meanDataForPCA(ones(size(meanShadowResponses,1),1),:))')';

paintShadowOnPCAFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
theGrays = linspace(.4,1,length(decodeInfo.uniqueIntensities));
for dc = 1:length(decodeInfo.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(mean(decodeInfo.meanPaintPCAResponses(dc,1)),mean(decodeInfo.meanPaintPCAResponses(dc,2)),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mean(decodeInfo.meanShadowPCAResponses(dc,1)),mean(decodeInfo.meanShadowPCAResponses(dc,2)),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end
xlabel('PCA Component 1 Wgt','FontSize',decodeInfo.labelFontSize);
ylabel('PCA Component 2 Wgt','FontSize',decodeInfo.labelFontSize);
decodeInfo.titleStr = decodeInfo.titleStr;
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfo.legendFontSize,'Location','SouthWest');
drawnow;
figName = [decodeInfo.figNameRoot '_extPaintShadowOnPCA'];
FigureSave(figName,paintShadowOnPCAFig,decodeInfo.figType);