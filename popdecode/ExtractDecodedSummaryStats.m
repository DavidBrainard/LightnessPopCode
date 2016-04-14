function [decodePaintRange, decodeShadowRange, decodeMeanRange, decodePaintMean, decodeShadowMean, meanPaintMatchesDiscrete, meanShadowMatchesDiscrete, checkerboardSizeDegs, checkerboardEccDegs, paintShadowDecodeMeanDifferenceDiscrete, ...
    decodeSlope, decodeIntercept, decodeSlopeSmooth, decodeInterceptSmooth, decodeClassifyCorrect, decodeMeanLOORMSE, ...
    decodeMinRFDistToStimCenter, decodePaintShadowDecodeAngle, decodePaintShadowPCAAngle ,...
    visClassifyFractionCorrect, visClassifyFractionCorrectOrth, visDecodeClassifyAngle, visOffsetGain, ...
    visRMSEDim1, visRMSEDim2, visPaintLessShadowDim1, visPaintLessShadowDim2] = ...
    ExtractDecodedSummaryStats(decodeInfo)
% [decodePaintRange, decodeShadowRange, decodeMeanRange, decodePaintMean, decodeShadowMean, meanPaintMatchesDiscrete, meanShadowMatchesDiscrete, checkerboardSizeDegs, checkerboardEccDegs, paintShadowDecodeMeanDifferenceDiscrete, ...
%   decodeSlope, decodeIntercept, decodeSlopeSmooth, decodeInterceptSmooth, decodeClassifyCorrect, decodeMeanLOORMSE, ...
%   decodeMinRFDistToStimCenter, decodePaintShadowDecodeAngle, decodePaintShadowPCAAngle ,...
%   visClassifyFractionCorrect, visClassifyFractionCorrectOrth, visDecodeClassifyAngle, visOffsetGain, ...
%   visRMSEDim1, visRMSEDim2, visPaintLessShadowDim1, visPaintLessShadowDim2] = ...
%   ExtractDecodedSummaryStats(decodeInfo)
%
% Extract vectors of useful summary statistics from a cell array of info structs.
%
% 3/32/14  dhb  Pulled it out.

for f = 1:length(decodeInfo)
    decodePaintRange(f) = decodeInfo{f}.decodePaintRange;
    decodeShadowRange(f) = decodeInfo{f}.decodeShadowRange;
    decodePaintLOORMSE(f) = decodeInfo{f}.paintLOORMSE;
    decodeShadowLOORMSE(f) = decodeInfo{f}.shadowLOORMSE;
    decodePaintMean(f) = decodeInfo{f}.decodePaintMean;
    decodeShadowMean(f) = decodeInfo{f}.decodeShadowMean;
    switch (decodeInfo{f}.paintShadowFitType)
        case 'intcpt'
            decodeIntercept(f) = decodeInfo{f}.decodeIntercept;
        otherwise
            error('Unknown paint shadow fit type specified');
    end
    meanPaintMatchesDiscrete(f) = decodeInfo{f}.meanPaintMatchesDiscrete;
    meanShadowMatchesDiscrete(f) = decodeInfo{f}.meanShadowMatchesDiscrete;
    paintShadowDecodeMeanDifferenceDiscrete(f)= decodeInfo{f}.paintShadowDecodeMeanDifferenceDiscrete;
    
    checkerboardSizeDegs(f) = decodeInfo{f}.theCheckerboardSizeDegs;
    checkerboardEccDegs(f) = sqrt(decodeInfo{f}.theCenterXDegs^2 + decodeInfo{f}.theCenterYDegs^2);
    decodeSlope(f) = decodeInfo{f}.decodeSlope;
    decodeIntercept(f) = decodeInfo{f}.decodeIntercept;
    decodeSlopeSmooth(f) = decodeInfo{f}.decodeSlopeSmooth;
    decodeInterceptSmooth(f) = decodeInfo{f}.decodeInterceptSmooth;
    decodeClassifyCorrect(f) = (decodeInfo{f}.paintClassifyLOOPerformance+decodeInfo{f}.shadowClassifyLOOPerformance)/2;
    decodeMinRFDistToStimCenter(f) = decodeInfo{f}.minRFDistToStimCenter;
    
    % The angle fields are not always set, depending on how options are set
    % up, so we protect against the case where they are not there.
    if (isfield(decodeInfo{f},'paintShadowDecodeAngle'))
        decodePaintShadowDecodeAngle(f) = decodeInfo{f}.paintShadowDecodeAngle;
    else
        decodePaintShadowDecodeAngle(f) = NaN;
    end
    if (isfield(decodeInfo{f},'paintShadowPCAAngle'))
        decodePaintShadowPCAAngle(f) = decodeInfo{f}.paintShadowPCAAngle(end);
    else
        decodePaintShadowPCAAngle(f) = NaN;
    end
    
    visClassifyFractionCorrect(f) = decodeInfo{f}.decodeVis.classifyFractionCorrect;
    visClassifyFractionCorrectOrth(f) = decodeInfo{f}.decodeVis.classifyFractionCorrectOrth;
    visDecodeClassifyAngle(f) = decodeInfo{f}.decodeVis.decodeClassifyAngle;
    visOffsetGain(f) = decodeInfo{f}.decodeVis.offsetGain(1);
    visRMSEDim1(f) = decodeInfo{f}.decodeVis.decodeRMSE(1);
    visRMSEDim2(f) = decodeInfo{f}.decodeVis.decodeRMSE(2);
    visPaintLessShadowDim1(f) = decodeInfo{f}.decodeVis.paintLessShadow(1);
    visPaintLessShadowDim2(f) = decodeInfo{f}.decodeVis.paintLessShadow(2);

end
decodeMeanRange = (decodePaintRange + decodeShadowRange)/2;
decodeMeanLOORMSE = (decodePaintLOORMSE + decodeShadowLOORMSE)/2;
