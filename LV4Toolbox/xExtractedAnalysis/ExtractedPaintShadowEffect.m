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
[~,~,decodeInfoPaintShadowEffect.paintDecodeBothPreds,decodeInfoPaintShadowEffect.shadowDecodeBothPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoPaintShadowEffect.paintDecodeBothRMSE = sqrt(mean((paintIntensities(:)-decodeInfoPaintShadowEffect.paintDecodeBothPreds(:)).^2));
decodeInfoPaintShadowEffect.shadowDecodeBothRMSE = sqrt(mean((shadowIntensities(:)-decodeInfoPaintShadowEffect.shadowDecodeBothPreds(:)).^2));
decodeInfoPaintShadowEffect.paintDecodeBothMean = mean(decodeInfoPaintShadowEffect.paintDecodeBothPreds(:));
decodeInfoPaintShadowEffect.shadowDecodeBothMean = mean(decodeInfoPaintShadowEffect.shadowDecodeBothPreds(:));
decodeInfoPaintShadowEffect.shadowMinusPaintDecodeBothMean = mean(decodeInfoPaintShadowEffect.shadowDecodeBothPreds(:))-mean(decodeInfoPaintShadowEffect.paintDecodeBothPreds(:));
[decodeInfoPaintShadowEffect.paintDecodeBothMeans,decodeInfoPaintShadowEffect.paintDecodeBothSEMs,~,~,~,decodeInfoPaintShadowEffect.paintDecodeBothGroupedIntensities] = ...
    sortbyx(paintIntensities,decodeInfoPaintShadowEffect.paintDecodeBothPreds);
[decodeInfoPaintShadowEffect.shadowDecodeBothMeans,decodeInfoPaintShadowEffect.shadowDecodeBothSEMs,~,~,~,decodeInfoPaintShadowEffect.shadowDecodeBothGroupedIntensities] = ...
    sortbyx(shadowIntensities,decodeInfoPaintShadowEffect.shadowDecodeBothPreds);
[paintShadowEffect] = ...
    FindPaintShadowEffect(decodeInfoTemp,decodeInfoPaintShadowEffect.paintDecodeBothGroupedIntensities,decodeInfoPaintShadowEffect.shadowDecodeBothGroupedIntensities, ...
    decodeInfoPaintShadowEffect.paintDecodeBothMeans,decodeInfoPaintShadowEffect.shadowDecodeBothMeans);

%% Build decoder on paint
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoPaintShadowEffect.paintDecodePaintRMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoPaintShadowEffect.shadowDecodePaintRMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoPaintShadowEffect.paintDecodePaintMean = mean(paintPreds(:));
decodeInfoPaintShadowEffect.shadowDecodePaintMean = mean(shadowPreds(:));
decodeInfoPaintShadowEffect.shadowMinusPaintDecodePaintMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on shadow, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoPaintShadowEffect.paintDecodeShadowLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoPaintShadowEffect.shadowDecodeShadowLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoPaintShadowEffect.paintDecodeShadowLOOMean = mean(paintPreds(:));
decodeInfoPaintShadowEffect.shadowDecodeShadowLOOMean = mean(shadowPreds(:));
decodeInfoPaintShadowEffect.shadowMinusPaintDecodeShadowLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));


%% PLOT: RMSE analyses
rmseAnaysisFig = figure; clf;
nHistobins = 10;
[nPaint,xPaint] = hist(decodeInfoPaintShadowEffect.paintDecodeRandomLOORMSE,nHistobins);
[nShadow,xShadow] = hist(decodeInfoPaintShadowEffect.shadowDecodeRandomLOORMSE,nHistobins);
yMax = max([nPaint(:) ; nShadow(:)]);

set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(2,1,1); hold on;
plot([decodeInfoPaintShadowEffect.paintDecodeBothLOORMSE decodeInfoPaintShadowEffect.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.paintDecodePaintLOORMSE decodeInfoPaintShadowEffect.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.paintDecodeShadowLOORMSE decodeInfoPaintShadowEffect.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.paintDecodeClassifyLOORMSE decodeInfoPaintShadowEffect.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.paintDecodeBothRMSE decodeInfoPaintShadowEffect.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
bar(xPaint,nPaint,'c','EdgeColor','c');
xlim([0,0.5]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Paint RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

subplot(2,1,2); hold on;
plot([decodeInfoPaintShadowEffect.shadowDecodeBothLOORMSE decodeInfoPaintShadowEffect.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.shadowDecodePaintLOORMSE decodeInfoPaintShadowEffect.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.shadowDecodeShadowLOORMSE decodeInfoPaintShadowEffect.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.shadowDecodeClassifyLOORMSE decodeInfoPaintShadowEffect.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoPaintShadowEffect.shadowDecodeBothRMSE decodeInfoPaintShadowEffect.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
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
decodeInfo.PaintShadowEffect = decodeInfoPaintShadowEffect;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extPaintShadowEffect'),'decodeInfoPaintShadowEffect','-v7.3');


        
  
        

        
       