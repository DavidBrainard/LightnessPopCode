function ExtractedClassificationVersusNUnits(doIt,decodeInfo,theData)
% ExtractedClassificationVersusNUnits(doIt,decodeInfo,theData)
%
% Study classification performance as a function of the number of units.
%
% 3/29/16  dhb  Pulled this out into its own function.

%% Are we doing it?
switch (doIt)
    case 'always'
    case 'never'
        return;
    case 'ifmissing'
        if (exist(fullfile(decodeInfo.writeDataDir,'extClassificationVersusNUnits.mat'),'file'))
            return;
        end
end

%% Get info about what to do
nUnitsToUseList = unique(round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy)));
uniqueNUnitsToStudy = length(nUnitsToUseList);

%% Decoding for various combinations of units
%
% Basic analysis, no trial shuffling
clear decodeInfoTemp
decodeInfoTemp.verbose = decodeInfo.verbose;
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoTemp.nNUnitsToStudy = decodeInfo.nNUnitsToStudy;
decodeInfoTemp.nRepeatsPerNUnits = decodeInfo.nRepeatsPerNUnits;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifyLOOType = decodeInfo.classifyLOOType;
decodeInfoTemp.classifyNFolds = decodeInfo.classifyNFolds;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
decodeInfoTemp.writeDataDir = decodeInfo.writeDataDir;
decodeInfoOut = DoBasicClassification(decodeInfoTemp,theData);
decodeSave.basicAnalysis = decodeInfoOut;

%% Decoding for various combinations of units
%
% Trial shuffling
clear decodeInfoTemp
decodeInfoTemp.verbose = decodeInfo.verbose;
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoTemp.nNUnitsToStudy = decodeInfo.nNUnitsToStudy;
decodeInfoTemp.nRepeatsPerNUnits = decodeInfo.nRepeatsPerNUnits;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifyLOOType = decodeInfo.classifyLOOType;
decodeInfoTemp.classifyNFolds = decodeInfo.classifyNFolds;
decodeInfoTemp.trialShuffleType = 'intshf';
decodeInfoTemp.paintShadowShuffleType = 'none';
decodeInfoTemp.writeDataDir = decodeInfo.writeDataDir;
decodeInfoOut = DoBasicClassification(decodeInfoTemp,theData);
decodeSave.shuffledAnalysis = decodeInfoOut;

%% Suppose all the units were like the best unit ...
%
% but differed by virtue of having independent noise like that of the best
% unit. How would performanc increase as a function of the number of such
% units?
clear decodeInfoTemp
decodeInfoTemp.verbose = decodeInfo.verbose;
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoTemp.nNUnitsToStudy = decodeInfo.nNUnitsToStudy;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifyLOOType = decodeInfo.classifyLOOType;
decodeInfoTemp.classifyNFolds = decodeInfo.classifyNFolds;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
decodeInfoOut= DoBestUnitClassification(decodeInfoTemp,theData,decodeSave.basicAnalysis.bestOnePerformanceUnit);
decodeSave.bestAnalysis = decodeInfoOut;

%% PLOT: Performance versus number of units used to decode
%
% First panel is basic analysis
smoothX = (1:decodeInfo.nFitMaxUnits)';
rmseVersusNUnitsfig = figure; clf;
set(gcf,'Position',[100 100 1600 1000]);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(1,2,1); hold on;

% The fit lines underneath everything else
h = plot(smoothX,decodeSave.basicAnalysis.fit(smoothX),'k:','LineWidth',decodeInfo.lineWidth-2);
h = plot(smoothX,decodeSave.bestAnalysis.fit(smoothX),'b:','LineWidth',decodeInfo.lineWidth-2);

