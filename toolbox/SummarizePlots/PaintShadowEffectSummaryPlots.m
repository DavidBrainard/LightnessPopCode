function PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams)
% PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams)
%
% Summary plots of the basic paint/shadow effect.
%
% Note that we include sessions based on the decode both RMSE, no matter
% how we are decoding.  This is because the logic is that a session is
% either good or bad, independent of what is being analyzed.
%
% The envelope threshold and RMSE thresholds used to make the plot are set here, rather than as
% a parameter.  And the mean psychophysical paint-shadow effect [log10(gain) = -0.06]
% is also coded by hand.  Probably that's bad coding practice, but sometimes we
% just need to get the job done.
%
% We decided by eye that an RMSE threshold of 0.2 seems about right.
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
basicInfo(1).filterMaxRMSE = 0.2;

%% PLOT: Envelope summaries in their multiple version glory
DoTheShiftedPlot(basicInfo,paintShadowEffect,figParams,figureDir,'decodeShift','');
%DoTheShiftedPlot(basicInfo,paintShadowEffect,figParams,figureDir,'decodeShiftPCABoth','PCABoth');
%DoTheShiftedPlot(basicInfo,paintShadowEffect,figParams,figureDir,'decodeShiftPCAPaint','PCAPaint');
%DoTheShiftedPlot(basicInfo,paintShadowEffect,figParams,figureDir,'decodeShiftPCAShadow','PCAShadow');

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

%% Print out null RMSE over included sessions
fprintf('Null model (guess mean) over included sessions (mean value over sessions): %0.2f\n',mean([paintShadowEffectDecodeBoth(booleanRMSEInclude).nullRMSE]));

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

%% Function to do the envelope summary plot
function DoTheShiftedPlot(basicInfo,paintShadowEffect,figParams,figureDir,shiftName,figureSuffix)

% This makes plots that try to summarize how much we can move the
% paint-shadow effect around without much of a hit in terms of RMSE.
% The threshold here is the hit (as a fractional increase) that we can
% tolerate, we then look at the range of p/s effects within that RMSE
% range.
%
% This value should match the value for the same variable that is also
% coded into routine ExtractedPaintShadowEffect. That one determines which
% points in the single session envelope plot get colored green.
envelopeThreshold = 1.05;

% Go through each session and extract the range.
for ii = 1:length(paintShadowEffect);
    % Get the decode shift structure from that session
    eval(['temp = paintShadowEffect(ii).' shiftName ';']);
    
    % Find all cases where the paint-shadow effect isn't empty and
    % collect them up along with corresponding RMSEs.
    inIndex = 1;
    envelopePaintShadowEffects = [];
    envelopeRMSEs = [];
    for kk = 1:length(temp)
        if ~isempty(temp(kk).paintShadowEffect)
            envelopePaintShadowEffects(inIndex) = temp(kk).paintShadowEffect;
            envelopeRMSEs(inIndex) = temp(kk).theRMSE;
            inIndex = inIndex + 1;
        else
            %envelopePaintShadowEffects = [];
            %envelopeRMSEs = [];
        end
    end
    
    % If there was at least one paint-shadow effect that wasn't empty,
    % analyze and accumulate.
    if (~isempty(envelopeRMSEs))
        [bestRMSE(ii),bestIndex] = min(envelopeRMSEs);
        normEnvelopeRMSEs = envelopeRMSEs/bestRMSE(ii);
        index = find(normEnvelopeRMSEs < envelopeThreshold);
        minPaintShadowEffect(ii) = min(envelopePaintShadowEffects(index));
        maxPaintShadowEffect(ii) = max(envelopePaintShadowEffects(index));
        meanPaintShadowEffect(ii) = mean(envelopePaintShadowEffects(index));
        bestPaintShadowEffect(ii) = envelopePaintShadowEffects(bestIndex);
    else
        bestRMSE(ii) = NaN;
        minPaintShadowEffect(ii) = NaN;
        maxPaintShadowEffect(ii) = NaN;
        meanPaintShadowEffect(ii) = NaN;
        bestPaintShadowEffect(ii) = NaN;
    end
end

% Figure out V1 versus V4
booleanSessionOK = ~isnan(bestRMSE);
booleanRMSE = bestRMSE <= basicInfo(1).filterMaxRMSE;
[~,booleanSubjectBR] = GetFilteringIndex(basicInfo,{'subjectStr'},{'BR'});
[~,booleanSubjectST] = GetFilteringIndex(basicInfo,{'subjectStr'},{'ST'});
[~,booleanSubjectJD] = GetFilteringIndex(basicInfo,{'subjectStr'},{'JD'});
[~,booleanSubjectSY] = GetFilteringIndex(basicInfo,{'subjectStr'},{'SY'});
booleanV1 = booleanSubjectBR | booleanSubjectST;
booleanV4 = booleanSubjectJD | booleanSubjectSY;

% Write out good filenames into a text file
allFilenames = {paintShadowEffect.theDataDir};
filenamesFilename = fullfile(figureDir,['summaryPaintShadowRMSEGood' figureSuffix '.txt'],'');
fid = fopen(filenamesFilename,'w');
for ii = 1:length(booleanRMSE)
    if (booleanRMSE(ii))
        [a,b] = fileparts(allFilenames{ii});
        fprintf(fid,'%s\n',b);
    end
end
fclose(fid);

% Say which version we are
fprintf('\n*****EnvelopeSummary%s*****\n',figureSuffix);

