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

%% Build decode on both, don't leave one out
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'no';
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
decodeInfo.paintDecodeBothRMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfo.shadowDecodeBothRMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on both, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
decodeInfo.paintDecodeBothLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfo.shadowDecodeBothLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on paint, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
decodeInfo.paintDecodePaintLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfo.shadowDecodePaintLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on shadow, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
decodeInfo.paintDecodeShadowLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfo.shadowDecodeShadowLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on classification direction (by finding that first)
clear decodeInfoTemp
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.classifyReduce = '';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classLooType = decodeInfo.classifyLOOType;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
    theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);
classifyDirection = decodeInfoTempOut.classifyInfo.Beta;
paintResponsesTemp = theData.paintResponses*classifyDirection;
shadowResponsesTemp = theData.shadowResponses*classifyDirection;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    theData.paintIntensities,paintResponsesTemp,theData.shadowIntensities,shadowResponsesTemp);
decodeInfo.paintDecodeClassifyLOORMSE = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfo.shadowDecodeClassifyLOORMSE = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Project data onto a randomly chosen unit vector in the response
% space, and decode based on that.
clear decodeInfoTemp
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.looType = 'ot';
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
for rr = 1:decodeInfo.nRandomVectorRepeats
    theDirection = rand(decodeInfo.nUnits,1);
    theDirection = theDirection/norm(theDirection);
    paintResponsesTemp = theData.paintResponses*theDirection;
    shadowResponsesTemp = theData.shadowResponses*theDirection;
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
        theData.paintIntensities,paintResponsesTemp,theData.shadowIntensities,shadowResponsesTemp);
    decodeInfo.paintDecodeRandomLOORMSE(rr) = sqrt(mean(([theData.paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfo.shadowDecodeRandomLOORMSE(rr) = sqrt(mean(([theData.shadowIntensities(:)]-[shadowPreds(:)]).^2));
end
decodeInfo.paintDecodeRandomLOORMSEMean = mean(decodeInfo.paintDecodeRandomLOORMSE);
decodeInfo.paintDecodeRandomLOORMSEStd = std(decodeInfo.paintDecodeRandomLOORMSE);
decodeInfo.shadowDecodeRandomLOORMSEMean = mean(decodeInfo.paintDecodeRandomLOORMSE);
decodeInfo.shadowDecodeRandomLOORMSEStd = std(decodeInfo.paintDecodeRandomLOORMSE);

%% PLOT: RMSE analyses
rmseAnaysisFig = figure; clf;
nHistobins = 10;
[nPaint,xPaint] = hist(decodeInfo.paintDecodeRandomLOORMSE,nHistobins);
[nShadow,xShadow] = hist(decodeInfo.shadowDecodeRandomLOORMSE,nHistobins);
yMax = max([nPaint(:) ; nShadow(:)]);

set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(2,1,1); hold on;
plot([decodeInfo.paintDecodeBothLOORMSE decodeInfo.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.paintDecodePaintLOORMSE decodeInfo.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.paintDecodeShadowLOORMSE decodeInfo.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.paintDecodeClassifyLOORMSE decodeInfo.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.paintDecodeBothRMSE decodeInfo.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
bar(xPaint,nPaint,'c','EdgeColor','c');
xlim([0,0.5]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Paint RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

subplot(2,1,2); hold on;
plot([decodeInfo.shadowDecodeBothLOORMSE decodeInfo.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.shadowDecodePaintLOORMSE decodeInfo.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.shadowDecodeShadowLOORMSE decodeInfo.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.shadowDecodeClassifyLOORMSE decodeInfo.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfo.shadowDecodeBothRMSE decodeInfo.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
h = bar(xShadow,nShadow,'c','EdgeColor','c');
xlim([0,0.5]);
ylim([0 yMax+1]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Shadow RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

figName = [decodeInfo.figNameRoot '_extRmseAnalysis'];
drawnow;
FigureSave(figName,rmseAnaysisFig,decodeInfo.figType);