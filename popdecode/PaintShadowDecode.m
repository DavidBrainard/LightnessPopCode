function [paintPreds,shadowPreds,paintPredsLOO,shadowPredsLOO,decodeInfo] = PaintShadowDecode(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
% [paintPreds,shadowPreds,paintPredsLOO,shadowPredsLOO,decodeInfo] = PaintShadowDecode(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
%
% Decode based on decoding option specified in decodeInfo.decodeJoint field and predict.
% The returned variables without the LOO in their name based on the entire input data set.
%
% For some decoding options, the decoding is also done using the specified leave-one-out (LOO)
% method specified in field decodeInfo.decodeLOOType.  If you ask for a decodeLOOType other than 'no'
% for a method where LOO is not implemented, this routine will exit with an error.  If LOO
% decoding is performed, the LOO decoding is returned in the variables with LOO in their names.
%
% If LOO method is none, the LOO returned variables are set to the decoding of the full data set.
%
% For LOO analysis on paint decoding, it doesn't make sense to do LOO on the shadow data.  The
% shadow predictor for this case is just based on the entire paint input.
%
% Some information about the decoding is returned in the decodeInfo struct.  This is based on
% the full decoding.  For example, the electrode weights returned are based on the full decoding.
%
% For available decoding options, see extensive comments in function RunOneCondition.
%
% Original code provided by Marlene and Doug.
%
% 10/29/13  dhb  Clean, comment, etc.
%           dhb  Add glm option with fixed params
% 11/17/13  dhb  Return shadow preds LOO too.
% 3/16/14   dhb  Change 'contrast' to 'intensity' everywhere, because that is what we represent currently.
% 4/1/14    dhb  Pull out shuffling.
% 4/14/16   dhb  Use Matlab's cvpartition object for cross-validation.

%% Parameter extraction
numPaint = length(paintIntensities);
numShadow = length(shadowIntensities);

%% Decode and predict
switch (decodeInfo.decodeJoint)
     case {'paint'}
        % Paint trials only used to build decoder.
        decodeInfo = DoTheDecode(decodeInfo,paintIntensities,paintResponses);
        paintPreds = DoThePrediction(decodeInfo,paintResponses);
        shadowPreds = DoThePrediction(decodeInfo,shadowResponses);
        
    case {'shadow'}
        % Shadow trials only used to build decoder.
        decodeInfo = DoTheDecode(decodeInfo,shadowIntensities,shadowResponses);
        paintPreds = DoThePrediction(decodeInfo,paintResponses);
        shadowPreds = DoThePrediction(decodeInfo,shadowResponses);
        
    case {'both'} 
        % Use both paint and shadow trials to do the decoding.
        decodeInfo = DoTheDecode(decodeInfo,[paintIntensities ; shadowIntensities],[paintResponses ; shadowResponses]);
        paintPreds = DoThePrediction(decodeInfo,paintResponses);
        shadowPreds = DoThePrediction(decodeInfo,shadowResponses);
        
        % Store the electrode weights and affine term.  The switch guarantees that there are weights
        % returned in the .b field for whatever decoding method is used.
        switch (decodeInfo.type)
            case {'aff'}
                decodeInfo.electrodeWeights = decodeInfo.b(1:end-1);
                decodeInfo.affineTerms = decodeInfo.b(end)*ones(size(decodeInfo.electrodeWeights));

                % For the case of both, we want to separately get the paint
                % and shadow regression parameters, so that we can look at
                % the angle between them.
                decodeInfoPaint = DoTheDecode(decodeInfo,paintIntensities,paintResponses);
                decodeInfoShadow = DoTheDecode(decodeInfo,shadowIntensities,shadowResponses);
                decodeInfo.paintElectrodeWeights = decodeInfoPaint.b(1:end-1);
                decodeInfo.paintAffineTerms = decodeInfoPaint.b(end)*ones(size(decodeInfo.electrodeWeights));
                decodeInfo.shadowElectrodeWeights = decodeInfoShadow.b(1:end-1);
                decodeInfo.shadowAffineTerms = decodeInfoShadow.b(end)*ones(size(decodeInfo.electrodeWeights));
                cosTheta = decodeInfo.paintElectrodeWeights'*decodeInfo.shadowElectrodeWeights/...
                    (norm(decodeInfo.paintElectrodeWeights)*norm(decodeInfo.shadowElectrodeWeights));
                decodeInfo.paintShadowDecodeAngle = rad2deg(acos(cosTheta));
                   
            otherwise
        end
           
    case {'bothbestsingle'}
        % Find best single electrode for decoding and return what we can do with that one.
        bestRange = -Inf;
        decodeInfo.electrodeWeights = zeros(size(paintResponses,2),1);
        decodeInfo.affineTerms = zeros(size(paintResponses,2),1);
        for j = 1:size(paintResponses,2);
            temp = [paintResponses ; shadowResponses];
            decodeInfoTemp = DoTheDecode(decodeInfo,[paintIntensities ; shadowIntensities],temp(:,j));
            paintPredsTemp = DoThePrediction(decodeInfoTemp,paintResponses(:,j));
            shadowPredsTemp = DoThePrediction(decodeInfoTemp,shadowResponses(:,j));
            decodeRange = mean([max(paintPredsTemp)-min(paintPredsTemp), max(shadowPredsTemp)-min(shadowPredsTemp)]);
            if (decodeRange > bestRange)
                decodeInfo.bestJ = j;
                paintPreds = paintPredsTemp;
                shadowPreds = shadowPredsTemp;
                bestRange = decodeRange;
            end
            
            % Report weight and affine found for each electrode when used alone.
            switch (decodeInfo.type)
                case {'aff'}
                    decodeInfo.electrodeWeights(j) = decodeInfoTemp.b(1);
                    decodeInfo.affineTerms(j) = decodeInfoTemp.b(2);
                otherwise
            end    
        end
        
    case {'bothbestdouble'}
        % Find best two electrodes for decoding and return what we can do with them.
        bestRange = -Inf;
        for j = 1:size(paintResponses,2);
            for k = setdiff(1:size(paintResponses,2),j)
                temp = [paintResponses ; shadowResponses];
                decodeInfoTemp = DoTheDecode(decodeInfo,[paintIntensities ; shadowIntensities],temp(:,[j k]));
                paintPredsTemp = DoThePrediction(decodeInfoTemp,paintResponses(:,[j k]));
                shadowPredsTemp = DoThePrediction(decodeInfoTemp,shadowResponses(:,[j k]));
                decodeRange = mean([max(paintPredsTemp)-min(paintPredsTemp), max(shadowPredsTemp)-min(shadowPredsTemp)]);
                if (decodeRange > bestRange)
                    decodeInfo.bestJ = j;
                    decodeInfo.bestK = k;
                    paintPreds = paintPredsTemp;
                    shadowPreds = shadowPredsTemp;
                    bestRange = decodeRange;
                end
            end
        end
        % Not entirely clear how we want to report electrode weights for
        % two electrode decoding case.  Below was an early attempt but
        % the convention is now inconsistent with what we do for 'bestsingle' 
        % method.
        %
        % decodeInfo.electrodeWeights = zeros(size(paintResponses,2),1);
        % decodeInfo.electrodeWeights(decodeInfo.bestJ) = decodeInfoTemp.b(1);
        % decodeInfo.electrodeWeights(decodeInfo.bestK) = decodeInfoTemp.b(2);     
    otherwise
        error('Bad option for field decodeJoint');
end

%% Tuck away rmse paint prediction error in percent
%[pmeans,pstes,~,~,~,pxs]=sortbyx(paintIntensities,paintPreds);
%decodeInfo.paintPredErr = ComputeDecodingError(decodeInfo,paintIntensities,paintPreds);
%decodeInfo.paintMeanErr = ComputeDecodingError(decodeInfo,pxs,pmeans');

%% Do the leave one out predictions
paintPredsLOO = NaN*ones(numPaint,1);
shadowPredsLOO = NaN*ones(numShadow,1);
switch (decodeInfo.decodeLOOType)
    case 'no'
        % No leave one out
        paintPredsLOO = paintPreds;
        shadowPredsLOO = shadowPreds;
        
    case 'ot'
        % Leave out one trial at a time
        switch (decodeInfo.decodeJoint)
            case {'paint'} 
                % Decoder was built using paint, so we do the LOO for that but
                % just return the decoded shadow predictions for the shadow data
                % (since it was not used to build the decoder.)
                for i = 1:numPaint
                    % Do the leave one out.
                    index = setdiff(1:numPaint,i);
                    tempIntensities = paintIntensities(index);
                    tempResponses = paintResponses(index,:);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,tempIntensities,tempResponses);
                    
                    % Do the prediction
                    paintPredsLOO(i) = DoThePrediction(decodeInfoTemp,paintResponses(i,:));
                end
                shadowPredsLOO = shadowPreds;
                
            case {'shadow'}
                % Decoder was built using shadow, so we do the LOO for that but
                % just return the decoded paint predictions for the paint data
                % (since it was not used to build the decoder.)
                for i = 1:numShadow
                    % Do the leave one out.
                    index = setdiff(1:numShadow,i);
                    tempIntensities = shadowIntensities(index);
                    tempResponses = shadowResponses(index,:);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,tempIntensities,tempResponses);
                    
                    % Do the prediction
                    shadowPredsLOO(i) = DoThePrediction(decodeInfoTemp,shadowResponses(i,:));
                end
                paintPredsLOO = paintPreds;
                
            case {'both'}
                % Decoder was built with both paint and shadow.  Do the LOO preds using
                % both, and for all trials of both types.
                temp1Intensities = [paintIntensities ; shadowIntensities];
                temp1Responses = [paintResponses ; shadowResponses];
                numTemp1 = length(temp1Intensities);
                temp1PredsLOO = NaN*ones(numTemp1,1);
                for i = 1:numTemp1
                    % Do the leave one out.
                    index = setdiff(1:numTemp1,i);
                    tempIntensities = temp1Intensities(index);
                    tempResponses = temp1Responses(index,:);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,tempIntensities,tempResponses);
                    
                    % Do the prediction
                    temp1PredsLOO(i) = DoThePrediction(decodeInfoTemp,temp1Responses(i,:));
                end
                paintPredsLOO = temp1PredsLOO(1:numPaint);
                shadowPredsLOO = temp1PredsLOO(numPaint+1:end);
                
            otherwise
                error('LOO onetrial not implemented for specified joint decode type');
        end
                
    case 'oi'
        % Leave out one intensity at a time for LOO calcs.
        switch (decodeInfo.decodeJoint)
            % Decoder was built using paint, so we do the LOO for that but
            % just return the decoded shadow predictions for the shadow data
            % (since it was not used to build the decoder.)
            case {'paint'}
                theUniqueIntensities = unique(paintIntensities);
                for i = 1:length(theUniqueIntensities)
                    decodeIndex = find(paintIntensities ~= theUniqueIntensities(i));
                    predictIndex = find(paintIntensities == theUniqueIntensities(i));
                    tempIntensities = paintIntensities(decodeIndex);
                    tempResponses = paintResponses(decodeIndex,:);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,tempIntensities,tempResponses);
                    
                    % Do the prediction
                    paintPredsLOO(predictIndex) = DoThePrediction(decodeInfoTemp,paintResponses(predictIndex,:));
                end
                shadowPredsLOO = shadowPreds;
            otherwise
                error('LOO oneintensity not implemented for specified joint decode type');
        end
    otherwise
        error('Unknown leave one out type specified.');
end

end


