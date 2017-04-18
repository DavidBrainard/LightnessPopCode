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

%% Override filterMaxRMSE
basicInfo(1).filterMaxRMSE = 0.4;

%% PLOT: Envelope summary
envelopeThreshold = 1.05;
sessionIndex = 1;
for ii = 1:length(paintShadowEffect);
    temp = paintShadowEffect(ii).decodeShift;
    inIndex = 1;
    for kk = 1:length(temp)
        if ~isempty(temp(kk).paintShadowEffect)
            useIndex(inIndex) = kk;
            envelopePaintShadowEffects(inIndex) = temp(kk).paintShadowEffect;
            envelopeRMSEs(inIndex) = temp(kk).theRMSE;
            inIndex = inIndex + 1;
        end
    end
    if (~isempty(envelopeRMSEs))
        bestRMSE(sessionIndex ) = min(envelopeRMSEs);
        normEnvelopeRMSEs = envelopeRMSEs/bestRMSE(sessionIndex );
        index = find(normEnvelopeRMSEs < envelopeThreshold);
        minPaintShadowEffect(sessionIndex) = min(envelopePaintShadowEffects(index));
        maxPaintShadowEffect(sessionIndex) = max(envelopePaintShadowEffects(index));
        meanPaintShadowEffect(sessionIndex) = mean(envelopePaintShadowEffects(index));
        sessionIndex = sessionIndex + 1;
    end
end
meanMeanPaintShadowEffect = mean(meanPaintShadowEffect);
paintShadowEnvelopeVsRMSEFig = figure; clf; hold on;
set(gcf,'Position',figParams.position);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
errorbar(bestRMSE,log10(meanPaintShadowEffect),abs(log10(minPaintShadowEffect)-log10(meanPaintShadowEffect)),abs(log10(maxPaintShadowEffect)-log10(meanPaintShadowEffect)),'ko','MarkerSize',8,'MarkerFaceColor','k');
plot(bestRMSE,meanMeanPaintShadowEffect*ones(size(bestRMSE)),'r:');
ylim([-0.6 0.6]);
ylabel('Log10 Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Decoding RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
figFilename = fullfile(figureDir,'summaryPaintShadowEnvelopeVsRMSE','');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig,figParams.figType);

paintShadowEnvelopeSortedFig = figure; clf;
tempPosition = figParams.position;
tempPosition(3) = 1000;
set(gcf,'Position',tempPosition);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
subplot(1,2,1); hold on
[~,index] = sort(minPaintShadowEffect,'ascend');
plot(log10(minPaintShadowEffect(index)),'r','LineWidth',2);
plot(log10(maxPaintShadowEffect(index)),'b','LineWidth',2);
plot(0*ones(size(minPaintShadowEffect)),'k:','LineWidth',1);
ylim([-0.6 0.6]);
xlabel('Sorted Session Index','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('Log10 Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
title({'Sorted by Lower Limit' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(1,2,2); hold on
[~,index] = sort(maxPaintShadowEffect,'descend');
plot(log10(minPaintShadowEffect(index)),'r','LineWidth',2);
plot(log10(maxPaintShadowEffect(index)),'b','LineWidth',2);
plot(0*ones(size(minPaintShadowEffect)),'k:','LineWidth',1);
ylim([-0.6 0.6]);
xlabel('Sorted Session Index','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('Log10 Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
title({'Sorted by Upper Limit' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryPaintShadowEnvelopeSorted','');
FigureSave(figFilename,paintShadowEnvelopeSortedFig,figParams.figType);

index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1);
fractionStraddle = length(index1)/length(minPaintShadowEffect);
fprintf('%d%% of sessions have p/s interval that straddle 0\n',round(100*fractionStraddle));
index2 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1);
fractionBelow = length(index2)/length(minPaintShadowEffect);
fprintf('%d%% of sessions have p/s interval less than 0\n',round(100*fractionBelow));
index3 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1);
fractionAbove = length(index3)/length(minPaintShadowEffect);
fprintf('%d%% of sessions have p/s interval greater than 0\n',round(100*fractionAbove));

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
    thePsychoFile = fullfile(getpref('LightnessPopCode','outputBaseDir'),'xPsychoSummary','Gain','OriginalPaintShadow');
    thePsychoData = load(thePsychoFile);
    psychoPaintShadowEffect = thePsychoData.theData.allPaintShadow;
    plot(startX:startX+length(psychoPaintShadowEffect)-1,psychoPaintShadowEffect,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize+1,'MarkerFaceColor',figParams.plotColor);
    plot(startX:startX+length(psychoPaintShadowEffect)-1,...
        mean(psychoPaintShadowEffect)*ones(size(startX:startX+length(psychoPaintShadowEffect)-1)),figParams.plotColor,'LineWidth',figParams.lineWidth);
    startX = startX + length(psychoPaintShadowEffect) + 2;
end

% Save the figure
figure(theFigure);
switch (basicInfo(1).paintShadowFitType)
    case 'gain'
        plot([1 startX],[1 1],'k:','LineWidth',figParams.lineWidth);
        ylim([figParams.gainLimLow figParams.gainLimHigh]);
    case 'intcpt'
        plot([1 startX],[0 0],'k:','LineWidth',figParams.lineWidth);
        ylim([figParams.interceptLimLow figParams.interceptLimHigh]);
end
xlim([0 startX+1]);
set(gca,'YTick',figParams.interceptTicks);
set(gca,'YTickLabel',figParams.interceptTickLabels);
set(gca,'XTickLabel',{});
ylabel('Paint/Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);

end


