function decodeInfo = ExtractedClassificationVersusNUnits(decodeInfo,theData)
% decodeInfo = ExtractedClassificationVersusNUnits(decodeInfo,theData)
%
% Study classification performance as a function of the number of units.
%
% 3/29/16  dhb  Pulled this out into its own function.

%% Get info about what to do
nUnitsToUseList = unique(round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy)));
uniqueNUnitsToStudy = length(nUnitsToUseList);

%% Set up input structure for classification
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.classifyReduce = '';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifydecodeLOOType = 'no';
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';

%% Set up space for some answers
theLOOPerformance = zeros(uniqueNUnitsToStudy,decodeInfo.nRepeatsPerNUnits);
theUnits = zeros(uniqueNUnitsToStudy,decodeInfo.nRepeatsPerNUnits);
maxLOOPerformanceUnits = zeros(uniqueNUnitsToStudy,1);
maxLOOPerformance = zeros(uniqueNUnitsToStudy,1);

%% Get classification performance for all choices of one unit
for jj = 1:decodeInfo.nUnits
    useUnits = jj;
    [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        theData.paintIntensities,theData.paintResponses(:,useUnits),theData.shadowIntensities,theData.shadowResponses(:,useUnits));
    switch (decodeInfo.classifydecodeLOOType)
        case 'no'
            decodeInfoTempOut.nFolds = decodeInfo.nFolds;
            paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
            shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
            oneLOOPerformance(jj) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
        case 'kfold'
            decodeInfoTempOut.nFolds = decodeInfo.nFolds;
            decodeInfoTempOut.classifyCVM = crossval(decodeInfoTempOut.classifyInfo,'Kfold',decodeInfo.nFolds);
            theKFoldLoss = kfoldLoss(decodeInfo.classifyCVM);
        otherwise
            error('Unknown classifydecodeLOOType')
    end
    whichOnePerformanceUnits(jj) = useUnits;
end
[decodeInfo.bestOneLOOPerformance,index] = max(oneLOOPerformance);
decodeInfo.bestOnePerformanceUnit = whichOnePerformanceUnits(index);

%% Get performance as a function of number of units
for uu = 1:length(nUnitsToUseList)
    nUnitsToUse = nUnitsToUseList(uu);
    fprintf('\tClassification for %d units\n',nUnitsToUse);
    for jj = 1:decodeInfo.nRepeatsPerNUnits
        shuffledUnits = Shuffle(1:decodeInfo.nUnits);
        useUnits = shuffledUnits(1:nUnitsToUse);
        
        [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoOutTemp] = PaintShadowClassify(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses(:,useUnits),theData.shadowIntensities,theData.shadowResponses(:,useUnits));
        
        paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
        shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
        theLOOPerformance(uu,jj) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
        theUnits(uu,jj) = nUnitsToUse;
    end
    maxLOOPerformanceUnits(uu) = nUnitsToUse;
    maxLOOPerformance(uu) = max(theLOOPerformance(uu,:));
end

% Fit an exponential through the lower envelope
a0 = max(maxLOOPerformance); b0 = 10; c0 = min(maxLOOPerformance);
decodeInfo.performance = c0;
decodeInfo.performanceVersusNUnitsFit = fit(maxLOOPerformanceUnits,maxLOOPerformance,'a-(a-c)*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.performanceVersusNUnitsFitScale = decodeInfo.performanceVersusNUnitsFit.b;
decodeInfo.performanceVersusNUnitsFitAsymp = decodeInfo.performanceVersusNUnitsFit.c;

%% PLOT: Performance versus number of units used to decode
performanceVersusNUnitsfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;

smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeInfo.performanceVersusNUnitsFit(smoothX),'k','LineWidth',decodeInfo.lineWidth);

h = plot(decodeInfo.performanceVersusNUnitsFitScale,decodeInfo.performanceVersusNUnitsFit(decodeInfo.performanceVersusNUnitsFitScale),'go','MarkerFaceColor','g','MarkerSize',8);
h = plot(1,decodeInfo.bestOneLOOPerformance,'go','MarkerFaceColor','g','MarkerSize',8);
h = plot(theUnits(:),theLOOPerformance(:),'ro','MarkerFaceColor','r','MarkerSize',4);

%h = legend({'Paint','Shadow'},'FontSize',decodeInfo.legendFontSize,'Location','NorthWest');
%lfactor = 0.5;
%lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
xlabel('Number of Units Used in Classification','FontSize',decodeInfo.labelFontSize);
ylabel('Paint/Shadow Classification Performance','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,1.1]);
axis square
figName = [decodeInfo.figNameRoot '_extClassPerformanceVersusNUnits'];
drawnow;
FigureSave(figName,performanceVersusNUnitsfig,decodeInfo.figType);