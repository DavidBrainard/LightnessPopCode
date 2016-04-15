function decodeInfo = ExtractedPaintShadowEffect(decodeInfo,theData)
% decodeInfo = ExtractedPaintShadowEffect(decodeInfo,theData)
%
% Do the basic paint/shadow decoding and get paint shadow effect.
%
% 3/29/16  dhb  Pulled this out as a function

%% Shuffle just once in this whole function, if desired
clear decodeInfoTemp
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% Build decoder on both
clear decodeInfoTemp d
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
[~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
d.shadowDecodeBothRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
d.paintDecodeBothMean = mean(d.paintPreds(:));
d.shadowDecodeBothMean = mean(d.shadowPreds(:));
d.shadowMinusPaintDecodeBothMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
[d.paintDecodeBothMeans,d.paintDecodeBothSEMs,~,~,~,d.paintDecodeBothGroupedIntensities] = ...
    sortbyx(paintIntensities,d.paintPreds);
[d.shadowDecodeBothMeans,d.shadowDecodeBothSEMs,~,~,~,d.shadowDecodeBothGroupedIntensities] = ...
    sortbyx(shadowIntensities,d.shadowPreds);
[d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
    d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
    FindPaintShadowEffect(decodeInfoTemp,d.paintDecodeBothGroupedIntensities,d.shadowDecodeBothGroupedIntensities,d.paintDecodeBothMeans,d.shadowDecodeBothMeans);
decodeInfoPaintShadowEffect.decodeBoth = d;

% PLOT: decoded intensities
decodingfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'g','LineWidth',decodeInfo.lineWidth);
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'k','LineWidth',decodeInfo.lineWidth);
h=errorbar(d.paintDecodeBothGroupedIntensities, d.paintDecodeBothMeans, d.paintDecodeBothSEMs, 'go');
set(h,'MarkerFaceColor','g','MarkerSize',decodeInfo.markerSize-6);
h=errorbar(d.shadowDecodeBothGroupedIntensities, d.shadowDecodeBothMeans, d.shadowDecodeBothSEMs, 'ko');
set(h,'MarkerFaceColor','k','MarkerSize',decodeInfo.markerSize-6);
h=plot(d.paintDecodeBothGroupedIntensities, d.paintDecodeBothMeans, 'go','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','g');
h=plot(d.shadowDecodeBothGroupedIntensities, d.shadowDecodeBothMeans, 'ko','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','k');
h = legend({'Paint','Shadow'},'FontSize',decodeInfo.legendFontSize,'Location','NorthWest');
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
xlabel('Stimulus Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance','FontSize',decodeInfo.labelFontSize);
%title(titleRootStr,'FontSize',decodeInfo.titleFontSize);
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowDecodeBothDecoding'];
drawnow;
FigureSave(figName,decodingfig,decodeInfo.figType);

% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscrete,'ro','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','r');
h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscretePred,'r','LineWidth',decodeInfo.lineWidth);
xlabel('Decoded Paint Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfo.labelFontSize);
switch (decodeInfo.paintShadowFitType)
    case 'intcpt'
        text(0,1,(sprintf('Paint/Shadow Effect: %0.2f',d.paintShadowEffect)),'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowDecodeBothInferredMatches'];
drawnow;
FigureSave(figName,predmatchfig,decodeInfo.figType);

%% Build decoder on paint
clear decodeInfoTemp d
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
[~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
d.shadowDecodeBothRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
d.paintDecodeBothMean = mean(d.paintPreds(:));
d.shadowDecodeBothMean = mean(d.shadowPreds(:));
d.shadowMinusPaintDecodeBothMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
[d.paintDecodeBothMeans,d.paintDecodeBothSEMs,~,~,~,d.paintDecodeBothGroupedIntensities] = ...
    sortbyx(paintIntensities,d.paintPreds);
[d.shadowDecodeBothMeans,d.shadowDecodeBothSEMs,~,~,~,d.shadowDecodeBothGroupedIntensities] = ...
    sortbyx(shadowIntensities,d.shadowPreds);
[d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
    d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
    FindPaintShadowEffect(decodeInfoTemp,d.paintDecodeBothGroupedIntensities,d.shadowDecodeBothGroupedIntensities,d.paintDecodeBothMeans,d.shadowDecodeBothMeans);
decodeInfoPaintShadowEffect.decodePaint = d;

% PLOT: decoded intensities
decodingfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'g','LineWidth',decodeInfo.lineWidth);
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'k','LineWidth',decodeInfo.lineWidth);
h=errorbar(d.paintDecodeBothGroupedIntensities, d.paintDecodeBothMeans, d.paintDecodeBothSEMs, 'go');
set(h,'MarkerFaceColor','g','MarkerSize',decodeInfo.markerSize-6);
h=errorbar(d.shadowDecodeBothGroupedIntensities, d.shadowDecodeBothMeans, d.shadowDecodeBothSEMs, 'ko');
set(h,'MarkerFaceColor','k','MarkerSize',decodeInfo.markerSize-6);
h=plot(d.paintDecodeBothGroupedIntensities, d.paintDecodeBothMeans, 'go','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','g');
h=plot(d.shadowDecodeBothGroupedIntensities, d.shadowDecodeBothMeans, 'ko','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','k');
h = legend({'Paint','Shadow'},'FontSize',decodeInfo.legendFontSize,'Location','NorthWest');
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
xlabel('Stimulus Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance','FontSize',decodeInfo.labelFontSize);
%title(titleRootStr,'FontSize',decodeInfo.titleFontSize);
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowDecodePaintDecoding'];
drawnow;
FigureSave(figName,decodingfig,decodeInfo.figType);

% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscrete,'ro','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','r');
h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscretePred,'r','LineWidth',decodeInfo.lineWidth);
xlabel('Decoded Paint Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfo.labelFontSize);
switch (decodeInfo.paintShadowFitType)
    case 'intcpt'
        text(0,1,(sprintf('Paint/Shadow Effect: %0.2f',d.paintShadowEffect)),'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowDecodePaintInferredMatches'];
drawnow;
FigureSave(figName,predmatchfig,decodeInfo.figType);

%% Build decoder on shadow
clear decodeInfoTemp d
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
[~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
d.shadowDecodeBothRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
d.paintDecodeBothMean = mean(d.paintPreds(:));
d.shadowDecodeBothMean = mean(d.shadowPreds(:));
d.shadowMinusPaintDecodeBothMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
[d.paintDecodeBothMeans,d.paintDecodeBothSEMs,~,~,~,d.paintDecodeBothGroupedIntensities] = ...
    sortbyx(paintIntensities,d.paintPreds);
[d.shadowDecodeBothMeans,d.shadowDecodeBothSEMs,~,~,~,d.shadowDecodeBothGroupedIntensities] = ...
    sortbyx(shadowIntensities,d.shadowPreds);
[d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
    d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
    FindPaintShadowEffect(decodeInfoTemp,d.paintDecodeBothGroupedIntensities,d.shadowDecodeBothGroupedIntensities,d.paintDecodeBothMeans,d.shadowDecodeBothMeans);
decodeInfoPaintShadowEffect.decodePaint = d;

% PLOT: decoded intensities
decodingfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'g','LineWidth',decodeInfo.lineWidth);
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'k','LineWidth',decodeInfo.lineWidth);
h=errorbar(d.paintDecodeBothGroupedIntensities, d.paintDecodeBothMeans, d.paintDecodeBothSEMs, 'go');
set(h,'MarkerFaceColor','g','MarkerSize',decodeInfo.markerSize-6);
h=errorbar(d.shadowDecodeBothGroupedIntensities, d.shadowDecodeBothMeans, d.shadowDecodeBothSEMs, 'ko');
set(h,'MarkerFaceColor','k','MarkerSize',decodeInfo.markerSize-6);
h=plot(d.paintDecodeBothGroupedIntensities, d.paintDecodeBothMeans, 'go','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','g');
h=plot(d.shadowDecodeBothGroupedIntensities, d.shadowDecodeBothMeans, 'ko','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','k');
h = legend({'Paint','Shadow'},'FontSize',decodeInfo.legendFontSize,'Location','NorthWest');
lfactor = 0.5;
lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
xlabel('Stimulus Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance','FontSize',decodeInfo.labelFontSize);
%title(titleRootStr,'FontSize',decodeInfo.titleFontSize);
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowDecodeShadowDecoding'];
drawnow;
FigureSave(figName,decodingfig,decodeInfo.figType);

% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscrete,'ro','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','r');
h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscretePred,'r','LineWidth',decodeInfo.lineWidth);
xlabel('Decoded Paint Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfo.labelFontSize);
switch (decodeInfo.paintShadowFitType)
    case 'intcpt'
        text(0,1,(sprintf('Paint/Shadow Effect: %0.2f',d.paintShadowEffect)),'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowDecodeShadowInferredMatches'];
drawnow;
FigureSave(figName,predmatchfig,decodeInfo.figType);

%% Store the data for return
decodeInfo.paintShadowEffect = decodeInfoPaintShadowEffect;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extPaintShadowEffect'),'decodeInfoPaintShadowEffect','-v7.3');


        
  
        

        
       