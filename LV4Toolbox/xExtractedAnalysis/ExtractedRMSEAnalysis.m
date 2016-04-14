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
decodeInfoTemp.decodeLOOType = 'no';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoRMSEAnalysis.paintDecodeBothRMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoRMSEAnalysis.shadowDecodeBothRMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on both, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoRMSEAnalysis.paintDecodeBothLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoRMSEAnalysis.shadowDecodeBothLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoRMSEAnalysis.paintDecodeBothLOOMean = mean(paintPreds(:));
decodeInfoRMSEAnalysis.shadowDecodeBothLOOMean = mean(shadowPreds(:));
decodeInfoRMSEAnalysis.shadowMinusPaintDecodeBothLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on paint, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoRMSEAnalysis.paintDecodePaintLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoRMSEAnalysis.shadowDecodePaintLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoRMSEAnalysis.paintDecodePaintLOOMean = mean(paintPreds(:));
decodeInfoRMSEAnalysis.shadowDecodePaintLOOMean = mean(shadowPreds(:));
decodeInfoRMSEAnalysis.shadowMinusPaintDecodePaintLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on shadow, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeInfoRMSEAnalysis.paintDecodeShadowLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeInfoRMSEAnalysis.shadowDecodeShadowLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeInfoRMSEAnalysis.paintDecodeShadowLOOMean = mean(paintPreds(:));
decodeInfoRMSEAnalysis.shadowDecodeShadowLOOMean = mean(shadowPreds(:));
decodeInfoRMSEAnalysis.shadowMinusPaintDecodeShadowLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on classification direction (by finding that first)
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.classifyReduce = '';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifydecodeLOOType = decodeInfo.classifydecodeLOOType;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
[~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
classifyDirection = decodeInfoTempOut.classifyInfo.Beta;
paintResponsesTemp = paintResponses*classifyDirection;
shadowResponsesTemp = shadowResponses*classifyDirection;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponsesTemp,shadowIntensities,shadowResponsesTemp);
decodeInfoRMSEAnalysis.paintDecodeClassifyLOORMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeInfoRMSEAnalysis.shadowDecodeClassifyLOORMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Project data onto a randomly chosen unit vector in the response
% space, and decode based on that.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = 'ot';
for rr = 1:decodeInfoTemp.nRandomVectorRepeats
    theDirection = rand(decodeInfoTemp.nUnits,1);
    theDirection = theDirection/norm(theDirection);
    paintResponsesTemp = paintResponses*theDirection;
    shadowResponsesTemp = shadowResponses*theDirection;
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
        paintIntensities,paintResponsesTemp,shadowIntensities,shadowResponsesTemp);
    decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSE(rr) = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeInfoRMSEAnalysis.shadowDecodeRandomLOORMSE(rr) = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));
end
decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSEMean = mean(decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSE);
decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSEStd = std(decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSE);
decodeInfoRMSEAnalysis.shadowDecodeRandomLOORMSEMean = mean(decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSE);
decodeInfoRMSEAnalysis.shadowDecodeRandomLOORMSEStd = std(decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSE);

%% PLOT: RMSE analyses
rmseAnaysisFig = figure; clf;
nHistobins = 10;
[nPaint,xPaint] = hist(decodeInfoRMSEAnalysis.paintDecodeRandomLOORMSE,nHistobins);
[nShadow,xShadow] = hist(decodeInfoRMSEAnalysis.shadowDecodeRandomLOORMSE,nHistobins);
yMax = max([nPaint(:) ; nShadow(:)]);

set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(2,1,1); hold on;
plot([decodeInfoRMSEAnalysis.paintDecodeBothLOORMSE decodeInfoRMSEAnalysis.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.paintDecodePaintLOORMSE decodeInfoRMSEAnalysis.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.paintDecodeShadowLOORMSE decodeInfoRMSEAnalysis.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.paintDecodeClassifyLOORMSE decodeInfoRMSEAnalysis.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.paintDecodeBothRMSE decodeInfoRMSEAnalysis.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
bar(xPaint,nPaint,'c','EdgeColor','c');
xlim([0,0.5]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Paint RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

subplot(2,1,2); hold on;
plot([decodeInfoRMSEAnalysis.shadowDecodeBothLOORMSE decodeInfoRMSEAnalysis.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.shadowDecodePaintLOORMSE decodeInfoRMSEAnalysis.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.shadowDecodeShadowLOORMSE decodeInfoRMSEAnalysis.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.shadowDecodeClassifyLOORMSE decodeInfoRMSEAnalysis.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeInfoRMSEAnalysis.shadowDecodeBothRMSE decodeInfoRMSEAnalysis.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
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
decodeInfo.RMSEAnalysis = decodeInfoRMSEAnalysis;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extRMSEAnalysis'),'decodeInfoRMSEAnalysis','-v7.3');