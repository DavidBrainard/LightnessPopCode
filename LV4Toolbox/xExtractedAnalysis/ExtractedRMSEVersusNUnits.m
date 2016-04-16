function decodeInfo = ExtractedRMSEVersusNUnits(decodeInfo,theData)
% decodeInfo = ExtractedRMSEVersusNUnits(decodeInfo,theData)
%
% Study decoding performance as a function of the number of units.
%
% NOTES:
%   One could think about how often to shuffle the data, when the data are
%   being shuffled.
%
% 3/29/16  dhb  Pulled this out.

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
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
decodeInfoOut = DoBasicDecoding(decodeInfoTemp,theData);
decodeInfoOut = EstimateNoiseCorrelations(decodeInfoOut,theData);
decodeInfoRMSEVersusNUnits.basicAnalysis = decodeInfoOut;

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
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.trialShuffleType = 'intshf';
decodeInfoTemp.paintShadowShuffleType = 'none';
decodeInfoOut = DoBasicDecoding(decodeInfoTemp,theData);
decodeInfoOut = EstimateNoiseCorrelations(decodeInfoOut,theData);
decodeInfoRMSEVersusNUnits.shuffledAnalysis = decodeInfoOut;

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
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
decodeInfoOut= DoBestUnitDecoding(decodeInfoTemp,theData,decodeInfoRMSEVersusNUnits.basicAnalysis.bestOneRMSEUnit);
decodeInfoRMSEVersusNUnits.bestAnalysis = decodeInfoOut;

%% PLOT: RMSE versus number of units used to decode
%
% First panel is basic analysis
smoothX = (1:decodeInfo.nFitMaxUnits)';
rmseVersusNUnitsfig = figure; clf;
set(gcf,'Position',[100 100 1600 1000]);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(1,2,1); hold on;

% The fit lines underneath everything else
h = plot(smoothX,decodeInfoRMSEVersusNUnits.basicAnalysis.fit(smoothX),'k:','LineWidth',decodeInfo.lineWidth-2);
h = plot(smoothX,decodeInfoRMSEVersusNUnits.bestAnalysis.fit(smoothX),'b:','LineWidth',decodeInfo.lineWidth-2);

% The points
h = plot(decodeInfoRMSEVersusNUnits.basicAnalysis.ranUnits(:),decodeInfoRMSEVersusNUnits.basicAnalysis.ranRMSE(:),'ro','MarkerSize',4);
h = plot(1,decodeInfoRMSEVersusNUnits.basicAnalysis.bestOneRMSE,'ro','MarkerSize',8);
h = plot(2,decodeInfoRMSEVersusNUnits.basicAnalysis.bestTwoRMSE,'ro','MarkerSize',8);
h = plot(decodeInfoRMSEVersusNUnits.basicAnalysis.minUnits,decodeInfoRMSEVersusNUnits.basicAnalysis.minRMSE,'ko','MarkerFaceColor','k','MarkerSize',4);
h = plot(decodeInfoRMSEVersusNUnits.bestAnalysis.theUnits,decodeInfoRMSEVersusNUnits.bestAnalysis.theRMSE,'bo','MarkerFaceColor','b','MarkerSize',4);
    
% Best unit analsyis
h = plot(decodeInfoRMSEVersusNUnits.basicAnalysis.fitScale,...
    decodeInfoRMSEVersusNUnits.basicAnalysis.fit(decodeInfoRMSEVersusNUnits.basicAnalysis.fitScale),...
    'ko','MarkerFaceColor','k','MarkerSize',8);
h = plot(decodeInfoRMSEVersusNUnits.bestAnalysis.fitScale,...
    decodeInfoRMSEVersusNUnits.bestAnalysis.fit(decodeInfoRMSEVersusNUnits.bestAnalysis.fitScale),...
    'bo','MarkerFaceColor','b','MarkerSize',8);

