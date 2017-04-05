function [responsesPCA] = PCATransform(decodeInfo,responses,pcaBasis,meanResponse)
%PCATransform
%  [responsesPCA] = PCATransform(decodeInfo,responses,pcaBasis,meanResponse)
%
% Use output of PaintShadowPCA to transform responses into the PCA
% coordinate system, with the mean response subtracted off.

responsesPCA = (pcaBasis\(responses-meanResponse(ones(size(responses,1),1),:))')';

end