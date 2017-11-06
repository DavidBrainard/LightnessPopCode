function ClassificationVersusNPCASummaryPlots(basicInfo,paintShadowEffect,ClassificationVersusNPCA,summaryDir,figParams)
% ClassificationVersusNPCASummaryPlots(basicInfo,paintShadowEffect,ClassificaitonVersusNPCA,summaryDir,figParams)
%
% Summary plots of classification performance for the case where
% classification is done on the PCA'd responses.
%
% This produces plots of classification versus RMSE as well as how
% well you do when you classify using PCA from both versus PCA based
% only on paint or on shadow trials.  Finally, a plot of paint-shadow
% effect versus classification performance.
%
% These plots aren't all tidied up because we don't currently plan to use
% them in the paper.
%
% The PCA dimension is whatever was set up in the extracted analysis.
% That's currently done in some code in ExtractedEngine, rather than as a
% parameter.
%
% 4/2/17  dhb  Wrote it.
% 11/6/17 dhb  Change sign of p/s effect in last plot.  Rename x-axis label.

%% Additional parameters
figParams.bumpSizeForMean = 6;
figureSubdir = 'ClassificaitonVersusNPCA';
figureDir = fullfile(summaryDir,figureSubdir,'');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Simple checks
if (length(basicInfo) ~= length(paintShadowEffect))
    error('Length mismatch on struct arrays that should be the same');
end
if (length(basicInfo) ~= length(ClassificationVersusNPCA))
    error('Length mismatch on struct arrays that should be the same');
end

%% Pull out the data we're going to look at here.
theUnitsMatrix = SubstructArrayFromStructArray(ClassificationVersusNPCA,'theUnits');
thePerformanceMatrix = SubstructArrayFromStructArray(ClassificationVersusNPCA,'thePerformance');
paintOnlyThePerformanceMatrix = SubstructArrayFromStructArray(ClassificationVersusNPCA,'paintOnlyThePerformance');
shadowOnlyThePerformanceMatrix = SubstructArrayFromStructArray(ClassificationVersusNPCA,'shadowOnlyThePerformance');
paintShadowEffectDecodeBoth = SubstructArrayFromStructArray(paintShadowEffect,'decodeBoth');
theRMSE = SubstructArrayFromStructArray(paintShadowEffectDecodeBoth,'theRMSE');

%% PLOT: Classification versus RMSE
whichClassificationEntry = 1;
ClassificationVsRMSEFig = figure; clf; hold on
plot(theRMSE,thePerformanceMatrix(whichClassificationEntry,:),'ro','MarkerFaceColor','r');
xlabel('RMSE');
ylabel('Classification Performance');
%xlim([0 0.3]);
ylim([0 1]);
%title({'N PCA Components Scale Parameter' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'ClassificationVsRMSE','');
FigureSave(figFilename,ClassificationVsRMSEFig,figParams.figType);

%% PLOT: Paint only classification versus clasification
whichClassificationEntry = 1;
shadowOnlyClassificationVsClassificationFig = figure; clf; hold on
plot(thePerformanceMatrix(whichClassificationEntry,:),paintOnlyThePerformanceMatrix(whichClassificationEntry,:),'ro','MarkerFaceColor','r');
plot([0 1],[0 1],'k:');
xlabel('Classification Performance');
ylabel('Paint Only Classification Performance');
xlim([0 1]);
ylim([0 1]);
axis('square');
figFilename = fullfile(figureDir,'PaintOnlyClassificationVsClassification','');
FigureSave(figFilename,shadowOnlyClassificationVsClassificationFig,figParams.figType);

%% PLOT: Shadow only classification versus clasification
whichClassificationEntry = 1;
shadowOnlyClassificationVsClassificationFig = figure; clf; hold on
plot(thePerformanceMatrix(whichClassificationEntry,:),shadowOnlyThePerformanceMatrix(whichClassificationEntry,:),'ro','MarkerFaceColor','r');
plot([0 1],[0 1],'k:');
xlabel('Classification Performance');
ylabel('Paint Only Classification Performance');
xlim([0 1]);
ylim([0 1]);
axis('square');
figFilename = fullfile(figureDir,'ShadowOnlyClassificationVsClassification','');
FigureSave(figFilename,shadowOnlyClassificationVsClassificationFig,figParams.figType);

%% Deal with empty values in paintShadowEffect field
paintShadowEffectPlot = [];
classificationPlot = [];
for ii = 1:length(paintShadowEffectDecodeBoth)
    if (~isempty(paintShadowEffectDecodeBoth(ii).paintShadowEffect))
        paintShadowEffectPlot = [paintShadowEffectPlot ; paintShadowEffectDecodeBoth(ii).paintShadowEffect];
        classificationPlot = [classificationPlot ;ClassificationVersusNPCA(ii).thePerformance(whichClassificationEntry)];
    end
end
    
%% PLOT: Classification versus RMSE
PaintShadowEffectVsClassificationFig = figure; clf; hold on
plot(classificationPlot,-log10(paintShadowEffectPlot),'ro','MarkerFaceColor','r');
xlabel('Classification Performance');
ylabel('Paint-Shadow Effect');
%xlim([0 0.3]);
%ylim([-0.5 0.5]);
%title({'N PCA Components Scale Parameter' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'PaintShadowEffectVsClassification','');
FigureSave(figFilename,PaintShadowEffectVsClassificationFig,figParams.figType);

