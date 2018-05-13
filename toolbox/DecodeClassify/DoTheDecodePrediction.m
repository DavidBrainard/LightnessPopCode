function predict = DoTheDecodePrediction(decodeInfo,responses)
% predict = DoTheDecodePrediction(decodeInfo,responses)
%
% Do the predictions
%
% 10/31/13  dhb  Pulled this out.

% Get/check dimensions
[nContrasts,nResponses] = size(responses);

% Build the decoder according to passed type
switch decodeInfo.type
    case {'aff', 'fitrlinear', 'fitrcvlasso', 'fitrcvridge', 'lassoglm1'}
        X = [responses ones(nContrasts,1)];
        predict = X*decodeInfo.b;
    case 'svmreg'
        decodeInfo.predictOpts = '';
        if (decodeInfo.svmQuiet)
            decodeInfo.predictOpts = [decodeInfo.predictOpts ' -q'];
        end
        X = [responses ones(nContrasts,1)];
        predict = svmpredict(rand(nContrasts,1), X, decodeInfo.svmModel, decodeInfo.predictOpts);
    case {'maxlikely' 'maxlikelyfano' 'mlbayes' 'mlbayesfano' 'maxlikelymeanvar' 'mlbayesmeanvar' 'maxlikelypoiss' 'mlbayespoiss'}
        predict = GetTheMaxLikelyPredict(decodeInfo,responses);
    otherwise
        error('Unknown decoder type specified');
end

end