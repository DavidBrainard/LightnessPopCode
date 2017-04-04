function [paintResponsesPCA,shadowResponsesPCA,decodeInfo,pcaBasis,meanResponse,meanResponsePCA] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
% function [paintResponsesPCA,shadowResponsesPCA,decodeInfo,pcaBasis,meanResponse,meanResponsePCA] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
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
%  If you pass shadowResponses as empty, the PCA will be done on the paint
%  respnoses and the shadowResponsePCA will come back empty.
%
% 4/22/14 dhb  Wrote it.
% 4/17/16 dhb  Switch to Matlab version.
% 3/31/17 dhb  Return the PCA basis and mean response in pcaBasis coordinates
%         dhb  Add the mean response back in to the returned PCA coordinates
%              I think this is conceptually correct.

%% Do PCA on responses
%
% We specify this by overloading the trial suffle type
switch (decodeInfo.pcaType)
    case {'no'}
    case {'ml'}
        dataForPCA = [paintResponses ; shadowResponses];
        if (~isempty(dataForPCA) & ~any(isnan(dataForPCA)))
            meanResponse = mean(dataForPCA,1);
            pcaBasis = pca(dataForPCA,'NumComponents',decodeInfo.pcaKeep);
            
            meanResponsePCA = (pcaBasis\meanResponse')';
            paintResponsesPCA = PCATransform(decodeInfo,paintResponses,pcaBasis,meanResponse,meanResponsePCA);
            
            paintResponsesPCACheck = (pcaBasis\paintResponses')';
            if (max(abs(paintResponsesPCACheck(:)-paintResponsesPCA(:))) > 1e-9)
                error('We do not understand PCA');
            end
            
            if (~isempty(shadowResponses))
                shadowResponsesPCA = PCATransform(decodeInfo,shadowResponses,pcaBasis,meanResponse,meanResponsePCA);
                shadowResponsesPCACheck = (pcaBasis\shadowResponses')';
                if (max(abs(shadowResponsesPCACheck(:)-shadowResponsesPCA(:))) > 1e-9)
                    error('We do not understand PCA');
                end
            else
                shadowResponsesPCA = [];
            end
            
            % Let's see if we can get same PCA with Marlene's routine
            pcaBasis2 = pca2(dataForPCA',min(size(dataForPCA'))-1);
            paintResponsesPCA2 = (pcaBasis2\paintResponses')';
            
            
        end

    otherwise
        error('Unknown PCA type specified');
        
end
