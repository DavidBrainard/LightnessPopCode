function decodeInfo = ExtractedRMSEVersusNPCA(decodeInfo,theData)
% decodeInfo = ExtractedRMSEVersusNPCA(decodeInfo,theData)
%
% Study decoding performance as a function of number of PCA dimensions
%
% 3/29/16  dhb  Pulled it out.
% 4/5/16   dhb  Cleaned up to use new conventions.  Not debugged.

%% Get info about what to do
nUnitsToUseList = unique([1 2 round(logspace(0,log10(decodeInfo.nUnits),decodeInfo.nNUnitsToStudy))]);
uniqueNUnitsToStudy = length(nUnitsToUseList);

%% Set up needed parameters
clear decodeSave
decodeSave.verbose = decodeInfo.verbose;
decodeSave.nUnits = decodeInfo.nUnits;
decodeSave.nFitMaxUnits = decodeInfo.nFitMaxUnits;
decodeSave.nNUnitsToStudy = decodeInfo.nNUnitsToStudy;
decodeSave.nRepeatsPerNUnits = decodeInfo.nRepeatsPerNUnits;
decodeSave.decodeJoint = 'both';
decodeSave.type = 'aff';
decodeSave.decodeLOOType = decodeInfo.decodeLOOType;
decodeSave.decodeNFolds = decodeInfo.decodeNFolds;
decodeSave.trialShuffleType = 'none';
decodeSave.paintShadowShuffleType = 'none';

%% Shuffle if desired
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% Get PCA
dataForPCA = [paintResponses ; shadowResponses];
clear decodeInfoPCA
decodeInfoPCA.pcaType = 'ml';
decodeInfoPCA.pcaKeep = decodeInfo.nUnits;
meanDataForPCA = mean(dataForPCA,1);
[paintPCAResponses,shadowPCAResponses] = PaintShadowPCA(decodeInfoPCA,paintResponses,shadowResponses);

% Get RMSE as a function of number of PCA components
decodeSave.theUnits = zeros(uniqueNUnitsToStudy,1);
decodeSave.theRMSE = zeros(uniqueNUnitsToStudy,1);
for uu = 1:uniqueNUnitsToStudy
    decodeInfo.nUnitsToUse = nUnitsToUseList(uu);
    [~,~,paintPCAPreds,shadowPCAPreds] = PaintShadowDecode(decodeSave, ...
        paintIntensities,paintPCAResponses(:,1:decodeInfo.nUnitsToUse),shadowIntensities,shadowPCAResponses(:,1:decodeInfo.nUnitsToUse));
    decodeSave.theRMSE(uu) = sqrt(mean(([theData.paintIntensities(:) ; theData.shadowIntensities(:)]-[paintPCAPreds(:) ; shadowPCAPreds(:)]).^2));
    decodeSave.theUnits(uu) = decodeInfo.nUnitsToUse;
end

% Fit an exponential
a0 = max(decodeSave.theRMSE); b0 = 5; c0 = min(decodeSave.theRMSE);
foptions = fitoptions('Lower',[0 2 0],'Upper',[5 200 5]);
index = find(decodeSave.theUnits <= decodeInfo.nFitMaxUnits);
decodeSave.fit = fit(decodeSave.theUnits(index),decodeSave.theRMSE(index),'a*exp(-(x-1)/(b-1)) + c',foptions,'StartPoint',[a0 b0 c0]);
decodeSave.rmse = c0;
decodeSave.fitScale = decodeSave.fit.b;
decodeSave.fitAsymp = decodeSave.fit.c;

% PLOT: RMSE versus number of PCA components used to decode
RMSEVersusNPCAfig = figure; clf;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
smoothX = (1:decodeInfo.nUnits)';
h = plot(smoothX,decodeSave.fit(smoothX),'k','LineWidth',decodeInfo.lineWidth);
h = plot(decodeSave.theUnits,decodeSave.theRMSE,'ro','MarkerFaceColor','r','MarkerSize',4);
h = plot(decodeSave.fitScale,decodeSave.fit(decodeSave.fitScale),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Number of PCA Components','FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance RMSE','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
xlim([0,100]);
ylim([0,0.5]);
axis square
figName = [decodeInfo.figNameRoot '_extRMSEVersusNPCA'];
drawnow;
FigureSave(figName,RMSEVersusNPCAfig,decodeInfo.figType);

% PLOT: paint/shadow mean responses on PCA 1 and 2, where we compute
% the PCA on the mean responses.
%
% I am not sure whether this is a useful figure, and if it is whether
% the pca should be computed on the mean responses or the raw responses.
for dc = 1:length(decodeInfo.uniqueIntensities)
    theIntensity = decodeInfo.uniqueIntensities(dc);
    paintIndex = find(theData.paintIntensities == theIntensity);
    shadowIndex = find(theData.shadowIntensities == theIntensity);
    meanPaintResponses(dc,:) = mean(theData.paintResponses(paintIndex,:),1);
    meanShadowResponses(dc,:) = mean(theData.shadowResponses(shadowIndex,:),1);
end
clear decodeInfoPCA
decodeInfoPCA.pcaType = 'ml';
decodeInfoPCA.pcaKeep = decodeInfo.nUnits;
[decodeSave.meanPaintPCAResponses, decodeSave.meanShadowPCAResponses] = ...
    PaintShadowPCA(decodeInfoPCA,meanPaintResponses,meanShadowResponses);

paintShadowOnPCAFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
theGrays = linspace(.4,1,length(decodeInfo.uniqueIntensities));
for dc = 1:length(decodeInfo.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(mean(decodeSave.meanPaintPCAResponses(dc,1)),mean(decodeSave.meanPaintPCAResponses(dc,2)),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mean(decodeSave.meanShadowPCAResponses(dc,1)),mean(decodeSave.meanShadowPCAResponses(dc,2)),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end
xlabel('PCA Component 1 Wgt','FontSize',decodeInfo.labelFontSize);
ylabel('PCA Component 2 Wgt','FontSize',decodeInfo.labelFontSize);
decodeInfo.titleStr = decodeInfo.titleStr;
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfo.legendFontSize,'Location','SouthWest');
drawnow;
figName = [decodeInfo.figNameRoot '_extRMSEVersusNPCAPaintShadowOnMeanPCA'];
FigureSave(figName,paintShadowOnPCAFig,decodeInfo.figType);

%% Store the data for return
decodeInfo.RMSEVersusNPCA = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extRMSEVersusNPCA '),'decodeSave','-v7.3');