% SingleSessionSummaryPlots
%
% Make summary plots from a single session
%
% 1/14/15  dhb  Pulled this out just to keep the calling script shorter.

% Root strings for title and figure out put filename
titleRootStr = {[filename ' ' decodeInfoIn.titleInfoStr] ; ...
    ['''Shadow'' condition ' num2str(decodeInfoIn.shadowCondition) ', ''paint'' condition ' num2str(decodeInfoIn.paintCondition)]; ...
    titleStr ; ...
    titleSizeLocStr; ...
    };

% PLOT: nonlinear fit between affine predictions and intensity.
if (false)
    nlfitfig = figure; clf; hold on;
    set(gcf,'Position',decodeInfoIn.sqPosition);
    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
    h=plot(paintPredictMeansAffine, paintGroupedIntensitiesAffine, 'ro','LineWidth',2,'MarkerSize',4,'MarkerFaceColor','k');
    xlabel('Affine Decode Luminance','FontSize',decodeInfoIn.labelFontSize);
    ylabel('Actual Luminance','FontSize',decodeInfoIn.labelFontSize);
    decodeInfoIn.xIntensityLimLow = -0.05;
    plot([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],[decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],'k:','LineWidth',0.5);
    axis([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh])
    set(gca,'XTick',decodeInfoIn.intensityTicks,'XTickLabel',decodeInfoIn.intensityTickLabels);
    set(gca,'YTick',decodeInfoIn.intensityTicks,'YTickLabel',decodeInfoIn.intensityYTickLabels);
    axis square
    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
    h=plot(nlx, nly, 'r','LineWidth',2);
    figName = [figNameRoot '_nlintensityfit'];
    drawnow;
    FigureSave(figName,nlfitfig,decodeInfoIn.figType);
end

% PLOT: decoded intensities.
decodingfig = figure; clf;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
hold on;
h=plot(fineSpacedIntensities(fineSpacedIntensities > decodeInfoIn.minFineGrainedIntensities),paintLOOSmooth(fineSpacedIntensities > decodeInfoIn.minFineGrainedIntensities),'g','LineWidth',decodeInfoIn.lineWidth);
h=plot(fineSpacedIntensities(fineSpacedIntensities > decodeInfoIn.minFineGrainedIntensities),shadowLOOSmooth(fineSpacedIntensities > decodeInfoIn.minFineGrainedIntensities),'k','LineWidth',decodeInfoIn.lineWidth);
h=errorbar(paintGroupedIntensitiesLOO, paintPredictMeansLOO, paintPredictSEMsLOO, 'go');
set(h,'MarkerFaceColor','g','MarkerSize',decodeInfoIn.markerSize-6);
h=errorbar(shadowGroupedIntensitiesLOO, shadowPredictMeansLOO, shadowPredictSEMsLOO, 'ko');
set(h,'MarkerFaceColor','k','MarkerSize',decodeInfoIn.markerSize-6);
h=plot(paintGroupedIntensitiesLOO, paintPredictMeansLOO, 'go','MarkerSize',decodeInfoIn.markerSize,'MarkerFaceColor','g');
h=plot(shadowGroupedIntensitiesLOO, shadowPredictMeansLOO, 'ko','MarkerSize',decodeInfoIn.markerSize,'MarkerFaceColor','k');
h = legend({'Paint','Shadow'},'FontSize',decodeInfoIn.legendFontSize,'Location','NorthWest');
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
xlabel('Stimulus Luminance','FontSize',decodeInfoIn.labelFontSize);
ylabel('Decoded Luminance','FontSize',decodeInfoIn.labelFontSize);
%title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
plot([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],[decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],'k:','LineWidth',decodeInfoIn.lineWidth);
axis([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh])
set(gca,'XTick',decodeInfoIn.intensityTicks,'XTickLabel',decodeInfoIn.intensityTickLabels);
set(gca,'YTick',decodeInfoIn.intensityTicks,'YTickLabel',decodeInfoIn.intensityYTickLabels);
axis square
figName = [figNameRoot '_decoding'];
drawnow;
FigureSave(figName,decodingfig,decodeInfoIn.figType);

%% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
hold on;
h=plot(paintLOOMatchesDiscrete,shadowLOOMatchesDiscrete,'ro','MarkerSize',decodeInfoIn.markerSize,'MarkerFaceColor','r');
h=plot(paintLOOMatchesDiscrete,shadowMatchesDiscreteAffinePred,'r','LineWidth',decodeInfoIn.lineWidth);
xlabel('Decoded Paint Luminance','FontSize',decodeInfoIn.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfoIn.labelFontSize);
switch (decodeInfoIn.paintShadowFitType)
    case 'aff'
        %title({titleRootStr{:} sprintf('Affine fit: slope %0.2f, intercept: %0.2f',paintShadowMb(1),paintShadowMb(2))}','FontSize',decodeInfoIn.titleFontSize);
        text(0,1,(sprintf('Slope %0.2f, Intercept %0.2f',paintShadowMb(1),paintShadowMb(2))),'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize);
    case 'intcpt'
        %title({titleRootStr{:} sprintf('Affine fit: intercept: %0.2f',paintShadowMb(1))}','FontSize',decodeInfoIn.titleFontSize);
        text(0,1,(sprintf('Paint/Shadow Effect: %0.2f',paintShadowMb(1))),'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],[decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],'k:','LineWidth',decodeInfoIn.lineWidth);
axis([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh])
set(gca,'XTick',decodeInfoIn.intensityTicks,'XTickLabel',decodeInfoIn.intensityTickLabels);
set(gca,'YTick',decodeInfoIn.intensityTicks,'YTickLabel',decodeInfoIn.intensityYTickLabels);
axis square
figName = [figNameRoot '_inferredmatches'];
drawnow;
FigureSave(figName,predmatchfig,decodeInfoIn.figType);

%% PLOT: Inferred matches without the fit line
predmatchfig1 = figure; clf;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
hold on;
h=plot(paintLOOMatchesDiscrete,shadowLOOMatchesDiscrete,'ro','MarkerSize',decodeInfoIn.markerSize,'MarkerFaceColor','r');
xlabel('Decoded Paint Luminance','FontSize',decodeInfoIn.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfoIn.labelFontSize);
switch (decodeInfoIn.paintShadowFitType)
    case 'aff'
        %title({titleRootStr{:} sprintf('Affine fit: slope %0.2f, intercept: %0.2f',paintShadowMb(1),paintShadowMb(2))}','FontSize',decodeInfoIn.titleFontSize);
        %text(0,1,(sprintf('Slope %0.2f, Intercept %0.2f',paintShadowMb(1),paintShadowMb(2))),'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.legendFontSize);
    case 'intcpt'
        %title({titleRootStr{:} sprintf('Affine fit: intercept: %0.2f',paintShadowMb(1))}','FontSize',decodeInfoIn.titleFontSize);
        %text(0,1,(sprintf('Intercept of Fit Unity Slope Line: %0.2f',paintShadowMb(1))),'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.legendFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],[decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh],'k:','LineWidth',decodeInfoIn.lineWidth);
axis([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh])
set(gca,'XTick',decodeInfoIn.intensityTicks,'XTickLabel',decodeInfoIn.intensityTickLabels);
set(gca,'YTick',decodeInfoIn.intensityTicks,'YTickLabel',decodeInfoIn.intensityYTickLabels);
axis square
figName = [figNameRoot '_inferredmatches_nofitline'];
drawnow;
FigureSave(figName,predmatchfig1,decodeInfoIn.figType);

% Add the smooth curve through the inferred matches, useful for debugging sometimes.
if (false)
    h=plot(paintLOOMatchesSmooth,shadowLOOMatchesSmooth,'g:','LineWidth',2);
    figName = [figNameRoot '_inferredmatchessmooth'];
    drawnow;
    FigureSave(figName,predmatchfig,decodeInfoIn.figType);
end

% PLOT: regression weights on individual units
switch (decodeInfoIn.type)
    case {'aff'}
        switch (decodeInfoIn.decodeJoint)
            case {'both' 'bothbestsingle'}
                weightfig = figure; clf;
                set(gcf,'Position',decodeInfoIn.position);
                set(gca,'FontName','Helvetica','FontSize',18);
                hold on;
                plot(decodeInfoIn.electrodeWeights,'r','LineWidth',1);
                plot(decodeInfoIn.electrodeWeights,'ro','MarkerSize',6,'MarkerFaceColor','r');
                switch (decodeInfoIn.decodeJoint)
                    case {'bothbestsingle'}
                        plot(decodeInfoIn.bestJ,decodeInfoIn.electrodeWeights(decodeInfoIn.bestJ),'bo','MarkerSize',6,'MarkerFaceColor','b');
                end
                switch (decodeInfoIn.paintShadowFitType)
                    case 'aff'
                        title({titleRootStr{:} sprintf('Affine fit: slope %0.2f, intercept: %0.2f',paintShadowMb(1),paintShadowMb(2)) [' '] [' ']}','FontSize',decodeInfoIn.titleFontSize);
                    case 'intcpt'
                        title({titleRootStr{:} sprintf('Intercept fit: intercept: %0.2f',paintShadowMb(1)) [' '] [' ']}','FontSize',decodeInfoIn.titleFontSize);
                    otherwise
                        error('Unknown paint/shadow fit type');
                end
                figName = [figNameRoot '_electrodewgt'];
                drawnow;
                FigureSave(figName,weightfig,decodeInfoIn.figType);
                
            otherwise
        end
end

%% Close up figs
close all;