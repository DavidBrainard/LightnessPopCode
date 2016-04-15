% Where figures will go
outputDir = fullfile(outputRootDir,[filename '_' sizeLocStr]);
if (~exist(outputDir,'dir'))
    mkdir(outputDir);
end
figNameRoot = fullfile(outputDir,[filename '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);

% Note that these containing dirs get made even when we don't have any RF data.
switch (decodeInfoIn.DATASTYLE)
    case 'new'
        rfSummaryDir = fullfile(outputDir,'xRFSummaryStuff');
        rfPlotDir = fullfile(outputDir,'xRFPlots','');
    otherwise
        error('Unknown data style');
end
if (~exist(rfSummaryDir,'dir'))
    mkdir(rfSummaryDir);
end
if (~exist(rfPlotDir,'dir'))
    mkdir(rfPlotDir);
end
rfSummaryNameRoot = fullfile(rfSummaryDir,[filename '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);
rfFigNameRoot = fullfile(rfPlotDir,[filename '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);
