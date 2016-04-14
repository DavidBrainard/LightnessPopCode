function decodeInfo = ExtractedClassificationVersusNPCA(decodeInfo,theData)
% decodeInfo = ExtractedClassificationVersusNPCA(decodeInfo,theData)
%
% Study classification performance as a function of number of PCA dimensions
%
% 3/29/16  dhb  Pulled this out into its own function

%% Get info about what to do
nUnitsToUseList = unique(round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy)));

%% Set up input structure for classification
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifyLOOType = decodeInfo.classifyLOOType;
decodeInfoTemp.classifyNFolds = decodeInfo.classifyNFolds;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';

%% Shuffle if desired
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% Get PCA
dataForPCA = [paintResponses ; shadowResponses];
meanDataForPCA = mean(dataForPCA,1);
[pcaBasis,paintShadowPCAResponsesTrans] = pca(dataForPCA,'NumComponents',decodeInfo.nUnits);
paintPCAResponses = (pcaBasis\(paintResponses-meanDataForPCA(ones(size(paintResponses,1),1),:))')';
shadowPCAResponses = (pcaBasis\(shadowResponses-meanDataForPCA(ones(size(shadowResponses,1),1),:))')';

%% Get classification performance as a function of number of PCA components
decodeInfoPerformanceVersusNPCA.theUnits = zeros(decodeInfo.nUnits,1);
decodeInfoPerformanceVersusNPCA.thePerformance = zeros(decodeInfo.nUnits,1);
for uu = 1:decodeInfo.nNUnitsToStudy
    nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        paintIntensities,paintPCAResponses(:,1:nUnitsToUse),shadowIntensities,shadowPCAResponses(:,1:nUnitsToUse));
    
    paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
    shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
    decodeInfoPerformanceVersusNPCA.thePerformance(uu) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
    decodeInfoPerformanceVersusNPCA.theUnits(uu) = nUnitsToUse;
end

% Fit an exponential to classification versus number of PCA components
a0 = max(decodeInfoPerformanceVersusNPCA.thePerformance); b0 = 5; c0 = min(decodeInfoPerformanceVersusNPCA.thePerformance);
decodeInfoPerformanceVersusNPCA.fit = fit(decodeInfoPerformanceVersusNPCA.theUnits,decodeInfoPerformanceVersusNPCA.thePerformance,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfoPerformanceVersusNPCA.fitScale = decodeInfoPerformanceVersusNPCA.fit.b;
decodeInfoPerformanceVersusNPCA.fitAsymp = decodeInfoPerformanceVersusNPCA.fit.c;

% PLOT: Classification performance versus number of PCA components used to decode
performanceVersusNPCAfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeInfoPerformanceVersusNPCA.fit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
h = plot(decodeInfoPerformanceVersusNPCA.theUnits,decodeInfoPerformanceVersusNPCA.thePerformance,'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(decodeInfoPerformanceVersusNPCA.fitScale,decodeInfoPerformanceVersusNPCA.fit(decodeInfoPerformanceVersusNPCA.fitScale),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Paint/Shadow Classification Performance','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,1.1]);
axis square
figName = [decodeInfo.figNameRoot '_extClassPerformanceVersusNPCA'];
drawnow;
FigureSave(figName,performanceVersusNPCAfig,decodeInfo.figType);

%% Store the data for return
decodeInfo.performanceVersusNPCA = decodeInfoPerformanceVersusNPCA;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extPerformanceVersusNPCA '),'decodeInfoPerformanceVersusNPCA','-v7.3');