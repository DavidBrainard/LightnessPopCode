function [paintPreds,shadowPreds,paintPredsLOO,shadowPredsLOO,decodeInfo] = PaintShadowClassify(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
% [paintPreds,shadowPreds,paintPredsLOO,shadowPredsLOO,decodeInfo] = PaintShadowClassify(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
%
% Classify paint versus shadow based on decoding option specified in decodeInfo.decodeJoint field and predict.
% The returned variables without the LOO in their name based on the entire input data set.
%
% For some classification options, the classification is also done using the leave-one-out (LOO)
% method specified in field decodeInfo.decodeLOOType.  If you ask for a decodeLOOType other than 'no'
% for a method where LOO is not implemented, this routine will exit with an error.  If LOO
% classification is performed, the LOO decoding is returned in the variables with LOO in their names.
%
% If LOO method is none, the LOO returned variables are set to the classification of the full data set.
%
% Some information about the classification is returned in the decodeInfo struct.  This is based on
% the full decoding.
%
% For available decoding options, see extensive comments in function RunOneCondition.
%
% 4/21/14  dhb  Wrote it.
% 4/22/14  dhb  Modified so that LOO is done with equal number of paint/shadow trials at each intensity.
% 4/14/16  dhb  Use Matlab's cvpartition object for cross-validation.

%% Parameter extraction
numPaint = length(paintIntensities);
numShadow = length(shadowIntensities);

%% Decoding direction
switch (decodeInfo.classifyReduce)
    case 'ignoredecode'
        switch (decodeInfo.type)
            case 'aff'
                decodeDirection = decodeInfo.electrodeWeights;
                ignoreBasis = null(decodeDirection')';
                paintResponses = (ignoreBasis*paintResponses')';
                shadowResponses = (ignoreBasis*shadowResponses')';
            otherwise
                error('Can only ignore decode direction for affine decoder');
        end
end

%% Numeric category labels
decodeInfo.paintLabel = 1;
decodeInfo.shadowLabel = -1;
theLabels = [decodeInfo.paintLabel*ones(size(paintIntensities)) ; decodeInfo.shadowLabel*ones(size(shadowIntensities))];
theResponses = [paintResponses ; shadowResponses];

%% Classify and predict
switch (decodeInfo.decodeJoint)
    case {'both'} 
        % Use both paint and shadow trials to do the classificaiton.
        switch (decodeInfo.classifyType)
            case {'mvma' 'mvmb' 'mvmh' 'svma' 'svmb' 'svmh' 'nna' 'nnb' 'nnh' }
                decodeInfo = DoTheClassify(decodeInfo,theLabels,theResponses);
                paintPreds = DoTheClassifyPrediction(decodeInfo,paintResponses);
                shadowPreds = DoTheClassifyPrediction(decodeInfo,shadowResponses);
            case 'no'
                paintPreds = NaN*ones(size(paintIntensities));
                shadowPreds = NaN*ones(size(shadowIntensities));
            otherwise
                error('Unkown classifier type specified');
        end
     
    otherwise
        paintPreds = NaN*ones(size(paintIntensities));
        shadowPreds = NaN*ones(size(shadowIntensities));
end

%% Do the cross validation
paintPredsLOO = NaN*ones(numPaint,1);
shadowPredsLOO = NaN*ones(numShadow,1);
thePredsLOO = NaN*ones(numPaint+numShadow,1);
switch (decodeInfo.classifydecodeLOOType)
    case 'no'
        % No cross validation, just take the full predictions
        paintPredsLOO = paintPreds;
        shadowPredsLOO = shadowPreds;
        
    case {'ot','kfold'}
        if (strcmp(decodeInfo.classifydecodeLOOType,'ot'))
            CVO = cvpartition(theLabels,'leaveout');

        elseif (strcmp(decodeInfo.classifydecodeLOOType,'kfold'))
            CVO = cvpartition(theLabels,'kfold',decodeInfo.classifyNFolds);
        else
            error('Unknown classify cross-validation (LOO) type');
        end

        % Cross validation
        switch (decodeInfo.decodeJoint)
            case {'both'}        
                switch (decodeInfo.classifyType)
                    case {'mvma' 'mvmb' 'mvmh' 'svma' 'svmb' 'svmh' 'nna' 'nnb' 'nnh'}
                        testCheckIndex = [];
                        for i = 1:CVO.NumTestSets
                            % Split set
                            trainingIndex = CVO.training(i);
                            testIndex = CVO.test(i);
                            testCheckIndex = [testCheckIndex ; find(testIndex)];
                            
                             % Do the classify
                            decodeInfoTemp = DoTheClassify(decodeInfo,theLabels(trainingIndex),theResponses(trainingIndex,:));
                            
                            % Do the prediction
                            thePredsLOO(testIndex) = DoTheClassifyPrediction(decodeInfoTemp,theResponses(testIndex,:));
                        end
                        testCheckIndex = sort(testCheckIndex);
                        if (any(testCheckIndex ~= (1:length(theLabels))'))
                            error('We do not understand the cvpartition object');
                        end
                        paintPredsLOO = thePredsLOO(1:numPaint);
                        shadowPredsLOO = thePredsLOO(numPaint+1:end); 
                        
                    % No classifier specfied, so we don't do anything but
                    % return empties and NaNs.
                    case 'no'
                        paintPredsLOO = NaN*ones(size(paintIntensities));
                        shadowPredsLOO = NaN*ones(size(shadowIntensities));
                        decodeInfo.classifyInfo = [];
                    otherwise
                        error('Unkown classifier type specified');
                end            
            
            % We don't expect to hit this case, but just return nothingness
            % if somehow we get here.
            otherwise
                paintPredsLOO = NaN*ones(size(paintIntensities));
                shadowPredsLOO = NaN*ones(size(shadowIntensities));
                decodeInfo.classifyInfo = [];
        end
               
    otherwise
        error('Unknown classify cross-validation (LOO) type');
end

end


