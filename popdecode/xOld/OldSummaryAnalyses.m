%% Load the saved analyses
clear decodeInfoIn decodeInfoOut
loadedData = load(saveFile);
close all

%% Plot params for summary plots.
OVERRIDE_FIGINFO = true;
if (OVERRIDE_FIGINFO)
    loadedData.decodeInfoIn = SetFigParams(loadedData.decodeInfoIn,'popdecode');
end

%% Open up and initialize the summary figures we'll make
SummaryFiguresOpen;
interceptSummaryPlot.startX = 1;

%% Collect up and plot some summary statistics

% V4 data for JD
filter.titleInfoStr = 'V4';
filter.subjectStr = 'JD';
filter.rangeLower = loadedData.decodeInfoOut{1}{1}.filterRangeLower;
filter.paintShadowFitType = loadedData.decodeInfoOut{1}{1}.paintShadowFitType;
filter.plotSymbol = 'o';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;

[decodeInfoFilter_JD_V4,outputSummaryTextStructs_JD_V4] = FilterDecodedSessionData(loadedData.decodeInfoOut,filter);
[decodePaintRange, decodeShadowRange, decodeMeanRange, ~, ~, meanPaintMatchesDiscrete, meanShadowMatchesDiscrete, ...
    checkerboardSizeDegs, checkerboardEccDegs, paintShadowDecodeMeanDifferenceDiscrete, decodeSlope, decodeIntercept, ...
    decodeSlopeSmooth, decodeInterceptSmooth, decodeClassifyCorrect, decodeMeanLOORMSE, ...
    decodeMinRFDistToStimCenter, decodePaintShadowDecodeAngle, decodePaintShadowPCAAngle, ...
    visClassifyFractionCorrect, visClassifyFractionCorrectOrth, visDecodeClassifyAngle, visOffsetGain, ...
    visRMSEDim1, visRMSEDim2, visPaintLessShadowDim1, visPaintLessShadowDim2] = ...
    ExtractDecodedSummaryStats(decodeInfoFilter_JD_V4);
SummaryFiguresAddData;
interceptSummaryPlot.startX = interceptSummaryPlot.startX+interceptSummaryPlot.nJustPlotted+2;

% V4 data for SY
filter.titleInfoStr = 'V4';
filter.subjectStr = 'SY';
filter.rangeLower = loadedData.decodeInfoOut{1}{1}.filterRangeLower;
filter.paintShadowFitType = loadedData.decodeInfoOut{1}{1}.paintShadowFitType;
filter.plotSymbol = 's';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;

[decodeInfoFilter_SY_V4,outputSummaryTextStructs_SY_V4] = FilterDecodedSessionData(loadedData.decodeInfoOut,filter);
[decodePaintRange, decodeShadowRange, decodeMeanRange, ~, ~, meanPaintMatchesDiscrete, meanShadowMatchesDiscrete, ...
    checkerboardSizeDegs, checkerboardEccDegs, paintShadowDecodeMeanDifferenceDiscrete, decodeSlope, decodeIntercept, ...
    decodeSlopeSmooth, decodeInterceptSmooth, decodeClassifyCorrect, decodeMeanLOORMSE, ...
    decodeMinRFDistToStimCenter, decodePaintShadowDecodeAngle, decodePaintShadowPCAAngle, ...
    visClassifyFractionCorrect, visClassifyFractionCorrectOrth, visDecodeClassifyAngle, visOffsetGain, ...
    visRMSEDim1, visRMSEDim2, visPaintLessShadowDim1, visPaintLessShadowDim2] = ...
    ExtractDecodedSummaryStats(decodeInfoFilter_SY_V4);
SummaryFiguresAddData;
interceptSummaryPlot.startX = interceptSummaryPlot.startX+interceptSummaryPlot.nJustPlotted+2;