% Labels, scale, etc
xlabel('Number of Units Used in Decoding','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,0.5]);
axis square

% Second panel is same plot for shuffled analysis
subplot(1,2,2); hold on;
h = plot(smoothX,decodeInfoRMSEVersusNUnits.shuffledAnalysis.fit(smoothX),'k:','LineWidth',decodeInfo.lineWidth-2);
h = plot(smoothX,decodeInfoRMSEVersusNUnits.bestAnalysis.fit(smoothX),'b:','LineWidth',decodeInfo.lineWidth-2);

% The points
h = plot(decodeInfoRMSEVersusNUnits.shuffledAnalysis.ranUnits(:),decodeInfoRMSEVersusNUnits.shuffledAnalysis.ranRMSE(:),'ro','MarkerSize',4);
h = plot(1,decodeInfoRMSEVersusNUnits.shuffledAnalysis.bestOneRMSE,'ro','MarkerSize',8);
h = plot(2,decodeInfoRMSEVersusNUnits.shuffledAnalysis.bestTwoRMSE,'ro','MarkerSize',8);
h = plot(decodeInfoRMSEVersusNUnits.shuffledAnalysis.minUnits,decodeInfoRMSEVersusNUnits.shuffledAnalysis.minRMSE,'ko','MarkerFaceColor','k','MarkerSize',4);
h = plot(decodeInfoRMSEVersusNUnits.bestAnalysis.theUnits,decodeInfoRMSEVersusNUnits.bestAnalysis.theRMSE,'bo','MarkerFaceColor','b','MarkerSize',4);
    
% Best unit analysis
h = plot(decodeInfoRMSEVersusNUnits.shuffledAnalysis.fitScale,...
    decodeInfoRMSEVersusNUnits.shuffledAnalysis.fit(decodeInfoRMSEVersusNUnits.shuffledAnalysis.fitScale),...
    'ko','MarkerFaceColor','k','MarkerSize',8);
h = plot(decodeInfoRMSEVersusNUnits.bestAnalysis.fitScale,...
    decodeInfoRMSEVersusNUnits.bestAnalysis.fit(decodeInfoRMSEVersusNUnits.bestAnalysis.fitScale),...
    'bo','MarkerFaceColor','b','MarkerSize',8);

% Labels, scale, etc
xlabel('Number of Units Used in Decoding','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance RMSE (Shuffled)','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,0.5]);
axis square

% Write the figure
figName = [decodeInfo.figNameRoot '_extRmseVersusNUnits'];
drawnow;
FigureSave(figName,rmseVersusNUnitsfig,decodeInfo.figType);

%% Store the data for return
decodeInfo.decodeInfoRMSEVersusNUnits = decodeInfoRMSEVersusNUnits;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extRMSEVersusNUnits'),'decodeInfoRMSEVersusNUnits','-v7.3');

end

%% decodeInfo = DoBasicDecoding(decodeInfo,theData)
function decodeInfo = DoBasicDecoding(decodeInfo,theData)
%
% Do the decoding for various choices of the number of units.
% This is set up so that the same code can do the shuffled and unshuffled
% versions, using the same control logic.

%% Get info about what to do
nUnitsToUseList = unique([1 2 round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy))]);
uniqueNUnitsToStudy = length(nUnitsToUseList);

%% Get RMSE for all choices of one unit
%
% Keep track of how well each decodes.

% Optional data shuffle, controlled by decodeInfo
if (decodeInfo.verbose)
    fprintf('\tRMSE for all choices of one unit\n');
end
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
for jj = 1:decodeInfo.nUnits
    useUnits = jj;
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfo, ...
        paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
    decodeInfo.oneRMSE(jj) = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[paintPreds(:) ; shadowPreds(:)]).^2));
    decodeInfo.oneUnits(jj) = useUnits;
end
[decodeInfo.bestOneRMSE] = min(decodeInfo.oneRMSE);
[~,oneRMSEIndex] = sort(decodeInfo.oneRMSE(:),1,'ascend');
decodeInfo.bestOneRMSEUnit = decodeInfo.oneUnits(oneRMSEIndex(1));
if (decodeInfo.oneRMSE(oneRMSEIndex(1)) ~= decodeInfo.bestOneRMSE)
    error('Inconsistency between sort and min');
end

%% Get RMSE for all choices of two units
if (decodeInfo.verbose)
    fprintf('\tRMSE for all choices of two units\n');
end
decodeInfo.orderedUnits = zeros(uniqueNUnitsToStudy ,1);
decodeInfo.orderedRMSE = zeros(uniqueNUnitsToStudy,1);
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
decodeInfo.bestTwoRMSE = Inf;
for uu1 = 1:decodeInfo.nUnits
    if (decodeInfo.verbose)
        fprintf('\t\tFirst unit %d\n',uu1);
    end
    for uu2 = (uu1+1):decodeInfo.nUnits
        useUnits = [uu1 uu2];
        [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfo, ...
            paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
        tmpRMSE = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[paintPreds(:) ; shadowPreds(:)]).^2));
        if (tmpRMSE < decodeInfo.bestTwoRMSE)
            decodeInfo.bestTwoRMSE = tmpRMSE;
        end
    end
end

%% Get RMSE as a function of number of units
%
% When we add them in according to how well they do one at a time
if (decodeInfo.verbose)
    fprintf('\tRMSE for adding in units in order\n');
