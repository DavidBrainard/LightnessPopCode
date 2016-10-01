function [paintResponses,shadowResponses,decodeInfo] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
% function [paintResponses,shadowResponses,decodeInfo] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
%
% PCA on responses.  
%   decodeInfo.pcaType - type of PCA
%     'no' - don't do PCA.
%     'ml' - use Matlab's pca
%
%  decodeInfo.pcaKeep - number of components to keep.
%  
%  With Matlab's algorithm, which subtracts the mean first, you'll get this
%  many components unless there isn't enough data to support that many, in
%  which case you get the number that are supported.
%
%  Matlab's pca by default centers the data around its mean before finding
%  the principle components.
%
% 4/22/14 dhb  Wrote it.
% 4/17/16 dhb  Switch to Matlab version.

%% Do PCA on responses
%
% We specify this by overloading the trial suffle type
switch (decodeInfo.pcaType)
    case {'no'}
    case {'ml'}
        dataForPCA = [paintResponses ; shadowResponses];
        if (~isempty(dataForPCA) & ~any(isnan(dataForPCA)))
            meanDataForPCA = mean(dataForPCA,1);
            pcaBasis = pca(dataForPCA,'NumComponents',decodeInfo.pcaKeep);
            paintResponses = (pcaBasis\(paintResponses-meanDataForPCA(ones(size(paintResponses,1),1),:))')';
            shadowResponses = (pcaBasis\(shadowResponses-meanDataForPCA(ones(size(shadowResponses,1),1),:))')';
        end

    otherwise
        error('Unknown PCA type specified');
        
end
