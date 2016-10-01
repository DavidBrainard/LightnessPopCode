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
    case {'maxlikely' 'maxlikelyfano' 'mlbayes' 'mlbayesfano'}
        for ii = 1:length(decodeInfo.maxlikely.uniqueContrasts)
            index = find(contrasts == decodeInfo.maxlikely.uniqueContrasts(ii));
            decodeInfo.maxlikely.meanResp(ii,:) = mean(responses(index,:),1);
            decodeInfo.maxlikely.varResp(ii,:) = var(responses(index,:),0,1);
        end
        for jj = 1:nElectrodes
            decodeInfo.maxlikely.fanoFactors(jj) = decodeInfo.maxlikely.meanResp(:,jj)\decodeInfo.maxlikely.varResp(:,jj);
        end

    otherwise
        error('Unknown decoder type specified');
end
end