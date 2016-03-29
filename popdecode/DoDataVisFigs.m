% DoDataVisFigs
%
% Make the figures we want from the "datavis" analysis.
%
% 12/22/15  dhb  Pulled these out.

%% PLOT: output paint/shadow offset versus input paint/shadow offset
visOutputOffsetVersusInputOffsetFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
plot(decodeVis.decodeOffsets,decodeVis.offsetPaintLessShadow(1,:),'ko','MarkerFaceColor','k','MarkerSize',decodeInfoIn.markerSize-10);
plot(decodeVis.decodeOffsets,decodeVis.offsetPaintLessShadow(2,:),'go','MarkerFaceColor','g','MarkerSize',decodeInfoIn.markerSize-10);
plot(decodeVis.decodeOffsets,decodeVis.offsetPaintLessShadow(3,:),'bo','MarkerFaceColor','b','MarkerSize',decodeInfoIn.markerSize-10);

% Add some reference lines
plot(decodeVis.decodeOffsets,zeros(size(decodeVis.decodeOffsets)),'r:','LineWidth',1);
plot(decodeVis.decodeOffsets,decodeVis.decodeOffsets,'r:','LineWidth',1);
plot(decodeVis.decodeOffsets,decodeVis.offsetpspred(1,:),'k','LineWidth',1);
plot(decodeVis.decodeOffsets,paintShadowDecodeMeanDifferenceDiscrete*ones(size(decodeVis.decodeOffsets)),'k:','LineWidth',2);
plot(decodeVis.decodeOffsets,paintShadowMb(1)*ones(size(decodeVis.decodeOffsets)),'b:','LineWidth',2);

% Labels, legends, save
xlabel('Decoding Offset In','FontSize',decodeInfoIn.labelFontSize);
ylabel('Decoding Offset Out','FontSize',decodeInfoIn.labelFontSize);
xlim([-.16 .16]); ylim([-.16 .16]);
decodeVis.titleStr = titleRootStr;
decodeVis.titleStr{end+1} = 'Offset Decoding';
title(decodeVis.titleStr,'FontSize',decodeInfoIn.titleFontSize);
h = legend({ 'Decode direction 1' 'Decode direction 2' 'Decode direction 3' },'FontSize',decodeInfoIn.legendFontSize,'Location','NorthWest');
figName = [figNameRoot '_visOutputOffsetVersusInputOffset'];
FigureSave(figName,visOutputOffsetVersusInputOffsetFig ,decodeInfoIn.figType);

%% PLOT: RMSE versus decoding dimension
visRmseVsDecodingDimFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
plot(1:decodeVis.nDecodeDirs,decodeVis.decodeRMSE,'ko','MarkerFaceColor','k','MarkerSize',decodeInfoIn.markerSize);
xlabel('Decoding Dimension Number','FontSize',decodeInfoIn.labelFontSize);
ylabel('Decoding RMSE','FontSize',decodeInfoIn.labelFontSize);
yl = ylim; ylim([0 0.5]);
decodeVis.titleStr = titleRootStr;
decodeVis.titleStr{end+1} = 'RMSE Versus Decoding Dimension';
title(decodeVis.titleStr,'FontSize',decodeInfoIn.titleFontSize);
drawnow;
figName = [figNameRoot '_visRmseVsDecodingDim'];
FigureSave(figName,visRmseVsDecodingDimFig,decodeInfoIn.figType);

%% PLOT: RMSE versus decoding offest plot.
%  These tend to be pretty flat
visRmseVsDecodingOffsetFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
plot(decodeVis.decodeOffsets,decodeVis.offsetRMSE(1,:),'ko','MarkerFaceColor','k','MarkerSize',decodeInfoIn.markerSize-6);
plot(decodeVis.decodeOffsets,decodeVis.offsetRMSE(2,:),'go','MarkerFaceColor','g','MarkerSize',decodeInfoIn.markerSize-6);
plot(decodeVis.decodeOffsets,decodeVis.offsetRMSE(3,:),'bo','MarkerFaceColor','b','MarkerSize',decodeInfoIn.markerSize-6);

% This provides a visual check that the RMSE we got this way is the same we
% got earlier, but it makes the plots uglier for general consumption.
if (false)
    plot(0,decodeVis.decodeRMSE(1),'ro','MarkerFaceColor','r','MarkerSize',decodeInfoIn.markerSize-12);
    plot(0,decodeVis.decodeRMSE(2),'ro','MarkerFaceColor','r','MarkerSize',decodeInfoIn.markerSize-12);
    plot(0,decodeVis.decodeRMSE(3),'ro','MarkerFaceColor','r','MarkerSize',decodeInfoIn.markerSize-12);
end

% This puts a white dot over the point of minimum RMSE, but the curves are
% so flat that it isn't all that interesting
if (false)
    plot(decodeVis.offsetMinRMSEOffset(1),decodeVis.offsetMinRMSE(1),'wo','MarkerFaceColor','w','MarkerSize',decodeInfoIn.markerSize-16);
    plot(decodeVis.offsetMinRMSEOffset(2),decodeVis.offsetMinRMSE(2),'wo','MarkerFaceColor','w','MarkerSize',decodeInfoIn.markerSize-16);
    plot(decodeVis.offsetMinRMSEOffset(3),decodeVis.offsetMinRMSE(3),'wo','MarkerFaceColor','w','MarkerSize',decodeInfoIn.markerSize-16);
