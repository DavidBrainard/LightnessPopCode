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
    case 'aff'
        X = [responses ones(nContrasts,1)];
        predict = X*decodeInfo.b;
    case 'svmreg'
        decodeInfo.predictOpts = '';
        if (decodeInfo.svmQuiet)
            decodeInfo.predictOpts = [decodeInfo.predictOpts ' -q'];
        end
        X = [responses ones(nContrasts,1)];
        predict = svmpredict(rand(nContrasts,1), X, decodeInfo.svmModel, decodeInfo.predictOpts);
    case {'maxlikely' 'maxlikelyfano' 'mlbayes' 'mlbayesfano'}
        predict = GetTheMaxLikelyPredict(decodeInfo,responses);
    case 'betacdf'
        X = [responses ones(nContrasts,1)];
        linpredict = X*decodeInfo.b;
        linpredict(linpredict < 0.001) = 0.001;
        linpredict(linpredict > 0.999) = 0.999;
        predict = decodeInfo.betacdfScale*betacdf(linpredict,decodeInfo.betacdfA,decodeInfo.betacdfB);
        if (any(isnan(predict)))
            disp('Oops, got NaNs in prediction');
        end
    case 'betadoublecdf'
        X = [responses ones(nContrasts,1)];
        linpredict = X*decodeInfo.b;
        linpredict(linpredict < 0.001) = 0.001;
        linpredict(linpredict > 0.999) = 0.999;
        predict = decodeInfo.betacdfScale*betadouble(betacdf(linpredict,decodeInfo.betacdfA1,decodeInfo.betacdfB1),decodeInfo.betacdfA2,decodeInfo.betacdfB2);
        if (any(isnan(predict)))
            disp('Oops, got NaNs in prediction');
        end
    case 'smoothing'
        X = [responses ones(nContrasts,1)];
        linpredict = X*decodeInfo.b;
        predict = feval(decodeInfo.fit,linpredict);
        if (any(isnan(predict)))
            disp('Oops, got NaNs in prediction');
        end
    otherwise
        error('Unknown decoder type specified');
end

end