% The points
h = plot(decodeSave.basicAnalysis.ranUnits(:),decodeSave.basicAnalysis.ranPerformance(:),'ro','MarkerSize',4);
h = plot(1,decodeSave.basicAnalysis.bestOnePerformance,'ro','MarkerSize',8);
h = plot(2,decodeSave.basicAnalysis.bestTwoPerformance,'ro','MarkerSize',8);
h = plot(decodeSave.basicAnalysis.maxUnits,decodeSave.basicAnalysis.maxPerformance,'ko','MarkerFaceColor','k','MarkerSize',4);
h = plot(decodeSave.bestAnalysis.theUnits,decodeSave.bestAnalysis.thePerformance,'bo','MarkerFaceColor','b','MarkerSize',4);
    
% Best unit analsyis
h = plot(decodeSave.basicAnalysis.fitScale,...
    decodeSave.basicAnalysis.fit(decodeSave.basicAnalysis.fitScale),...
    'ko','MarkerFaceColor','k','MarkerSize',8);
h = plot(decodeSave.bestAnalysis.fitScale,...
    decodeSave.bestAnalysis.fit(decodeSave.bestAnalysis.fitScale),...
    'bo','MarkerFaceColor','b','MarkerSize',8);

% Labels, scale, etc
xlabel('Number of Units Used in Decoding','FontSize',decodeInfo.labelFontSize);
ylabel('Classification Performance','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,1]);
axis square

% Second panel is same plot for shuffled analysis
subplot(1,2,2); hold on;
h = plot(smoothX,decodeSave.shuffledAnalysis.fit(smoothX),'k:','LineWidth',decodeInfo.lineWidth-2);
h = plot(smoothX,decodeSave.bestAnalysis.fit(smoothX),'b:','LineWidth',decodeInfo.lineWidth-2);

% The points
h = plot(decodeSave.shuffledAnalysis.ranUnits(:),decodeSave.shuffledAnalysis.ranPerformance(:),'ro','MarkerSize',4);
h = plot(1,decodeSave.shuffledAnalysis.bestOnePerformance,'ro','MarkerSize',8);
h = plot(2,decodeSave.shuffledAnalysis.bestTwoPerformance,'ro','MarkerSize',8);
h = plot(decodeSave.shuffledAnalysis.maxUnits,decodeSave.shuffledAnalysis.maxPerformance,'ko','MarkerFaceColor','k','MarkerSize',4);
h = plot(decodeSave.bestAnalysis.theUnits,decodeSave.bestAnalysis.thePerformance,'bo','MarkerFaceColor','b','MarkerSize',4);
    
% Best unit analysis
h = plot(decodeSave.shuffledAnalysis.fitScale,...
    decodeSave.shuffledAnalysis.fit(decodeSave.shuffledAnalysis.fitScale),...
    'ko','MarkerFaceColor','k','MarkerSize',8);
h = plot(decodeSave.bestAnalysis.fitScale,...
    decodeSave.bestAnalysis.fit(decodeSave.bestAnalysis.fitScale),...
    'bo','MarkerFaceColor','b','MarkerSize',8);

% Labels, scale, etc
xlabel('Number of Units Used in Decoding','FontSize',decodeInfo.labelFontSize);
ylabel('Classification Performance (Shuffled)','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,1]);
axis square

% Write the figure
figName = [decodeInfo.figNameRoot '_extClassificationVersusNUnits'];
drawnow;
FigureSave(figName,rmseVersusNUnitsfig,decodeInfo.figType);

%% Store the data for return
decodeInfo.classificationVersusNUnits = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extClassificationVersusNUnits'),'decodeSave','-v7.3');

end

%% decodeInfo = DoBasicClassification(decodeInfo,theData)
function decodeInfo = DoBasicClassification(decodeInfo,theData)
%
% Do the decoding for various choices of the number of units.
% This is set up so that the same code can do the shuffled and unshuffled
% versions, using the same control logic.

%% Get info about what to do
nUnitsToUseList = unique([1 2 round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy))]);
uniqueNUnitsToStudy = length(nUnitsToUseList);

%% Get performance for all choices of one unit
%
% Keep track of how well each performs.

% Optional data shuffle, controlled by decodeInfo
if (decodeInfo.verbose)
    fprintf('\tPerformance for all choices of one unit\n');
