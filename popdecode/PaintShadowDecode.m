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
        paintPreds = DoTheDecodePrediction(decodeInfo,paintResponses);
        shadowPreds = DoTheDecodePrediction(decodeInfo,shadowResponses);
        
    case {'shadow'}
        % Shadow trials only used to build decoder.
        decodeInfo = DoTheDecode(decodeInfo,shadowIntensities,shadowResponses);
        paintPreds = DoTheDecodePrediction(decodeInfo,paintResponses);
        shadowPreds = DoTheDecodePrediction(decodeInfo,shadowResponses);
        
    case {'both'} 
        % Use both paint and shadow trials to do the decoding.
        theIntensities = [paintIntensities ; shadowIntensities];
        theResponses = [paintResponses ; shadowResponses];
        decodeInfo = DoTheDecode(decodeInfo,theIntensities,theResponses);
        paintPreds = DoTheDecodePrediction(decodeInfo,paintResponses);
        shadowPreds = DoTheDecodePrediction(decodeInfo,shadowResponses);
        
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
    otherwise
        error('Bad option for field decodeJoint');
end

%% Do the leave one out predictions
paintPredsLOO = NaN*ones(numPaint,1);
shadowPredsLOO = NaN*ones(numShadow,1);
switch (decodeInfo.decodeLOOType)
    case 'no'
        % No leave one out
        paintPredsLOO = paintPreds;
        shadowPredsLOO = shadowPreds;
        
    case {'ot','kfold'}      
        % Leave out one trial at a time
        switch (decodeInfo.decodeJoint)
            case {'paint'}
                % Decoder was built using paint, so we do the LOO for that but
                % just return the decoded shadow predictions for the shadow data
                % (since it was not used to build the decoder.)
                if (strcmp(decodeInfo.decodeLOOType,'ot'))
                    CVO = cvpartition(paintIntensities,'leaveout');
                    
                elseif (strcmp(decodeInfo.decodeLOOType,'kfold'))
                    CVO = cvpartition(paintIntensities,'kfold',decodeInfo.decodeNFolds);
                else
                    error('Unknown decode cross-validation (LOO) type');
                end
                for i = 1:CVO.NumTestSets
                    % Split set
                    trainingIndex = CVO.training(i);
                    testIndex = CVO.test(i);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,paintIntensities(trainingIndex),paintResponses(trainingIndex,:));
                    
                    % Do the prediction
                    paintPredsLOO(testIndex) = DoTheDecode(decodeInfoTemp,paintResponses(testIndex,:));
                end
                shadowPredsLOO = shadowPreds;
                
            case {'shadow'}
                % Decoder was built using shadow, so we do the LOO for that but
                % just return the decoded paint predictions for the paint data
                % (since it was not used to build the decoder.)
                if (strcmp(decodeInfo.decodeLOOType,'ot'))
                    CVO = cvpartition(shadowIntensities,'leaveout');
                    
                elseif (strcmp(decodeInfo.decodeLOOType,'kfold'))
                    CVO = cvpartition(shadowIntensities,'kfold',decodeInfo.decodeNFolds);
                else
                    error('Unknown decode cross-validation (LOO) type');
                end
                for i = 1:CVO.NumTestSets
                    % Split set
                    trainingIndex = CVO.training(i);
                    testIndex = CVO.test(i);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,shadowIntensities(trainingIndex),shadowResponses(trainingIndex,:));
                    
                    % Do the prediction
                    shadowPredsLOO(testIndex) = DoTheDecode(decodeInfoTemp,shadowResponses(testIndex,:));
                end
                paintPredsLOO = paintPreds;
                
            case {'both'}
                % Decoder was built on both, do full cross val.  We don't
                % worry about selecting equal paint and shadow in the cross
                % val, just figure that it is OK because we have a fair
                % number of trials.
                if (strcmp(decodeInfo.decodeLOOType,'ot'))
                    CVO = cvpartition(theIntensities,'leaveout');
                    
                elseif (strcmp(decodeInfo.decodeLOOType,'kfold'))
                    CVO = cvpartition(theIntensities,'kfold',decodeInfo.decodeNFolds);
                else
                    error('Unknown decode cross-validation (LOO) type');
                end
                for i = 1:CVO.NumTestSets
                    % Split set
                    trainingIndex = CVO.training(i);
                    testIndex = CVO.test(i);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,theIntensities(trainingIndex),theResponses(trainingIndex,:));
                    
                    % Do the prediction
                    thePredsLOO(testIndex) = DoTheDecode(decodeInfoTemp,theResponses(testIndex,:));
                end
                paintPredsLOO = thePredsLOO(1:numPaint);
                shadowPredsLOO = thePredsLOO(numPaint+1:end);
                
            otherwise
                error('LOO onetrial not implemented for specified joint decode type');
        end
                
    case 'oi'
        % Leave out one intensity at a time for LOO calcs.
        switch (decodeInfo.decodeJoint)
            case {'paint'}
                % Decoder was built using paint, so we do the LOO for that but
                % just return the decoded shadow predictions for the shadow data
                % (since it was not used to build the decoder.)
                theUniqueIntensities = unique(paintIntensities);
                for i = 1:length(theUniqueIntensities)
                    decodeIndex = find(paintIntensities ~= theUniqueIntensities(i));
                    predictIndex = find(paintIntensities == theUniqueIntensities(i));
                    tempIntensities = paintIntensities(decodeIndex);
                    tempResponses = paintResponses(decodeIndex,:);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,tempIntensities,tempResponses);
                    
                    % Do the prediction
                    paintPredsLOO(predictIndex) = DoTheDecodePrediction(decodeInfoTemp,paintResponses(predictIndex,:));
                end
                shadowPredsLOO = shadowPreds;
            
            case {'shadow'}
                % Decoder was built using shadow, so we do the LOO for that but
                % just return the decoded shadow predictions for the paint data
                % (since it was not used to build the decoder.)
                theUniqueIntensities = unique(shadowIntensities);
                for i = 1:length(theUniqueIntensities)
                    decodeIndex = find(shadowIntensities ~= theUniqueIntensities(i));
                    predictIndex = find(shadowIntensities == theUniqueIntensities(i));
                    tempIntensities = shadowIntensities(decodeIndex);
                    tempResponses = shadowResponses(decodeIndex,:);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,tempIntensities,tempResponses);
                    
                    % Do the prediction
                    shadowPredsLOO(predictIndex) = DoTheDecodePrediction(decodeInfoTemp,shadowResponses(predictIndex,:));
                end
                paintPredsLOO = paintPreds;
                
            case {'both'}
                % Do it when both paint and shadow were used for decoding.
                theUniqueIntensities = unique(theIntensities);
                for i = 1:length(theUniqueIntensities)
                    decodeIndex = find(theIntensities ~= theUniqueIntensities(i));
                    predictIndex = find(theIntensities == theUniqueIntensities(i));
                    tempIntensities = theIntensities(decodeIndex);
                    tempResponses = theResponses(decodeIndex,:);
                    
                    % Do the decode
                    decodeInfoTemp = DoTheDecode(decodeInfo,tempIntensities,tempResponses);
                    
                    % Do the prediction
                    thePredsLOO(predictIndex) = DoTheDecodePrediction(decodeInfoTemp,theResponses(predictIndex,:));
                end
                paintPredsLOO = thePredsLOO(1:numPaint);
                shadowPredsLOO = thePredsLOO(numPaint+1:end);
                
            otherwise
                error('LOO oneintensity (oi) not implemented for specified joint decode type');
        end
    otherwise
        error('Unknown leave one out type specified.');
end

end


