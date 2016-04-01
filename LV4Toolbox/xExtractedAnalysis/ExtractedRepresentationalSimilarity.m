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
dissimMatrix = ComputePSDissimMatrix(decodeInfo,theData);

% Get the MDS solution
mdsSoln = mdscale(dissimMatrix,2);

%% Fit the dissimilarity matrix with a stimulus based model of how things might be.
[decodeInfo.dissimMatrixFit,decodeInfo.repsimFitTau,decodeInfo.repsimShadowIntensityShift,decodeInfo.repSimIntensityExponent] = ...
    FitPSDissimMatrix(decodeInfo.uniqueIntensities,dissimMatrix);

%% Do MDS on best fit dissimilarity matrix
mdsSolnFit = mdscale(decodeInfo.dissimMatrixFit,2);
[~,mdsSolnPro] = procrustes(mdsSolnFit,mdsSoln);

%% PLOT: The dissimilarity matrix and its fit
dissimMatrixFig = figure; clf;
set(gcf,'Position',decodeInfo.position);
subplot(1,2,1);
imagesc(dissimMatrix); colorbar; axis('square');
title('Dissimilarity Matrix','FontSize',decodeInfo.titleFontSize);
subplot(1,2,2);
imagesc(decodeInfo.dissimMatrixFit); colorbar; axis('square');
title(sprintf('Fit: Tau = %0.2f, Shadow Shift = %0.2f, Exponent= %0.2f', ...
    decodeInfo.repsimFitTau,decodeInfo.repsimShadowIntensityShift,decodeInfo.repSimIntensityExponent),'FontSize',decodeInfo.titleFontSize);
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