end
decodeInfo.orderedUnits = zeros(uniqueNUnitsToStudy ,1);
decodeInfo.orderedRMSE = zeros(uniqueNUnitsToStudy,1);
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
for uu = 1:length(nUnitsToUseList)
    nUnitsToUse = nUnitsToUseList(uu);
    useUnits = oneRMSEIndex(1:nUnitsToUse);
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfo, ...
        paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
    decodeInfo.orderedRMSE(uu) = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[paintPreds(:) ; shadowPreds(:)]).^2));
    decodeInfo.orderedUnits(uu) = nUnitsToUse;
end

%% Get RMSE as a function of number of units
%
% Random draws of units
decodeInfo.ranRMSE = zeros(uniqueNUnitsToStudy,decodeInfo.nRepeatsPerNUnits);
decodeInfo.ranUnits = zeros(uniqueNUnitsToStudy,decodeInfo.nRepeatsPerNUnits);
decodeInfo.minRanUnits = zeros(uniqueNUnitsToStudy ,1);
decodeInfo.minRanRMSE = zeros(uniqueNUnitsToStudy,1);
for uu = 1:length(nUnitsToUseList)
    nUnitsToUse = nUnitsToUseList(uu);
    if (decodeInfo.verbose)
        fprintf('\tRMSE for %d random units\n',nUnitsToUse);
    end
    [paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
        PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
    for jj = 1:decodeInfo.nRepeatsPerNUnits
        shuffledUnits = Shuffle(1:decodeInfo.nUnits);
        useUnits = shuffledUnits(1:nUnitsToUse);
        [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfo, ...
            paintIntensities,paintResponses(:,useUnits),shadowIntensities,shadowResponses(:,useUnits));
        decodeInfo.ranRMSE(uu,jj) = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[paintPreds(:) ; shadowPreds(:)]).^2));
        decodeInfo.ranUnits(uu,jj) = nUnitsToUse;
    end
    decodeInfo.minRanUnits(uu) = nUnitsToUse;
    decodeInfo.minRanRMSE(uu) = min(decodeInfo.ranRMSE(uu,:));
end

%% Combine the ways we try decoding with a particular number of units
%
% And take the minimum.
if (strcmp(decodeInfo.trialShuffleType,'none') & strcmp(decodeInfo.paintShadowShuffleType,'none'))
    if (any(decodeInfo.minRanUnits(:) ~= decodeInfo.orderedUnits(:)))
        error('This should not happen in the no shuffle case');
    end
end
 decodeInfo.minUnits = decodeInfo.minRanUnits;
 decodeInfo.minRMSE = min([decodeInfo.minRanRMSE(:) decodeInfo.orderedRMSE(:)],[],2);
 
% And also deal with the fact that we found the best decoding for two at a
% time, so slip this into the minimum.
index = find(decodeInfo.minUnits == 2);
if (strcmp(decodeInfo.trialShuffleType,'none') & strcmp(decodeInfo.paintShadowShuffleType,'none'))
    if (decodeInfo.bestTwoRMSE > decodeInfo.minRMSE(index))
        % This should not happen, but sometimes does.  My current theory is
        % that the SVM classifier may behave differently given [a,b] as
        % dimensions than when given [b,a].  When we use K-fold cross-validation,
        % this might also occur.
        %
        % Because it happens rarely and is hard to debug on the cluster,
        % this code now saves out the workspace when this occurs, for
        % looking at later.
        % error('Oops.  Best decode two at a time not the best in the no shuffle case.');
        save(fullfile(decodeInfo.writeDataDir,'extRMSEBUGBESTTWOUNITSCODE'),'-v7.3');
    end
end
decodeInfo.minRMSE(index) = decodeInfo.bestTwoRMSE;
 
%% Fit an exponential through the lower envelope of the RMSE versus units
a0 = max(decodeInfo.minRMSE); b0 = 10; c0 = min(decodeInfo.minRMSE);
decodeInfo.RMSE = c0;
index = find(decodeInfo.minUnits <= decodeInfo.nFitMaxUnits);
decodeInfo.fit = fit(decodeInfo.minUnits(index),decodeInfo.minRMSE(index),'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.fitScale = decodeInfo.fit.b;
decodeInfo.fitAsymp = decodeInfo.fit.c;

end

%% decodeInfo = DoBestUnitDecoding(decodeInfo,theData,bestUnit)
function decodeInfo = DoBestUnitDecoding(decodeInfo,theData,bestUnit)
%
% Do the decoding based on the idea that all units are independent
% draws from trials for the best unit.

% Figure out N to run for
nUnitsToUseList = unique([1 2 round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy))]);
uniqueNUnitsToStudy = length(nUnitsToUseList);

% Unique intensities
uniqueIntensities = unique([theData.paintIntensities(:) ; theData.shadowIntensities(:)]);

% Get best unit responses.
bestRMSEUnitPaintResponses = theData.paintResponses(:,bestUnit);
bestRMSEUnitShadowResponses = theData.shadowResponses(:,bestUnit);

