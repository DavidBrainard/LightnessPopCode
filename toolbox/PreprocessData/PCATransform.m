function [responsesPCA] = PCATransform(decodeInfo,responses,pcaBasis,meanResponse,meanResponsePCA)
%PCATransform
%  [responsesPCA] = PCATransform(decodeInfo,responses,pcaBasis,meanResponse,meanResponsePCA)
%
% Use output of PaintShadowPCA to transform responses into the PCA
% coordinate system.

responsesPCA = (pcaBasis\(responses-meanResponse(ones(size(responses,1),1),:))')' + meanResponsePCA(ones(size(responses,1),1),:);

responsesPCACheck = (pcaBasis\responses')';
if (max(abs(responsesPCACheck(:)-responsesPCA(:))) > 1e-9)
    error('We do not understand PCA');
end