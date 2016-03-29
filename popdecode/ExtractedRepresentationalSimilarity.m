function decodeInfo = ExtractedRepresentationalSimilarity(decodeInfo,theData)
% decodeInfo = ExtractedRepresentationalSimilarity(decodeInfo,theData)
% 
% Run through and make plots of the respresentational similarity analysis
% for one session.
%
% Designed to be run as a script from RunAndPlotLightnessDecodeExtracted.
%
% 3/29/16  dhb  Pulled this out of main script, as a quasi modularization.

%% Get similarity matrix based on mean responses as a point of
% departure.
for dc = 1:length(decodeInfo.uniqueIntensities)
    theIntensity = decodeInfo.uniqueIntensities(dc);
    paintIndex = find(theData.paintIntensities == theIntensity);
    shadowIndex = find(theData.shadowIntensities == theIntensity);
    meanPaintResponses(dc,:) = mean(theData.paintResponses(paintIndex,:),1);
    meanShadowResponses(dc,:) = mean(theData.shadowResponses(shadowIndex,:),1);
end
dataMatrixForCorr = [meanPaintResponses ; meanShadowResponses];
corrMatrix = corrcoef(dataMatrixForCorr');
dissimMatrix = 1-corrMatrix; dissimMatrix = dissimMatrix+dissimMatrix';
%dissimMatrix = log10(1./(corrMatrix + .05)); dissimMatrix = dissimMatrix - min(dissimMatrix(:)); dissimMatrix = dissimMatrix+dissimMatrix';
mdsSoln = mdscale(dissimMatrix,2);

%% Build a p/s model of the dissimilarity matrix
psDissimModel = zeros(size(dissimMatrix));
psDissimModel((end/2)+1:end,1:end/2) = 1;
psDissimModel(1:end/2,(end/2)+1:end) = 1;
%figure;
%imagesc(psDissimModel); colorbar;

%% Build a model of the intensity effect, with a shift parameter
theShadowIntensityShift = 0;
psIntensityDissimModel = BuildPSIntensityModel(decodeInfo.uniqueIntensities,theShadowIntensityShift);
%figure;
%imagesc(psIntensityModel); colorbar;

%% Fit the dissimilarity matrix
%
% Explore various choices of the shadow fit for the dissimilarity matrix
theShadowIntensityShifts = linspace(-0.2,0.2,50)';
taus = zeros(size(theShadowIntensityShifts));
for ii = 1:length(theShadowIntensityShifts)
    theShadowIntensityShift = theShadowIntensityShifts(ii);
    psIntensityDissimModel = BuildPSIntensityModel(decodeInfo.uniqueIntensities,theShadowIntensityShift);
    modelMatrices{1} = psDissimModel;
    modelMatrices{2} = psIntensityDissimModel;
    [dissimMatrixFits{ii},taus(ii),params(:,ii)] = FitDissimMatrix(dissimMatrix,modelMatrices);
end

%% Put a smooth curve through the tau versus shift curve.
decodeInfo.tauVersusShiftFit = fit(theShadowIntensityShifts,taus,'poly2');
tausFit = decodeInfo.tauVersusShiftFit(theShadowIntensityShifts);
[decodeInfo.bestTausFit,index] = max(tausFit);
bestFitIndex = index(1);
decodeInfo.bestShadowIntensityShift = theShadowIntensityShifts(bestFitIndex);
decodeInfo.dissimMatrixBestFit = dissimMatrixFits{bestFitIndex};
mdsSolnFit = mdscale(decodeInfo.dissimMatrixBestFit,2);
[~,mdsSolnPro] = procrustes(mdsSolnFit,mdsSoln);

%% PLOT: Quality of fit to dissimilarity matrix with shadow shift
shadowShiftFitFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
plot(theShadowIntensityShifts,taus,'ro','MarkerFaceColor','r','MarkerSize',decodeInfo.markerSize-8);
plot(theShadowIntensityShifts,tausFit,'r','LineWidth',decodeInfo.lineWidth);
plot(decodeInfo.bestShadowIntensityShift,decodeInfo.bestTausFit,'go','MarkerFaceColor','g','MarkerSize',decodeInfo.markerSize-8);
xlabel('Shadow Intensity Shift','FontSize',decodeInfo.labelFontSize);
ylabel('Tau of Fit','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
drawnow;
figName = [decodeInfo.figNameRoot '_extDissimFitShadowShift'];
FigureSave(figName,shadowShiftFitFig,decodeInfo.figType);

%% PLOT: The dissimilarity matrix and its fit
dissimMatrixFig = figure; clf;
set(gcf,'Position',decodeInfo.position);
subplot(1,2,1);
imagesc(dissimMatrix); colorbar; axis('square');
title('Dissimilarity Matrix','FontSize',decodeInfo.titleFontSize);
subplot(1,2,2);
imagesc(decodeInfo.dissimMatrixBestFit); colorbar; axis('square');
title(sprintf('Fit: Shadow Shift = %0.2f',decodeInfo.bestShadowIntensityShift),'FontSize',decodeInfo.titleFontSize);
drawnow;
figName = [decodeInfo.figNameRoot '_extDissimMatrix'];
FigureSave(figName,dissimMatrixFig,decodeInfo.figType);

%% PLOT: The MDS solution
paintShadowOnMDSFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
theGrays = linspace(.4,1,length(decodeInfo.uniqueIntensities));
for dc = 1:length(decodeInfo.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(mdsSolnPro(dc,1),mdsSolnPro(dc,2),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mdsSolnPro(dc+length(decodeInfo.uniqueIntensities),1),mdsSolnPro(dc+length(decodeInfo.uniqueIntensities),2),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    
    plot(mdsSolnFit(dc,1),mdsSolnFit(dc,2),...
        'x','MarkerSize',8,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mdsSolnFit(dc+length(decodeInfo.uniqueIntensities),1),mdsSolnFit(dc+length(decodeInfo.uniqueIntensities),2),...
        'x','MarkerSize',8,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end
xlabel('MDS Solution 1 Wgt','FontSize',decodeInfo.labelFontSize);
ylabel('MDS Solution 2 Wgt','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfo.legendFontSize,'Location','SouthWest');
drawnow;
figName = [decodeInfo.figNameRoot '_extPaintShadowOnMDS'];
FigureSave(figName,paintShadowOnMDSFig,decodeInfo.figType);