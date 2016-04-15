function [paintShadowEffect] = ...
    FindPaintShadowEffect(decodeInfo,paintIntensities,shadowIntensities,paintPredictions,shadowPredictions)
%
%
% Fit the decoded shadow and paint data with a smooth curve.  Then infer intensity matches
% and extract paint shadow effect.

% Get min and max of stimulus intensity range studied.  We expect, generally, for these to
% be the same for paint and shadow, and currently throw an error if they are not.  I don't
% think any code will break in that case, but it seems to me that the reason the two differ
% should be looked into so the error condition enforces it for now.
paintMin = min(paintIntensities); paintMax = max(paintIntensities);
shadowMin = min(shadowIntensities); shadowMax = max(shadowIntensities);
if (paintMin ~= shadowMin || paintMax ~= shadowMax)
    error('Same range of stimulus intensities was not used for paint and shadow');
end
intensityMin = max([paintMin shadowMin]); intensityMax = min([paintMax shadowMax]);
if (intensityMin > intensityMax)
    error('This would be a weird condition, so we check for it.');
end

% Set up finely spaced intensities
fineSpacedIntensities = linspace(intensityMin,intensityMax,decodeInfo.nFinelySpacedIntensities)';

% Put a smooth curve through the decoded intensities
paintFitObject = FitDecodedIntensities(decodeInfo,paintIntensities,paintPredictions');
paintSmooth = PredictDecodedIntensities(decodeInfo,paintFitObject,fineSpacedIntensities);
shadowFitObject = FitDecodedIntensities(decodeInfo,shadowIntensities,shadowPredictions');
shadowSmooth = PredictDecodedIntensities(decodeInfo,shadowFitObject,fineSpacedIntensities);

% Find the inferred matches
[paintMatchesSmooth,shadowMatchesSmooth,paintMatchesDiscrete,shadowMatchesDiscrete,paintDecodeDiscrete,shadowDecodeDiscrete] = ...
    InferIntensityMatches(decodeInfo,paintFitObject,shadowFitObject,intensityMin,intensityMax);
paintShadowDecodeMeanDifferenceDiscrete = mean(paintDecodeDiscrete-shadowDecodeDiscrete);

% Find the paint/shadow effect
switch (decodeInfo.paintShadowFitType)
    case 'intcpt'
        % Summarize intensity matches with a line through the discrete level matches.
        paintShadowEffect = mean(shadowMatchesDiscrete') - mean(paintMatchesDiscrete');
    otherwise
        error('Unknown paint/shadow match fit type');
end
end