% DoDataVisAnalysis
%
% Part of this is trying to look at the data in low dimensions, 
% toactually visualize what is happening.  But other things
% have gotten tacked on over time.
%
% 12/19/15  dhb  Pulled this out of RunAndPlotLightnessDecode.

%% First step, project onto best decoding direction, w/o the
% affine term.  Just because I like to check things, do
% regression from scratch here.
decodeVis.nDecodeDirs = 5;
decodeVis.paintIntensities = paintIntensities;
decodeVis.shadowIntensities = shadowIntensities;
decodeVis.decodeIntensities = [decodeVis.paintIntensities ; decodeVis.shadowIntensities];
decodeVis.uniqueIntensities = sort(unique(decodeVis.paintIntensities));
decodeVis.meanIntensity = mean(decodeVis.decodeIntensities);
decodeVis.paintResponses = paintResponses;
decodeVis.shadowResponses = shadowResponses;
decodeVis.responses = [decodeVis.paintResponses ; decodeVis.shadowResponses];
decodeVis.nPaintTrials = size(decodeVis.paintResponses,1);
decodeVis.nShadowTrials = size(decodeVis.shadowResponses,1);
decodeVis.nTrials = size(decodeVis.responses,1);
decodeVis.nUnits = size(decodeVis.responses,2);

decodeVis.meanResponse = mean(decodeVis.responses,1);
decodeVis.meanSubtractPaintResponses{1} = decodeVis.paintResponses - decodeVis.meanResponse(ones(1,decodeVis.nPaintTrials),:);
decodeVis.meanSubtractShadowResponses{1} = decodeVis.shadowResponses - decodeVis.meanResponse(ones(1,decodeVis.nShadowTrials),:);
decodeVis.meanSubtractResponses{1} = [decodeVis.meanSubtractPaintResponses{1} ; decodeVis.meanSubtractShadowResponses{1}];

%% Make sure we get same as when we did it way back where.
%
% This check only makes sense if the offset here matches that used in the
% main decoding.
decodeVis.affineDirection = ([decodeVis.responses ones(decodeVis.nTrials,1)])\decodeVis.decodeIntensities;
decodeVis.affinePrediction = [decodeVis.responses ones(decodeVis.nTrials,1)]*decodeVis.affineDirection;
if (decodeInfoIn.decodeOffset == 0  && strcmp(decodeInfoIn.decodeJoint,'both'))
    if (max(abs(decodeVis.affineDirection(1:end-1) - decodeInfoIn.electrodeWeights)) ~= 0)
        error('Didn''t manage to do affine regression the same way twice');
    end
end

% Do regression the mean subtracted way
decodeVis.decodeDirection{1} = decodeVis.meanSubtractResponses{1}\(decodeVis.decodeIntensities-decodeVis.meanIntensity);
decodeVis.decodePrediction{1} = (decodeVis.meanSubtractResponses{1}*decodeVis.decodeDirection{1}) + decodeVis.meanIntensity;
if (max(abs(decodeVis.affinePrediction-decodeVis.decodePrediction{1})) > 1e-10);
    error('Two ways of doing regression don''t match up');
end
decodeVis.paintPrediction{1} = decodeVis.meanSubtractPaintResponses{1}*decodeVis.decodeDirection{1} + decodeVis.meanIntensity;
decodeVis.shadowPrediction{1} = decodeVis.meanSubtractShadowResponses{1}*decodeVis.decodeDirection{1} + decodeVis.meanIntensity;
decodeVis.decodeRange(1) = max(decodeVis.decodePrediction{1})-min(decodeVis.decodePrediction{1});
decodeVis.decodeRMSE(1) = sqrt(sum((decodeVis.decodeIntensities-decodeVis.decodePrediction{1}).^2)/length(decodeVis.decodeIntensities));
[tempPaintMeans,~,~,~,~,tempPaintIntensities] = sortbyx(decodeVis.paintIntensities,decodeVis.paintPrediction{1});
[tempShadowMeans,~,~,~,~,tempShadowIntensities] = sortbyx(decodeVis.shadowIntensities,decodeVis.shadowPrediction{1});
decodeVis.paintPredictMeans(1) = 0; decodeVis.shadowPredictMeans(1) = 0;
tempNPaint = 0; tempNShadow = 0;
for i = 1:length(tempPaintIntensities)
    if (any(tempPaintIntensities(i) == decodeInfoIn.inferIntensityLevelsDiscrete))
        decodeVis.paintPredictMeans(1) = decodeVis.paintPredictMeans(1) + tempPaintMeans(i);
        tempNPaint = tempNPaint + 1;
    end