% Find mean and std for each intensity/[paint/shadow] combination
for dc = 1:length(uniqueIntensities)
    theIntensity = uniqueIntensities(dc);
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
decodeInfo.theRMSE = zeros(length(nUnitsToUseList),1);
decodeInfo.theUnits = zeros(length(nUnitsToUseList),1);
for uu = 1:length(nUnitsToUseList)
    nBestSynthesizedUnitsToUse = nUnitsToUseList(uu);
    
    % Create a synthesized dataset
    synthesizedPaintData = zeros(nPaintStimuli,nBestSynthesizedUnitsToUse);
    synthesizedShadowData = zeros(nShadowStimuli,nBestSynthesizedUnitsToUse);
    for ii = 1:nPaintStimuli
        theIntensity = theData.paintIntensities(ii);
        oneLOORMSEIndex = find(uniqueIntensities == theIntensity);
        for jj = 1:nBestSynthesizedUnitsToUse
            synthesizedPaintData(ii,jj) = normrnd(meanBestRMSEPaintResponses(oneLOORMSEIndex),stdBestRMSEPaintResponses(oneLOORMSEIndex));
        end
    end
    for ii = 1:nShadowStimuli
        theIntensity = theData.shadowIntensities(ii);
        oneLOORMSEIndex = find(uniqueIntensities == theIntensity);
        for jj = 1:nBestSynthesizedUnitsToUse
            synthesizedShadowData(ii,jj) = normrnd(meanBestRMSEShadowResponses(oneLOORMSEIndex),stdBestRMSEShadowResponses(oneLOORMSEIndex));
        end
    end
    
    % Get performance for this many units
    [~,~,paintPredsLOO,shadowPredsLOO] = PaintShadowDecode(decodeInfo, ...
        theData.paintIntensities,synthesizedPaintData,theData.shadowIntensities,synthesizedShadowData);
    decodeInfo.theRMSE(uu) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPredsLOO(:) ; shadowPredsLOO(:)]).^2));
    decodeInfo.theUnits(uu) = nBestSynthesizedUnitsToUse;
end

% Fit an exponential through the best like unit rmse versus number of
% units.
a0 = max(decodeInfo.theRMSE); b0 = 10; c0 = min(decodeInfo.theRMSE);
decodeInfo.bestSynthesizedRMSE = c0;
index = find(decodeInfo.theUnits <= decodeInfo.nFitMaxUnits);
decodeInfo.rmse = c0;
decodeInfo.fit = fit(decodeInfo.theUnits(index),decodeInfo.theRMSE(index),'a*exp(-(x-1)/(b-1)) + c','StartPoint',[a0 b0 c0]);
decodeInfo.fitScale = decodeInfo.fit.b;
decodeInfo.fitAsymp = decodeInfo.fit.c;

end


%% decodeInfo = EstimateNoiseCorrelations(decodeInfo,theData)
function decodeInfo = EstimateNoiseCorrelations(decodeInfo,theData)
%
% Estimate noise correlations across units

%% Optional shuffle, should destroy (mostly) any noise correlations
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% Unique intensities
uniqueIntensities = unique([paintIntensities(:) ; shadowIntensities(:)]);

%% Get residual response for each intensity/[paint/shadow]/unit combination
residualPaintResponses = zeros(size(paintResponses));
residualShadowResponses = zeros(size(shadowResponses));
for uu = 1:decodeInfo.nUnits   
    for dc = 1:length(uniqueIntensities)
        theIntensity = uniqueIntensities(dc);
        paintIndex = find(theData.paintIntensities == theIntensity);
        shadowIndex = find(theData.shadowIntensities == theIntensity);
        meanPaintResponses(uu,dc) = mean(paintResponses(paintIndex,uu),1);
        meanShadowResponses(uu,dc) = mean(shadowResponses(shadowIndex,uu),1);
        residualPaintResponses(paintIndex,uu) = paintResponses(paintIndex,uu)-meanPaintResponses(uu,dc);
        residualShadowResponses(shadowIndex,uu) = shadowResponses(shadowIndex,uu)-meanShadowResponses(uu,dc);
    end 
end

%% Compute correlations
paintCorrMatrix = corrcoef(residualPaintResponses);
shadowCorrMatrix = corrcoef(residualShadowResponses);
paintCorrTri = triu(paintCorrMatrix);
shadowCorrTri = triu(shadowCorrMatrix);
decodeInfo.paintNoiseCorr = mean(paintCorrTri(:));
decodeInfo.shadowNoiseCorr = mean(shadowCorrTri(:));
decodeInfo.noiseCorr = mean([decodeInfo.paintNoiseCorr decodeInfo.shadowNoiseCorr]);

end
