% ExtractedRunAndPlotRepresentationalSim
% 
% Run through and make plots of the respresentational similarity analysis
% for one session.
%
% Designed to be run as a script from ExtractedRunAndPlotLightnessDecode.
%
% 3/29/16  dhb  Pulled this out of main script, as a quasi modularization.

% *******
% Representational similarity
%
% Get similarity matrix based on mean responses as a point of
% departure.
for dc = 1:length(decodeInfoOut.uniqueIntensities)
    theIntensity = decodeInfoOut.uniqueIntensities(dc);
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

% Build a p/s model of the dissimilarity matrix
psDissimModel = zeros(size(dissimMatrix));
psDissimModel((end/2)+1:end,1:end/2) = 1;
psDissimModel(1:end/2,(end/2)+1:end) = 1;
%figure;
%imagesc(psDissimModel); colorbar;

% Build a model of the intensity effect, with
% a shift parameter
theShadowIntensityShift = 0;
psIntensityDissimModel = BuildPSIntensityModel(decodeInfoOut.uniqueIntensities,theShadowIntensityShift);
%figure;
%imagesc(psIntensityModel); colorbar;

% Fit the dissimilarity matrix, with various choices of the shadow fit
% for the dissimilarity matrix
theShadowIntensityShifts = linspace(-0.2,0.2,50)';
taus = zeros(size(theShadowIntensityShifts));
for ii = 1:length(theShadowIntensityShifts)
    theShadowIntensityShift = theShadowIntensityShifts(ii);
    psIntensityDissimModel = BuildPSIntensityModel(decodeInfoOut.uniqueIntensities,theShadowIntensityShift);
    modelMatrices{1} = psDissimModel;
    modelMatrices{2} = psIntensityDissimModel;
    [dissimMatrixFits{ii},taus(ii),params(:,ii)] = FitDissimMatrix(dissimMatrix,modelMatrices);
end

% Put a smooth curve through the tau versus shift curve.
decodeInfoOut.tauVersusShiftFit = fit(theShadowIntensityShifts,taus,'poly2');
tausFit = decodeInfoOut.tauVersusShiftFit(theShadowIntensityShifts);
[decodeInfoOut.bestTausFit,index] = max(tausFit);
bestFitIndex = index(1);
decodeInfoOut.bestShadowIntensityShift = theShadowIntensityShifts(bestFitIndex);
decodeInfoOut.dissimMatrixBestFit = dissimMatrixFits{bestFitIndex};
mdsSolnFit = mdscale(decodeInfoOut.dissimMatrixBestFit,2);
[~,mdsSolnPro] = procrustes(mdsSolnFit,mdsSoln);

% PLOT: Quality of fit to dissimilarity matrix with shadow shift
shadowShiftFitFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
plot(theShadowIntensityShifts,taus,'ro','MarkerFaceColor','r','MarkerSize',decodeInfoIn.markerSize-8);
plot(theShadowIntensityShifts,tausFit,'r','LineWidth',decodeInfoIn.lineWidth);
plot(decodeInfoOut.bestShadowIntensityShift,decodeInfoOut.bestTausFit,'go','MarkerFaceColor','g','MarkerSize',decodeInfoIn.markerSize-8);
xlabel('Shadow Intensity Shift','FontSize',decodeInfoIn.labelFontSize);
ylabel('Tau of Fit','FontSize',decodeInfoIn.labelFontSize);
decodeInfoOut.titleStr = titleRootStr;
title(decodeInfoOut.titleStr,'FontSize',decodeInfoIn.titleFontSize);
drawnow;
figName = [figNameRoot '_extDissimFitShadowShift'];
FigureSave(figName,shadowShiftFitFig,decodeInfoIn.figType);

% PLOT: The dissimilarity matrix and its fit
dissimMatrixFig = figure; clf;
set(gcf,'Position',decodeInfoIn.position);
subplot(1,2,1);
imagesc(dissimMatrix); colorbar; axis('square');
title('Dissimilarity Matrix','FontSize',decodeInfoIn.titleFontSize);
subplot(1,2,2);
imagesc(decodeInfoOut.dissimMatrixBestFit); colorbar; axis('square');
title(sprintf('Fit: Shadow Shift = %0.2f',decodeInfoOut.bestShadowIntensityShift),'FontSize',decodeInfoIn.titleFontSize);
drawnow;
figName = [figNameRoot '_extDissimMatrix'];
FigureSave(figName,dissimMatrixFig,decodeInfoIn.figType);

% PLOT: The MDS solution
paintShadowOnMDSFig = figure; clf; hold on;
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
theGrays = linspace(.4,1,length(decodeInfoOut.uniqueIntensities));
for dc = 1:length(decodeInfoOut.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(mdsSolnPro(dc,1),mdsSolnPro(dc,2),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mdsSolnPro(dc+length(decodeInfoOut.uniqueIntensities),1),mdsSolnPro(dc+length(decodeInfoOut.uniqueIntensities),2),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    
    plot(mdsSolnFit(dc,1),mdsSolnFit(dc,2),...
        'x','MarkerSize',8,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(mdsSolnFit(dc+length(decodeInfoOut.uniqueIntensities),1),mdsSolnFit(dc+length(decodeInfoOut.uniqueIntensities),2),...
        'x','MarkerSize',8,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end
xlabel('MDS Solution 1 Wgt','FontSize',decodeInfoIn.labelFontSize);
ylabel('MDS Solution 2 Wgt','FontSize',decodeInfoIn.labelFontSize);
decodeInfoOut.titleStr = titleRootStr;
title(decodeInfoOut.titleStr,'FontSize',decodeInfoIn.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfoIn.legendFontSize,'Location','SouthWest');
drawnow;
figName = [figNameRoot '_extPaintShadowOnMDS'];
FigureSave(figName,paintShadowOnMDSFig,decodeInfoIn.figType);