end
for i = 1:length(tempShadowIntensities)
    if (any(tempShadowIntensities(i) == decodeInfoIn.inferIntensityLevelsDiscrete))
        decodeVis.shadowPredictMeans(1) = decodeVis.shadowPredictMeans(1) + tempShadowMeans(i);
        tempNShadow = tempNShadow + 1;
    end
end
decodeVis.paintPredictMeans(1) = decodeVis.paintPredictMeans(1)/tempNPaint;
decodeVis.shadowPredictMeans(1) = decodeVis.shadowPredictMeans(1)/tempNShadow;
decodeVis.paintLessShadow(1) = decodeVis.paintPredictMeans(1)-decodeVis.shadowPredictMeans(1);

%% Find best directions for decoding paint only and shadow only, the mean subtracted way.
tempPaintMean = mean(decodeVis.paintResponses);
tempShadowMean = mean(decodeVis.shadowResponses);
tempSubtractPaintResponses = decodeVis.paintResponses - tempPaintMean(ones(1,decodeVis.nPaintTrials),:);
tempSubtractShadowResponses = decodeVis.shadowResponses - tempShadowMean(ones(1,decodeVis.nShadowTrials),:);

decodeVis.decodePaintDirection = tempSubtractPaintResponses\[decodeVis.paintIntensities-mean(decodeVis.paintIntensities)];
decodeVis.decodeShadowDirection = tempSubtractShadowResponses\[decodeVis.shadowIntensities-mean(decodeVis.shadowIntensities)];
decodeVis.decodePaintDirectonPaintPrediction = tempSubtractPaintResponses*decodeVis.decodePaintDirection + mean(decodeVis.paintIntensities);
decodeVis.decodePaintDirectonShadowPrediction = tempSubtractShadowResponses*decodeVis.decodePaintDirection + mean(decodeVis.shadowIntensities);
decodeVis.decodeShadowDirectonPaintPrediction = tempSubtractPaintResponses*decodeVis.decodeShadowDirection + mean(decodeVis.paintIntensities);
decodeVis.decodeShadowDirectonShadowPrediction = tempSubtractShadowResponses*decodeVis.decodeShadowDirection + mean(decodeVis.shadowIntensities);
decodeVis.paintShadowDecodeAngle = (180/pi)*subspace(decodeVis.decodePaintDirection,decodeVis.decodeShadowDirection);

%% Now loop and do the decoding on progressive orthogonal subspaces
%
% The printout of p/s effect will be wrong if we use an affine fit to the
% inferred matches.
fprintf('\tIterating decoding on orthogonal subspaces\n');
fprintf('\t\tDecode dim 1: range %0.2f, RMSE %0.2f, p/s intercept effect = %0.2f, p/s mean diff orig = %0.2f, p/s mean diff = %0.2f\n',...
    decodeVis.decodeRange(1),decodeVis.decodeRMSE(1),paintShadowMb(1),paintShadowDecodeMeanDifferenceDiscrete,decodeVis.paintLessShadow(1));
