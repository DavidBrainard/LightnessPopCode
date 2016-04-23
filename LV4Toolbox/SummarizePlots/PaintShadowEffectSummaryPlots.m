function PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams)
% PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams)
%
% Summary plots of the basic paint/shadow effect.
%
% Note that we include sessions based on the decode both RMSE, no matter
% how we are decoding.  This is because the logic is that a session is
% either good or bad, independent of what is being analyzed.
%
% 4/19/16  dhb  Wrote it.

%% Additional parameters
figParams.bumpSizeForMean = 6;
figureSubdir = 'PaintShadowEffect';
figureDir = fullfile(summaryDir,figureSubdir,'');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% PLOT: Paint/shadow effect from decoding on both paint and shadow
%
% Get the decode both results from the top level structure, and also get
% the boolean for inclusion based on decoded RMSE.
paintShadowEffectDecodeBoth = SubstructArrayFromStructArray(paintShadowEffect,'decodeBoth');
if (length(basicInfo) ~= length(paintShadowEffectDecodeBoth))
    error('Length mismatch on struct arrays that should be the same');
end
[~,booleanRMSEInclude] = GetFilteringIndex(paintShadowEffectDecodeBoth,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});

% Make the figure
paintShadowEffectDecodeBothFig = PaintShadowEffectFigure(basicInfo,paintShadowEffectDecodeBoth,booleanRMSEInclude,figParams);

% Add title and save
figure(paintShadowEffectDecodeBothFig);
title({'Paint/Shadow Effect, Decode On Both'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryPaintShadowEffectDecodeBoth','');
FigureSave(figFilename,paintShadowEffectDecodeBothFig,figParams.figType);

%% PLOT: Paint/shadow effect from decoding on paint
%
% Get the decode both results from the top level structure.
paintShadowEffectDecodePaint = SubstructArrayFromStructArray(paintShadowEffect,'decodePaint');
if (length(basicInfo) ~= length(paintShadowEffectDecodeBoth))
    error('Length mismatch on struct arrays that should be the same');
end

% Make the figure
paintShadowEffectDecodePaintFig = PaintShadowEffectFigure(basicInfo,paintShadowEffectDecodePaint,booleanRMSEInclude,figParams);

% Add title and save
figure(paintShadowEffectDecodePaintFig);
title({'Paint/Shadow Effect, Decode On Paint'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryPaintShadowEffectDecodePaint','');
FigureSave(figFilename,paintShadowEffectDecodePaintFig,figParams.figType);

%% PLOT: Paint/shadow effect from decoding on shadow
%
% Get the decode both results from the top level structure.
paintShadowEffectDecodeShadow = SubstructArrayFromStructArray(paintShadowEffect,'decodeShadow');
if (length(basicInfo) ~= length(paintShadowEffectDecodeBoth))
    error('Length mismatch on struct arrays that should be the same');
end

% Make the figure
paintShadowEffectDecodeShadowFig = PaintShadowEffectFigure(basicInfo,paintShadowEffectDecodeShadow,booleanRMSEInclude,figParams);

% Add title and save
figure(paintShadowEffectDecodeShadowFig);
title({'Paint/Shadow Effect, Decode On Shadow'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryPaintShadowEffectDecodeShadow','');
FigureSave(figFilename,paintShadowEffectDecodeShadowFig,figParams.figType);

end

%% Function to actually make the figure
function [theFigure,booleanRMSE] = PaintShadowEffectFigure(basicInfo,paintShadowEffectIn,booleanRMSE,figParams)

% Open figure
theFigure = figure; clf; hold on
tempPosition = figParams.position;
tempPosition(3) = 1000;
set(gcf,'Position',tempPosition);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
startX = 1;

% Get data for JD (V4) and add to plot
whichSubject = 'JD';
figParams.plotSymbol = 'o';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Get data for SY (V4) and add to plot
whichSubject = 'SY';
figParams.plotSymbol = 's';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
[~,booleanRMSE] = GetFilteringIndex(paintShadowEffectIn,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Get data for BR (V1) and add to plot
whichSubject = 'BR';
figParams.plotSymbol = 's';
figParams.plotColor = 'k';
figParams.outlineColor = 'k';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
[~,booleanRMSE] = GetFilteringIndex(paintShadowEffectIn,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Get data for ST (V1) and add to plot
whichSubject = 'ST';
figParams.plotSymbol = '^';
figParams.plotColor = 'k';
figParams.outlineColor = 'k';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
[~,booleanRMSE] = GetFilteringIndex(paintShadowEffectIn,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Add psychophysics to summary plot
%
% The script ../psychoanalysis/AnalyzeOriginalPaintShadow produces the output files we need.
% You, the user, are responsible for ensuring that the analysis done there
% is commensurate with what we are reporting from the neural recordings
% here.
if (basicInfo(1).paintCondition == 1 && basicInfo(1).shadowCondition == 2)
    figParams.plotSymbol = 'v';
    figParams.plotColor = 'b';
    thePsychoFile = '../psychoanalysis/xSummary/OriginalPaintShadowIntercept';
    thePsychoData = load(thePsychoFile);
    psychoPaintShadowEffect = thePsychoData.theData.allPaintShadow;
    plot(startX:startX+length(psychoPaintShadowEffect)-1,psychoPaintShadowEffect,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize+1,'MarkerFaceColor',figParams.plotColor);
    plot(startX:startX+length(psychoPaintShadowEffect)-1,...
        mean(psychoPaintShadowEffect)*ones(size(startX:startX+length(psychoPaintShadowEffect)-1)),figParams.plotColor,'LineWidth',figParams.lineWidth);
    startX = startX + length(psychoPaintShadowEffect) + 2;
end

% Save the figure
figure(theFigure);
plot([1 startX],[0 0],'k:','LineWidth',figParams.lineWidth);
xlim([0 startX+1]);
ylim([figParams.interceptLimLow figParams.interceptLimHigh]);
set(gca,'YTick',figParams.interceptTicks);
set(gca,'YTickLabel',figParams.interceptTickLabels);
set(gca,'XTickLabel',{});
ylabel('Paint/Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);

end


