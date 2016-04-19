function prediction = DoTheClassifyPrediction(decodeInfo,responses)
% prediction = DoTheClassifyPrediction(decodeInfo,responses)
%
% Do the classification predictions
%
% 4/21/14  dhb  Wrote it.
% 12/2/15  dhb  Update calling form for Matlab

% Get/check dimensions
[nContrasts,nResponses] = size(responses);

% Predict according to passed type
switch decodeInfo.classifyType
    case {'mvma' 'mvmb' 'mvmh'}
        % Matlab's SVM prediction
        prediction = predict(decodeInfo.classifyInfo,responses);
        
    case {'nna' 'nnb' 'nnh'}
        % Nearest neighbor classification.
        %
        % I'm sure this could be vectorized to make it run faster, but
        % writing the loops is perhaps more readable.
        %
        % Go through each response to be classified
        for jj = 1:size(responses,1);
            % For each one, find the exemplar from the training set that is
            % closest. and choose its label as the classification output.
            nTraining = length(decodeInfo.classifyInfo.labels);
            minLength = Inf;
            prediction(jj) = Inf;
            for ii = 1:nTraining
                diff = decodeInfo.classifyInfo.responses(ii,:)-responses(jj,:);
                diffLength = norm(diff);
                if (diffLength < minLength)
                    minLength = diffLength;
                    prediction(jj) = decodeInfo.classifyInfo.labels(ii);
                end
            end
        end
        
    otherwise
        error('Unknown decoder type specified');
end

end