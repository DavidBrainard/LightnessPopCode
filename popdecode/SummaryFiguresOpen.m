% SummaryFiguresOpen
%
% 1/5/15  dhb  Pulled this code out.

%% Check for sanity
if (~strcmp(loadedData.decodeInfoIn.paintShadowFitType,'intcpt'))
    error('Unsupported paint shadow inferred fit type specified');
end
if (loadedData.decodeInfoIn.paintCondition ~= 1 || loadedData.decodeInfoIn.shadowCondition ~= 2)
    error('Unsupported condition specified');
end

%% Decoding RMSE versus decoded range
rmseVersusRangeFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Original classification accuracy versus decoding RMSE figure
classifyOrigVersusRMSEFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Vis general classificaiton accuracy versus original
classifyVisGeneralVersusClassifyOrigFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Vis orth classificaiton accuracy versus vis orthogonal classification
visClassifyOrthVersusVisClassifyGeneralFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Classification accuracy versus paint/shadow effect
classifyOrigVersusPSEffectFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Vis decoding offset gain versus paint/shadow effect
visOffsetGainVersusPSEffectFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Inferred match diff versus paint/shadow effect
% The discrete matches are based on the levels matched to the range of the psychophysics, and are
% distinguished from the means over the decoded range (of some sort) that we store in
% the summary file.  The difference in discrete means should be the same as the intercept
% when we are fitting the inferred matches with intercept only, so this
% graph is just a check of that.
inferredMatchDiffVersusPSEffectFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Distance to nearest sig RF versus paint/shadow effect
rfDistanceVersusPSEffectFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Difference in decoded intensities between paint and shadow versus intercept based PS effect
%
% This is, I am pretty sure, the difference between measuring a conceptually correct horizontal shift
% in the decoding and measuring a quick and dirty vertical shift.
% Measuring the horizontal shift relies on a fit to the decodings.  The two
% are the same for decodings that are lines with slope 1, but diverge
% otherwise.  This plot lets you see how much.
meanDecodedIntensityVsPSEffectFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Vis difference in decoded intensities versus decoding difference obtained earlier
visPSDecodeDiffVersusPSDecodediffFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Vis difference in decoded intensities for first two decoding dimensions
visPSDecodeDiffDim2VersusDim1Fig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Vis difference in RMSE for first two decoding dimensions
visRMSEDim2VersusDim1Fig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Decoded RMSE and paint/shadow effect versus stimulus size and eccentricity in subplots
figSizeEcc = figure; clf;
set(gcf,'Position',[100 100 2*loadedData.decodeInfoIn.basicSize 2*loadedData.decodeInfoIn.basicSize]);
subplot(2,2,1); hold on
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize-4,'LineWidth',loadedData.decodeInfoIn.axisLineWidth-1);
subplot(2,2,2); hold on
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize-4,'LineWidth',loadedData.decodeInfoIn.axisLineWidth-1);
subplot(2,2,3); hold on
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize-4,'LineWidth',loadedData.decodeInfoIn.axisLineWidth-1);
subplot(2,2,4); hold on
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize-4,'LineWidth',loadedData.decodeInfoIn.axisLineWidth-1);

%% Paint shadow summary effect
psEffectSummaryFig = figure; clf; hold on
tempPosition = loadedData.decodeInfoIn.position;
tempPosition(3) = 1000;
set(gcf,'Position',tempPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Paint shadow effect versus paint shadow effect smooth.
%
% We generally use the discrete version, where the paint intensities
% are restricted to the range of the psychphysics.  But the smooth version can be useful for seeing
% the effects of this restriction.  In particular, note that choosing the discrete decoded points based
% on the paint intensities can produce a bias in the intercept because of co-occurance of cases where
% the intercept would be positive and where there are no decoded discrete points (in which case the
% datum doesn't show up in the summary.)  This can happen for shuffled data where the decoded intensity
% curves are very very flat.
psEffectVsPaintShadowEffectSmoothFig = figure; clf; hold on
set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);

%% Decoded range summary
doDecodeRangeSummary = false;
if (doDecodeRangeSummary)
    decodedRangeSummaryFig = figure; clf; hold on
    set(gcf,'Position',loadedData.decodeInfoIn.position);
    set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);
end

%% Angle between paint/shadow decodings versus intercept, etc.
%
% These have not been very diagnostic so far, and are currently off
doPSAnglePlots = false;
if (doPSAnglePlots && strcmp(loadedData.decodeInfoIn.decodeJoint,'both'))
    psAngleVersusInferredMatch = figure; clf; hold on
    set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
    set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);
    
    psPCAAngleVersusInferredMatch = figure; clf; hold on
    set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
    set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);
    
    psPCAAngleVersusClassification = figure; clf; hold on
    set(gcf,'Position',loadedData.decodeInfoIn.sqPosition);
    set(gca,'FontName',loadedData.decodeInfoIn.fontName,'FontSize',loadedData.decodeInfoIn.axisFontSize,'LineWidth',loadedData.decodeInfoIn.axisLineWidth);
end



