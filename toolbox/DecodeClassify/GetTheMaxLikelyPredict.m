function predict = GetTheMaxLikelyPredict(decodeInfo,responses)
% predict = GetTheMaxLikelyPredict(decodeInfo,responses)
%
% Get the parameters for a maximum likelihood and related decoders
%
% 2/5/15  dhb  Wrote it.

% Get sizes and allocate space for predictions.
nTrials = size(responses,1);
predict = zeros(nTrials,1);
nElectrodes = size(decodeInfo.maxlikely.meanResp,2);
if (size(responses,2) ~= nElectrodes)
    error('Mismatch between classifier and response number of electrodes');
end


%% Pull out variables that we want
uniqueContrasts = decodeInfo.maxlikely.uniqueContrasts;
meanResp = decodeInfo.maxlikely.meanResp;

%% We have two noise models.  In one, the mean and variance
% for each stimulus level and electrode are estimated separately.
% In the other, the noise is treated as a multipicative function of
% the mean within each electrode (but across stimulus levels).
switch decodeInfo.type
    case {'maxlikely' 'mlbayes'}
        % These are just the sample variances for each stimulus
        % level/electrode, which we computed when we got the decoder
        % parameters.
        varResp = decodeInfo.maxlikely.varResp;
    case {'maxlikelyfano' 'mlbayesfano'}
        varResp = decodeInfo.maxlikely.fanoFactor * meanResp;
    case {'maxlikelymeanvar' 'mlbayesmeanvar'}
        varResp = decodeInfo.maxlikely.meanVar * ones(size(meanResp));
    case {'maxlikelypoiss' 'mlbayespoiss'}
        varResp = meanResp;
end

% Fix pathological variances.  Hard to know what to stick in here, but this
% will prevent code from crashing, I think.
index = find(varResp(:) <= 0);
index1 = find(varResp(:) > 0);
meanPosVar = mean(varResp(index1));
varResp(index) = meanPosVar;

%% Loop over trials
for rr = 1:nTrials
    % For each contrast, get the log likelihood
    % This is done by summing over the log likelihood of each
    % electrode's response.  Given the Gaussian model, the log
    % likelihood is easily computed from the formula for the
    % Gaussian PDF.  We assume independent noise on each electrode.
    for ii = 1:length(uniqueContrasts)
        loglikely(ii) = 0;
        for jj = 1:nElectrodes
            loglikely(ii) = loglikely(ii) + log( 1 / sqrt(2*pi*varResp(ii,jj))) - ((responses(rr,jj)-meanResp(ii,jj))^2) / (2*varResp(ii,jj));
            if (isnan(loglikely(ii)))
                fprintf('%d\n',jj);
            end
        end
    end
    
    % What we do with the log likihoods depends on the decoder type
    switch decodeInfo.type
        % Once the variance model is set up, the maximum likelihood calculation
        % works the same for either variance model.
        case {'maxlikely' 'maxlikelyfano' 'maxlikelymeanvar' 'maxlikelypoiss'}      
            % Find the maximum likelihood contrast
            [~,index] = max(loglikely);
            predict(rr) = uniqueContrasts(index(1));
        case {'mlbayes' 'mlbayesfano' 'mlbayesmeanvar' 'mlbayespoiss'}
            % To do Bayes, we need to weight each contrast by its posterior
            % probability.
            
            % Scale the probabilities up so that max is 1.  This puts
            % things into a better numerical range, and we only care
            % that these numbers are proportional to probability.
            maxlikeli = max(loglikely);
            useLogLikeli = loglikely-maxlikeli;
            
            % Get posterior mean
            probs = exp(useLogLikeli);
            numerator = sum(uniqueContrasts .* probs');
            denominator = sum(probs);
            if (denominator == 0)
                error('Numerical issues in computing probabilities from likelihoods');
            end   
            predict(rr) = numerator/denominator;
        otherwise
            error('Unknown decoder type specified');
    end
end
end


