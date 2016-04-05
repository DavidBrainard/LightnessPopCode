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
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'no';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoTemp.paintDecodeBothRMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoTemp.shadowDecodeBothRMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));


%% Build decoder on both, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoTemp.paintDecodeBothLOORMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoTemp.shadowDecodeBothLOORMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on paint, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoTemp.paintDecodePaintLOORMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoTemp.shadowDecodePaintLOORMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on shadow, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoTemp.paintDecodeShadowLOORMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoTemp.shadowDecodeShadowLOORMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on classification direction (by finding that first)
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
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
decodeInfoTemp.paintDecodeClassifyLOORMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoTemp.shadowDecodeClassifyLOORMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Project data onto a randomly chosen unit vector in the response
% space, and decode based on that.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nFitMaxUnits = decodeInfo.nFitMaxUnits;
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
    decodeInfoTemp.paintDecodeRandomLOORMSE(rr) = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoTemp.shadowDecodeRandomLOORMSE(rr) = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));
end
decodeInfoTemp.paintDecodeRandomLOORMSEMean = mean(decodeInfoTemp.paintDecodeRandomLOORMSE);
decodeInfoTemp.paintDecodeRandomLOORMSEStd = std(decodeInfoTemp.paintDecodeRandomLOORMSE);
decodeInfoTemp.shadowDecodeRandomLOORMSEMean = mean(decodeInfoTemp.paintDecodeRandomLOORMSE);
decodeInfoTemp.shadowDecodeRandomLOORMSEStd = std(decodeInfoTemp.paintDecodeRandomLOORMSE);

%% PLOT: RMSE analyses
rmseAnaysisFig = figure; clf;
nHistobins = 10;
[nPaint,xPaint] = hist(decodeInfoTemp.paintDecodeRandomLOORMSE,nHistobins);
[nShadow,xShadow] = hist(decodeInfoTemp.shadowDecodeRandomLOORMSE,nHistobins);
yMax = max([nPaint(:) ; nShadow(:)]);

set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(2,1,1); hold on;
plot([decodeInfoTemp.paintDecodeBothLOORMSE decodeInfoTemp.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.paintDecodePaintLOORMSE decodeInfoTemp.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.paintDecodeShadowLOORMSE decodeInfoTemp.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.paintDecodeClassifyLOORMSE decodeInfoTemp.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.paintDecodeBothRMSE decodeInfoTemp.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
bar(xPaint,nPaint,'c','EdgeColor','c');
xlim([0,0.5]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Paint RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

subplot(2,1,2); hold on;
plot([decodeInfoTemp.shadowDecodeBothLOORMSE decodeInfoTemp.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.shadowDecodePaintLOORMSE decodeInfoTemp.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.shadowDecodeShadowLOORMSE decodeInfoTemp.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.shadowDecodeClassifyLOORMSE decodeInfoTemp.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoTemp.shadowDecodeBothRMSE decodeInfoTemp.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
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
decodeInfo.RMSEVersusNPCA = decodeInfoTemp;