% Sometimes we want V1 data in the summary figures, and sometimes not.
if (~preserved.plotV4Only)
    % V1 data for BR
    filter.titleInfoStr = 'V1';
    filter.subjectStr = 'BR';
    filter.rangeLower = loadedData.decodeInfoOut{1}{1}.filterRangeLower;
    filter.paintShadowFitType = loadedData.decodeInfoOut{1}{1}.paintShadowFitType;
    filter.plotSymbol = 's';
    filter.plotColor = 'k';
    filter.outlineColor = 'k';
    filter.bumpSizeForMean = 6;
    [decodeInfoFilter_BR_V1,outputSummaryTextStructs_BR_V1] = FilterDecodedSessionData(loadedData.decodeInfoOut,filter);
    [decodePaintRange, decodeShadowRange, decodeMeanRange, ~, ~, meanPaintMatchesDiscrete, meanShadowMatchesDiscrete, checkerboardSizeDegs, checkerboardEccDegs, paintShadowDecodeMeanDifferenceDiscrete, decodeSlope, decodeIntercept, ...
        decodeSlopeSmooth, decodeInterceptSmooth, decodeClassifyCorrect, decodeMeanLOORMSE, ...
        decodeMinRFDistToStimCenter, decodePaintShadowDecodeAngle, decodePaintShadowPCAAngle, ...
        visClassifyFractionCorrect, visClassifyFractionCorrectOrth, visDecodeClassifyAngle, visOffsetGain, ...
        visRMSEDim1, visRMSEDim2, visPaintLessShadowDim1, visPaintLessShadowDim2] = ...
        ExtractDecodedSummaryStats(decodeInfoFilter_BR_V1);
    SummaryFiguresAddData;
    interceptSummaryPlot.startX = interceptSummaryPlot.startX+interceptSummaryPlot.nJustPlotted + 2;
    
    % V1 data for ST
    filter.titleInfoStr = 'V1';
    filter.subjectStr = 'ST';
    filter.rangeLower = loadedData.decodeInfoOut{1}{1}.filterRangeLower;
    filter.paintShadowFitType = loadedData.decodeInfoOut{1}{1}.paintShadowFitType;
    filter.plotSymbol = '^';
    filter.plotColor = 'k';
    filter.outlineColor = 'k';
    filter.bumpSizeForMean = 6;
    [decodeInfoFilter_ST_V1,outputSummaryTextStructs_ST_V1] = FilterDecodedSessionData(loadedData.decodeInfoOut,filter);
    [decodePaintRange, decodeShadowRange, decodeMeanRange, ~, ~, meanPaintMatchesDiscrete, meanShadowMatchesDiscrete, checkerboardSizeDegs, checkerboardEccDegs, paintShadowDecodeMeanDifferenceDiscrete, decodeSlope, decodeIntercept, ...
        decodeSlopeSmooth, decodeInterceptSmooth, decodeClassifyCorrect, decodeMeanLOORMSE, ...
        decodeMinRFDistToStimCenter, decodePaintShadowDecodeAngle, decodePaintShadowPCAAngle, ...
        visClassifyFractionCorrect, visClassifyFractionCorrectOrth, visDecodeClassifyAngle, visOffsetGain, ...
        visRMSEDim1, visRMSEDim2, visPaintLessShadowDim1, visPaintLessShadowDim2] = ...
        ExtractDecodedSummaryStats(decodeInfoFilter_ST_V1);
    SummaryFiguresAddData;
    interceptSummaryPlot.startX = interceptSummaryPlot.startX+interceptSummaryPlot.nJustPlotted+2;
end

%% Add psychophysics to summary plot
psychoPlot.color = 'b';
psychoPlot.symbol = 'v';

% Original Paint/Shadow
if (loadedData.decodeInfoIn.paintCondition == 1 && loadedData.decodeInfoIn.shadowCondition == 2)
    % The script ../psychoanalysis/AnalyzeOriginalPaintShadow produces the output files we need.
    switch (decodeInfoFilter_JD_V4{1}.paintShadowFitType)
        case 'intcpt' 
            % Get psycho summary
            thePsychoFile = '../psychoanalysis/xSummary/OriginalPaintShadowIntercept';
            thePsychoData = load(thePsychoFile);
            psychoIntercepts = thePsychoData.theData.allPaintShadow;
            
            figure(psEffectSummaryFig);
            plot(interceptSummaryPlot.startX:interceptSummaryPlot.startX+length(psychoIntercepts)-1,psychoIntercepts,[psychoPlot.color psychoPlot.symbol],'MarkerSize',loadedData.decodeInfoIn.markerSize+1,'MarkerFaceColor',psychoPlot.color);
            plot(interceptSummaryPlot.startX:interceptSummaryPlot.startX+length(psychoIntercepts)-1,...
                mean(psychoIntercepts)*ones(size(interceptSummaryPlot.startX:interceptSummaryPlot.startX+length(psychoIntercepts)-1)),psychoPlot.color,'LineWidth',loadedData.decodeInfoIn.lineWidth);
                       
            interceptSummaryPlot.nJustPlotted = length(psychoIntercepts);
            interceptSummaryPlot.startX = interceptSummaryPlot.startX+interceptSummaryPlot.nJustPlotted+2;
        otherwise
            error('Unknown paint shadow fit type specified');
    end
end    

%% Finish off summary figures
SummaryFiguresFinishAndSave;

%% Write out summary text file
if (preserved.plotV4Only)
    outputSummaryStructs = [outputSummaryTextStructs_JD_V4];
    summaryFilename =  fullfile(summaryDir,['Summary'  '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType '_V4' '.txt'],'');
else
    outputSummaryStructs = [outputSummaryTextStructs_BR_V1 outputSummaryTextStructs_ST_V1 outputSummaryTextStructs_JD_V4 outputSummaryTextStructs_SY_V4];
    summaryFilename =  fullfile(summaryDir,['Summary'  '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType '.txt'],'');
end
WriteStructsToText(summaryFilename,outputSummaryStructs);
