function ExtractedPaintShadowEffect(doIt,decodeInfo,theData)
% ExtractedPaintShadowEffect(doIt,doPaintShadowEffect,decodeInfo,theData)
%
% Do the basic paint/shadow decoding and get paint shadow effect.
%
% 3/29/16  dhb  Pulled this out as a function

%% Are we doing it?
switch (doIt)
    case 'always'
    case 'never'
        return;
    case 'ifmissing'
        if (exist(fullfile(decodeInfo.writeDataDir,'extPaintShadowEffect.mat'),'file'))
            return;
        end
end

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
decodeInfoTemp.type = decodeInfo.type;
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
[~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
d.shadowRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
d.theRMSE = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[d.paintPreds(:) ; d.shadowPreds(:)]).^2));
d.paintMean = mean(d.paintPreds(:));
d.shadowMean = mean(d.shadowPreds(:));
d.shadowMinusPaintMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
[d.paintMeans,d.paintSEMs,~,~,~,d.paintGroupedIntensities] = ...
    sortbyx(paintIntensities,d.paintPreds);
[d.shadowMeans,d.shadowSEMs,~,~,~,d.shadowGroupedIntensities] = ...
    sortbyx(shadowIntensities,d.shadowPreds);
[d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
    d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
    FindPaintShadowEffect(decodeInfoTemp,d.paintGroupedIntensities,d.shadowGroupedIntensities,d.paintMeans,d.shadowMeans);
decodeSave.decodeBoth = d;

% PLOT: decoded intensities
decodingfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'r','LineWidth',decodeInfo.lineWidth);
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'b','LineWidth',decodeInfo.lineWidth);
h=errorbar(d.paintGroupedIntensities, d.paintMeans, d.paintSEMs, 'ro');
set(h,'MarkerFaceColor','r','MarkerSize',decodeInfo.markerSize-6);
h=errorbar(d.shadowGroupedIntensities, d.shadowMeans, d.shadowSEMs, 'bo');
set(h,'MarkerFaceColor','b','MarkerSize',decodeInfo.markerSize-6);
h=plot(d.paintGroupedIntensities, d.paintMeans, 'ro','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','r');
h=plot(d.shadowGroupedIntensities, d.shadowMeans, 'bo','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','b');
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
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeBothDecoding'];
drawnow;
FigureSave(figName,decodingfig,decodeInfo.figType);

% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
if (~isempty(d.paintMatchesDiscrete) & ~isempty(d.shadowMatchesDiscrete))
    h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscrete,'bo','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','b');
    h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscretePred,'b','LineWidth',decodeInfo.lineWidth);
end
xlabel('Decoded Paint Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfo.labelFontSize);
switch (decodeInfo.paintShadowFitType)
    case {'intcpt' 'gain'}
        text(0,1,(sprintf('Paint-Shadow Effect: %0.2f',d.paintShadowEffect)),'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeBothInferredMatches'];
drawnow;
FigureSave(figName,predmatchfig,decodeInfo.figType);

%% Build decoder on both with shadow intensity shifts
shadowShiftInValues = linspace(0.7, 1.3, 20);
for ii = 1:length(shadowShiftInValues)
    clear decodeInfoTemp d
    decodeInfoTemp.shadowShiftIn = shadowShiftInValues(ii);
    decodeInfoTemp.nUnits = decodeInfo.nUnits;
    decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
    decodeInfoTemp.decodeJoint = 'both';
    decodeInfoTemp.type = decodeInfo.type;
    decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
    decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
    decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
    decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
    decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
    decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
    [~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
        paintIntensities,paintResponses,shadowIntensities*decodeInfoTemp.shadowShiftIn,shadowResponses);
    d.shadowShiftIn = decodeInfoTemp.shadowShiftIn;
    d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
    d.shadowRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
    d.theRMSE = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[d.paintPreds(:) ; d.shadowPreds(:)]).^2));
    d.paintMean = mean(d.paintPreds(:));
    d.shadowMean = mean(d.shadowPreds(:));
    d.shadowMinusPaintMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
    [d.paintMeans,d.paintSEMs,~,~,~,d.paintGroupedIntensities] = ...
        sortbyx(paintIntensities,d.paintPreds);
    [d.shadowMeans,d.shadowSEMs,~,~,~,d.shadowGroupedIntensities] = ...
        sortbyx(shadowIntensities,d.shadowPreds);
    [d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
        d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
        FindPaintShadowEffect(decodeInfoTemp,d.paintGroupedIntensities,d.shadowGroupedIntensities,d.paintMeans,d.shadowMeans);
    decodeSave.decodeShift(ii) = d;
end

% PLOT: Inferred matches with a fit line
temp = decodeSave.decodeShift;
tempPaintShadowEffect = [temp.paintShadowEffect];
tempRMSE = [temp.theRMSE];
clear useIndex tempPaintShadowEffect
inIndex = 1;
useIndex = [];
for kk = 1:length(temp)
    if ~isempty(temp(kk).paintShadowEffect)
        useIndex(inIndex) = kk; 
        tempPaintShadowEffect(inIndex) = temp(kk).paintShadowEffect;
        inIndex = inIndex + 1;
    end
end
rmseenvelopefig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
if (~isempty(useIndex))
    h=plot(tempRMSE(useIndex),tempPaintShadowEffect,'bo','MarkerSize',decodeInfo.markerSize-6,'MarkerFaceColor','b');
end
xlabel('Decoded RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Paint-Shadow Effect','FontSize',decodeInfo.labelFontSize);
xlim([0 0.4]);
ylim([0.5 1.5]);
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectRMSEEnvelope'];
drawnow;
FigureSave(figName,rmseenvelopefig,decodeInfo.figType);

%% Build decoder on paint
clear decodeInfoTemp d
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = decodeInfo.type;
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
[~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
d.shadowRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
d.theRMSE = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[d.paintPreds(:) ; d.shadowPreds(:)]).^2));
d.paintMean = mean(d.paintPreds(:));
d.shadowMean = mean(d.shadowPreds(:));
d.shadowMinusPaintMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
[d.paintMeans,d.paintSEMs,~,~,~,d.paintGroupedIntensities] = ...
    sortbyx(paintIntensities,d.paintPreds);
