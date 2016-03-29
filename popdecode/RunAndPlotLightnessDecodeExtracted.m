function decodeInfoOut = RunAndPlotExtractedData(theDir,decodeInfoIn)
% decodeInfoOut = RunAndPlotExtractedData(theDir,decodeInfoIn)
%
% Work on data extracted by earlier big program.  Streamlines a bit for new
% things.
%
% 3/8/16  dhb  Wrote from earlier stuff.

%% Basic initialization
close all;

%% Plot info
%
% Condition and title strings
condStr = MakePopDecodeConditionStr(decodeInfoIn);
titleStr = strrep(condStr,'_',' ');
[~,filename] = fileparts(theDir);
titleRootStr = LiteralUnderscore({filename ; ...
    ['''Shadow'' condition ' num2str(decodeInfoIn.shadowCondition) ', ''paint'' condition ' num2str(decodeInfoIn.paintCondition)]; ...
    titleStr ...
    });

% Where to put extracted plots
extractedPlotBaseDir = '../../PennOutput/xPlots';
if (~exist(extractedPlotBaseDir,'dir'))
    mkdir(extractedPlotBaseDir);
end
extractedPlotRootDir = fullfile(extractedPlotBaseDir,condStr,'');
if (~exist(extractedPlotRootDir,'dir'))
    mkdir(extractedPlotRootDir);
end
extractedPlotDir = fullfile(extractedPlotRootDir,filename);
if (~exist(extractedPlotDir,'dir'))
    mkdir(extractedPlotDir);
end
filenameFig = [];
for ii = 1:length(filename)
    if (filename(ii) == '_')
        break;
    end
    filenameFig(ii) = filename(ii);
end
figNameRoot = fullfile(extractedPlotDir,[filenameFig '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);

%% Read in extracted data
curDir = pwd; cd(theDir);
theData = load('paintShadowData');
cd(curDir);

%% Check that there are enough trials left to analyze
decodeInfoOut = decodeInfoIn;
decodeInfoOut.OK = true;
nPaintTrials = length(theData.paintIntensities);
nShadowTrials = length(theData.shadowIntensities);
if (nPaintTrials < decodeInfoIn.minTrials)
    decodeInfoOut.OK = false;
end
if (nShadowTrials < decodeInfoIn.minTrials)
    decodeInfoOut.OK = false;
end

%% Only process if there are enough good data.
decodeInfoOut.filename = filename;
decodeInfoOut.subjectStr = filename(1:2);
if (decodeInfoOut.OK)
    fprintf('\tWorking on condition %s\n',theDir);
    
    % General stuff
    %
    % The switch gives us control for quicker debugging.
    decodeInfoOut.uniqueIntensities = unique([theData.paintIntensities ; theData.shadowIntensities]);
    nUnits = size(theData.paintResponses,2);
    runType = 'SLOWER';
    switch (runType)
        case 'FAST'
            nNUnitsToStudy = 3;
            nRepeatsPerNUnits = 2;
            nRandomVectorRepeats = 5;
            decodeLOOType = 'no';
            classifyLOOType = 'no';
        case 'SLOWER'
            nNUnitsToStudy = 25;
            nRepeatsPerNUnits = 50;
            nRandomVectorRepeats = 50;
            decodeLOOType = 'no';
            classifyLOOType = 'no';
        case 'REAL'
            nNUnitsToStudy = 25;
            nRepeatsPerNUnits = 100;
            nRandomVectorRepeats = 100;
            decodeLOOType = 'ot';
            classifyLOOType = 'foo';
    end
    
    % *******
    % Representational similarity
    % 
    % Get similarity matrix based on mean responses as a point of
    % departure.
    for dc = 1:length(decodeInfoOut.uniqueIntensities)
        theIntensity = decodeInfoOut.uniqueIntensities(dc);
        paintIndex = find(theData.paintIntensities == theIntensity);
        shadowIndex = find(theData.shadowIntensities == theIntensity);
        meanPaintResponses(dc,:) = mean(theData.paintResponses(paintIndex,:),1);
        meanShadowResponses(dc,:) = mean(theData.shadowResponses(shadowIndex,:),1);
    end
    dataMatrixForCorr = [meanPaintResponses ; meanShadowResponses];
    corrMatrix = corrcoef(dataMatrixForCorr');
    dissimMatrix = 1-corrMatrix; dissimMatrix = dissimMatrix+dissimMatrix';
    %dissimMatrix = log10(1./(corrMatrix + .05)); dissimMatrix = dissimMatrix - min(dissimMatrix(:)); dissimMatrix = dissimMatrix+dissimMatrix';
    mdsSoln = mdscale(dissimMatrix,2);
    
    % Build a p/s model of the dissimilarity matrix
    psDissimModel = zeros(size(dissimMatrix));
    psDissimModel((end/2)+1:end,1:end/2) = 1;
    psDissimModel(1:end/2,(end/2)+1:end) = 1;
    %figure;
    %imagesc(psDissimModel); colorbar;
    
    % Build a model of the intensity effect, with 
    % a shift parameter
    theShadowIntensityShift = 0;
    psIntensityDissimModel = BuildPSIntensityModel(decodeInfoOut.uniqueIntensities,theShadowIntensityShift);
    %figure;
    %imagesc(psIntensityModel); colorbar;
    
    % Fit the dissimilarity matrix, with various choices of the shadow fit
    % for the dissimilarity matrix
    theShadowIntensityShifts = linspace(-0.2,0.2,50)';
    taus = zeros(size(theShadowIntensityShifts));
    for ii = 1:length(theShadowIntensityShifts)
        theShadowIntensityShift = theShadowIntensityShifts(ii);
        psIntensityDissimModel = BuildPSIntensityModel(decodeInfoOut.uniqueIntensities,theShadowIntensityShift);
        modelMatrices{1} = psDissimModel;
        modelMatrices{2} = psIntensityDissimModel;
        [dissimMatrixFits{ii},taus(ii),params(:,ii)] = FitDissimMatrix(dissimMatrix,modelMatrices);
    end
    
    % Put a smooth curve through the tau versus shift curve.
    decodeInfoOut.tauVersusShiftFit = fit(theShadowIntensityShifts,taus,'poly2');
    tausFit = decodeInfoOut.tauVersusShiftFit(theShadowIntensityShifts);
    [decodeInfoOut.bestTausFit,index] = max(tausFit);
    bestFitIndex = index(1);
    decodeInfoOut.bestShadowIntensityShift = theShadowIntensityShifts(bestFitIndex);
    decodeInfoOut.dissimMatrixBestFit = dissimMatrixFits{bestFitIndex};
    mdsSolnFit = mdscale(decodeInfoOut.dissimMatrixBestFit,2);
    [~,mdsSolnPro] = procrustes(mdsSolnFit,mdsSoln);
    
    % PLOT: Quality of fit to dissimilarity matrix with shadow shift
    shadowShiftFitFig = figure; clf; hold on;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    plot(theShadowIntensityShifts,taus,'ro','MarkerFaceColor','r','MarkerSize',decodeInfoIn.markerSize-8);
    plot(theShadowIntensityShifts,tausFit,'r','LineWidth',decodeInfoIn.lineWidth);
    plot(decodeInfoOut.bestShadowIntensityShift,decodeInfoOut.bestTausFit,'go','MarkerFaceColor','g','MarkerSize',decodeInfoIn.markerSize-8);
    xlabel('Shadow Intensity Shift','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Tau of Fit','FontSize',decodeInfoIn.labelFontSize);
    decodeInfoOut.titleStr = titleRootStr;
    title(decodeInfoOut.titleStr,'FontSize',decodeInfoIn.titleFontSize);
    drawnow;
    figName = [figNameRoot '_extDissimFitShadowShift'];
    FigureSave(figName,shadowShiftFitFig,decodeInfoIn.figType);
    
    % PLOT: The dissimilarity matrix and its fit
    dissimMatrixFig = figure; clf;
    set(gcf,'Position',decodeInfoIn.position);
    subplot(1,2,1); 
    imagesc(dissimMatrix); colorbar; axis('square');
    title('Dissimilarity Matrix','FontSize',decodeInfoIn.titleFontSize);
    subplot(1,2,2); 
    imagesc(decodeInfoOut.dissimMatrixBestFit); colorbar; axis('square');
    title(sprintf('Fit: Shadow Shift = %0.2f',decodeInfoOut.bestShadowIntensityShift),'FontSize',decodeInfoIn.titleFontSize);
    drawnow;
    figName = [figNameRoot '_extDissimMatrix'];
    FigureSave(figName,dissimMatrixFig,decodeInfoIn.figType);
    
    % PLOT: The MDS solution
    paintShadowOnMDSFig = figure; clf; hold on;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    theGrays = linspace(.4,1,length(decodeInfoOut.uniqueIntensities));
    for dc = 1:length(decodeInfoOut.uniqueIntensities)
        theGreen = [0 theGrays(dc) 0];
        theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
        
        % Basic points first, so legend comes out right
        plot(mdsSolnPro(dc,1),mdsSolnPro(dc,2),...
            'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
        plot(mdsSolnPro(dc+length(decodeInfoOut.uniqueIntensities),1),mdsSolnPro(dc+length(decodeInfoOut.uniqueIntensities),2),...
            'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
        
        plot(mdsSolnFit(dc,1),mdsSolnFit(dc,2),...
            'x','MarkerSize',8,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
        plot(mdsSolnFit(dc+length(decodeInfoOut.uniqueIntensities),1),mdsSolnFit(dc+length(decodeInfoOut.uniqueIntensities),2),...
            'x','MarkerSize',8,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    end
    xlabel('MDS Solution 1 Wgt','FontSize',decodeInfoIn.labelFontSize);
    ylabel('MDS Solution 2 Wgt','FontSize',decodeInfoIn.labelFontSize);
    decodeInfoOut.titleStr = titleRootStr;
    title(decodeInfoOut.titleStr,'FontSize',decodeInfoIn.titleFontSize);
    h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfoIn.legendFontSize,'Location','SouthWest');
    drawnow;
    figName = [figNameRoot '_extPaintShadowOnMDS'];
    FigureSave(figName,paintShadowOnMDSFig,decodeInfoIn.figType);
    
    % *******
    % Analyze how paint and shadow RMSE/Prediction compare with each other when
    % decoder is built with both, built with paint only, built with shadow
    % only, is chosen randomly, is built to classify, etc.  This will
    % provide some measures of how intertwined paint and shadow are, as
    % well as how well aligned decode and classification directions are.
    % Doing it this way is based on our sense that almost all angles in
    % high dimensions are at near 90 degrees, so that looking at angle
    % doesn't provide good intuitions.
    %    
    % Build decode on both, don't leave one out
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = 'no';
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    decodeInfoOut.paintDecodeBothRMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoOut.shadowDecodeBothRMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));
    
    % Build decoder on both, use one trial LOO to evaluate.
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = 'ot';
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    decodeInfoOut.paintDecodeBothLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoOut.shadowDecodeBothLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));

    % Build decoder on paint, use one trial LOO to evaluate.
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'paint';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = 'ot';
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    decodeInfoOut.paintDecodePaintLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoOut.shadowDecodePaintLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));
    
    % Build decoder on shadow, use one trial LOO to evaluate.
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'shadow';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = 'ot';
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    decodeInfoOut.paintDecodeShadowLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoOut.shadowDecodeShadowLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));
    
    % Build decoder on classification direction (by finding that first)
    clear decodeInfoTemp
    decodeInfoTemp.classifyType = 'mvma';
    decodeInfoTemp.classifyReduce = '';
    decodeInfoTemp.MVM_ALG = 'SMO';
    decodeInfoTemp.MVM_COMPARECLASS = 0;
    decodeInfoTemp.classLooType = classifyLOOType;
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = 'ot';
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
        theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    classifyDirection = decodeInfoTempOut.classifyInfo.Beta;
    paintResponsesTemp = theData.paintResponses*classifyDirection;
    shadowResponsesTemp = theData.shadowResponses*classifyDirection;
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
        theData.paintIntensities,paintResponsesTemp,theData.shadowIntensities,shadowResponsesTemp);
    decodeInfoOut.paintDecodeClassifyLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoOut.shadowDecodeClassifyLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));

    % Project data onto a randomly chosen unit vector in the response
    % space, and decode based on that.
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = 'ot';
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    for rr = 1:nRandomVectorRepeats
        theDirection = rand(nUnits,1);
        theDirection = theDirection/norm(theDirection);
        paintResponsesTemp = theData.paintResponses*theDirection;
        shadowResponsesTemp = theData.shadowResponses*theDirection;
        [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,paintResponsesTemp,theData.shadowIntensities,shadowResponsesTemp);
        decodeInfoOut.paintDecodeRandomLOORMSE(rr) = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
        decodeInfoOut.shadowDecodeRandomLOORMSE(rr) = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));   
    end
    decodeInfoOut.paintDecodeRandomLOORMSEMean = mean(decodeInfoOut.paintDecodeRandomLOORMSE);
    decodeInfoOut.paintDecodeRandomLOORMSEStd = std(decodeInfoOut.paintDecodeRandomLOORMSE);
    decodeInfoOut.shadowDecodeRandomLOORMSEMean = mean(decodeInfoOut.paintDecodeRandomLOORMSE);
    decodeInfoOut.shadowDecodeRandomLOORMSEStd = std(decodeInfoOut.paintDecodeRandomLOORMSE);
    
    % PLOT: RMSE analyses
    rmseAnaysisFig = figure; clf;
    nHistobins = 10;
    [nPaint,xPaint] = hist(decodeInfoOut.paintDecodeRandomLOORMSE,nHistobins);
    [nShadow,xShadow] = hist(decodeInfoOut.shadowDecodeRandomLOORMSE,nHistobins);
    yMax = max([nPaint(:) ; nShadow(:)]);

    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    subplot(2,1,1); hold on;
    plot([decodeInfoOut.paintDecodeBothLOORMSE decodeInfoOut.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.paintDecodePaintLOORMSE decodeInfoOut.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.paintDecodeShadowLOORMSE decodeInfoOut.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.paintDecodeClassifyLOORMSE decodeInfoOut.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.paintDecodeBothRMSE decodeInfoOut.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
    bar(xPaint,nPaint,'c','EdgeColor','c');
    xlim([0,0.5]);
    legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfoIn.legendFontSize-4);
    xlabel('Paint RMSE','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Histogram Count','FontSize',decodeInfoIn.labelFontSize);

    subplot(2,1,2); hold on;
    plot([decodeInfoOut.shadowDecodeBothLOORMSE decodeInfoOut.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.shadowDecodePaintLOORMSE decodeInfoOut.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.shadowDecodeShadowLOORMSE decodeInfoOut.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.shadowDecodeClassifyLOORMSE decodeInfoOut.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfoIn.lineWidth);
    plot([decodeInfoOut.shadowDecodeBothRMSE decodeInfoOut.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
    h = bar(xShadow,nShadow,'c','EdgeColor','c');
    xlim([0,0.5]);
    ylim([0 yMax+1]);
    legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfoIn.legendFontSize-4);
    xlabel('Shadow RMSE','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Histogram Count','FontSize',decodeInfoIn.labelFontSize);

    figName = [figNameRoot '_extRmseAnalysis'];
    drawnow;
    FigureSave(figName,rmseAnaysisFig,decodeInfoIn.figType);

    % *******
    % Study decoding performance as a function of the number of units
    % *******
    nUnitsToUseList = unique(round(logspace(0,log10(nUnits),nNUnitsToStudy )));
    nNUnitsToStudy = length(nUnitsToUseList);
      
    % Get RMSE for all choices of one unit
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = decodeLOOType;
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    for jj = 1:nUnits
        useUnits = jj;
        [~,~,paintPredsLOO,shadowPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses(:,useUnits),theData.shadowIntensities,theData.shadowResponses(:,useUnits));
        oneLOORMSE(jj) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPredsLOO(:) ; shadowPredsLOO(:)]).^2));
        whichOneRMSEUnits(jj) = useUnits;
    end
    [decodeInfoOut.bestOneLOORMSE,index] = min(oneLOORMSE);
    decodeInfoOut.bestOneRMSEUnit = whichOneRMSEUnits(index);
    
    % Get RMSE as a function of number of units
    theLOORMSE = zeros(nNUnitsToStudy ,nRepeatsPerNUnits);
    theUnits = zeros(nNUnitsToStudy ,nRepeatsPerNUnits);
    minLOORMSEUnits = zeros(nNUnitsToStudy ,1);
    minLOORMSE = zeros(nNUnitsToStudy,1);
    for uu = 1:length(nUnitsToUseList)
        nUnitsToUse = nUnitsToUseList(uu);
        fprintf('\tRMSE for %d units\n',nUnitsToUse);
        for jj = 1:nRepeatsPerNUnits
            shuffledUnits = Shuffle(1:nUnits);
            useUnits = shuffledUnits(1:nUnitsToUse);     
            [~,~,paintPredsLOO,shadowPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
                theData.paintIntensities,theData.paintResponses(:,useUnits),theData.shadowIntensities,theData.shadowResponses(:,useUnits));
            theLOORMSE(uu,jj) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPredsLOO(:) ; shadowPredsLOO(:)]).^2));
            theUnits(uu,jj) = nUnitsToUse;
        end
        minLOORMSEUnits(uu) = nUnitsToUse;
        minLOORMSE(uu) = min(theLOORMSE(uu,:));
    end
    
    % Fit an exponential through the lower envelope of the RMSE versus units
    a0 = max(minLOORMSE); b0 = 10; c0 = min(minLOORMSE);
    decodeInfoOut.rmse = c0;
    decodeInfoOut.rmseVersusNUnitsFit = fit(minLOORMSEUnits,minLOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
    decodeInfoOut.rmseVersusNUnitsFitScale = decodeInfoOut.rmseVersusNUnitsFit.b;
    decodeInfoOut.rmseVersusNUnitsFitAsymp = decodeInfoOut.rmseVersusNUnitsFit.c;
    
    % Shuffle trials and then get RMSE as a function of number of units
    theShuffledLOORMSE = zeros(nNUnitsToStudy ,nRepeatsPerNUnits);
    theShuffledUnits = zeros(nNUnitsToStudy ,nRepeatsPerNUnits);
    minShuffledLOORMSEUnits = zeros(nNUnitsToStudy ,1);
    minShuffledLOORMSE = zeros(nNUnitsToStudy,1);
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = decodeLOOType;
    decodeInfoTemp.trialShuffleType = 'intshf';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    for uu = 1:length(nUnitsToUseList)
        nUnitsToUse = nUnitsToUseList(uu);
        fprintf('\tShuffled RMSE for %d units\n',nUnitsToUse);

        % Shuffle data within intensities and within paint/shadow
        [shufflePaintIntensities,shufflePaintResponses,shuffleShadowIntensities,shuffleShadowResponses] = ...
            PaintShadowShuffle(decodeInfoTemp,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
     
        for jj = 1:nRepeatsPerNUnits
            shuffledUnits = Shuffle(1:nUnits);
            useUnits = shuffledUnits(1:nUnitsToUse);     
            
            [~,~,paintPredsLOO,shadowPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
                shufflePaintIntensities,shufflePaintResponses(:,useUnits),shuffleShadowIntensities,shuffleShadowResponses(:,useUnits));
            theShuffledLOORMSE(uu,jj) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPredsLOO(:) ; shadowPredsLOO(:)]).^2));
            theShuffledUnits(uu,jj) = nUnitsToUse;
        end
        minShuffledLOORMSEUnits(uu) = nUnitsToUse;
        minShuffledLOORMSE(uu) = min(theShuffledLOORMSE(uu,:));
    end
    
    % Fit an exponential through the lower envelope of the shuffled data
    % RMSE versus units.
    a0 = max(minShuffledLOORMSE); b0 = 10; c0 = min(minShuffledLOORMSE);
    decodeInfoOut.shuffledRMSE = c0;
    decodeInfoOut.shuffledRMSEVersusNUnitsFit = fit(minShuffledLOORMSEUnits,minShuffledLOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
    decodeInfoOut.shuffledRMSEVersusNUnitsFitScale = decodeInfoOut.shuffledRMSEVersusNUnitsFit.b;
    decodeInfoOut.shuffledRMSEVersusNUnitsFitAsymp = decodeInfoOut.shuffledRMSEVersusNUnitsFit.c;
    
    % Suppose all the units were like the best unit, but differed 
    % by virtue of having independent noise like that of the best unit.
    % How would performanc increase as a function of the number of such
    % units?
    % 
    % Get all responses for the unit
    bestRMSEUnitPaintResponses = theData.paintResponses(:,decodeInfoOut.bestOneRMSEUnit);
    bestRMSEUnitShadowResponses = theData.shadowResponses(:,decodeInfoOut.bestOneRMSEUnit);
    
    % Find mean and std for each intensity/[paint/shadow] combination
    for dc = 1:length(decodeInfoOut.uniqueIntensities)
        theIntensity = decodeInfoOut.uniqueIntensities(dc);
        paintIndex = find(theData.paintIntensities == theIntensity);
        shadowIndex = find(theData.shadowIntensities == theIntensity);
        meanBestRMSEPaintResponses(dc) = mean(bestRMSEUnitPaintResponses(paintIndex),1);
        meanBestRMSEShadowResponses(dc) = mean(bestRMSEUnitShadowResponses(shadowIndex),1);
        stdBestRMSEPaintResponses(dc) = std(bestRMSEUnitPaintResponses(paintIndex),[],1);
        stdBestRMSEShadowResponses(dc) = std(bestRMSEUnitShadowResponses(shadowIndex),[],1);
    end
    
    % Find RMSE for more and more of best-like units
    nPaintStimuli = size(theData.paintResponses,1);
    nShadowStimuli = size(theData.shadowResponses,1);
    theBestSynthesizedLOORMSE = zeros(length(nUnitsToUseList),1);
    theBestSynthesizedUnits = zeros(length(nUnitsToUseList),1);
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = decodeLOOType;
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    for uu = 1:length(nUnitsToUseList)
        nBestSynthesizedUnitsToUse = nUnitsToUseList(uu);
        
        % Create a synthesized dataset
        synthesizedPaintData = zeros(nPaintStimuli,nBestSynthesizedUnitsToUse);
        synthesizedShadowData = zeros(nShadowStimuli,nBestSynthesizedUnitsToUse);
        for ii = 1:nPaintStimuli
            theIntensity = theData.paintIntensities(ii);
            index = find(decodeInfoOut.uniqueIntensities == theIntensity);
            for jj = 1:nBestSynthesizedUnitsToUse
                synthesizedPaintData(ii,jj) = normrnd(meanBestRMSEPaintResponses(index),stdBestRMSEPaintResponses(index));
            end
        end
        for ii = 1:nShadowStimuli
            theIntensity = theData.shadowIntensities(ii);
            index = find(decodeInfoOut.uniqueIntensities == theIntensity);
            for jj = 1:nBestSynthesizedUnitsToUse
                synthesizedShadowData(ii,jj) = normrnd(meanBestRMSEShadowResponses(index),stdBestRMSEShadowResponses(index));  
            end
        end
        
        % Get performance for this many units
        [~,~,paintPredsLOO,shadowPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,synthesizedPaintData,theData.shadowIntensities,synthesizedShadowData);
        theBestSynthesizedLOORMSE(uu) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPredsLOO(:) ; shadowPredsLOO(:)]).^2));
        theBestSynthesizedUnits(uu) = nBestSynthesizedUnitsToUse;
    end
         
    % Fit an exponential through the best like unit rmse versus number of
    % units.
    a0 = max(theBestSynthesizedLOORMSE); b0 = 10; c0 = min(theBestSynthesizedLOORMSE);
    decodeInfoOut.bestSynthesizedRMSE = c0;
    decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFit = fit(theBestSynthesizedUnits,theBestSynthesizedLOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
    decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFitScale = decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFit.b;
    decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFitAsymp = decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFit.c;
    
    % PLOT: RMSE versus number of units used to decode
    rmseVersusNUnitsfig = figure; clf;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    hold on;
    
    % The points
    h = plot(theUnits(:),theLOORMSE(:),'ro','MarkerFaceColor','r','MarkerSize',4);
    h = plot(theBestSynthesizedUnits,theBestSynthesizedLOORMSE,'bo','MarkerFaceColor','b','MarkerSize',4);
    h = plot(minShuffledLOORMSEUnits,minShuffledLOORMSE,'co','MarkerFaceColor','c','MarkerSize',4);

    % The fits to lower envelopes
    smoothX = (1:nUnits)';
    h = plot(smoothX,decodeInfoOut.rmseVersusNUnitsFit(smoothX),'k','LineWidth',decodeInfoIn.lineWidth);
    h = plot(smoothX,decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFit(smoothX),'k:','LineWidth',decodeInfoIn.lineWidth-2);
    h = plot(smoothX,decodeInfoOut.shuffledRMSEVersusNUnitsFit(smoothX),'c:','LineWidth',decodeInfoIn.lineWidth-2);

    % Specific points of interest
    h = plot(1,decodeInfoOut.bestOneLOORMSE,'go','MarkerFaceColor','g','MarkerSize',8);
    h = plot(decodeInfoOut.rmseVersusNUnitsFitScale,decodeInfoOut.rmseVersusNUnitsFit(decodeInfoOut.rmseVersusNUnitsFitScale),...
        'go','MarkerFaceColor','g','MarkerSize',8);
    %h = plot(decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFitScale,decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFit(decodeInfoOut.bestSynthesizedRMSEVersusNUnitsFitScale),...
    %    'bo','MarkerFaceColor','b','MarkerSize',8);
    %h = plot(decodeInfoOut.shuffledRMSEVersusNUnitsFitScale,decodeInfoOut.shuffledRMSEVersusNUnitsFit(decodeInfoOut.shuffledRMSEVersusNUnitsFitScale),...
    %    'co','MarkerFaceColor','c','MarkerSize',8);  
    xlabel('Number of Units Used in Decoding','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Decoded Luminance RMSE','FontSize',decodeInfoIn.labelFontSize);
    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
    xlim([0,100]);
    ylim([0,0.5]);
    axis square
    figName = [figNameRoot '_extRmseVersusNUnits'];
    drawnow;
    FigureSave(figName,rmseVersusNUnitsfig,decodeInfoIn.figType);
    
    % *******
    % Study decoding performance as a function of number of PCA dimensions
    % *******
    %
    % Get PCA
    dataForPCA = [theData.paintResponses ; theData.shadowResponses];
    meanDataForPCA = mean(dataForPCA,1);
    [pcaBasis,paintShadowPCAResponsesTrans] = pca(dataForPCA,'NumComponents',nUnits);
    decodeInfoOut.paintPCAResponses = (pcaBasis\(theData.paintResponses-meanDataForPCA(ones(size(theData.paintResponses,1),1),:))')';
    decodeInfoOut.shadowPCAResponses = (pcaBasis\(theData.shadowResponses-meanDataForPCA(ones(size(theData.shadowResponses,1),1),:))')';

    % Get RMSE as a function of number of PCA components  
    thePCAUnits = zeros(nNUnitsToStudy,1);
    thePCALOORMSE = zeros(nNUnitsToStudy,1);
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = 'aff';
    decodeInfoTemp.looType = decodeLOOType;
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    for uu = 1:nNUnitsToStudy
        nUnitsToUse = nUnitsToUseList(uu);
        [~,~,paintPCAPredsLOO,shadowPCAPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
            theData.paintIntensities,decodeInfoOut.paintPCAResponses(:,1:nUnitsToUse),theData.shadowIntensities,decodeInfoOut.shadowPCAResponses(:,1:nUnitsToUse));
        thePCALOORMSE(uu) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPCAPredsLOO(:) ; shadowPCAPredsLOO(:)]).^2));
        thePCAUnits(uu) = nUnitsToUse;
    end
    
    % Fit an exponential
    a0 = max(thePCALOORMSE); b0 = 5; c0 = min(thePCALOORMSE);
    decodeInfoOut.rmseVersusNPCAFit = fit(thePCAUnits,thePCALOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
    decodeInfoOut.rmseVersusNPCAFitScale = decodeInfoOut.rmseVersusNPCAFit.b;
    decodeInfoOut.rmseVersusNPCAFitAsymp = decodeInfoOut.rmseVersusNPCAFit.c;
    
    % PLOT: RMSE versus number of PCA components used to decode
    rmseVersusNPCAfig = figure; clf;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    hold on;
    smoothX = (1:nUnits)';
    h = plot(smoothX,decodeInfoOut.rmseVersusNPCAFit(smoothX),'k','LineWidth',decodeInfoIn.lineWidth);    
    h = plot(thePCAUnits,thePCALOORMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
    h = plot(decodeInfoOut.rmseVersusNPCAFitScale,decodeInfoOut.rmseVersusNPCAFit(decodeInfoOut.rmseVersusNPCAFitScale),'go','MarkerFaceColor','g','MarkerSize',8);
    xlabel('Number of PCA Components','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Decoded Luminance RMSE','FontSize',decodeInfoIn.labelFontSize);
    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
    xlim([0,100]);
    ylim([0,0.5]);
    axis square
    figName = [figNameRoot '_extRmseVersusNPCA'];
    drawnow;
    FigureSave(figName,rmseVersusNPCAfig,decodeInfoIn.figType);
    
    % PLOT: paint/shadow mean responses on PCA 1 and 2, where we compute
    % the PCA on the mean responses
    for dc = 1:length(decodeInfoOut.uniqueIntensities)
        theIntensity = decodeInfoOut.uniqueIntensities(dc);
        paintIndex = find(theData.paintIntensities == theIntensity);
        shadowIndex = find(theData.shadowIntensities == theIntensity);
        meanPaintResponses(dc,:) = mean(theData.paintResponses(paintIndex,:),1);
        meanShadowResponses(dc,:) = mean(theData.shadowResponses(shadowIndex,:),1);
    end
    dataForPCA = [meanPaintResponses ; meanShadowResponses];
    meanDataForPCA = mean(dataForPCA,1);
    pcaBasis = pca(dataForPCA,'NumComponents',nUnits);
    decodeInfoOut.meanPaintPCAResponses = (pcaBasis\(meanPaintResponses-meanDataForPCA(ones(size(meanPaintResponses,1),1),:))')';
    decodeInfoOut.meanShadowPCAResponses = (pcaBasis\(meanShadowResponses-meanDataForPCA(ones(size(meanShadowResponses,1),1),:))')';

    paintShadowOnPCAFig = figure; clf; hold on;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    theGrays = linspace(.4,1,length(decodeInfoOut.uniqueIntensities));
    for dc = 1:length(decodeInfoOut.uniqueIntensities)
        theGreen = [0 theGrays(dc) 0];
        theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
        
        % Basic points first, so legend comes out right
        plot(mean(decodeInfoOut.meanPaintPCAResponses(dc,1)),mean(decodeInfoOut.meanPaintPCAResponses(dc,2)),...
            'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
        plot(mean(decodeInfoOut.meanShadowPCAResponses(dc,1)),mean(decodeInfoOut.meanShadowPCAResponses(dc,2)),...
            'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    end
    xlabel('PCA Component 1 Wgt','FontSize',decodeInfoIn.labelFontSize);
    ylabel('PCA Component 2 Wgt','FontSize',decodeInfoIn.labelFontSize);
    decodeInfoOut.titleStr = titleRootStr;
    title(decodeInfoOut.titleStr,'FontSize',decodeInfoIn.titleFontSize);
    h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfoIn.legendFontSize,'Location','SouthWest');
    drawnow;
    figName = [figNameRoot '_extPaintShadowOnPCA'];
    FigureSave(figName,paintShadowOnPCAFig,decodeInfoIn.figType);
    
    % *******
    % Study classification performance as a function of the number of units
    % *******
    %
    % Use same unit/repeat parameters as for the rmse version above.
    theLOOPerformance = zeros(nNUnitsToStudy,nRepeatsPerNUnits);
    theUnits = zeros(nNUnitsToStudy,nRepeatsPerNUnits);
    maxLOOPerformanceUnits = zeros(nNUnitsToStudy,1);
    maxLOOPerformance = zeros(nNUnitsToStudy,1);
    clear decodeInfoTemp
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.classifyType = 'mvma';
    decodeInfoTemp.classifyReduce = '';
    decodeInfoTemp.MVM_ALG = 'SMO';
    decodeInfoTemp.MVM_COMPARECLASS = 0;
    decodeInfoTemp.classLooType = classifyLOOType;
    decodeInfoTemp.trialShuffleType = 'none';
    decodeInfoTemp.paintShadowShuffleType = 'none';
    
    % Get classification performance for all choices of one unit
    for jj = 1:nUnits
        useUnits = jj;
        [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses(:,useUnits),theData.shadowIntensities,theData.shadowResponses(:,useUnits));
        
        paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
        shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
        oneLOOPerformance(jj) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
        whichOnePerformanceUnits(jj) = useUnits;
    end
    [decodeInfoOut.bestOneLOOPerformance,index] = max(oneLOOPerformance);
    decodeInfoOut.bestOnePerformanceUnit = whichOnePerformanceUnits(index);
    
    % Get performance as a function of number of units
    for uu = 1:length(nUnitsToUseList)
        nUnitsToUse = nUnitsToUseList(uu);
        fprintf('\tClassification for %d units\n',nUnitsToUse);
        for jj = 1:nRepeatsPerNUnits
            shuffledUnits = Shuffle(1:nUnits);
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
    decodeInfoOut.performance = c0;
    decodeInfoOut.performanceVersusNUnitsFit = fit(maxLOOPerformanceUnits,maxLOOPerformance,'a-(a-c)*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
    decodeInfoOut.performanceVersusNUnitsFitScale = decodeInfoOut.performanceVersusNUnitsFit.b;
    decodeInfoOut.performanceVersusNUnitsFitAsymp = decodeInfoOut.performanceVersusNUnitsFit.c;
    
    % PLOT: Performance versus number of units used to decode
    performanceVersusNUnitsfig = figure; clf;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    hold on;
    
    smoothX = (1:nUnits)';
    h = plot(smoothX,decodeInfoOut.performanceVersusNUnitsFit(smoothX),'k','LineWidth',decodeInfoIn.lineWidth);
    
    h = plot(decodeInfoOut.performanceVersusNUnitsFitScale,decodeInfoOut.performanceVersusNUnitsFit(decodeInfoOut.performanceVersusNUnitsFitScale),'go','MarkerFaceColor','g','MarkerSize',8);
    h = plot(1,decodeInfoOut.bestOneLOOPerformance,'go','MarkerFaceColor','g','MarkerSize',8);
    h = plot(theUnits(:),theLOOPerformance(:),'ro','MarkerFaceColor','r','MarkerSize',4);
    
    %h = legend({'Paint','Shadow'},'FontSize',decodeInfoIn.legendFontSize,'Location','NorthWest');
    %lfactor = 0.5;
    %lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
    xlabel('Number of Units Used in Classification','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Paint/Shadow Classification Performance','FontSize',decodeInfoIn.labelFontSize);
    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
    xlim([0,100]);
    ylim([0,1.1]);
    axis square
    figName = [figNameRoot '_extClassPerformanceVersusNUnits'];
    drawnow;
    FigureSave(figName,performanceVersusNUnitsfig,decodeInfoIn.figType);
    
    % *******
    % Study classification performance as a function of number of PCA dimensions
    % *******

    % Get classification performance as a function of number of PCA components
    thePCAClassifyUnits = zeros(nUnits,1);
    thePCALOOPerformance = zeros(nUnits,1);
    for uu = 1:nNUnitsToStudy
        nUnitsToUse = nUnitsToUseList(uu);
        [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
            theData.paintIntensities,theData.paintResponses(:,1:nUnitsToUse),theData.shadowIntensities,theData.shadowResponses(:,1:nUnitsToUse));
        
        paintClassifyLOONCorrect = length(find(paintClassifyPredsLOO == decodeInfoTempOut.paintLabel));
        shadowClassifyLOONCorrect = length(find(shadowClassifyPredsLOO == decodeInfoTempOut.shadowLabel));
        thePCALOOPerformance(uu) = (paintClassifyLOONCorrect+shadowClassifyLOONCorrect)/(length(paintClassifyPredsLOO)+length(shadowClassifyPredsLOO));
        thePCAClassifyUnits(uu) = nUnitsToUse; 
    end
    
    % Fit an exponential to classification versus number of PCA components
    a0 = max(thePCALOOPerformance); b0 = 5; c0 = min(thePCALOOPerformance);
    decodeInfoOut.performanceVersusNPCAFit = fit(thePCAClassifyUnits,thePCALOOPerformance,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
    decodeInfoOut.performanceVersusNPCAFitScale = decodeInfoOut.performanceVersusNPCAFit.b;
    decodeInfoOut.performanceVersusNPCAFitAsymp = decodeInfoOut.performanceVersusNPCAFit.c;
    
    % PLOT: Classification performance versus number of PCA components used to decode
    performanceVersusNPCAfig = figure; clf;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    hold on;
    smoothX = (1:nUnits)';
    h = plot(smoothX,decodeInfoOut.performanceVersusNPCAFit(smoothX),'k','LineWidth',decodeInfoIn.lineWidth);
    h = plot(thePCAClassifyUnits,thePCALOOPerformance,'ro','MarkerFaceColor','r','MarkerSize',4);
    h = plot(decodeInfoOut.performanceVersusNPCAFitScale,decodeInfoOut.performanceVersusNPCAFit(decodeInfoOut.performanceVersusNPCAFitScale),'go','MarkerFaceColor','g','MarkerSize',8);
    xlabel('Number of PCA Components','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Paint/Shadow Classification Performance','FontSize',decodeInfoIn.labelFontSize);
    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
    xlim([0,100]);
    ylim([0,1.1]);
    axis square
    figName = [figNameRoot '_extClassPerformanceVersusNPCA'];
    drawnow;
    FigureSave(figName,performanceVersusNPCAfig,decodeInfoIn.figType);
    
end
end