for s = 2:decodeVis.nDecodeDirs
    % Project responses down
    decodeVis.ignoreDecodeBasis{s-1} = null(decodeVis.decodeDirection{s-1}')';
    decodeVis.meanSubtractPaintResponses{s} = (decodeVis.ignoreDecodeBasis{s-1}*decodeVis.meanSubtractPaintResponses{s-1}')';
    decodeVis.meanSubtractShadowResponses{s} = (decodeVis.ignoreDecodeBasis{s-1}*decodeVis.meanSubtractShadowResponses{s-1}')';
    decodeVis.meanSubtractResponses{s} = [decodeVis.meanSubtractPaintResponses{s} ; decodeVis.meanSubtractShadowResponses{s}];
    
    % Decode based on the projected responses, and find that direction.
    decodeVis.decodeDirection{s} = decodeVis.meanSubtractResponses{s}\(decodeVis.decodeIntensities-decodeVis.meanIntensity);
    decodeVis.decodePrediction{s} = (decodeVis.meanSubtractResponses{s}*decodeVis.decodeDirection{s}) + decodeVis.meanIntensity;
    decodeVis.paintPrediction{s} = (decodeVis.meanSubtractPaintResponses{s}*decodeVis.decodeDirection{s}) + decodeVis.meanIntensity;
    decodeVis.shadowPrediction{s} = (decodeVis.meanSubtractShadowResponses{s}*decodeVis.decodeDirection{s}) + decodeVis.meanIntensity;
    decodeVis.decodeRange(s) = max(decodeVis.decodePrediction{s})-min(decodeVis.decodePrediction{s});
    decodeVis.decodeRMSE(s) = sqrt(sum((decodeVis.decodeIntensities-decodeVis.decodePrediction{s}).^2)/length(decodeVis.decodeIntensities));
    decodeVis.paintPredictMeans(s) = mean(sortbyx(decodeVis.paintIntensities,decodeVis.paintPrediction{s}));
    [tempPaintMeans,~,~,~,~,tempPaintIntensities] = sortbyx(decodeVis.paintIntensities,decodeVis.paintPrediction{s});
    [tempShadowMeans,~,~,~,~,tempShadowIntensities] = sortbyx(decodeVis.shadowIntensities,decodeVis.shadowPrediction{s});
    decodeVis.paintPredictMeans(s) = 0; decodeVis.shadowPredictMeans(s) = 0;
    tempNPaint = 0; tempNShadow = 0;
    for i = 1:length(tempPaintIntensities)
        if (any(tempPaintIntensities(i) == decodeInfoIn.inferIntensityLevelsDiscrete))
            decodeVis.paintPredictMeans(s) = decodeVis.paintPredictMeans(s) + tempPaintMeans(i);
            tempNPaint = tempNPaint + 1;
        end
    end
    for i = 1:length(tempShadowIntensities)
        if (any(tempShadowIntensities(i) == decodeInfoIn.inferIntensityLevelsDiscrete))
            decodeVis.shadowPredictMeans(s) = decodeVis.shadowPredictMeans(s) + tempShadowMeans(i);
            tempNShadow = tempNShadow + 1;
        end
    end
    decodeVis.paintPredictMeans(s) = decodeVis.paintPredictMeans(s)/tempNPaint;
    decodeVis.shadowPredictMeans(s) = decodeVis.shadowPredictMeans(s)/tempNShadow;
    decodeVis.paintLessShadow(s) = decodeVis.paintPredictMeans(s)-decodeVis.shadowPredictMeans(s);
    fprintf('\t\tDecode dim %d: range %0.2f, RMSE %0.2f, p/s intercept effect = %0.2f, p/s mean diff orig = %0.2f, p/s mean diff = %0.2f\n',s,...
        decodeVis.decodeRange(s),decodeVis.decodeRMSE(s),paintShadowMb(1),paintShadowDecodeMeanDifferenceDiscrete,decodeVis.paintLessShadow(s));
    
    % This is a quick and dirty figure that shows the decoding on
    % subsequent dimensions versus decoding on the first.  The RMSE
    % summary figure below is probably what we want to look at for this.
    %
    % tempFig = figure; clf;
    % hold on
    % plot(decodeVis.paintPrediction{1},decodeVis.paintPrediction{s},'go');
    % plot(decodeVis.shadowPrediction{1},decodeVis.shadowPrediction{s},'ko');
    % hold off
    % pause
    % close(tempFig);
end

%% Look at how decoded paint shadow effect depends on an offset applied to the regression.
decodeVis.decodeOffsets = [.1 .09 .08 .07 .06 .05 .04 .03 .02 .01 0 -.01 -.02 -.03 -.04 -.05 -.06 -.07 -.08 -0.09 -.1];
clear temp
for o = 1:length(decodeVis.decodeOffsets)
    % Adjust intensities to try to get a paint/shadow effect
    temp.decodeOffset = decodeVis.decodeOffsets(o);
    temp.decodeIntensities = [decodeVis.paintIntensities ; decodeVis.shadowIntensities - temp.decodeOffset];
    temp.meanIntensity = mean(temp.decodeIntensities);
    
    % Decode based on previously obtained spaces (full and then projected
    % out one by one).
    for s = 1:decodeVis.nDecodeDirs
        decodeVis.offsetDecodeDirection{s}{o} = decodeVis.meanSubtractResponses{s}\(temp.decodeIntensities-temp.meanIntensity);
        decodeVis.offsetDecodePrediction{s}{o} = (decodeVis.meanSubtractResponses{s}*decodeVis.offsetDecodeDirection{s}{o}) + temp.meanIntensity;
        decodeVis.offsetPaintPrediction{s}{o} = (decodeVis.meanSubtractPaintResponses{s}*decodeVis.offsetDecodeDirection{s}{o}) + temp.meanIntensity;
        decodeVis.offsetShadowPrediction{s}{o} = (decodeVis.meanSubtractShadowResponses{s}*decodeVis.offsetDecodeDirection{s}{o}) + temp.meanIntensity;
        decodeVis.offsetRange(s,o) = max(decodeVis.offsetDecodePrediction{s}{o})-min(decodeVis.offsetDecodePrediction{s}{o});
        decodeVis.offsetRMSE(s,o) = sqrt(sum((temp.decodeIntensities-decodeVis.offsetDecodePrediction{s}{o}).^2)/length(temp.decodeIntensities));
        [tempPaintMeans,~,~,~,~,tempPaintIntensities] = sortbyx(decodeVis.paintIntensities,decodeVis.offsetPaintPrediction{s}{o});
        [tempShadowMeans,~,~,~,~,tempShadowIntensities] = sortbyx(decodeVis.shadowIntensities,decodeVis.offsetShadowPrediction{s}{o});
        decodeVis.offsetPaintPredictMeans(s,o) = 0; decodeVis.offsetShadowPredictMeans(s,o) = 0;
        tempNPaint = 0; tempNShadow = 0;
        for i = 1:length(tempPaintIntensities)
            if (any(tempPaintIntensities(i) == decodeInfoIn.inferIntensityLevelsDiscrete))
                decodeVis.offsetPaintPredictMeans(s,o) = decodeVis.offsetPaintPredictMeans(s,o) + tempPaintMeans(i);
                tempNPaint = tempNPaint + 1;
            end
        end
        for i = 1:length(tempShadowIntensities)
            if (any(tempShadowIntensities(i) == decodeInfoIn.inferIntensityLevelsDiscrete))
                decodeVis.offsetShadowPredictMeans(s,o) = decodeVis.offsetShadowPredictMeans(s,o) + tempShadowMeans(i);
                tempNShadow = tempNShadow + 1;
            end
        end
        decodeVis.offsetPaintPredictMeans(s,o) = decodeVis.offsetPaintPredictMeans(s,o)/tempNPaint;
        decodeVis.offsetShadowPredictMeans(s,o) = decodeVis.offsetShadowPredictMeans(s,o)/tempNShadow;
        decodeVis.offsetPaintLessShadow(s,o) = decodeVis.offsetPaintPredictMeans(s,o)-decodeVis.offsetShadowPredictMeans(s,o);
    end
end

%% Regress recovered p/s effects versus input offset, as a possible measure of info contained in the responses
% Also get minimum RMSE, as another measure that might be of interest.
clear temp temp1
for s = 1:decodeVis.nDecodeDirs
    temp = [decodeVis.decodeOffsets' ones(size(decodeVis.decodeOffsets'))]\decodeVis.offsetPaintLessShadow(s,:)';
    decodeVis.offsetGain(s) = temp(1);
    decodeVis.offsetIntercept(s) = temp(2);
    decodeVis.offsetpspred(s,:) = [decodeVis.decodeOffsets' ones(size(decodeVis.decodeOffsets'))]*temp;
    [decodeVis.offsetMinRMSE(s),temp1] = min( decodeVis.offsetRMSE(s,:));
    decodeVis.offsetMinRMSEOffset(s) = decodeVis.decodeOffsets(temp1);