[d.shadowMeans,d.shadowSEMs,~,~,~,d.shadowGroupedIntensities] = ...
    sortbyx(shadowIntensities,d.shadowPreds);
[d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
    d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
    FindPaintShadowEffect(decodeInfoTemp,d.paintGroupedIntensities,d.shadowGroupedIntensities,d.paintMeans,d.shadowMeans);
decodeSave.decodePaint = d;

% PLOT: decoded intensities
decodingfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'g','LineWidth',decodeInfo.lineWidth);
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'k','LineWidth',decodeInfo.lineWidth);
h=errorbar(d.paintGroupedIntensities, d.paintMeans, d.paintSEMs, 'go');
set(h,'MarkerFaceColor','g','MarkerSize',decodeInfo.markerSize-6);
h=errorbar(d.shadowGroupedIntensities, d.shadowMeans, d.shadowSEMs, 'ko');
set(h,'MarkerFaceColor','k','MarkerSize',decodeInfo.markerSize-6);
h=plot(d.paintGroupedIntensities, d.paintMeans, 'go','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','g');
h=plot(d.shadowGroupedIntensities, d.shadowMeans, 'ko','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','k');
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
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodePaintDecoding'];
drawnow;
FigureSave(figName,decodingfig,decodeInfo.figType);

% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
if (~isempty(d.paintMatchesDiscrete) & ~isempty(d.shadowMatchesDiscrete))
    h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscrete,'ro','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','r');
    h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscretePred,'r','LineWidth',decodeInfo.lineWidth);
end
xlabel('Decoded Paint Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfo.labelFontSize);
switch (decodeInfo.paintShadowFitType)
    case {'intcpt' 'gain'}
        text(0,1,(sprintf('Paint/Shadow Effect: %0.2f',d.paintShadowEffect)),'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodePaintInferredMatches'];
drawnow;
FigureSave(figName,predmatchfig,decodeInfo.figType);

%% Build decoder on shadow
clear decodeInfoTemp d
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = decodeInfo.type;
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
[~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
d.shadowRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
d.theRMSE = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[d.paintPreds(:) ; d.shadowPreds(:)]).^2));
d.paintMean = mean(d.paintPreds(:));
d.shadowMean = mean(d.shadowPreds(:));
d.shadowMinusPaintMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
[d.paintMeans,d.paintSEMs,~,~,~,d.paintGroupedIntensities] = ...
    sortbyx(paintIntensities,d.paintPreds);
[d.shadowMeans,d.shadowSEMs,~,~,~,d.shadowGroupedIntensities] = ...
    sortbyx(shadowIntensities,d.shadowPreds);
[d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
    d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
    FindPaintShadowEffect(decodeInfoTemp,d.paintGroupedIntensities,d.shadowGroupedIntensities,d.paintMeans,d.shadowMeans);
decodeSave.decodeShadow = d;

% PLOT: decoded intensities
decodingfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'g','LineWidth',decodeInfo.lineWidth);
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'k','LineWidth',decodeInfo.lineWidth);
h=errorbar(d.paintGroupedIntensities, d.paintMeans, d.paintSEMs, 'go');
set(h,'MarkerFaceColor','g','MarkerSize',decodeInfo.markerSize-6);
h=errorbar(d.shadowGroupedIntensities, d.shadowMeans, d.shadowSEMs, 'ko');
set(h,'MarkerFaceColor','k','MarkerSize',decodeInfo.markerSize-6);
h=plot(d.paintGroupedIntensities, d.paintMeans, 'go','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','g');
h=plot(d.shadowGroupedIntensities, d.shadowMeans, 'ko','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','k');
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
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeShadowDecoding'];
drawnow;
FigureSave(figName,decodingfig,decodeInfo.figType);

% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
if (~isempty(d.paintMatchesDiscrete) & ~isempty(d.shadowMatchesDiscrete))
    h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscrete,'ro','MarkerSize',decodeInfo.markerSize,'MarkerFaceColor','r');
    h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscretePred,'r','LineWidth',decodeInfo.lineWidth);
end
xlabel('Decoded Paint Luminance','FontSize',decodeInfo.labelFontSize);
ylabel('Matched Decoded Shadow Luminance','FontSize',decodeInfo.labelFontSize);
switch (decodeInfo.paintShadowFitType)
    case {'intcpt' 'gain'}
        text(0,1,(sprintf('Paint/Shadow Effect: %0.2f',d.paintShadowEffect)),'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
    otherwise
        error('Unknown paint/shadow fit type');
end
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:','LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeShadowInferredMatches'];
drawnow;
FigureSave(figName,predmatchfig,decodeInfo.figType);

%% Store the data for return
decodeInfo.paintShadowEffect = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extPaintShadowEffect'),'decodeSave','-v7.3');


        
  
        

        
       