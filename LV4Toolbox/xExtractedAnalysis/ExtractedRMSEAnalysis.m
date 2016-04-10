function decodeInfo = ExtractRMSEAnalysis(decodeInfo,theData)
% decodeInfo = ExtractRMSEAnalysis(decodeInfo,theData)
%
% Analyze how paint and shadow RMSE/Prediction compare with each other when
% decoder is built with both, built with paint only, built with shadow
% only, is chosen randomly, is built to classify, etc.  This will
% provide some measures of how intertwined paint and shadow are, as
% well as how well aligned decode and classification directions are.
% Doing it this way is based on our sense that almost all angles in
% high dimensions are at near 90 degrees, so that looking at angle
% doesn't provide good intuitions.
%
% 3/29/16  dhb  Pulled this out as a function

%% Shuffle just once in this whole function, if desired
clear decodeInfoTemp
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% Build decode on both, don't leave one out
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'no';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoKeep.paintDecodeBothRMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoKeep.shadowDecodeBothRMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on both, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoKeep.paintDecodeBothLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoKeep.shadowDecodeBothLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoKeep.paintDecodeBothLOOMean = mean(paintPreds(:));
decodeInfoKeep.shadowDecodeBothLOOMean = mean(shadowPreds(:));
decodeInfoKeep.shadowMinusPaintDecodeBothLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on paint, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoKeep.paintDecodePaintLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoKeep.shadowDecodePaintLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoKeep.paintDecodePaintLOOMean = mean(paintPreds(:));
decodeInfoKeep.shadowDecodePaintLOOMean = mean(shadowPreds(:));
decodeInfoKeep.shadowMinusPaintDecodePaintLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on shadow, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoKeep.paintDecodeShadowLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoKeep.shadowDecodeShadowLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoKeep.paintDecodeShadowLOOMean = mean(paintPreds(:));
decodeInfoKeep.shadowDecodeShadowLOOMean = mean(shadowPreds(:));
decodeInfoKeep.shadowMinusPaintDecodeShadowLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on classification direction (by finding that first)
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.classifyReduce = '';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classLooType = decodeInfo.classifyLOOType;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
[~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
classifyDirection = decodeInfoTempOut.classifyInfo.Beta;
paintResponsesTemp = paintResponses*classifyDirection;
shadowResponsesTemp = shadowResponses*classifyDirection;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponsesTemp,shadowIntensities,shadowResponsesTemp);
decodeInfoKeep.paintDecodeClassifyLOORMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoKeep.shadowDecodeClassifyLOORMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Project data onto a randomly chosen unit vector in the response
% space, and decode based on that.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
for rr = 1:decodeInfoTemp.nRandomVectorRepeats
    theDirection = rand(decodeInfoTemp.nUnits,1);
    theDirection = theDirection/norm(theDirection);
    paintResponsesTemp = paintResponses*theDirection;
    shadowResponsesTemp = shadowResponses*theDirection;
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
        paintIntensities,paintResponsesTemp,shadowIntensities,shadowResponsesTemp);
    decodeInfoKeep.paintDecodeRandomLOORMSE(rr) = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoKeep.shadowDecodeRandomLOORMSE(rr) = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));
end
decodeInfoKeep.paintDecodeRandomLOORMSEMean = mean(decodeInfoKeep.paintDecodeRandomLOORMSE);
decodeInfoKeep.paintDecodeRandomLOORMSEStd = std(decodeInfoKeep.paintDecodeRandomLOORMSE);
decodeInfoKeep.shadowDecodeRandomLOORMSEMean = mean(decodeInfoKeep.paintDecodeRandomLOORMSE);
decodeInfoKeep.shadowDecodeRandomLOORMSEStd = std(decodeInfoKeep.paintDecodeRandomLOORMSE);

%% PLOT: RMSE analyses
rmseAnaysisFig = figure; clf;
nHistobins = 10;
[nPaint,xPaint] = hist(decodeInfoKeep.paintDecodeRandomLOORMSE,nHistobins);
[nShadow,xShadow] = hist(decodeInfoKeep.shadowDecodeRandomLOORMSE,nHistobins);
yMax = max([nPaint(:) ; nShadow(:)]);

set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(2,1,1); hold on;
plot([decodeInfoKeep.paintDecodeBothLOORMSE decodeInfoKeep.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.paintDecodePaintLOORMSE decodeInfoKeep.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.paintDecodeShadowLOORMSE decodeInfoKeep.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.paintDecodeClassifyLOORMSE decodeInfoKeep.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.paintDecodeBothRMSE decodeInfoKeep.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
bar(xPaint,nPaint,'c','EdgeColor','c');
xlim([0,0.5]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Paint RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

subplot(2,1,2); hold on;
plot([decodeInfoKeep.shadowDecodeBothLOORMSE decodeInfoKeep.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.shadowDecodePaintLOORMSE decodeInfoKeep.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.shadowDecodeShadowLOORMSE decodeInfoKeep.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.shadowDecodeClassifyLOORMSE decodeInfoKeep.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoKeep.shadowDecodeBothRMSE decodeInfoKeep.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
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
decodeInfo.RMSEAnalysis = decodeInfoKeep;