% SummaryFiguresFinishAndSave
%
% Save the various summary figures, after adding axis labels and scale, etc.
%
% The legends need to be done by hand.  This could probably be fixed up to
% be more automatic.
%
% 1/5/15  dhb  Pulled this out.

%% Create V4 only string
if (preserved.plotV4Only)
    v4OnlyString = '_V4';
else
    v4OnlyString = '';
end

%% Decoding RMSE versus decoded range
figure(rmseVersusRangeFig)
xlim([0 1]);
ylim([0 0.4]);
xlabel('Mean Shadow/Paint Decoded Range','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Mean Shadow/Paint Decoded RMSE','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
end
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Decoding RMSE Versus Range' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['DecodeRMSEVsRange' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,rmseVersusRangeFig,loadedData.decodeInfoIn.figType);

%% Original classification accuracy versus decoding RMSE figure
figure(classifyOrigVersusRMSEFig);
xlim([0 0.4]);
ylim([0 1]);
xlabel('Mean Paint/Shadow Decoded RMSE','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Classification Performance','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
end
lfactor = 0.25;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)+lfactor*lpos(3) lpos(2)+lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Classification Versus Decoded RMSE' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['ClassifyOrigVersusRMSE' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,classifyOrigVersusRMSEFig,loadedData.decodeInfoIn.figType);

%% Vis general classificaiton accuracy versus original
figure(classifyVisGeneralVersusClassifyOrigFig);
xlim([0 1]);
ylim([0 1]);
xlabel('Paint/Shadow Classification (Orig)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Classification (Vis General)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
end
lfactor = 0.25;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)+lfactor*lpos(3) lpos(2)+lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Vis Classification Versus Orig' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['ClassifyVisGeneralVersusClassifyOrig' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,classifyVisGeneralVersusClassifyOrigFig,loadedData.decodeInfoIn.figType);

%% Vis orth classification accuracy versus vis orthogonal classification
figure(visClassifyOrthVersusVisClassifyGeneralFig);
xlim([0 1]);
ylim([0 1]);
xlabel('Paint/Shadow Classification (Vis General)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Classification (Vis Orthogonal)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
end
lfactor = 0.25;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)+lfactor*lpos(3) lpos(2)+lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Classification Vis Orth Versus General' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['ClassifyVisOrthVersusClassifyVisGeneral' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,visClassifyOrthVersusVisClassifyGeneralFig,loadedData.decodeInfoIn.figType);

%% Classification accuracy versus paint/shadow effect figure
figure(classifyOrigVersusPSEffectFig);
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
ylim([0 1]);
xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Classification Performance','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
end
lfactor = 0.25;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)+lfactor*lpos(3) lpos(2)+lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Classification Versus Paint/Shadow Effect' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['ClassifyOrigVersusPSEffect' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,classifyOrigVersusPSEffectFig,loadedData.decodeInfoIn.figType);

%% Classification accuracy versus paint/shadow effect figure
figure(classifyOrigVersusPSEffectFig);
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
ylim([0 1]);
xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Classification Performance','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','SouthWest');
end
lfactor = 0.25;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)+lfactor*lpos(3) lpos(2)+lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Classification Versus Paint/Shadow Effect' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['ClassifyOrigVersusPSEffect' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,classifyOrigVersusPSEffectFig,loadedData.decodeInfoIn.figType);

%% Vis decoding offset gain versus paint/shadow effect
figure(visOffsetGainVersusPSEffectFig);
%plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[0 0],'k:');
%plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],'k:');
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'XTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'XTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Offset Gain','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY'},'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
end
title({'Offset Gain Versus Paint/Shadow Effect' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['VisOffsetGainVsPSEffect' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,visOffsetGainVersusPSEffectFig,loadedData.decodeInfoIn.figType);

%% Distance to nearest sig RF versus paint/shadow effect
figure(rfDistanceVersusPSEffectFig);
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'XTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'XTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Distance to Nearest RF (pixels)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthEast');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthEast');
end
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'RF Distance Versus Paint/Shadow Effect' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['RFDistanceVersusPSEffect' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,rfDistanceVersusPSEffectFig,loadedData.decodeInfoIn.figType);

%% Difference in decoded intensities between paint and shadow versus intercept-based PS effect
figure(meanDecodedIntensityVsPSEffectFig);
plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[0 0],'k:');
plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],'k:');
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'XTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'XTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
ylim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'YTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'YTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Mean Paint-Shadow Decoded Difference','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
end
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Paint/Shadow Decode  Difference Versus Paint/Shadow Effect' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['PSDecodeDiffVsPSEffect' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,meanDecodedIntensityVsPSEffectFig,loadedData.decodeInfoIn.figType);