% A little print out of where intervals fall
%
% We haven't yet taken the log10, so we compare to 1 but printout relative
% to zero.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE);
fractionStraddle = length(index1)/length(find(booleanRMSE));
fprintf('\n%d%% of %d sessions have p/s interval that straddle 0\n',round(100*fractionStraddle),length(find(booleanRMSE)));
index2 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE);
fractionBelow = length(index2)/length(find(booleanRMSE));
fprintf('%d%% of %d sessions have p/s interval less than 0\n',round(100*fractionBelow),length(find(booleanRMSE)));
index3 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE);
fractionAbove = length(index3)/length(find(booleanRMSE));
fprintf('%d%% of %d sessions have p/s interval greater than 0\n',round(100*fractionAbove),length(find(booleanRMSE)));

% A little print out of where intervals fall
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV1));
fprintf('\n%d%% of %d V1 sessions have p/s interval that straddle 0\n',round(100*fractionStraddle),length(find(booleanRMSE & booleanV1)));
index2 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV1);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV1));
fprintf('%d%% of %d V1 sessions have p/s interval less than 0\n',round(100*fractionBelow),length(find(booleanRMSE & booleanV1)));
index3 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV1));
fprintf('%d%% of %d V1 sessions have p/s interval greater than 0\n',round(100*fractionAbove),length(find(booleanRMSE & booleanV1)));

% A little print out of where intervals fall
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV4));
fprintf('\n%d%% of %d V4 sessions have p/s interval that straddle 0\n',round(100*fractionStraddle),length(find(booleanRMSE & booleanV4)));
index2 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV4);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV4));
fprintf('%d%% of %d V4 sessions have p/s interval less than 0\n',round(100*fractionBelow),length(find(booleanRMSE & booleanV4)));
index3 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV4));
fprintf('%d%% of %d V4 sessions have p/s interval greater than 0\n',round(100*fractionAbove),length(find(booleanRMSE & booleanV4)));

% And printout where the best RMSE p/s effects are
index1 = find(bestPaintShadowEffect < 1 & booleanRMSE);
fractionBestUnder = length(index1)/length(find(booleanRMSE));
fprintf('\n%d%% of %d sessions have best p/s effect less than 0\n',round(100*fractionBestUnder),length(find(booleanRMSE)));
index1 = find(bestPaintShadowEffect < 1 & booleanRMSE & booleanV1);
fractionBestUnder = length(index1)/length(find(booleanRMSE & booleanV1));
fprintf('%d%% of %d V1 sessions have best p/s effect less than 0\n',round(100*fractionBestUnder),length(find(booleanRMSE & booleanV1)));
index1 = find(bestPaintShadowEffect < 1 & booleanRMSE & booleanV4);
fractionBestUnder = length(index1)/length(find(booleanRMSE & booleanV4));
fprintf('%d%% of %d V4 sessions have best p/s effect less than 0\n',round(100*fractionBestUnder),length(find(booleanRMSE & booleanV4)));

% And range
index1 = find(booleanRMSE);
psRange = mean(log10(maxPaintShadowEffect(index1)) - log10(minPaintShadowEffect(index1)));
fprintf('\nMean p/s effect range %0.3f\n',psRange);
index1 = find(booleanRMSE & booleanV1);
psRange = mean(log10(maxPaintShadowEffect(index1)) - log10(minPaintShadowEffect(index1)));
fprintf('Mean V1 p/s effect range %0.3f\n',psRange);
index1 = find(booleanRMSE & booleanV4);
psRange = mean(log10(maxPaintShadowEffect(index1)) - log10(minPaintShadowEffect(index1)));
fprintf('Mean V4 p/s effect range %0.3f\n',psRange);

% Figure version 1
paintShadowEnvelopeVsRMSEFig = figure; clf; hold on;
set(gcf,'Position',figParams.position);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
plotV1index = booleanV1 & booleanRMSE & booleanSessionOK;
plotV4index = booleanV4 & booleanRMSE & booleanSessionOK;
errorbar(bestRMSE(plotV1index),log10(bestPaintShadowEffect(plotV1index)),...
    abs(log10(minPaintShadowEffect(plotV1index))-log10(meanPaintShadowEffect(plotV1index))),...
    abs(log10(maxPaintShadowEffect(plotV1index))-log10(meanPaintShadowEffect(plotV1index))),...
    'ko','MarkerSize',4,'MarkerFaceColor','k');
errorbar(bestRMSE(plotV4index),log10(bestPaintShadowEffect(plotV4index)),...
    abs(log10(minPaintShadowEffect(plotV4index))-log10(meanPaintShadowEffect(plotV4index))),...
    abs(log10(maxPaintShadowEffect(plotV4index))-log10(meanPaintShadowEffect(plotV4index))),...
    'ro','MarkerSize',4,'MarkerFaceColor','r');
plot([0 basicInfo(1).filterMaxRMSE],[0 0],'k:','LineWidth',1);
plot([0 basicInfo(1).filterMaxRMSE],[-0.06 -0.06],'b:','LineWidth',1);
xlim([0.05 basicInfo(1).filterMaxRMSE]);
ylim([-0.15 0.15]);
set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
ylabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Best Decoding RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeVsRMSE' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig,figParams.figType);

% Figure version 2
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
ylabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
title({'Sorted by Lower Limit' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(1,2,2); hold on
[~,index] = sort(maxPaintShadowEffect,'descend');
plot(log10(minPaintShadowEffect(index)),'r','LineWidth',2);
plot(log10(maxPaintShadowEffect(index)),'b','LineWidth',2);
plot(0*ones(size(minPaintShadowEffect)),'k:','LineWidth',1);
ylim([-0.6 0.6]);
xlabel('Sorted Session Index','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
title({'Sorted by Upper Limit' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeSorted' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeSortedFig,figParams.figType);

end

