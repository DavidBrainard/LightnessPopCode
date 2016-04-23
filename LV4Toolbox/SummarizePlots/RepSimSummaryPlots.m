function RepSimSummaryPlots(basicInfo,paintShadowEffect,repSim,summaryDir,figParams)
% RepSimSummaryPlots(basicInfo,paintShadowEffect,repSim,summaryDir,figParams)
%
% Summary plots of the representational similarity analysis.
%
% 4/19/16  dhb  Wrote it.

%% Additional parameters
figParams.bumpSizeForMean = 6;
figureSubdir = 'RepSim';
figureDir = fullfile(summaryDir,figureSubdir,'');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Get the inclusion boolean based on decoding RMSE
%
% Extract the decode both results from the top level structure, and also get
% the boolean for inclusion based on decoded RMSE.
paintShadowEffectDecodeBoth = SubstructArrayFromStructArray(paintShadowEffect,'decodeBoth');
if (length(basicInfo) ~= length(paintShadowEffectDecodeBoth))
    error('Length mismatch on struct arrays that should be the same');
end
[~,booleanRMSEInclude] = GetFilteringIndex(paintShadowEffectDecodeBoth,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});

%% Compute and plot the average dissimilarity matrix, JD
whichSubject = 'JD';
figParams.plotSymbol = 'o';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);

meanDissimMatrixJD = 0;
dissimMatrixCellArrayJD = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArrayJD))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrixJD = meanDissimMatrixJD + dissimMatrixCellArrayJD{ii};
end
meanDissimMatrixJD = meanDissimMatrixJD/length(index);

figureRepSimDissimMatrixJD = figure; hold on
imagesc(meanDissimMatrixJD); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, JD'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryfigureRepSimDissimMatrixJD ','');
FigureSave(figFilename,figureRepSimDissimMatrixJD ,figParams.figType);

%% Compute and plot the average dissimilarity matrix, SY
whichSubject = 'SY';
figParams.plotSymbol = 'o';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);

meanDissimMatrixSY = 0;
dissimMatrixCellArraySY = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArraySY))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrixSY = meanDissimMatrixSY + dissimMatrixCellArraySY{ii};
end
meanDissimMatrixSY = meanDissimMatrixSY/length(index);

figureRepSimDissimMatrixSY = figure; hold on
imagesc(meanDissimMatrixSY); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, SY'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryfigureRepSimDissimMatrixSY ','');
FigureSave(figFilename,figureRepSimDissimMatrixSY ,figParams.figType);

%% Compute and plot the average dissimilarity matrix, BR
whichSubject = 'BR';
figParams.plotSymbol = 'o';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);

meanDissimMatrixBR = 0;
dissimMatrixCellArrayBR = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArrayBR))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrixBR = meanDissimMatrixBR + dissimMatrixCellArrayBR{ii};
end
meanDissimMatrixBR = meanDissimMatrixBR/length(index);

figureRepSimDissimMatrixBR = figure; hold on
imagesc(meanDissimMatrixBR); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, BR'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryfigureRepSimDissimMatrixBR ','');
FigureSave(figFilename,figureRepSimDissimMatrixBR ,figParams.figType);

%% Compute and plot the average dissimilarity matrix, ST
whichSubject = 'ST';
figParams.plotSymbol = 'o';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
index = find(booleanRMSEInclude & booleanSubject);

meanDissimMatrixST = 0;
dissimMatrixCellArrayST = {repSim(index).dissimMatrix};
if (length(index) ~= length(dissimMatrixCellArrayST))
    error('Length mismatch on things that should be the same');
end
for ii = 1:length(index)
    meanDissimMatrixST = meanDissimMatrixST + dissimMatrixCellArrayST{ii};
end
meanDissimMatrixST = meanDissimMatrixST/length(index);

figureRepSimDissimMatrixST = figure; hold on
imagesc(meanDissimMatrixST); colorbar; axis('square');
title({'Mean Dissimilarity Matrix, ST'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryfigureRepSimDissimMatrixST ','');
FigureSave(figFilename,figureRepSimDissimMatrixST ,figParams.figType);

end

%