end
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
for jj = 1:decodeInfo.nUnits
    useUnits = jj;
    [~,~,paintPreds,shadowPreds,decodeInfoOutTemp] = PaintShadowClassify(decodeInfo, ...
        paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
    paintClassifyNCorrect = length(find(paintPreds == decodeInfoOutTemp.paintLabel));
    shadowClassifyNCorrect = length(find(shadowPreds == decodeInfoOutTemp.shadowLabel));
    decodeInfo.onePerformance(jj) = (paintClassifyNCorrect+shadowClassifyNCorrect)/(length(paintPreds)+length(shadowPreds));
    decodeInfo.oneUnits(jj) = useUnits;
end
[decodeInfo.bestOnePerformance] = max(decodeInfo.onePerformance);
[~,onePerformanceIndex] = sort(decodeInfo.onePerformance(:),1,'descend');
decodeInfo.bestOnePerformanceUnit = decodeInfo.oneUnits(onePerformanceIndex(1));
if (decodeInfo.onePerformance(onePerformanceIndex(1)) ~= decodeInfo.bestOnePerformance)
    error('Inconsistency between sort and max');
end

%% Get performance for all choices of two units
if (decodeInfo.verbose)
    fprintf('\tPerformance for all choices of two units\n');
end
decodeInfo.orderedUnits = zeros(uniqueNUnitsToStudy ,1);
decodeInfo.orderedPerformance = zeros(uniqueNUnitsToStudy,1);
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
decodeInfo.bestTwoPerformance = -Inf;
for uu1 = 1:decodeInfo.nUnits
    if (decodeInfo.verbose)
        fprintf('\t\tFirst unit %d\n',uu1);
    end
    for uu2 = (uu1+1):decodeInfo.nUnits
        useUnits = [uu1 uu2];
        [~,~,paintPreds,shadowPreds,decodeInfoOutTemp] = PaintShadowClassify(decodeInfo, ...
            paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
        paintClassifyNCorrect = length(find(paintPreds == decodeInfoOutTemp.paintLabel));
        shadowClassifyNCorrect = length(find(shadowPreds == decodeInfoOutTemp.shadowLabel));
        tmpPerformance = (paintClassifyNCorrect+shadowClassifyNCorrect)/(length(paintPreds)+length(shadowPreds));
        if (tmpPerformance > decodeInfo.bestTwoPerformance)
            decodeInfo.bestTwoPerformance = tmpPerformance;
            decodeInfo.bestTwoPerformanceFirstUnit = uu1;
            decodeInfo.bestTwoPerformanceSecondUnit = uu2;
        end
    end
end

%% Get performance as a function of number of units
%
% When we add them in according to how well they do one at a time
if (decodeInfo.verbose)
    fprintf('\tPerformance for adding in units in order\n');
end
decodeInfo.orderedUnits = zeros(uniqueNUnitsToStudy ,1);
decodeInfo.orderedPerformance = zeros(uniqueNUnitsToStudy,1);
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
for uu = 1:length(nUnitsToUseList)
    nUnitsToUse = nUnitsToUseList(uu);
    useUnits = onePerformanceIndex(1:nUnitsToUse);
    [~,~,paintPreds,shadowPreds,decodeInfoOutTemp] = PaintShadowClassify(decodeInfo, ...
        paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
    paintClassifyNCorrect = length(find(paintPreds == decodeInfoOutTemp.paintLabel));
    shadowClassifyNCorrect = length(find(shadowPreds == decodeInfoOutTemp.shadowLabel));
    decodeInfo.orderedPerformance(uu) = (paintClassifyNCorrect+shadowClassifyNCorrect)/(length(paintPreds)+length(shadowPreds));
    decodeInfo.orderedUnits(uu) = nUnitsToUse;
end

%% Get performance as a function of number of units
%
% Random draws of units
decodeInfo.ranPerformance = zeros(uniqueNUnitsToStudy,decodeInfo.nRepeatsPerNUnits);
decodeInfo.ranUnits = zeros(uniqueNUnitsToStudy,decodeInfo.nRepeatsPerNUnits);
decodeInfo.maxRanUnits = zeros(uniqueNUnitsToStudy ,1);
decodeInfo.maxRanPerformance = zeros(uniqueNUnitsToStudy,1);
for uu = 1:length(nUnitsToUseList)
    nUnitsToUse = nUnitsToUseList(uu);
    if (decodeInfo.verbose)
        fprintf('\tPerformance for %d random units\n',nUnitsToUse);
    end
    [paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
        PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    for jj = 1:decodeInfo.nRepeatsPerNUnits
        shuffledUnits = Shuffle(1:decodeInfo.nUnits);
        useUnits = shuffledUnits(1:nUnitsToUse);
        [~,~,paintPreds,shadowPreds,decodeInfoOutTemp] = PaintShadowClassify(decodeInfo, ...
            paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
        paintClassifyNCorrect = length(find(paintPreds == decodeInfoOutTemp.paintLabel));
        shadowClassifyNCorrect = length(find(shadowPreds == decodeInfoOutTemp.shadowLabel));
        decodeInfo.ranPerformance(uu,jj) = (paintClassifyNCorrect+shadowClassifyNCorrect)/(length(paintPreds)+length(shadowPreds));
        decodeInfo.ranUnits(uu,jj) = nUnitsToUse;
    end
    decodeInfo.maxRanUnits(uu) = nUnitsToUse;
    decodeInfo.maxRanPerformance(uu) = max(decodeInfo.ranPerformance(uu,:));
end

%% Combine the ways we try decoding with a particular number of units
%
% And take the maximum.
if (strcmp(decodeInfo.trialShuffleType,'none') & strcmp(decodeInfo.paintShadowShuffleType,'none'))
    if (any(decodeInfo.maxRanUnits(:) ~= decodeInfo.orderedUnits(:)))
        error('This should not happen in the no shuffle case');
    end
end
 decodeInfo.maxUnits = decodeInfo.maxRanUnits;
 decodeInfo.maxPerformance = max([decodeInfo.maxRanPerformance(:) decodeInfo.orderedPerformance(:)],[],2);
 
% And also deal with the fact that we found the best decoding for two at a
% time, so slip this into the maximum.
%
% Cross validation and/or different trial shuffling can lead to a  small
% amount of variation so that it could be that the best classification when
% we search over all pairs of units sometimes is slightly worse than the
% best we get when we get the minimum across random draws.  We just take
% the from the exhaustive check of two at a time.
index = find(decodeInfo.maxUnits == 2);
decodeInfo.maxPerformance(index) = decodeInfo.bestTwoPerformance;
 
%% Fit an exponential through the upper envelope of the performance versus units
a0 = max(decodeInfo.maxPerformance); b0 = 10; c0 = max(decodeInfo.maxPerformance);
ftype = fittype('a-(a-c)*exp(-(x-1)/(b-1)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[0 2 0],'Upper',[5 200 5]);
decodeInfo.Performance = c0;
index = find(decodeInfo.maxUnits <= decodeInfo.nFitMaxUnits);
decodeInfo.fit = fit(decodeInfo.maxUnits(index),decodeInfo.maxPerformance(index),ftype,foptions);
decodeInfo.fitScale = decodeInfo.fit.b;
decodeInfo.fitAsymp = decodeInfo.fit.c;

end

%% decodeInfo = DoBestUnitClassification(decodeInfo,theData,bestUnit)
function decodeInfo = DoBestUnitClassification(decodeInfo,theData,bestUnit)
%
% Do the decoding based on the idea that all units are independent
% draws from trials for the best unit.

% Figure out N to run for
nUnitsToUseList = unique([1 2 round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy))]);
uniqueNUnitsToStudy = length(nUnitsToUseList);

% Unique intensities
uniqueIntensities = unique([theData.paintIntensities(:) ; theData.shadowIntensities(:)]);

% Get best unit responses.
bestPerformanceUnitPaintResponses = theData.paintResponses(:,bestUnit);
bestPerformanceUnitShadowResponses = theData.shadowResponses(:,bestUnit);

% Find mean and std for each intensity/[paint/shadow] combination
for dc = 1:length(uniqueIntensities)
    theIntensity = uniqueIntensities(dc);
    paintIndex = find(theData.paintIntensities == theIntensity);
    shadowIndex = find(theData.shadowIntensities == theIntensity);
    meanBestPerformancePaintResponses(dc) = mean(bestPerformanceUnitPaintResponses(paintIndex),1);
    meanBestPerformanceShadowResponses(dc) = mean(bestPerformanceUnitShadowResponses(shadowIndex),1);
    stdBestPerformancePaintResponses(dc) = std(bestPerformanceUnitPaintResponses(paintIndex),[],1);
    stdBestPerformanceShadowResponses(dc) = std(bestPerformanceUnitShadowResponses(shadowIndex),[],1);
end

% Find performance for more and more of best-like units
nPaintStimuli = size(theData.paintResponses,1);
nShadowStimuli = size(theData.shadowResponses,1);
decodeInfo.thePerformance = zeros(length(nUnitsToUseList),1);
decodeInfo.theUnits = zeros(length(nUnitsToUseList),1);
for uu = 1:length(nUnitsToUseList)
    nBestSynthesizedUnitsToUse = nUnitsToUseList(uu);
    
    % Create a synthesized dataset
    synthesizedPaintData = zeros(nPaintStimuli,nBestSynthesizedUnitsToUse);
    synthesizedShadowData = zeros(nShadowStimuli,nBestSynthesizedUnitsToUse);
    for ii = 1:nPaintStimuli
        theIntensity = theData.paintIntensities(ii);
        onePerformanceIndex = find(uniqueIntensities == theIntensity);
        for jj = 1:nBestSynthesizedUnitsToUse
            synthesizedPaintData(ii,jj) = normrnd(meanBestPerformancePaintResponses(onePerformanceIndex),stdBestPerformancePaintResponses(onePerformanceIndex));
        end
    end
    for ii = 1:nShadowStimuli
        theIntensity = theData.shadowIntensities(ii);
        onePerformanceIndex = find(uniqueIntensities == theIntensity);
        for jj = 1:nBestSynthesizedUnitsToUse
            synthesizedShadowData(ii,jj) = normrnd(meanBestPerformanceShadowResponses(onePerformanceIndex),stdBestPerformanceShadowResponses(onePerformanceIndex));
        end
    end
    
    % Get performance for this many units
    [~,~,paintPreds,shadowPreds,decodeInfoOutTemp] = PaintShadowClassify(decodeInfo, ...
        theData.paintIntensities,synthesizedPaintData,theData.shadowIntensities,synthesizedShadowData);
    paintClassifyNCorrect = length(find(paintPreds == decodeInfoOutTemp.paintLabel));
    shadowClassifyNCorrect = length(find(shadowPreds == decodeInfoOutTemp.shadowLabel));
    decodeInfo.thePerformance(uu) = (paintClassifyNCorrect+shadowClassifyNCorrect)/(length(paintPreds)+length(shadowPreds));
    decodeInfo.theUnits(uu) = nBestSynthesizedUnitsToUse;
end

% Fit an exponential through the best like unit rmse versus number of units.
a0 = max(decodeInfo.thePerformance); b0 = 10; c0 = max(decodeInfo.thePerformance);
ftype = fittype('a-(a-c)*exp(-(x-1)/(b-1)) + c');
foptions = fitoptions('Method','NonLinearLeastSquares','StartPoint',[a0 b0 c0],'Lower',[0 2 0],'Upper',[5 200 5]);
decodeInfo.Performance = c0;
index = find(decodeInfo.theUnits <= decodeInfo.nFitMaxUnits);
decodeInfo.fit = fit(decodeInfo.theUnits(index),decodeInfo.thePerformance(index),ftype,foptions);
decodeInfo.fitScale = decodeInfo.fit.b;
decodeInfo.fitAsymp = decodeInfo.fit.c;

end


