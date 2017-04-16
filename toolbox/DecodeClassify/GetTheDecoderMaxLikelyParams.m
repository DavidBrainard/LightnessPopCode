function decodeInfo = GetTheDecoderMaxLikelyParams(decodeInfo,contrasts,responses)
% decodeInfo = GetTheDecoderMaxLikelyParams(decodeInfo,contrasts,responses)
%
% Get the parameters for a maximum likelihood decoder
%
% 2/5/15  dhb  Wrote it.

nContrasts = length(contrasts);
decodeInfo.maxlikely.uniqueContrasts = unique(contrasts);
nElectrodes = size(responses,2);

switch decodeInfo.type
    case {'maxlikely' 'maxlikelyfano' 'mlbayes' 'mlbayesfano' 'maxlikelymeanvar' 'mlbayesmeanvar' 'maxlikelypoiss' 'mlbayespoiss'}
        % For each contrast, fine the mean response and response variance
        % for each unit.
        for ii = 1:length(decodeInfo.maxlikely.uniqueContrasts)
            index = find(contrasts == decodeInfo.maxlikely.uniqueContrasts(ii));
            decodeInfo.maxlikely.meanResp(ii,:) = mean(responses(index,:),1);
            decodeInfo.maxlikely.varResp(ii,:) = var(responses(index,:),0,1);
        end
        decodeInfo.maxlikely.fanoFactor = decodeInfo.maxlikely.meanResp(:)\decodeInfo.maxlikely.varResp(:);
        decodeInfo.maxlikely.meanVar = mean(decodeInfo.maxlikely.varResp(:));

    otherwise
        error('Unknown decoder type specified');
end
end