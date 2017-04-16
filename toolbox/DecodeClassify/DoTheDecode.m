function decodeInfo = DoTheDecode(decodeInfo,intensities,responses)
% decodeInfo = DoTheDecode(decodeInfo,intensities,responses)
%
% Build the decoder and return appropriate info about it.
%
% 3/23/14  dhb  Factorized this out.

% Get/check dimensions
[nIntensities,nResponses] = size(responses);
if (length(intensities) ~= nIntensities)
    error('nIntensities mismatch');
end

% Build the decoder according to passed type
switch decodeInfo.type
    case {'aff' 'svmreg'};
        decodeInfo = GetTheDecoderRegressionParams(decodeInfo,intensities,responses);
    case {'maxlikely' 'maxlikelyfano' 'mlbayes' 'mlbayesfano' 'maxlikelymeanvar' 'mlbayesmeanvar' 'maxlikelypoiss' 'mlbayespoiss'}
        decodeInfo = GetTheDecoderMaxLikelyParams(decodeInfo,intensities,responses);       
    otherwise
        error('Unknown type specified');
end

end









