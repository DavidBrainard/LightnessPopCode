function [paintMatchesSmooth,shadowMatchesSmooth,paintMatchesDiscrete,shadowMatchesDiscrete,paintDecodeDiscrete,shadowDecodeDiscrete] = ...
    InferIntensityMatches(decodeInfoIn,paintFitObject,shadowFitObject,stimulusMin,stimulusMax)
% [paintMatchesSmooth,shadowMatchesSmooth,paintMatchesDiscrete,shadowMatchesDiscrete] = ...
%   InferIntensityMatches(decodeInfoIn,paintFitObject,shadowFitObject,stimulusMin,stimulusMax)
% 
% Infer shadow vs paint matches from the smooth fits to predicted paint/shadow decoded intensities.
%
% This works numerical inversion of finely spaced fits.  Return both smoothly spaced curve and values
% at discrete levels set in decodeInfoIn.inferIntensityLevelsDiscrete.  These latter set the range
% to match the psychophysics.
%
% 3/25/14  dhb  Factored this out.

% Do forward fit.  We could pass this but it seems cleaner to modularize here.
smoothIntensities = linspace(stimulusMin,stimulusMax,decodeInfoIn.nFinelySpacedIntensities);
paintSmooth = PredictDecodedIntensities(decodeInfoIn,paintFitObject,smoothIntensities);
shadowSmooth = PredictDecodedIntensities(decodeInfoIn,shadowFitObject,smoothIntensities);

% Find common decoded range and do inversion over this.
minCommon = max([min(paintSmooth(:)) min(shadowSmooth(:))]);
maxCommon = min([max(paintSmooth(:)) max(shadowSmooth(:))]);

% Make sure there is some common decoded range, otherwise it is not possible to find 
% any inferred matches at all.
if (minCommon <= maxCommon)
    % Do a finely spaced inversion.
    inferIntensityLevelsSmooth = linspace(minCommon,maxCommon,decodeInfoIn.nFinelySpacedIntensities);
    for i = 1:length(inferIntensityLevelsSmooth)
        [~,indexPaint] = min(abs(paintSmooth-inferIntensityLevelsSmooth(i)));
        [~,indexShadow]= min(abs(shadowSmooth-inferIntensityLevelsSmooth(i)));
        paintMatchesSmooth(i) = smoothIntensities(indexPaint(1));
        shadowMatchesSmooth(i) = smoothIntensities(indexShadow(1));
    end

    % Do the discrete inversion.  Only inverted for levels in the common range.
    outIndex = 1;
    paintMatchesDiscrete = [];
    shadowMatchesDiscrete = [];
    for i = 1:length(decodeInfoIn.inferIntensityLevelsDiscrete)
        paintDecodeDiscrete(i) = PredictDecodedIntensities(decodeInfoIn,paintFitObject,decodeInfoIn.inferIntensityLevelsDiscrete(i)); 
        shadowDecodeDiscrete(i) = PredictDecodedIntensities(decodeInfoIn,shadowFitObject,decodeInfoIn.inferIntensityLevelsDiscrete(i)); 
        if (paintDecodeDiscrete(i) > minCommon && paintDecodeDiscrete(i) < maxCommon)
            [~,indexPaint] = min(abs(paintSmooth-paintDecodeDiscrete(i)));
            [~,indexShadow]= min(abs(shadowSmooth-paintDecodeDiscrete(i)));
            paintMatchesDiscrete(outIndex) = smoothIntensities(indexPaint(1));
            shadowMatchesDiscrete(outIndex) = smoothIntensities(indexShadow(1));
            if (abs(decodeInfoIn.inferIntensityLevelsDiscrete(i) - paintMatchesDiscrete(outIndex)) > 1e-2)
                fprintf('WARNING: We think that %0.3f should be the same as %0.3f\n',decodeInfoIn.inferIntensityLevelsDiscrete(i),paintMatchesDiscrete(outIndex));
            end
            outIndex = outIndex + 1;
        end
    end
else
    paintMatchesSmooth = [];
    shadowMatchesSmooth = [];
    paintMatchesDiscrete = [];
    shadowMatchesDiscrete = [];
    paintDecodeDiscrete = [];
    shadowDecodeDiscrete = [];
end

% Some debugging output
DEBUG = true;
if (DEBUG)
    debugFig = figure; hold on;
    plot(paintMatchesSmooth,shadowMatchesSmooth);
    plot(paintMatchesDiscrete,shadowMatchesDiscrete,'ko','MarkerSize',8,'MarkerFaceColor','k');
    plot([0 1],[0 1],'k:','LineWidth',0.5);
    xlim([0 1]); ylim([0 1]);
    axis('square');
    close(debugFig);
    
end