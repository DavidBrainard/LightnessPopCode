function RMSEVersusNPCASummaryPlots(basicInfo,RMSEVersusNPCA,summaryDir,figParams)
% RMSEVersusNPCASummaryPlots(basicInfo,RMSEVersusNPCA,summaryDir,figParams)
%
% Summary plots of RMSE versus NPCA components, in various combinations.
%
% 4/2/17  dhb  Wrote it.

%% Additional parameters
figParams.bumpSizeForMean = 6;
figureSubdir = 'RMSEVersusNPCA';
figureDir = fullfile(summaryDir,figureSubdir,'');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Simple checks
if (length(basicInfo) ~= length(RMSEVersusNPCA))
    error('Length mismatch on struct arrays that should be the same');
end

%% PLOT: Paint/shadow effect from decoding on paint
%
% Get the decode both results from the top level structure.
RMSEVersusNPCABestRMSE = SubstructArrayFromStructArray(RMSEVersusNPCA,'bestRMSE');
RMSEVersusNPCAFitScale = SubstructArrayFromStructArray(RMSEVersusNPCA,'fitScale');
RMSEVersusNPCAFitAsymp = SubstructArrayFromStructArray(RMSEVersusNPCA,'fitAsymp');

RMSEVersusNPCATheRMSE = SubstructArrayFromStructArray(RMSEVersusNPCA,'theRMSE');
RMSEVersusNPCAPaintOnlyPaintRMSE = SubstructArrayFromStructArray(RMSEVersusNPCA,'thePaintOnlyPaintRMSE');
RMSEVersusNPCAPaintOnlyShadowRMSE = SubstructArrayFromStructArray(RMSEVersusNPCA,'thePaintOnlyShadowRMSE');
RMSEVersusNPCAShadowOnlyPaintRMSE = SubstructArrayFromStructArray(RMSEVersusNPCA,'theShadowOnlyPaintRMSE');
RMSEVersusNPCAShadowOnlyShadowRMSE = SubstructArrayFromStructArray(RMSEVersusNPCA,'theShadowOnlyShadowRMSE');