end

%% Classify on the full mean subtracted responses, and find classifier direction.
decodeVis.paintLabel = 1;
decodeVis.shadowLabel = -1;
decodeVis.classifyLabels = [decodeVis.paintLabel*ones(size(paintIntensities)) ; decodeVis.shadowLabel*ones(size(shadowIntensities))];
decodeVis.classifyResponses = decodeVis.meanSubtractResponses{1};
decodeVis.classifyInfo = fitcsvm(decodeVis.classifyResponses,decodeVis.classifyLabels,'KernelFunction','linear','Solver',decodeInfoIn.MVM_ALG);
decodeVis.classifyPredict = predict(decodeVis.classifyInfo,decodeVis.classifyResponses);
decodeVis.classifyFractionCorrect = length(find(decodeVis.classifyPredict == decodeVis.classifyLabels))/length(decodeVis.classifyLabels);
decodeVis.classifyDirection = decodeVis.classifyInfo.Beta;
decodeVis.paintInClassifyDirection = paintResponses*decodeVis.classifyDirection;
decodeVis.shadowInClassifyDirection = shadowResponses*decodeVis.classifyDirection;
decodeVis.decodeClassifyAngle = (180/pi)*subspace(decodeVis.decodeDirection{1},decodeVis.classifyDirection);

