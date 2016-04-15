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
clear decodeInfoTemp
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
[~,~,d.paintDecodeBothPreds,d.shadowDecodeBothPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintDecodeBothRMSE = sqrt(mean((paintIntensities(:)-d.paintDecodeBothPreds(:)).^2));
d.shadowDecodeBothRMSE = sqrt(mean((shadowIntensities(:)-d.shadowDecodeBothPreds(:)).^2));
d.paintDecodeBothMean = mean(d.paintDecodeBothPreds(:));
d.shadowDecodeBothMean = mean(d.shadowDecodeBothPreds(:));
d.shadowMinusPaintDecodeBothMean = mean(d.shadowDecodeBothPreds(:))-mean(d.paintDecodeBothPreds(:));
[d.paintDecodeBothMeans,d.paintDecodeBothSEMs,~,~,~,d.paintDecodeBothGroupedIntensities] = ...
    sortbyx(paintIntensities,d.paintDecodeBothPreds);
[d.shadowDecodeBothMeans,d.shadowDecodeBothSEMs,~,~,~,d.shadowDecodeBothGroupedIntensities] = ...
    sortbyx(shadowIntensities,d.shadowDecodeBothPreds);
[d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
    d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
    FindPaintShadowEffect(decodeInfoTemp,d.paintDecodeBothGroupedIntensities,d.shadowDecodeBothGroupedIntensities,d.paintDecodeBothMeans,d.shadowDecodeBothMeans);

% PLOT: decoded intensities, for decoding on both paint and shadow
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

%% PLOT: Inferred matches with a fit line
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
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintDecodePaintRMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
d.shadowDecodePaintRMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
d.paintDecodePaintMean = mean(paintPreds(:));
d.shadowDecodePaintMean = mean(shadowPreds(:));
d.shadowMinusPaintDecodePaintMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on shadow, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
d.paintDecodeShadowLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
d.shadowDecodeShadowLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
d.paintDecodeShadowLOOMean = mean(paintPreds(:));
d.shadowDecodeShadowLOOMean = mean(shadowPreds(:));
d.shadowMinusPaintDecodeShadowLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));


%% PLOT: RMSE analyses
rmseAnaysisFig = figure; clf;
nHistobins = 10;
[nPaint,xPaint] = hist(d.paintDecodeRandomLOORMSE,nHistobins);
[nShadow,xShadow] = hist(d.shadowDecodeRandomLOORMSE,nHistobins);
yMax = max([nPaint(:) ; nShadow(:)]);

set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(2,1,1); hold on;
plot([d.paintDecodeBothLOORMSE d.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([d.paintDecodePaintLOORMSE d.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([d.paintDecodeShadowLOORMSE d.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([d.paintDecodeClassifyLOORMSE d.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([d.paintDecodeBothRMSE d.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
bar(xPaint,nPaint,'c','EdgeColor','c');
xlim([0,0.5]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Paint RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

subplot(2,1,2); hold on;
plot([d.shadowDecodeBothLOORMSE d.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([d.shadowDecodePaintLOORMSE d.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([d.shadowDecodeShadowLOORMSE d.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([d.shadowDecodeClassifyLOORMSE d.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([d.shadowDecodeBothRMSE d.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
h = bar(xShadow,nShadow,'c','EdgeColor','c');
xlim([0,0.5]);
ylim([0 yMax+1]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Shadow RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

figName = [decodeInfo.figNameRoot '_extRmseAnalysis'];
drawnow;
FigureSave(figName,rmseAnaysisFig,decodeInfo.figType);

%% Store the data for return
decodeInfoPaintShadowEffect = d;
decodeInfo.paintShadowEffect = decodeInfoPaintShadowEffect;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extPaintShadowEffect'),'decodeInfoPaintShadowEffect','-v7.3');


        
  
        

        
       