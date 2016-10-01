function RepSimSummaryPlots(basicInfoAll,paintShadowEffect,repSim,summaryDir,figParams)
% RepSimSummaryPlots(basicInfoAll,paintShadowEffect,repSim,summaryDir,figParams)
%
% Summary plots of the representational similarity analysis.
%
% 4/19/16  dhb  Wrote it.

%% Additional parameters
figParams.bumpSizeForMean = 6;
repSimSubdir = 'RepSim';
repSimDir = fullfile(summaryDir,repSimSubdir,'');
if (~exist(repSimDir,'dir'))
    mkdir(repSimDir);
end

%% Get the inclusion boolean based on decoding RMSE
%
% Extract the decode both results from the top level structure, and also get
% the boolean for inclusion based on decoded RMSE.
paintShadowEffectDecodeBoth = SubstructArrayFromStructArray(paintShadowEffect,'decodeBoth');
if (length(basicInfoAll) ~= length(paintShadowEffectDecodeBoth))
    error('Length mismatch on struct arrays that should be the same');
end
[~,booleanRMSEInclude] = GetFilteringIndex(paintShadowEffectDecodeBoth,{'paintRMSE' 'shadowRMSE'},{basicInfoAll(1).filterMaxRMSE basicInfoAll(1).filterMaxRMSE}, {'<=' '<='});

%% Start up overall figures
tauPlotFig = figure; clf; hold on
set(gcf,'Position',figParams.sqPosition);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

%% Compute and plot the average dissimilarity matrix, JD
whichSubject = 'JD';
figParams.plotSymbol = 'o';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfoAll,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);
basicInfo = basicInfoAll(index);

% Compute mean dissim matrix, and plot
meanDissimMatrix = 0;
dissimMatrixCellArray = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArray))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrix = meanDissimMatrix + dissimMatrixCellArray{ii};
end
meanDissimMatrix = meanDissimMatrix/length(index);

figureRepSimDissimMatrix = figure; hold on
imagesc(meanDissimMatrix); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, JD'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(repSimDir,'repsimAvgDissimMatrixJD','');
FigureSave(figFilename,figureRepSimDissimMatrix ,figParams.figType);

% Add variables to summary plots
figure(tauPlotFig);
plot([repSim(index).fitTau],[repSim(index).noShiftTau],[figParams.plotSymbol figParams.plotColor],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);

% Save information for further analysis
save(fullfile(repSimDir,'dissimMatricesJD'),'dissimMatrixCellArray','meanDissimMatrix','basicInfo','-v7.3');

%% Compute and plot the average dissimilarity matrix, SY
whichSubject = 'SY';
figParams.plotSymbol = 's';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfoAll,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);
basicInfo = basicInfoAll(index);

% Compute mean dissim matrix, and plot
meanDissimMatrix = 0;
dissimMatrixCellArray = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArray))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrix = meanDissimMatrix + dissimMatrixCellArray{ii};
end
meanDissimMatrix = meanDissimMatrix/length(index);

figureRepSimDissimMatrix = figure; hold on
imagesc(meanDissimMatrix); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, SY'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(repSimDir,'repsimAvgDissimMatrixSY','');
FigureSave(figFilename,figureRepSimDissimMatrix ,figParams.figType);

% Add variables to summary plots
figure(tauPlotFig);
plot([repSim(index).fitTau],[repSim(index).noShiftTau],[figParams.plotSymbol figParams.plotColor],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);

% Save information for further analysis
save(fullfile(repSimDir,'dissimMatricesSY'),'dissimMatrixCellArray','meanDissimMatrix','basicInfo','-v7.3');

%% Compute and plot the average dissimilarity matrix, BR
whichSubject = 'BR';
figParams.plotSymbol = 's';
figParams.plotColor = 'k';
figParams.outlineColor = 'k';
[~,booleanSubject] = GetFilteringIndex(basicInfoAll,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);
basicInfo = basicInfoAll(index);

% Compute mean dissim matrix, and plot
meanDissimMatrix = 0;
dissimMatrixCellArray = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArray))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrix = meanDissimMatrix + dissimMatrixCellArray{ii};
end
meanDissimMatrix = meanDissimMatrix/length(index);

figureRepSimDissimMatrix = figure; hold on
imagesc(meanDissimMatrix); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, BR'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(repSimDir,'repsimAvgDissimMatrixBR','');
FigureSave(figFilename,figureRepSimDissimMatrix ,figParams.figType);

% Add variables to summary plots
figure(tauPlotFig);
plot([repSim(index).fitTau],[repSim(index).noShiftTau],[figParams.plotSymbol figParams.plotColor],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);

% Save information for further analysis
save(fullfile(repSimDir,'dissimMatricesBR'),'dissimMatrixCellArray','meanDissimMatrix','basicInfo','-v7.3');

%% Compute and plot the average dissimilarity matrix, ST
whichSubject = 'ST';
figParams.plotSymbol = '^';
figParams.plotColor = 'k';
figParams.outlineColor = 'k';
[~,booleanSubject] = GetFilteringIndex(basicInfoAll,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);
basicInfo = basicInfoAll(index);

% Compute mean dissim matrix, and plot
meanDissimMatrix = 0;
dissimMatrixCellArray = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArray))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrix = meanDissimMatrix + dissimMatrixCellArray{ii};
end
meanDissimMatrix = meanDissimMatrix/length(index);

figureRepSimDissimMatrix = figure; hold on
imagesc(meanDissimMatrix); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, ST'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(repSimDir,'repsimAvgDissimMatrixST','');
FigureSave(figFilename,figureRepSimDissimMatrix ,figParams.figType);

% Add variables to summary plots
figure(tauPlotFig);
plot([repSim(index).fitTau],[repSim(index).noShiftTau],[figParams.plotSymbol figParams.plotColor],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);

% Save information for further analysis
save(fullfile(repSimDir,'dissimMatricesST'),'dissimMatrixCellArray','meanDissimMatrix','basicInfo','-v7.3');

%% Finish up summary plots
figure(tauPlotFig);
xlabel('Best Fit Tau','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('Best Fit Tau No Shift','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
title('Effect of Shift in Fit','FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
xlim([0 1]); ylim([0 1]);
plot([0 1],[0 1],'k','LineWidth',1);
h = legend({ 'V4, JD' 'V4, SY' 'V1, BR' 'V1, ST' },'FontSize',figParams.legendFontSize,'Location','NorthWest');
figFilename = fullfile(repSimDir,'repsimFitTauValues','');
FigureSave(figFilename,tauPlotFig,figParams.figType);