%% Vis difference in decoded intensities versus decoding difference obtained earlier
figure(visPSDecodeDiffVersusPSDecodediffFig);
plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[0 0],'k:');
plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],'k:');
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'XTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'XTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
ylim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'YTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'YTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
xlabel('Mean Paint-Shadow Decoded Difference','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Vis Paint-Shadow Decoded Difference (Dim 1)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
end
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Paint/Shadow Decode Difference Orig Versus Vis' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['VisPSDecodeDiffVsPSDecodeDiff' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,visPSDecodeDiffVersusPSDecodediffFig,loadedData.decodeInfoIn.figType);

%% Vis difference in decoded intensities for first two decoding dimensions
figure(visPSDecodeDiffDim2VersusDim1Fig);
plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[0 0],'k:');
plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],'k:');
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'XTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'XTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
ylim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'YTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'YTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
xlabel('Vis Paint-Shadow Decoded Difference (Dim 1)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Vis Paint-Shadow Decoded Difference (Dim 2)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
end
%lfactor = 0.5;
%lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Paint/Shadow Decode Difference Vis Dim1 Vs Dim 2' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['VisPSDecodeDiffDim2VersusDim1' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,visPSDecodeDiffDim2VersusDim1Fig,loadedData.decodeInfoIn.figType);

%% Vis difference in RMSE for first two decoding dimensions
figure(visRMSEDim2VersusDim1Fig);
plot([0 0.4],[0 0.4],'k:');
xlim([0 0.4]);
ylim([0 0.4]);
xlabel('Vis Decode RMSE (Dim 1)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Vis Decode RMSE (Dim 2)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
end
%lfactor = 0.5;
%lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
title({'Paint/Shadow Decode Difference Vis Dim1 Vs Dim 2' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['VisRMSEDim2VersusDim1' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,visRMSEDim2VersusDim1Fig,loadedData.decodeInfoIn.figType);%% Vis difference in RMSE for first two decoding dimensions

%% Decoded RMSE and paint/shadow effect versus stimulus size and eccentricity in four subplots
figure(figSizeEcc);
subplot(2,2,1); hold on
xlabel('Checkerboard Size (degs)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'YTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'YTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
end
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
subplot(2,2,2); hold on
xlabel('Checkerboard Size (degs)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Mean Decoded RMSE','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylim([0 0.4]);
subplot(2,2,3); hold on
xlabel('Checkerboard Eccentricity (degs)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'YTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'YTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
subplot(2,2,4); hold on
xlabel('Checkerboard Eccentricity (degs)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Mean Decoded RMSE','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylim([0 0.4]);
[a,h] = suplabel(titleStr,'t');
set(h,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['SizeEccEffects' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,figSizeEcc,loadedData.decodeInfoIn.figType);

%% Paint shadow effect summary
figure(psEffectSummaryFig);
plot([1 interceptSummaryPlot.startX],[0 0],'k:','LineWidth',loadedData.decodeInfoIn.lineWidth);
xlim([0 interceptSummaryPlot.startX+1]);
ylim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'YTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'YTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
set(gca,'XTickLabel',{});
ylabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
title({'Paint/Shadow Effect Summary' ; titleStr}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['PSEffectSummary' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,psEffectSummaryFig,loadedData.decodeInfoIn.figType);

%% Paint shadow effect versus paint shadow effect smooth.
figure(psEffectVsPaintShadowEffectSmoothFig);
plot([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],[loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh],'k:');
xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
ylim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
set(gca,'YTick',loadedData.decodeInfoIn.interceptTicks);
set(gca,'YTickLabel',loadedData.decodeInfoIn.interceptTickLabels);
xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
ylabel('Paint/Shadow Effect (intercept, smooth)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
if (preserved.plotV4Only)
    h = legend({ 'V4, JD' 'V4, SY'},'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
else
    h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
end
title({'Paint/Shadow Effect Versus Paint Shadow Effect Smooth' ; titleStr ; ' '}, ...
    'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
figFilename = fullfile(summaryDir,['PSEffectVsPSEffectSmooth' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
FigureSave(figFilename,psEffectVsPaintShadowEffectSmoothFig,loadedData.decodeInfoIn.figType);

%% Decoded range summary
if (doDecodeRangeSummary)
    figure(decodedRangeSummaryFig);
    plot([0 interceptSummaryPlot.startX+1],[filter.rangeLower filter.rangeLower],'k:');
    xlim([0 interceptSummaryPlot.startX+1]);
    ylim([0 1]);
    xlabel('Session Number','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    ylabel('Mean Paint/Shadow Decoded Range','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    title({'Decoded Range Summary' ; titleStr; ' '}, ...
        'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
    figFilename = fullfile(summaryDir,['DecodedRangeSummary'  '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
    if (preserved.plotV4Only)
        h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
    else
        h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize);
    end
    lfactor = 0.5;
    lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
    FigureSave(figFilename,decodedRangeSummaryFig,loadedData.decodeInfoIn.figType);
end

%% Angle between paint/shadow decodings versus intercept, etc.
if (doPSAnglePlots && strcmp(loadedData.decodeInfoIn.decodeJoint,'both'))
    figure(psAngleVersusInferredMatch);
    xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
    %ylim([0 1]);
    xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    ylabel('Angle between paint/shadow decoder (degrees)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    if (preserved.plotV4Only)
        h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthEast');
    else
        h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthEast');
    end
    lfactor = 0.5;
    lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
    title({'PS Decoder Angle Versus Inferred Match' ; titleStr ; ' '}, ...
        'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
    figFilename = fullfile(summaryDir,['PSDecodeAngleVersusInferredMatch' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
    FigureSave(figFilename,psAngleVersusInferredMatch,loadedData.decodeInfoIn.figType);
    
    figure(psPCAAngleVersusInferredMatch);
    xlim([loadedData.decodeInfoIn.interceptLimLow loadedData.decodeInfoIn.interceptLimHigh]);
    %ylim([0 1]);
    xlabel('Paint/Shadow Effect (intercept)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    ylabel('Angle between paint/shadow PCA 1 (degrees)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    if (preserved.plotV4Only)
        h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthEast');
    else
        h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthEast');
    end
    lfactor = 0.5;
    lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
    title({'PS First PCA Angle Versus Inferred Match' ; titleStr ; ' '}, ...
        'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
    figFilename = fullfile(summaryDir,['PSPCAAngleVersusInferredMatch' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
    FigureSave(figFilename,psPCAAngleVersusInferredMatch,loadedData.decodeInfoIn.figType);
    
    figure(psPCAAngleVersusClassification);
    xlim([0 1]);
    %ylim([0 1]);
    xlabel('Paint/shadow classification','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    ylabel('Angle between paint/shadow PCA 1 (degrees)','FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.labelFontSize);
    if (preserved.plotV4Only)
        h = legend({ 'V4, JD' 'V4, SY' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthEast');
    else
        h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',loadedData.decodeInfoIn.legendFontSize,'Location','NorthWest');
    end
    lfactor = 0.5;
    %lpos = get(h,'Position'); set(h,'Position',[lpos(1)+lfactor*lpos(3) lpos(2)+lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
    title({'PS First PCA Angle Versus Classification' ; titleStr ; ' '}, ...
        'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.titleFontSize);
    figFilename = fullfile(summaryDir,['PSPCAAngleVersusClassification' '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType v4OnlyString],'');
    FigureSave(figFilename,psPCAAngleVersusClassification,loadedData.decodeInfoIn.figType);
end


