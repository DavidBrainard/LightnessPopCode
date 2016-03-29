function [paintResponses,shadowResponses,decodeInfo] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
% function [paintResponses,shadowResponses,decodeInfo] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
%
% PCA on responses
%
% 4/22/14 dhb  Wrote it.

% Get path to svmlib.  Ugh.  This is to call it 
% which full path and avoid convlicts with 
% matlab functions of same name.
sdnicaPath = fileparts(which('jhisto'));
curDir = pwd;

%% Do PCA on responses
%
% We specify this by overloading the trial suffle type
switch (decodeInfo.pcaType)
    case {'no'}
    case {'sdn'}
        totalResponses = [paintResponses ; shadowResponses];
        if (~isempty(totalResponses) & ~any(isnan(totalResponses)))

            if (size(totalResponses,2) < decodeInfo.pcaKeep)
                error('Have fewer electrodes than specified decodeInfo.pcaKeep value');
            end
            
            cd(sdnicaPath);
            [~,~,decodeInfo.pcaevals,decodeInfo.pcamat] = pca(totalResponses');
            cd(curDir);
            decodeInfo.pcamat = decodeInfo.pcamat(1:decodeInfo.pcaKeep,:);
            paintResponses = (decodeInfo.pcamat*paintResponses')';
            shadowResponses = (decodeInfo.pcamat*shadowResponses')';
        end

    otherwise
        error('Unknown PCA type specified');
        
end
