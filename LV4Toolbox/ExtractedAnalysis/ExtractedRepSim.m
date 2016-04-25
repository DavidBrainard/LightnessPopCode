function ExtractedRepSim(doIt,decodeInfo,theData)
% ExtractedRepSim(doIt,decodeInfo,theData)
%
% Run through and make plots of the respresentational similarity analysis
% for one session.
%
% Designed to be run as a script from RunAndPlotLightnessDecodeExtracted.
%
% 3/29/16  dhb  Pulled this out of main script, as a quasi modularization.
% 4/5/16   dhb  Cleaned up to use new conventions.  Not debugged.

%% Are we doing it?
switch (doIt)
    case 'always'
    case 'never'
        return;
    case 'ifmissing'
        if (exist(fullfile(decodeInfo.writeDataDir,'extRepSim'),'file'))
            return;
        end
end

%% Setup decodeSave
clear decodeSave
decodeSave.uniqueIntensities = decodeInfo.uniqueIntensities;

%% Get similarity matrix based on mean responses as a point of
% departure.
decodeSave.dissimMatrix = ComputePSDissimMatrix(decodeInfo,theData);

% Get the MDS solution
try
    decodeSave.mdsSoln = mdscale(decodeSave.dissimMatrix,2);
catch
    try
        decodeSave.mdsSoln = mdscale(decodeSave.dissimMatrix,2,'Start','random');
    catch
        decodeSave.mdsSoln = cmdscale(decodeSave.dissimMatrix,2);
    end
end

%% Fit the dissimilarity matrix with a stimulus based model of how things might be.
[decodeSave.dissimMatrixFit,decodeSave.fitTau,decodeSave.shadowIntensityShift,decodeSave.exponent] = ...
    FitPSDissimMatrix(decodeSave.uniqueIntensities,decodeSave.dissimMatrix,true,true);

%% Repeat fit without allowing a shift
[decodeSave.noShiftDissimMatrixFit,decodeSave.noShiftTau,decodeSave.noShiftShadowIntensityShift,decodeSave.noShiftExponent] = ...
    FitPSDissimMatrix(decodeSave.uniqueIntensities,decodeSave.dissimMatrix,false,true);
if (decodeSave.noShiftShadowIntensityShift ~= 0)
    error('This should be constrained to zero');
end

%% Do MDS on best fit dissimilarity matrix
try 
    decodeSave.mdsSolnFit = mdscale(decodeSave.dissimMatrixFit,2);
catch
    try
        decodeSave.mdsSolnFit = mdscale(decodeSave.dissimMatrixFit,2,'Start','random');
    catch
        decodeSave.mdsSolnFit = cmdscale(decodeSave.dissimMatrixFit,2,'Start','random');
    end
end
[~,decodeSave.mdsSolnFitPro] = procrustes(decodeSave.mdsSolnFit,decodeSave.mdsSoln);

%% PLOT: The dissimilarity matrix and its fit
dissimMatrixFig = figure; clf;
set(gcf,'Position',decodeInfo.position);
subplot(1,2,1);
imagesc(decodeSave.dissimMatrix); colorbar; axis('square');
title('Dissimilarity Matrix','FontSize',decodeInfo.titleFontSize);
subplot(1,2,2);
imagesc(decodeSave.dissimMatrixFit); colorbar; axis('square');
title(sprintf('Fit: Tau = %0.2f, Shadow Shift = %0.2f, Exponent= %0.2f', ...
    decodeSave.fitTau,decodeSave.shadowIntensityShift,decodeSave.exponent),'FontSize',decodeInfo.titleFontSize);
drawnow;
figName = [decodeInfo.figNameRoot '_extRepSimDissimMatrix'];
FigureSave(figName,dissimMatrixFig,decodeInfo.figType);

%% PLOT: The MDS solution
paintShadowOnMDSFig = figure; clf; hold on;
set(gcf,'Position',decodeInfo.sqPosition);
set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
theGrays = linspace(.4,1,length(decodeSave.uniqueIntensities));
for dc = 1:length(decodeSave.uniqueIntensities)
    theGreen = [0 theGrays(dc) 0];
    theBlack = [theGrays(dc) theGrays(dc) theGrays(dc)];
    
    % Basic points first, so legend comes out right
    plot(decodeSave.mdsSolnFitPro(dc,1),decodeSave.mdsSolnFitPro(dc,2),...
        'o','MarkerSize',15,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(decodeSave.mdsSolnFitPro(dc+length(decodeSave.uniqueIntensities),1),decodeSave.mdsSolnFitPro(dc+length(decodeSave.uniqueIntensities),2),...
        'o','MarkerSize',15,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
    
    plot(decodeSave.mdsSolnFit(dc,1),decodeSave.mdsSolnFit(dc,2),...
        'x','MarkerSize',8,'MarkerFaceColor',theGreen,'MarkerEdgeColor',theGreen);
    plot(decodeSave.mdsSolnFit(dc+length(decodeSave.uniqueIntensities),1),decodeSave.mdsSolnFit(dc+length(decodeSave.uniqueIntensities),2),...
        'x','MarkerSize',8,'MarkerFaceColor',theBlack,'MarkerEdgeColor',theBlack);
end
xlabel('MDS Solution 1 Wgt','FontSize',decodeInfo.labelFontSize);
ylabel('MDS Solution 2 Wgt','FontSize',decodeInfo.labelFontSize);
title(decodeInfo.titleStr,'FontSize',decodeInfo.titleFontSize);
h = legend({ 'Paint' 'Shadow' },'FontSize',decodeInfo.legendFontSize,'Location','SouthWest');
drawnow;
figName = [decodeInfo.figNameRoot '_extRepSimPaintShadowOnMDS'];
FigureSave(figName,paintShadowOnMDSFig,decodeInfo.figType);

%% Store the data for return
decodeInfo.repSim = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extRepSim'),'decodeSave','-v7.3');