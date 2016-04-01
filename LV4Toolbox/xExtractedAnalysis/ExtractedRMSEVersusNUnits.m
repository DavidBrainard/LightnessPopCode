function decodeInfo = ExtractedRMSEVersusNUnits(decodeInfo,theData)
% decodeInfo = ExtractedRMSEVersusNUnits(decodeInfo,theData)
%
% Study decoding performance as a function of the number of units
%
% 3/29/16  dhb  Pulled this out.

%% Get info about what to do
nUnitsToUseList = unique(round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy)));

%% Get RMSE for all choices of one unit
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = decodeInfo.ndecodeLOOType;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
for jj = 1:decodeInfo.nUnits
    useUnits = jj;
    [~,~,paintPredsLOO,shadowPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
        theData.paintIntensities,theData.paintResponses(:,useUnits),theData.shadowIntensities,theData.shadowResponses(:,useUnits));
    oneLOORMSE(jj) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPredsLOO(:) ; shadowPredsLOO(:)]).^2));
    whichOneRMSEUnits(jj) = useUnits;
end
[decodeInfo.bestOneLOORMSE,index] = min(oneLOORMSE);
decodeInfo.bestOneRMSEUnit = whichOneRMSEUnits(index);

%% Get RMSE as a function of number of units
theLOORMSE = zeros(decodeInfo.nNUnitsToStudy ,decodeInfo.nRepeatsPerNUnits);
theUnits = zeros(decodeInfo.nNUnitsToStudy ,decodeInfo.nRepeatsPerNUnits);
minLOORMSEUnits = zeros(decodeInfo.nNUnitsToStudy ,1);
minLOORMSE = zeros(decodeInfo.nNUnitsToStudy,1);
for uu = 1:length(nUnitsToUseList)
    nUnitsToUse = nUnitsToUseList(uu);
    fprintf('\tRMSE for %d units\n',nUnitsToUse);
    for jj = 1:decodeInfo.nRepeatsPerNUnits
        shuffledUnits = Shuffle(1:decodeInfo.nUnits);
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
decodeInfo.rmse = c0;
decodeInfo.rmseVersusNUnitsFit = fit(minLOORMSEUnits,minLOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.rmseVersusNUnitsFitScale = decodeInfo.rmseVersusNUnitsFit.b;
decodeInfo.rmseVersusNUnitsFitAsymp = decodeInfo.rmseVersusNUnitsFit.c;

%% Shuffle trials and then get RMSE as a function of number of units
theShuffledLOORMSE = zeros(decodeInfo.nNUnitsToStudy ,decodeInfo.nRepeatsPerNUnits);
theShuffledUnits = zeros(decodeInfo.nNUnitsToStudy ,decodeInfo.nRepeatsPerNUnits);
minShuffledLOORMSEUnits = zeros(decodeInfo.nNUnitsToStudy ,1);
minShuffledLOORMSE = zeros(decodeInfo.nNUnitsToStudy,1);
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = decodeInfo.ndecodeLOOType;
decodeInfoTemp.trialShuffleType = 'intshf';
decodeInfoTemp.paintShadowShuffleType = 'none';
for uu = 1:length(nUnitsToUseList)
    nUnitsToUse = nUnitsToUseList(uu);
    fprintf('\tShuffled RMSE for %d units\n',nUnitsToUse);
    
    % Shuffle data within intensities and within paint/shadow
    [shufflePaintIntensities,shufflePaintResponses,shuffleShadowIntensities,shuffleShadowResponses] = ...
        PaintShadowShuffle(decodeInfoTemp,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    
    for jj = 1:decodeInfo.nRepeatsPerNUnits
        shuffledUnits = Shuffle(1:decodeInfo.nUnits);
        useUnits = shuffledUnits(1:nUnitsToUse);
        
        [~,~,paintPredsLOO,shadowPredsLOO] = PaintShadowDecode(decodeInfoTemp, ...
            shufflePaintIntensities,shufflePaintResponses(:,useUnits),shuffleShadowIntensities,shuffleShadowResponses(:,useUnits));
        theShuffledLOORMSE(uu,jj) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPredsLOO(:) ; shadowPredsLOO(:)]).^2));
        theShuffledUnits(uu,jj) = nUnitsToUse;
    end
    minShuffledLOORMSEUnits(uu) = nUnitsToUse;
    minShuffledLOORMSE(uu) = min(theShuffledLOORMSE(uu,:));
end