end

xlabel('Decoding Offset In','FontSize',decodeInfoIn.labelFontSize);
ylabel('Offset Decoding RMSE','FontSize',decodeInfoIn.labelFontSize);
h = legend({ 'Decode direction 1' 'Decode direction 2' 'Decode direction 3' },'FontSize',decodeInfoIn.legendFontSize,'Location','NorthEast');
xlim([-.15 .15]); ylim([0 .5]);
decodeVis.titleStr = titleRootStr;
decodeVis.titleStr{end+1} = 'Offset Decoding RMSE';
title(decodeVis.titleStr,'FontSize',decodeInfoIn.titleFontSize);
drawnow;
figName = [figNameRoot '_visRmseVsDecodingOffset'];
FigureSave(figName,visRmseVsDecodingOffsetFig ,decodeInfoIn.figType);

%% PLOT: projection on the best decoding direction and best classificaiton direction,
%  best orthogonal linear classifier.
visDecodeVsClassOrthFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
theGrays = linspace(.4,1,length(decodeVis.uniqueIntensities));
for dc = 1:length(decodeVis.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];

    theIntensity = decodeVis.uniqueIntensities(dc);
    paintIndex = find(paintIntensities == theIntensity);
    shadowIndex = find(shadowIntensities == theIntensity);
    
    % Plot paint and shadow points first, so legend comes out right
    plot(mean(decodeVis.paintPrediction{1}(paintIndex,:),1),mean(decodeVis.paintInClassifyDirectionOrth(paintIndex,:),1),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mean(decodeVis.shadowPrediction{1}(shadowIndex,:),1),mean(decodeVis.shadowInClassifyDirectionOrth(shadowIndex,:),1),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    
    % Add paint error bars
    h = errorbarX(mean(decodeVis.paintPrediction{1}(paintIndex,:),1),mean(decodeVis.paintInClassifyDirectionOrth(paintIndex,:),1), ...
        std(decodeVis.paintPrediction{1}(paintIndex,:),[],1));
    set(h,'Color',theGreen);
    h = errorbar(mean(decodeVis.paintPrediction{1}(paintIndex,:),1),mean(decodeVis.paintInClassifyDirectionOrth(paintIndex,:),1), ...
        std(decodeVis.paintInClassifyDirectionOrth(paintIndex,:),[],1));
    set(h,'Color',theGreen);
    
    % Add shadow error bars
    h = errorbarX(mean(decodeVis.shadowPrediction{1}(shadowIndex,:),1),mean(decodeVis.shadowInClassifyDirectionOrth(shadowIndex,:),1), ...
        std(decodeVis.shadowPrediction{1}(shadowIndex,:),[],1));
    set(h,'Color',theBlack);
    h = errorbar(mean(decodeVis.shadowPrediction{1}(shadowIndex,:),1),mean(decodeVis.shadowInClassifyDirectionOrth(shadowIndex,:),1), ...
        std(decodeVis.shadowInClassifyDirectionOrth(shadowIndex,:),[],1));
    set(h,'Color',theBlack);
end
xlabel('Decode Direction Wgt','FontSize',decodeInfoIn.labelFontSize);
ylabel('Orth Classify Direction Wgt','FontSize',decodeInfoIn.labelFontSize);
decodeVis.titleStr = titleRootStr;
decodeVis.titleStr{end+1} = sprintf('Decode range %0.2f, p/s effect %0.2f, classify %0.1f%%, mean orth %0.2f',...
    mean([decodeInfoOutTemp.decodePaintRange decodeInfoOutTemp.decodeShadowRange]),paintShadowMb(1),100*decodeVis.classifyFractionCorrectOrth,decodeVis.meanOrthResponse);
title(decodeVis.titleStr,'FontSize',decodeInfoIn.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfoIn.legendFontSize,'Location','SouthWest');
drawnow;
figName = [figNameRoot '_visDecodeVsClassOrth'];
FigureSave(figName,visDecodeVsClassOrthFig,decodeInfoIn.figType);

%% PLOT: projection on the best decoding direction and best classificaiton direction,
%  best general linear classifier.
visDecodeVsClassFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
for dc = 1:length(decodeVis.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    theIntensity = decodeVis.uniqueIntensities(dc);
    paintIndex = find(paintIntensities == theIntensity);
    shadowIndex = find(shadowIntensities == theIntensity);

    % Basic points first, so legend comes out right   
    plot(mean(decodeVis.paintPrediction{1}(paintIndex,:),1),mean(decodeVis.paintInClassifyDirection(paintIndex,:),1),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mean(decodeVis.shadowPrediction{1}(shadowIndex,:),1),mean(decodeVis.shadowInClassifyDirection(shadowIndex,:),1),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    
    % Paint error bars
    h = errorbarX(mean(decodeVis.paintPrediction{1}(paintIndex,:),1),mean(decodeVis.paintInClassifyDirection(paintIndex,:),1), ...
        std(decodeVis.paintPrediction{1}(paintIndex,:),[],1));
    set(h,'Color',theGreen);
    h = errorbar(mean(decodeVis.paintPrediction{1}(paintIndex,:),1),mean(decodeVis.paintInClassifyDirection(paintIndex,:),1), ...
        std(decodeVis.paintInClassifyDirection(paintIndex,:),[],1));
    set(h,'Color',theGreen);
    
    % Shadow error bars
    h = errorbarX(mean(decodeVis.shadowPrediction{1}(shadowIndex,:),1),mean(decodeVis.shadowInClassifyDirection(shadowIndex,:),1), ...
        std(decodeVis.shadowPrediction{1}(shadowIndex,:),[],1));
    set(h,'Color',theBlack);
    h = errorbar(mean(decodeVis.shadowPrediction{1}(shadowIndex,:),1),mean(decodeVis.shadowInClassifyDirection(shadowIndex,:),1), ...
        std(decodeVis.shadowInClassifyDirection(shadowIndex,:),[],1));
    set(h,'Color',theBlack);
end
xlabel('Decode Direction Wgt','FontSize',decodeInfoIn.labelFontSize);
ylabel('Classify Direction Wgt','FontSize',decodeInfoIn.labelFontSize);
decodeVis.titleStr = titleRootStr;
decodeVis.titleStr{end+1} = sprintf('Decode range %0.2f, p/s effect %0.2f, classify %0.1f%%, angle %d', ...
    mean([decodeInfoOutTemp.decodePaintRange decodeInfoOutTemp.decodeShadowRange]),paintShadowMb(1),100*decodeVis.classifyFractionCorrect,round(decodeVis.decodeClassifyAngle));
title(decodeVis.titleStr,'FontSize',decodeInfoIn.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfoIn.legendFontSize,'Location','SouthWest');
drawnow;
figName = [figNameRoot '_visDecodeVsClass'];
FigureSave(figName,visDecodeVsClassFig,decodeInfoIn.figType);

%% PLOT: paint and shadow decodings on paint and shadow decoders
visPaintShadowDecodersFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
theGrays = linspace(.4,1,length(decodeVis.uniqueIntensities));
for dc = 1:length(decodeVis.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    theIntensity = decodeVis.uniqueIntensities(dc);
    paintIndex = find(decodeVis.paintIntensities == theIntensity);
    shadowIndex = find(shadowIntensities == theIntensity);

    % Plot paint/shadow points first, so legend comes out right    
    plot(mean(decodeVis.decodePaintDirectonPaintPrediction(paintIndex)),mean(decodeVis.decodeShadowDirectonPaintPrediction(paintIndex)),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mean(decodeVis.decodePaintDirectonShadowPrediction(shadowIndex)),mean(decodeVis.decodeShadowDirectonShadowPrediction(shadowIndex)),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    
    % Paint error bars
    h = errorbarX(mean(decodeVis.decodePaintDirectonPaintPrediction(paintIndex)),mean(decodeVis.decodeShadowDirectonPaintPrediction(paintIndex)), ...
        std(decodeVis.decodePaintDirectonPaintPrediction(paintIndex),[],1));
    set(h,'Color',theGreen);
    h = errorbarX(mean(decodeVis.decodePaintDirectonPaintPrediction(paintIndex)),mean(decodeVis.decodeShadowDirectonPaintPrediction(paintIndex)), ...
        std(decodeVis.decodeShadowDirectonPaintPrediction(paintIndex),[],1));
    set(h,'Color',theGreen);
    
    % Shadow error bars
    h = errorbarX(mean(decodeVis.decodePaintDirectonShadowPrediction(shadowIndex)),mean(decodeVis.decodeShadowDirectonShadowPrediction(shadowIndex)),...
        std(decodeVis.decodePaintDirectonShadowPrediction(shadowIndex),[],1));
    set(h,'Color',theBlack);
    h = errorbar(mean(decodeVis.decodePaintDirectonShadowPrediction(shadowIndex)),mean(decodeVis.decodeShadowDirectonShadowPrediction(shadowIndex)),...
        std(decodeVis.decodeShadowDirectonShadowPrediction(shadowIndex),[],1));
    set(h,'Color',theBlack);
end
plot([0,1],[0,1],'k:','LineWidth',1);
xlabel('Paint decoded value','FontSize',decodeInfoIn.labelFontSize);
ylabel('Shadow decoded value','FontSize',decodeInfoIn.labelFontSize);
xlim([0 1]); ylim([0 1]);
decodeVis.titleStr = titleRootStr;
decodeVis.titleStr{end+1} = sprintf('Separate paint/shadow decoding, angle is %d deg',round(decodeVis.paintShadowDecodeAngle));
title(decodeVis.titleStr,'FontSize',decodeInfoIn.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfoIn.legendFontSize,'Location','NorthWest');
drawnow;
figName = [figNameRoot '_visPaintShadowDecoders'];
FigureSave(figName,visPaintShadowDecodersFig  ,decodeInfoIn.figType);