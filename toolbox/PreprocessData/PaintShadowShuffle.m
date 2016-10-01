function [paintIntensities,paintResponses,shadowIntensities,shadowResponses,decodeInfo] = PaintShadowShuffle(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
% [paintIntensities,paintResponses,shadowIntensities,shadowResponses,decodeInfo] = PaintShadowShuffle(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
%
% Implement trial and paint/shadow shuffling.
%
% 4/1/13  dhb  This was in PaintShadowDecode but neeeds to be one level up so that analyis on decoded shuffled data
%              gets handled right.
% 4/22/14 dhb  Returne decodeInfo for calling consistency across functions.


%% Parameter extraction
numPaint = length(paintIntensities);
numShadow = length(shadowIntensities);

%% Shuffle responses across trials.
%
% Can do this within intensity or across all trials.  Operates
% on paint/shadow data separately.
%
% This shuffling breaks relationship between intensity and response and
% may be used to examine information in correlations across
% responses or information carried when intensity/response
% relation is removed within paint and shadow separately.
switch (decodeInfo.trialShuffleType)
    case {'intshf'}
        % Shuffling within trials of the same intensity checks for whether
        % the correlation structure of the responses has an effect.
        %
        % The code here shuffles for both paint and shadow in all cases, since
        % the shuffle on responses that we don't use for decoding does not hurt
        % anything and this way saves writing the same code multiple times.
        uniqueIntensities = unique(paintIntensities);
        for i = 1:length(uniqueIntensities)
            index = find(paintIntensities == uniqueIntensities(i));
            for j = 1:size(paintResponses,2);
                shuffleIndex = Shuffle(index);
                paintResponsesTemp(index,j) = paintResponses(shuffleIndex,j);
            end
        end
        if (~isempty(paintResponses))
            paintResponses = paintResponsesTemp;
        end
        
        uniqueIntensities = unique(shadowIntensities);
        for i = 1:length(uniqueIntensities)
            index = find(shadowIntensities == uniqueIntensities(i));
            for j = 1:size(shadowResponses,2);
                shuffleIndex = Shuffle(index);
                shadowResponsesTemp(index,j) = shadowResponses(shuffleIndex,j);
            end
        end
        if (~isempty(shadowResponses))
            shadowResponses = shadowResponsesTemp;
        end
        
    case {'alltshf'}
        % Shuffling across all trials provides a control that our code isn't
        % doing anything magic - intensity decoding should be very bad under
        % this condition.
        %
        % The code here shuffles for both paint and shadow in all cases, since
        % the shuffle on responses that we don't use for decoding does not hurt
        % anything and this way saves writing the same code multiple times.
        index = Shuffle(1:numPaint);
        paintResponses = paintResponses(index,:);
        
        index = Shuffle(1:numShadow);
        shadowResponses = shadowResponses(index,:);
end

%% Shuffle paint and shadow
switch (decodeInfo.paintShadowShuffleType)
    case {'psshf'}
        % Shuffle paint and shadow trials together and artificially separate again.
        % This preserves the intensity response relationship but destroys the paint
        % shadow structure.
        %
        % We shuffle up paint and shadow trials here, and then unshuffle at the end
        % so that the relationship to the input data is preserved for the calling routine.
        numTotal = numPaint+numShadow;
        totalIntensities = [paintIntensities ; shadowIntensities];
        totalResponses = [paintResponses ; shadowResponses];
        
        paintshadowshuffleindex = Shuffle(1:numTotal);
        totalIntensities = totalIntensities(paintshadowshuffleindex);
        totalResponses = totalResponses(paintshadowshuffleindex,:);
        
        paintIntensities = totalIntensities(1:numPaint);
        paintResponses = totalResponses(1:numPaint,:);
        shadowIntensities = totalIntensities(numPaint+1:end);
        shadowResponses = totalResponses(numPaint+1:end,:);
        if (length(shadowIntensities) ~= numShadow)
            error('Logic error in code');
        end
        clear numTotal totalIntensities totalResponses
end