%% Classify on the mean subtracted responses orthogonal to the primary decoding direction.
decodeVis.classifyResponsesOrth = decodeVis.meanSubtractResponses{2};
decodeVis.classifyInfoOrth = fitcsvm(decodeVis.classifyResponsesOrth,decodeVis.classifyLabels,'KernelFunction','linear','Solver',decodeInfoIn.MVM_ALG);
decodeVis.classifyPredictOrth = predict(decodeVis.classifyInfoOrth,decodeVis.classifyResponsesOrth);
decodeVis.classifyFractionCorrectOrth = length(find(decodeVis.classifyPredictOrth == decodeVis.classifyLabels))/length(decodeVis.classifyLabels);
decodeVis.classifyDirectionOrth = decodeVis.classifyInfoOrth.Beta;
decodeVis.paintInClassifyDirectionOrth = decodeVis.meanSubtractPaintResponses{2}*decodeVis.classifyDirectionOrth;
decodeVis.shadowInClassifyDirectionOrth = decodeVis.meanSubtractShadowResponses{2}*decodeVis.classifyDirectionOrth;
decodeVis.meanOrthResponse = mean([ decodeVis.paintInClassifyDirectionOrth ; decodeVis.shadowInClassifyDirectionOrth]);

%% Figures
DoDataVisFigs;

%% Get rid of some really big stuff that we probably don't need
decodeVis = rmfield(decodeVis,'ignoreDecodeBasis');
decodeVis = rmfield(decodeVis,'classifyResponses');
decodeVis = rmfield(decodeVis,'classifyResponsesOrth');
decodeVis = rmfield(decodeVis,'meanSubtractPaintResponses');
decodeVis = rmfield(decodeVis,'meanSubtractShadowResponses');
decodeVis = rmfield(decodeVis,'meanSubtractResponses');
decodeVis = rmfield(decodeVis,'responses');
decodeVis = rmfield(decodeVis,'shadowResponses');
decodeVis = rmfield(decodeVis,'paintResponses');
