% SummaryFiguresAddData
%
% Add data from one subject/area to the summary figures.
%
% 1/5/15  dhb  Happy new year.  Pulled this out separately.


%% Decoding RMSE versus decoded range
figure(rmseVersusRangeFig)
plot(decodeMeanRange,decodeMeanLOORMSE,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Original classification accuracy versus decoding RMSE figure
figure(classifyOrigVersusRMSEFig);
plot(decodeMeanLOORMSE,decodeClassifyCorrect,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Vis general classificaiton accuracy versus original
figure(classifyVisGeneralVersusClassifyOrigFig);
plot(decodeClassifyCorrect,visClassifyFractionCorrect,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Vis orth classification accuracy versus vis orthogonal classification
figure(visClassifyOrthVersusVisClassifyGeneralFig);
plot(visClassifyFractionCorrect,visClassifyFractionCorrectOrth,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Classification accuracy versus paint/shadow effect
figure(classifyOrigVersusPSEffectFig);
plot(decodeIntercept,decodeClassifyCorrect,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Vis decoding offset gain versus paint/shadow effect
figure(visOffsetGainVersusPSEffectFig);
plot(decodeIntercept,visOffsetGain,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Match diff versus paint/shadow effect
figure(inferredMatchDiffVersusPSEffectFig);
plot(decodeIntercept,meanShadowMatchesDiscrete-meanPaintMatchesDiscrete,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Distance to nearest sig RF versus paint/shadow effect
figure(rfDistanceVersusPSEffectFig);
plot(decodeIntercept,decodeMinRFDistToStimCenter,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Difference in decoded intensities between paint and shadow versus intercept based PS effect
figure(meanDecodedIntensityVsPSEffectFig);
plot(decodeIntercept,paintShadowDecodeMeanDifferenceDiscrete,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Vis difference in decoded intensities versus decoding difference obtained earlier
figure(visPSDecodeDiffVersusPSDecodediffFig);
plot(paintShadowDecodeMeanDifferenceDiscrete,visPaintLessShadowDim1,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Vis difference in decoded intensities for first two decoding dimensions
figure(visPSDecodeDiffDim2VersusDim1Fig);
plot(visPaintLessShadowDim1,visPaintLessShadowDim2,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Vis difference in RMSE for first two decoding dimensions
figure(visRMSEDim2VersusDim1Fig);
plot(visRMSEDim1,visRMSEDim2,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Decoded RMSE and paint/shadow effect versus stimulus size and eccentricity in four subplots
figure(figSizeEcc);
subplot(2,2,1); hold on
plot(checkerboardSizeDegs,decodeIntercept,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
subplot(2,2,2); hold on
plot(checkerboardSizeDegs,decodeMeanLOORMSE,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
subplot(2,2,3); hold on
plot(checkerboardEccDegs,decodeIntercept,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
subplot(2,2,4); hold on
plot(checkerboardEccDegs,decodeMeanLOORMSE,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Paint shadow summary effect figures
%
% Check and warn about out of range data, which won't show up on the plots.
if (any(decodeIntercept < decodeInterceptLow | decodeIntercept > decodeInterceptHigh))
    fprintf('WARNING: there is an out of plot range decode intercept\n');
end
if (any(isnan(decodeIntercept)))
    fprintf('WANRING: a decode intercept is NaN\n');
end
figure(psEffectSummaryFig);
plot(interceptSummaryPlot.startX:interceptSummaryPlot.startX+length(decodeInterceptSmooth)-1,decodeIntercept,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
plot(interceptSummaryPlot.startX:interceptSummaryPlot.startX+length(decodeInterceptSmooth)-1,mean(decodeIntercept(~isnan(decodeIntercept)))*ones(size(1:length(decodeIntercept))), ...
    filter.plotColor,'LineWidth',loadedData.decodeInfoIn.lineWidth);
interceptSummaryPlot.nJustPlotted = length(decodeInterceptSmooth);

%% Paint shadow effect versus paint shadow effect smooth.
figure(psEffectVsPaintShadowEffectSmoothFig );
plot(decodeIntercept,decodeInterceptSmooth,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);

%% Decoded range summary
if (doDecodeRangeSummary)
    figure(decodedRangeSummaryFig);
    plot(interceptSummaryPlot.startX:interceptSummaryPlot.startX+length(decodeInterceptSmooth)-1,decodeMeanRange,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
end

%% Angle between paint/shadow decodings versus intercept, etc.
if (doPSAnglePlots && strcmp(loadedData.decodeInfoIn.decodeJoint,'both'))
    figure(psAngleVersusInferredMatch);
    plot(decodeIntercept,decodePaintShadowDecodeAngle,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
    
    figure(psPCAAngleVersusInferredMatch);
    plot(decodeIntercept,decodePaintShadowPCAAngle,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
    
    figure(psPCAAngleVersusClassification);
    plot(decodeClassifyCorrect,decodePaintShadowPCAAngle,[filter.plotColor filter.plotSymbol],'MarkerSize',loadedData.decodeInfoIn.markerSize,'MarkerFaceColor',filter.outlineColor);
end

