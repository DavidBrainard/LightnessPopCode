function outputSummaryStructs = RunAndPlotLightnessDecodeExtracted(varargin)
% outputSummaryStructs = RunAndPlotLightnessDecodeExtracted(varargin)
%
% Make plots based on the data extracted by the main pass through the data.
%
% 3/09/16   dhb  Made this version.

%% Clear
close all;

%% Set path
SetAnalysisPath;

%% Random number generator seed
ClockRandSeed;

% Set up decodeInfoIn from args
[decodeInfoIn,COMPUTE] = ParseDecodeInfo(varargin{:});

%% Set up summary file directory
summaryRootDir = '../../PennOutput/xSummaryExtracted';
if (~exist(summaryRootDir))
    mkdir(summaryRootDir);
end

%% Set up file names
condStr = MakePopDecodeConditionStr(decodeInfoIn);
titleStr = strrep(condStr,'_',' ');
summaryDir = fullfile(summaryRootDir,condStr,'');
if (~exist(summaryDir,'dir'))
    mkdir(summaryDir);
end
saveFile = fullfile(summaryDir,['Output' '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType],'');

%% Find extracted data basic location
extractedDataDir = '../../PennOutput/xPlots';
if (~exist(extractedDataDir,'dir'))
    error('Extracted data base dir doesn''t exist');
end
extractedDataRootDir = fullfile(extractedDataDir,condStr,'');
if (~exist(extractedDataRootDir,'dir'))
    error('Extracted root data dir doesn''t exist');
end

%% Get all the files and run whatever we want to do on them
if (COMPUTE)
    curDir = pwd; cd(extractedDataRootDir);
    theDirs = dir('*00*');
    cd(curDir);
    for runIndex = 1:length(theDirs)
        theDir = fullfile(extractedDataRootDir,theDirs(runIndex).name,'');
        decodeInfoOut{runIndex} = RunAndPlotLightnessDecodeExtracted(theDir,decodeInfoIn);
    end
    
    %% Save the returned analyses
    if (~exist(summaryDir,'file'))
        mkdir(summaryDir);
    end
    save(saveFile,'-v7.3');
end

%% Load the saved analyses
clear decodeInfoIn decodeInfoOut
loadedData = load(saveFile);
close all

%% Plot params for summary plots.
OVERRIDE_FIGINFO = true;
if (OVERRIDE_FIGINFO)
    loadedData.decodeInfoIn = SetFigParams(loadedData.decodeInfoIn,'popdecode');
end

%% Collect up and plot some summary statistics
rmseLower = 0.20;

figure; clf; hold on

% V4 data for JD
filter.titleInfoStr = 'V4';
filter.subjectStr = 'JD';
filter.rmseLower = rmseLower;
filter.plotSymbol = 'o';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;
[decodeInfoFilter_JD_V4,outputSummaryTextStructs_JD_V4] = FilterDecodedSessionDataExtracted(loadedData.decodeInfoOut,filter);
[rmse, rmseVersusNUnitsFitScale] = ExtractDecodedSummaryStatsExtracted(decodeInfoFilter_JD_V4);
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',loadedData.decodeInfoIn.markerSize);

% V4 data for SY
filter.titleInfoStr = 'V4';
filter.subjectStr = 'SY';
filter.rmseLower = rmseLower;
filter.plotSymbol = 's';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;
[decodeInfoFilter_SY_V4,outputSummaryTextStructs_SY_V4] = FilterDecodedSessionDataExtracted(loadedData.decodeInfoOut,filter);
[rmse, rmseVersusNUnitsFitScale] = ExtractDecodedSummaryStatsExtracted(decodeInfoFilter_SY_V4);
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',loadedData.decodeInfoIn.markerSize);

% V1 data for BR
filter.titleInfoStr = 'V1';
filter.subjectStr = 'BR';
filter.rmseLower = rmseLower;
filter.plotSymbol = 's';
filter.plotColor = 'k';
filter.outlineColor = 'k';
filter.bumpSizeForMean = 6;
[decodeInfoFilter_BR_V1,outputSummaryTextStructs_BR_V1] = FilterDecodedSessionDataExtracted(loadedData.decodeInfoOut,filter);
[rmse, rmseVersusNUnitsFitScale] = ExtractDecodedSummaryStatsExtracted(decodeInfoFilter_BR_V1);
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',loadedData.decodeInfoIn.markerSize);

% V1 data for ST
filter.titleInfoStr = 'V1';
filter.subjectStr = 'ST';
filter.rmseLower = rmseLower;
filter.plotSymbol = '^';
filter.plotColor = 'k';
filter.outlineColor = 'k';
filter.bumpSizeForMean = 6;
[decodeInfoFilter_ST_V1,outputSummaryTextStructs_ST_V1] = FilterDecodedSessionDataExtracted(loadedData.decodeInfoOut,filter);
[rmse, rmseVersusNUnitsFitScale] = ExtractDecodedSummaryStatsExtracted(decodeInfoFilter_ST_V1);
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',loadedData.decodeInfoIn.markerSize);

%% Write out summary text file
outputSummaryStructs = [outputSummaryTextStructs_BR_V1 outputSummaryTextStructs_ST_V1 outputSummaryTextStructs_JD_V4 outputSummaryTextStructs_SY_V4];
summaryFilename =  fullfile(summaryDir,['Summary'  '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType '.txt'],'');
WriteStructsToText(summaryFilename,outputSummaryStructs);


