function [paintPreds,shadowPreds,paintPredsLOO,shadowPredsLOO,decodeInfo] = PaintShadowClassify(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
% [paintPreds,shadowPreds,paintPredsLOO,shadowPredsLOO,decodeInfo] = PaintShadowClassify(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
%
% Classify paint versus shadow based on decoding option specified in decodeInfo.decodeJoint field and predict.
% The returned variables without the LOO in their name based on the entire input data set.
%
% For some classification options, the classification is also done using the leave-one-out (LOO)
% method specified in field decodeInfo.looType.  If you ask for a looType other than 'no'
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

%% Do the leave one out predictions
paintPredsLOO = NaN*ones(numPaint,1);
shadowPredsLOO = NaN*ones(numShadow,1);
switch (decodeInfo.classLooType)
    case 'no'
        % No leave one out
        paintPredsLOO = paintPreds;
        shadowPredsLOO = shadowPreds;
        
    case 'ot'
        % Leave out one trial at a time
        switch (decodeInfo.decodeJoint)
            case {'both'}        
                switch (decodeInfo.classifyType)
                    case {'mvma' 'mvmb' 'mvmh' 'svma' 'svmb' 'svmh' 'nna' 'nnb' 'nnh'}
                        % Classifier was built with both paint and shadow.  Do the LOO preds using
                        % both, and for all trials of both types.
                        temp1Intensities = [paintIntensities ; shadowIntensities];
                        temp1Labels = [decodeInfo.paintLabel*ones(size(paintIntensities)) ; decodeInfo.shadowLabel*ones(size(shadowIntensities))];
                        temp1Responses = [paintResponses ; shadowResponses];
                        numTemp1 = length(temp1Labels);
                        temp1PredsLOO = NaN*ones(numTemp1,1);
                        for i = 1:numTemp1
                            % if (decodeInfo.SVM_LOOPROGRESS  && rem(i,200) == 1)
                            %     fprintf('\tLOO classify trial %d of %d\n',i,numTemp1);
                            % end                           
                                
                            % Get the index for the not left out trials
                            index = setdiff(1:numTemp1,i);
                            thisIntensities= temp1Intensities(index);
                            thisLabels = temp1Labels(index);
                            thisResponses = temp1Responses(index,:);
                            
                            % Need to equate number of trials of each intensity across paint and shadow,
                            % to avoid driving the classifier with spurious stimulus driven inf
                            uniqueIntensities = unique(thisIntensities);
                            useIntensities = [];
                            useLabels = [];
                            useResponses = [];
                            for ui = 1:length(uniqueIntensities)
                                paintIntensityIndex = find(thisIntensities == uniqueIntensities(ui) & thisLabels == decodeInfo.paintLabel)';
                                shadowIntensityIndex = find(thisIntensities == uniqueIntensities(ui) & thisLabels == decodeInfo.shadowLabel)';
                                if (length(paintIntensityIndex) < length(shadowIntensityIndex))
                                    tempIndex = Shuffle(1:length(shadowIntensityIndex));
                                    shadowIntensityIndex = shadowIntensityIndex(tempIndex(1:length(paintIntensityIndex)));
                                elseif (length(paintIntensityIndex) > length(shadowIntensityIndex))
                                    tempIndex = Shuffle(1:length(paintIntensityIndex));
                                    paintIntensityIndex = paintIntensityIndex(tempIndex(1:length(shadowIntensityIndex)));
                                end
                                
                                useIntensities = [useIntensities ; thisIntensities(paintIntensityIndex) ; thisIntensities(shadowIntensityIndex)];
                                useLabels = [useLabels ; thisLabels(paintIntensityIndex) ; thisLabels(shadowIntensityIndex)];
                                useResponses = [useResponses ; thisResponses(paintIntensityIndex,:) ; thisResponses(shadowIntensityIndex,:)];
                            end
                            
                            % Do the decode
                            decodeInfoTemp = DoTheClassify(decodeInfo,useLabels,useResponses);
                            
                            % Do the prediction
                            temp1PredsLOO(i) = DoTheClassifyPrediction(decodeInfoTemp,temp1Responses(i,:));
                        end
                        paintPredsLOO = temp1PredsLOO(1:numPaint);
                        shadowPredsLOO = temp1PredsLOO(numPaint+1:end);
                        
                    case 'no'
                        paintPredsLOO = NaN*ones(size(paintIntensities));
                        shadowPredsLOO = NaN*ones(size(shadowIntensities));
                        decodeInfo.classifyInfo = [];
                    otherwise
                        error('Unkown classifier type specified');
                end            
                
            otherwise
                paintPredsLOO = NaN*ones(size(paintIntensities));
                shadowPredsLOO = NaN*ones(size(shadowIntensities));
                decodeInfo.classifyInfo = [];
        end
               
    otherwise
        error('Unknown leave one out type specified.');
end

end


