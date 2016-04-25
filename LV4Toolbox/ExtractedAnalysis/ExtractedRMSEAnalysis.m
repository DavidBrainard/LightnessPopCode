function ExtractedRMSEAnalysis(doIt,decodeInfo,theData)
% ExtractedRMSEAnalysis(doIt,decodeInfo,theData)
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

%% Are we doing it?
switch (doIt)
    case 'always'
    case 'never'
        return;
    case 'ifmissing'
        if (exist(fullfile(decodeInfo.writeDataDir,'extRMSEAnalysis'),'file'))
            return;
        end
end

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
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeSave.paintDecodeBothRMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeSave.shadowDecodeBothRMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Build decoder on both, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeSave.paintDecodeBothLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeSave.shadowDecodeBothLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeSave.paintDecodeBothLOOMean = mean(paintPreds(:));
decodeSave.shadowDecodeBothLOOMean = mean(shadowPreds(:));
decodeSave.shadowMinusPaintDecodeBothLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on paint, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'paint';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeSave.paintDecodePaintLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeSave.shadowDecodePaintLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeSave.paintDecodePaintLOOMean = mean(paintPreds(:));
decodeSave.shadowDecodePaintLOOMean = mean(shadowPreds(:));
decodeSave.shadowMinusPaintDecodePaintLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on shadow, use one trial LOO to evaluate.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'shadow';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
decodeSave.paintDecodeShadowLOORMSE = sqrt(mean((paintIntensities(:)-paintPreds(:)).^2));
decodeSave.shadowDecodeShadowLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPreds(:)).^2));
decodeSave.paintDecodeShadowLOOMean = mean(paintPreds(:));
decodeSave.shadowDecodeShadowLOOMean = mean(shadowPreds(:));
decodeSave.shadowMinusPaintDecodeShadowLOOMean = mean(shadowPreds(:))-mean(paintPreds(:));

%% Build decoder on classification direction (by finding that first)
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.classifyType = 'mvma';
decodeInfoTemp.MVM_ALG = 'SMO';
decodeInfoTemp.MVM_COMPARECLASS = 0;
decodeInfoTemp.classifyLOOType = decodeInfo.classifyLOOType;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.classifyLOOType = 'no';
decodeInfoTemp.classifyNFolds = 10;
[~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoTempOut] = PaintShadowClassify(decodeInfoTemp, ...
    paintIntensities,paintResponses,shadowIntensities,shadowResponses);
classifyDirection = decodeInfoTempOut.classifyInfo.Beta;
paintResponsesTemp = paintResponses*classifyDirection;
shadowResponsesTemp = shadowResponses*classifyDirection;
[~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
    paintIntensities,paintResponsesTemp,shadowIntensities,shadowResponsesTemp);
decodeSave.paintDecodeClassifyLOORMSE = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
decodeSave.shadowDecodeClassifyLOORMSE = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));

%% Project data onto a randomly chosen unit vector in the response
% space, and decode based on that.
clear decodeInfoTemp
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = 'aff';
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
for rr = 1:decodeInfoTemp.nRandomVectorRepeats
    theDirection = rand(decodeInfoTemp.nUnits,1);
    theDirection = theDirection/norm(theDirection);
    paintResponsesTemp = paintResponses*theDirection;
    shadowResponsesTemp = shadowResponses*theDirection;
    [~,~,paintPreds,shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
        paintIntensities,paintResponsesTemp,shadowIntensities,shadowResponsesTemp);
    decodeSave.paintDecodeRandomLOORMSE(rr) = sqrt(mean(([paintIntensities(:)]-[paintPreds(:)]).^2));
    decodeSave.shadowDecodeRandomLOORMSE(rr) = sqrt(mean(([shadowIntensities(:)]-[shadowPreds(:)]).^2));
end
decodeSave.paintDecodeRandomLOORMSEMean = mean(decodeSave.paintDecodeRandomLOORMSE);
decodeSave.paintDecodeRandomLOORMSEStd = std(decodeSave.paintDecodeRandomLOORMSE);
decodeSave.shadowDecodeRandomLOORMSEMean = mean(decodeSave.paintDecodeRandomLOORMSE);
decodeSave.shadowDecodeRandomLOORMSEStd = std(decodeSave.paintDecodeRandomLOORMSE);

%% PLOT: RMSE analyses
rmseAnaysisFig = figure; clf;
nHistobins = 10;
[nPaint,xPaint] = hist(decodeSave.paintDecodeRandomLOORMSE,nHistobins);
[nShadow,xShadow] = hist(decodeSave.shadowDecodeRandomLOORMSE,nHistobins);
yMax = max([nPaint(:) ; nShadow(:)]);

set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
subplot(2,1,1); hold on;
plot([decodeSave.paintDecodeBothLOORMSE decodeSave.paintDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.paintDecodePaintLOORMSE decodeSave.paintDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.paintDecodeShadowLOORMSE decodeSave.paintDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.paintDecodeClassifyLOORMSE decodeSave.paintDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.paintDecodeBothRMSE decodeSave.paintDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
bar(xPaint,nPaint,'c','EdgeColor','c');
xlim([0,0.5]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Paint RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

subplot(2,1,2); hold on;
plot([decodeSave.shadowDecodeBothLOORMSE decodeSave.shadowDecodeBothLOORMSE],[0 yMax],'k','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.shadowDecodePaintLOORMSE decodeSave.shadowDecodePaintLOORMSE],[0 yMax],'g','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.shadowDecodeShadowLOORMSE decodeSave.shadowDecodeShadowLOORMSE],[0 yMax],'b','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.shadowDecodeClassifyLOORMSE decodeSave.shadowDecodeClassifyLOORMSE],[0 yMax],'r','LineWidth',decodeInfo.lineWidth);
plot([decodeSave.shadowDecodeBothRMSE decodeSave.shadowDecodeBothRMSE],[0 yMax],'k:','LineWidth',1);
h = bar(xShadow,nShadow,'c','EdgeColor','c');
xlim([0,0.5]);
ylim([0 yMax+1]);
legend({'Decode Both', 'Decode Paint', 'Decode Shadow' 'DecodeClassify' 'Decode Both (No LOO)' 'Random'},'Location','NorthEast','FontSize',decodeInfo.legendFontSize-4);
xlabel('Shadow RMSE','FontSize',decodeInfo.labelFontSize);
ylabel('Histogram Count','FontSize',decodeInfo.labelFontSize);

figName = [decodeInfo.figNameRoot '_extRMSEAnalysis'];
drawnow;
FigureSave(figName,rmseAnaysisFig,decodeInfo.figType);

%% Store the data for return
decodeInfo.RMSEAnalysis = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extRMSEAnalysis'),'decodeSave','-v7.3');