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
decodeInfoTemp.classifyReduce = '';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifyLOOType = decodeInfo.classifyLOOType;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';

% Get PCA
dataForPCA = [theData.paintResponses ; theData.shadowResponses];
meanDataForPCA = mean(dataForPCA,1);
[pcaBasis,paintShadowPCAResponsesTrans] = pca(dataForPCA,'NumComponents',decodeInfo.nUnits);
paintPCAResponses = (pcaBasis\(theData.paintResponses-meanDataForPCA(ones(size(theData.paintResponses,1),1),:))')';
shadowPCAResponses = (pcaBasis\(theData.shadowResponses-meanDataForPCA(ones(size(theData.shadowResponses,1),1),:))')';

%% Get classification performance as a function of number of PCA components
thePCAClassifyUnits = zeros(decodeInfo.nUnits,1);
thePCALOOPerformance = zeros(decodeInfo.nUnits,1);
for uu = 1:decodeInfo.nNUnitsToStudy
    nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        theData.paintIntensities,paintPCAResponses(:,1:nUnitsToUse),theData.shadowIntensities,shadowPCAResponses(:,1:nUnitsToUse));
    
    paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
    shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
    thePCALOOPerformance(uu) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
    thePCAClassifyUnits(uu) = nUnitsToUse;
end

% Fit an exponential to classification versus number of PCA components
a0 = max(thePCALOOPerformance); b0 = 5; c0 = min(thePCALOOPerformance);
decodeInfo.performanceVersusNPCAFit = fit(thePCAClassifyUnits,thePCALOOPerformance,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.performanceVersusNPCAFitScale = decodeInfo.performanceVersusNPCAFit.b;
decodeInfo.performanceVersusNPCAFitAsymp = decodeInfo.performanceVersusNPCAFit.c;

% PLOT: Classification performance versus number of PCA components used to decode
performanceVersusNPCAfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeInfo.performanceVersusNPCAFit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
h = plot(thePCAClassifyUnits,thePCALOOPerformance,'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(decodeInfo.performanceVersusNPCAFitScale,decodeInfo.performanceVersusNPCAFit(decodeInfo.performanceVersusNPCAFitScale),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Paint/Shadow Classification Performance','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,1.1]);
axis square
figName = [decodeInfo.figNameRoot '_extClassPerformanceVersusNPCA'];
drawnow;
FigureSave(figName,performanceVersusNPCAfig,decodeInfo.figType);