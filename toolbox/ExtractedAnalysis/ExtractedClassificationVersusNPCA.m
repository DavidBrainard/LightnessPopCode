function ExtractedClassificationVersusNPCA(doIt,decodeInfo,theData)
% ExtractedClassificationVersusNPCA(doIt,decodeInfo,theData)
%
% Study classification performance as a function of number of PCA dimensions
%
% 3/29/16  dhb  Pulled this out into its own function

%% Are we doing it?
%
% Rename buggy filename if it exists
if (exist(fullfile(decodeInfo.writeDataDir,'extClassificationVersusNPCA .mat'),'file'))
    unix(['mv ' fullfile(decodeInfo.writeDataDir,'extClassificationVersusNPCA\ .mat') ' ' fullfile(decodeInfo.writeDataDir,'extClassificationVersusNPCA.mat')]);
end
switch (doIt)
    case 'always'
    case 'never'
        return;
    case 'ifmissing'
        if (exist(fullfile(decodeInfo.writeDataDir,'extClassificationVersusNPCA.mat'),'file'))
            return;
        end
end

%% Get info about what to do
nUnitsToUseList = unique(round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy)));
uniqueNUnitsToStudy = length(nUnitsToUseList);

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
clear decodeInfoPCA
decodeInfoPCA.pcaType = 'ml';
decodeInfoPCA.pcaKeep = decodeInfo.nUnits;
meanDataForPCA = mean(dataForPCA,1);
[paintPCAResponses,shadowPCAResponses] = PaintShadowPCA(decodeInfoPCA,paintResponses,shadowResponses);

%% Get classification performance as a function of number of PCA components
decodeSave.theUnits = zeros(decodeInfo.nUnits,1);
decodeSave.thePerformance = zeros(decodeInfo.nUnits,1);
for uu = 1:uniqueNUnitsToStudy
    nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        paintIntensities,paintPCAResponses(:,1:nUnitsToUse),shadowIntensities,shadowPCAResponses(:,1:nUnitsToUse));
    
    paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
    shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
    decodeSave.thePerformance(uu) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
    decodeSave.theUnits(uu) = nUnitsToUse;
end

% Fit an exponential to classification versus number of PCA components
a0 = max(decodeSave.thePerformance); b0 = 5; c0 = min(decodeSave.thePerformance);
ftype = fittype('a-(a-c)*exp(-(x-1)/(b-1)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[0 2 0],'Upper',[5 200 5]);
index = find(decodeSave.theUnits <= decodeInfo.nFitMaxUnits);
decodeSave.fit = fit(decodeSave.theUnits(index),decodeSave.thePerformance(index),ftype,foptions);
decodeSave.fitScale = decodeSave.fit.b;
decodeSave.fitAsymp = decodeSave.fit.c;

% PLOT: Classification performance versus number of PCA components used to decode
performanceVersusNPCAfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeSave.fit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
h = plot(decodeSave.theUnits,decodeSave.thePerformance,'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(decodeSave.fitScale,decodeSave.fit(decodeSave.fitScale),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Paint/Shadow Classification Performance','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,1.1]);
axis square
figName = [decodeInfo.figNameRoot '_extClassificationVersusNPCA'];
drawnow;
FigureSave(figName,performanceVersusNPCAfig,decodeInfo.figType);

%% Store the data for return
decodeInfo.classificationVersusNPCA = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extClassificationVersusNPCA '),'decodeSave','-v7.3');