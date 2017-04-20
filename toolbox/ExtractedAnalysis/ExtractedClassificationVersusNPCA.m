function ExtractedClassificationVersusNPCA(doIt,decodeInfo,theData)
% ExtractedClassificationVersusNPCA(doIt,decodeInfo,theData)
%
% Study classification performance as a function of number of PCA dimensions
%
% 3/29/16  dhb  Pulled this out into its own function

%% Are we doing it?
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
nUnitsToUseList = decodeInfo.classifyPCADimsToTry;
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
paintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,pcaBasis,meanResponse);
shadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,pcaBasis,meanResponse);

%% Get classification performance as a function of number of PCA components
decodeSave.theUnits = zeros(uniqueNUnitsToStudy,1);
decodeSave.thePerformance = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        paintIntensities,paintPCAResponses(:,1:nUnitsToUse),shadowIntensities,shadowPCAResponses(:,1:nUnitsToUse));
    
    paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
    shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
    decodeSave.thePerformance(uu) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
    decodeSave.theUnits(uu) = nUnitsToUse;
    fprintf('\tClassification performance for %d PCA components: %d%%\n',decodeSave.theUnits(uu),round(100*decodeSave.thePerformance(uu)));
end

%% Fit an exponential if we are running with some reasonable number of components
if (uniqueNUnitsToStudy > 4)
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
end

%% Do the classification on PCA from paint responses only
[~,~,paintOnlyPCABasis,paintOnlyMeanResponse] = PaintShadowPCA(decodeInfoPCA,meanPaintResponses,[]);
paintOnlyPaintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,paintOnlyPCABasis,paintOnlyMeanResponse);
paintOnlyShadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,paintOnlyPCABasis,paintOnlyMeanResponse);

% Get classification performance as a function of number of PCA components
decodeSave.paintOnlyThePerformance(uu) = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintOnlyPaintClassifyPredsLOO,paintOnlyShadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        paintIntensities,paintOnlyPaintPCAResponses(:,1:nUnitsToUse),shadowIntensities,paintOnlyShadowPCAResponses(:,1:nUnitsToUse));
    
    paintOnlyPaintClassifyLOONCorrect = length(find(paintOnlyPaintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
    paintOnlyShadowClassifyLOONCorrect = length(find(paintOnlyShadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
    decodeSave.paintOnlyThePerformance(uu) = (paintOnlyPaintClassifyLOONCorrect+paintOnlyShadowClassifyLOONCorrect)/(length(paintOnlyPaintClassifyPredsLOO)+length(paintOnlyShadowClassifyPredsLOO));
    fprintf('\tClassification performance for %d paint only PCA components: %d%%\n',decodeSave.theUnits(uu),round(100*decodeSave.paintOnlyThePerformance(uu)));
end

%% Do the classification on PCA from shadow responses only
[~,~,shadowOnlyPCABasis,shadowOnlyMeanResponse] = PaintShadowPCA(decodeInfoPCA,meanShadowResponses,[]);
shadowOnlyPaintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,shadowOnlyPCABasis,shadowOnlyMeanResponse);
shadowOnlyShadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,shadowOnlyPCABasis,shadowOnlyMeanResponse);

%% Get classification performance as a function of number of PCA components
decodeSave.shadowOnlyThePerformance = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    nUnitsToUse = nUnitsToUseList(uu);
    [~,~,shadowOnlyPaintClassifyPredsLOO,shadowOnlyShadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        paintIntensities,shadowOnlyPaintPCAResponses(:,1:nUnitsToUse),shadowIntensities,shadowOnlyShadowPCAResponses(:,1:nUnitsToUse));
    
    shadowOnlyPaintClassifyLOONCorrect = length(find(shadowOnlyPaintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
    shadowOnlyShadowClassifyLOONCorrect = length(find(shadowOnlyShadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
    decodeSave.shadowOnlyThePerformance(uu) = (shadowOnlyPaintClassifyLOONCorrect+shadowOnlyShadowClassifyLOONCorrect)/(length(shadowOnlyPaintClassifyPredsLOO)+length(shadowOnlyShadowClassifyPredsLOO));
    fprintf('\tClassification performance for %d shadow only PCA components: %d%%\n',decodeSave.theUnits(uu),round(100*decodeSave.shadowOnlyThePerformance(uu)));
end

%% Store the data for return
decodeInfo.classificationVersusNPCA = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extClassificationVersusNPCA'),'decodeSave','-v7.3');