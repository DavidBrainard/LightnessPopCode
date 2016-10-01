function [paintIRFResponses,shadowIRFResponses,paintIRFStes,shadowIRFStes,paintIRFStds,shadowIRFStds,paintIRFIntensities,shadowIRFIntensities,decodeInfo] ...
    = PaintShadowIntensityResponse(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
% [paintIRFResponses,shadowIRFResponses,paintIRFStes,shadowIRFStes,paintIRFStds,shadowIRFStds,paintIRFIntensities,shadowIRFIntensities,decodeInfo] ...
%   = PaintShadowIntensityResponse(decodeInfo,paintIntensities,paintResponses,shadowIntensities,shadowResponses)
%
% Computes intensity response functions for each electrode.  The paint/shadow IRF variables are cell arrays,
% one for each electrode.
%
% 5/13/14   dhb  Wrote it.
% 1/09/15   dhb  Also return standard deviations, as a rough measure of SNR.

%% Parameter extraction
numPaint = length(paintIntensities);
numShadow = length(shadowIntensities);

% Loop over electrodes
for j = 1:size(paintResponses,2);  
    [paintIRFResponses{j},paintIRFStes{j},~,~,~,paintIRFIntensities{j},paintIRFStds{j}] = sortbyx(paintIntensities,paintResponses(:,j));
    [shadowIRFResponses{j},shadowIRFStes{j},~,~,~,shadowIRFIntensities{j},shadowIRFStds{j}] = sortbyx(shadowIntensities,shadowResponses(:,j));
end

end