%% PLOT: Exponential scale parameter versus RMSE
ScaleVsRMSEFig = figure; clf; hold on
maxScaleShown = 10;
plot(RMSEVersusNPCATheRMSE(end,:),RMSEVersusNPCAFitScale,'ro','MarkerFaceColor','r');
plot([0 0.3],mean(RMSEVersusNPCAFitScale(RMSEVersusNPCAFitScale < maxScaleShown))*ones(size([0 0.3])),'k:','LineWidth',1);
xlabel('RMSE with all PCA components');
ylabel('Exponential Fit Scale Parameter');
xlim([0 0.3]);
ylim([0 maxScaleShown]);
title({'N PCA Components Scale Parameter' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'NPCAScaleParamVsRMSE','');
FigureSave(figFilename,ScaleVsRMSEFig,figParams.figType);

%% PLOT: Various ways of looking at dimensionality of the neural representation
%
% Do this for PCA on both and decode both, and paint/paint, shadow,shadow as well.  They all look
% basically the same.
MakeDimensionalityFigure(figParams,RMSEVersusNPCATheRMSE,figureDir,'RMSEAsNPCAIncreases','Both');
MakeDimensionalityFigure(figParams,RMSEVersusNPCAPaintOnlyPaintRMSE,figureDir,'RMSEAsNPCAIncreasesPaintOnly','Paint');
MakeDimensionalityFigure(figParams,RMSEVersusNPCAShadowOnlyShadowRMSE,figureDir,'RMSEAsNPCAIncreasesShadowOnly','Shadow');

%% PLOT: Compare decoding with PCA based on paint and on shadow PCA.
PaintVsShadowPCARMSEFig = figure; clf; 
pcaDim = 2;
set(gcf,'Position',[100 100 750 750]);
subplot(2,2,1); hold on
plot(RMSEVersusNPCAPaintOnlyPaintRMSE(pcaDim,:),RMSEVersusNPCAPaintOnlyPaintRMSE(pcaDim,:)-RMSEVersusNPCAShadowOnlyPaintRMSE(pcaDim,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(RMSEVersusNPCAPaintOnlyPaintRMSE(pcaDim,:)-RMSEVersusNPCAShadowOnlyPaintRMSE(pcaDim,:))*ones(size([0 0.3])),'r:','LineWidth',1);
xlabel('Paint RMSE from Paint PCA');
ylabel('RMSE Difference');
xlim([0 0.3]);
ylim([-0.2 0.2]);
title({'Paint RMSE From Paint PCA - Paint RMSE From Shadow PCA' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
legend(sprintf('%d PCA Components',pcaDim),'Location','NorthWest');
figFilename = fullfile(figureDir,'PaintVsShadowPCARMSE','');
FigureSave(figFilename,PaintVsShadowPCARMSEFig,figParams.figType);

subplot(2,2,2); hold on
pcaDim = 6;
plot(RMSEVersusNPCAPaintOnlyPaintRMSE(pcaDim,:),RMSEVersusNPCAPaintOnlyPaintRMSE(pcaDim,:)-RMSEVersusNPCAShadowOnlyPaintRMSE(pcaDim,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(RMSEVersusNPCAPaintOnlyPaintRMSE(pcaDim,:)-RMSEVersusNPCAShadowOnlyPaintRMSE(pcaDim,:))*ones(size([0 0.3])),'r:','LineWidth',1);
xlabel('Paint RMSE from Paint PCA');
ylabel('RMSE Difference');
xlim([0 0.3]);
ylim([-0.2 0.2]);
title({'Paint RMSE From Paint PCA - Paint RMSE From Shadow PCA' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
legend(sprintf('%d PCA Components',pcaDim),'Location','NorthWest');
figFilename = fullfile(figureDir,'PaintVsShadowPCARMSE','');
FigureSave(figFilename,PaintVsShadowPCARMSEFig,figParams.figType);

pcaDim = 2;
set(gcf,'Position',[100 100 750 750]);
subplot(2,2,3); hold on
plot(RMSEVersusNPCAShadowOnlyShadowRMSE(pcaDim,:),RMSEVersusNPCAShadowOnlyShadowRMSE(pcaDim,:)-RMSEVersusNPCAPaintOnlyShadowRMSE(pcaDim,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(RMSEVersusNPCAShadowOnlyShadowRMSE(pcaDim,:)-RMSEVersusNPCAPaintOnlyShadowRMSE(pcaDim,:))*ones(size([0 0.3])),'r:','LineWidth',1);
xlabel('Shadow RMSE from Shadow PCA');
ylabel('RMSE Difference');
xlim([0 0.3]);
ylim([-0.2 0.2]);
title({'Shadow RMSE From Shadow PCA - Shadow RMSE From Paint PCA' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
legend(sprintf('%d PCA Components',pcaDim),'Location','NorthWest');
figFilename = fullfile(figureDir,'PaintVsShadowPCARMSE','');
FigureSave(figFilename,PaintVsShadowPCARMSEFig,figParams.figType);

subplot(2,2,4); hold on
pcaDim = 6;
plot(RMSEVersusNPCAShadowOnlyShadowRMSE(pcaDim,:),RMSEVersusNPCAShadowOnlyShadowRMSE(pcaDim,:)-RMSEVersusNPCAPaintOnlyShadowRMSE(pcaDim,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(RMSEVersusNPCAShadowOnlyShadowRMSE(pcaDim,:)-RMSEVersusNPCAPaintOnlyShadowRMSE(pcaDim,:))*ones(size([0 0.3])),'r:','LineWidth',1);
xlabel('Shadow RMSE from Shadow PCA');
ylabel('RMSE Difference');
xlim([0 0.3]);
ylim([-0.2 0.2]);
title({'Shadow RMSE From Shadow PCA - Shadow RMSE From Paint PCA' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
legend(sprintf('%d PCA Components',pcaDim),'Location','NorthWest');

figFilename = fullfile(figureDir,'PaintVsShadowPCARMSE','');
FigureSave(figFilename,PaintVsShadowPCARMSEFig,figParams.figType);

end


%% Function to make dimensionality fig
function figHandle = MakeDimensionalityFigure(figParams,theRMSE,figureDir,figureName,titleStr)

figureHandle = figure; clf; 
set(gcf,'Position',[100 100 1400 750]);
subplot(2,4,1); hold on
plot(theRMSE(1,:),theRMSE(2,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0.3],'k:','LineWidth',1);
xlabel('RMSE with 1 PCA component');
ylabel('RMSE with 2 PCA components');
xlim([0 0.3]);
ylim([0 0.3]);
axis('square');
title({sprintf('%s RMSE Improve 1->2 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(2,4,2); hold on
plot(theRMSE(2,:),theRMSE(3,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0.3],'k:','LineWidth',1);
xlabel('RMSE with 2 PCA components');
ylabel('RMSE with 3 PCA components');
xlim([0 0.3]);
ylim([0 0.3]);
axis('square');
title({sprintf('%s RMSE Improve 2->3 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(2,4,3); hold on
plot(theRMSE(3,:),theRMSE(4,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0.3],'k:','LineWidth',1);
xlabel('RMSE with 3 PCA components');
ylabel('RMSE with 4 PCA components');
xlim([0 0.3]);
ylim([0 0.3]);
axis('square');
title({sprintf('%s RMSE Improve 3->4 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(2,4,4); hold on
plot(theRMSE(4,:),theRMSE(5,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0.3],'k:','LineWidth',1);
xlabel('RMSE with 4 PCA components');
ylabel('RMSE with 5 PCA components');
xlim([0 0.3]);
ylim([0 0.3]);
axis('square');
title({sprintf('%s RMSE Improve 4->5 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(2,4,5); hold on
plot(theRMSE(end,:),theRMSE(2,:)-theRMSE(1,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(theRMSE(2,:)-theRMSE(1,:))*ones(size([0 0])),'r:','LineWidth',1);
xlabel('RMSE with all PCA components');
ylabel('RMSE difference 2 vs 1');
xlim([0 0.3]);
ylim([-0.2 0.2]);
axis('square');
title({sprintf('%s RMSE Improve 1->2 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(2,4,6); hold on
plot(theRMSE(end,:),theRMSE(3,:)-theRMSE(2,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(theRMSE(3,:)-theRMSE(2,:))*ones(size([0 0])),'r:','LineWidth',1);
xlabel('RMSE with all PCA components');
ylabel('RMSE difference 3 vs 2');
xlim([0 0.3]);
ylim([-0.2 0.2]);
axis('square');
title({sprintf('%s RMSE Improve 2->3 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(2,4,7); hold on
plot(theRMSE(end,:),theRMSE(4,:)-theRMSE(3,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(theRMSE(4,:)-theRMSE(3,:))*ones(size([0 0])),'r:','LineWidth',1);
xlabel('RMSE with all PCA components');
ylabel('RMSE difference 4 vs 3');
xlim([0 0.3]);
ylim([-0.2 0.2]);
axis('square');
title({sprintf('%s RMSE Improve 3->4 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(2,4,8); hold on
plot(theRMSE(end,:),theRMSE(5,:)-theRMSE(4,:),'ro','MarkerFaceColor','r');
plot([0 0.3],[0 0],'k:','LineWidth',1);
plot([0 0.3],mean(theRMSE(5,:)-theRMSE(4,:))*ones(size([0 0])),'r:','LineWidth',1);
xlabel('RMSE with all PCA components');
ylabel('RMSE difference 5 vs 4');
xlim([0 0.3]);
ylim([-0.2 0.2]);
axis('square');
title({sprintf('%s RMSE Improve 4->5 PCA',titleStr) ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

figFilename = fullfile(figureDir,figureName,'');
FigureSave(figFilename,figureHandle,figParams.figType);

end