% Fit an exponential through the lower envelope...
% 
% of the shuffled data RMSE versus units.
a0 = max(minShuffledLOORMSE); b0 = 10; c0 = min(minShuffledLOORMSE);
decodeInfo.shuffledRMSE = c0;
decodeInfo.shuffledRMSEVersusNUnitsFit = fit(minShuffledLOORMSEUnits,minShuffledLOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.shuffledRMSEVersusNUnitsFitScale = decodeInfo.shuffledRMSEVersusNUnitsFit.b;
decodeInfo.shuffledRMSEVersusNUnitsFitAsymp = decodeInfo.shuffledRMSEVersusNUnitsFit.c;

%% Suppose all the units were like the best unit ...
%
% but differed by virtue of having independent noise like that of the best unit.
% How would performanc increase as a function of the number of such
% units?
%
% Get all responses for the unit
bestRMSEUnitPaintResponses = theData.paintResponses(:,decodeInfo.bestOneRMSEUnit);
bestRMSEUnitShadowResponses = theData.shadowResponses(:,decodeInfo.bestOneRMSEUnit);

% Find mean and std for each intensity/[paint/shadow] combination
for dc = 1:length(decodeInfo.uniqueIntensities)
    theIntensity = decodeInfo.uniqueIntensities(dc);
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
decodeInfoTemp.looType = decodeInfo.ndecodeLOOType;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
for uu = 1:length(nUnitsToUseList)
    nBestSynthesizedUnitsToUse = nUnitsToUseList(uu);
    
    % Create a synthesized dataset
    synthesizedPaintData = zeros(nPaintStimuli,nBestSynthesizedUnitsToUse);
    synthesizedShadowData = zeros(nShadowStimuli,nBestSynthesizedUnitsToUse);
    for ii = 1:nPaintStimuli
        theIntensity = theData.paintIntensities(ii);
        index = find(decodeInfo.uniqueIntensities == theIntensity);
        for jj = 1:nBestSynthesizedUnitsToUse
            synthesizedPaintData(ii,jj) = normrnd(meanBestRMSEPaintResponses(index),stdBestRMSEPaintResponses(index));
        end
    end
    for ii = 1:nShadowStimuli
        theIntensity = theData.shadowIntensities(ii);
        index = find(decodeInfo.uniqueIntensities == theIntensity);
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
decodeInfo.bestSynthesizedRMSE = c0;
decodeInfo.bestSynthesizedRMSEVersusNUnitsFit = fit(theBestSynthesizedUnits,theBestSynthesizedLOORMSE,'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.bestSynthesizedRMSEVersusNUnitsFitScale = decodeInfo.bestSynthesizedRMSEVersusNUnitsFit.b;
decodeInfo.bestSynthesizedRMSEVersusNUnitsFitAsymp = decodeInfo.bestSynthesizedRMSEVersusNUnitsFit.c;

%% PLOT: RMSE versus number of units used to decode
rmseVersusNUnitsfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;

% The points
h = plot(theUnits(:),theLOORMSE(:),'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(theBestSynthesizedUnits,theBestSynthesizedLOORMSE,'bo','MarkerFaceColor','b','MarkerSize',4);
h = plot(minShuffledLOORMSEUnits,minShuffledLOORMSE,'co','MarkerFaceColor','c','MarkerSize',4);

% The fits to lower envelopes
smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeInfo.rmseVersusNUnitsFit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
h = plot(smoothX,decodeInfo.bestSynthesizedRMSEVersusNUnitsFit(smoothX),'k:','LineWidth',decodeInfo.lineWidth-2);
h = plot(smoothX,decodeInfo.shuffledRMSEVersusNUnitsFit(smoothX),'c:','LineWidth',decodeInfo.lineWidth-2);

% Specific points of interest
h = plot(1,decodeInfo.bestOneLOORMSE,'go','MarkerFaceColor','g','MarkerSize',8);
h = plot(decodeInfo.rmseVersusNUnitsFitScale,decodeInfo.rmseVersusNUnitsFit(decodeInfo.rmseVersusNUnitsFitScale),...
    'go','MarkerFaceColor','g','MarkerSize',8);
%h = plot(decodeInfo.bestSynthesizedRMSEVersusNUnitsFitScale,decodeInfo.bestSynthesizedRMSEVersusNUnitsFit(decodeInfo.bestSynthesizedRMSEVersusNUnitsFitScale),...
%    'bo','MarkerFaceColor','b','MarkerSize',8);
%h = plot(decodeInfo.shuffledRMSEVersusNUnitsFitScale,decodeInfo.shuffledRMSEVersusNUnitsFit(decodeInfo.shuffledRMSEVersusNUnitsFitScale),...
%    'co','MarkerFaceColor','c','MarkerSize',8);
xlabel('Number of Units Used in Decoding','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,0.5]);
axis square
figName = [decodeInfo.figNameRoot '_extRmseVersusNUnits'];
drawnow;
FigureSave(figName,rmseVersusNUnitsfig,decodeInfo.figType);