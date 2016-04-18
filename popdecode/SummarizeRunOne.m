function SummarizeRunOne(varargin)
% SummarizeRunOne(varargin)
%
% Make summary plots based on the data extracted by the main pass through the data.
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
summaryRootDir = '../../PennOutput/xSummary';
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

%% Find extracted output basic location
extractedDataDir = '../../PennOutput/xExtractedPlots';
if (~exist(extractedDataDir,'dir'))
    error('Extracted analysis output base dir doesn''t exist');
end
extractedDataRootDir = fullfile(extractedDataDir,condStr,'');
if (~exist(extractedDataRootDir,'dir'))
    error('Extracted analysis output condition dir doesn''t exist');
end

%% Get all the files and run whatever we want to do on them
%
% Save after each call so we can recover from partial runs.
curDir = pwd; cd(extractedDataRootDir);
theDirs = dir('*00*');
cd(curDir);
if (exist('IsCluster','file') & IsCluster)
    parfor runIndex = 1:length(theDirs)
        theDir = fullfile(extractedDataRootDir,theDirs(runIndex).name,'');
        paintShadowEffect{runIndex} = SummaryGetStructs(theDir,'extPaintShadowEffect.mat');
        repSim{runIndex} = SummaryGetStructs(theDir,'extRepSim.mat');
        RMSEAnalysis{runIndex} = SummaryGetStructs(theDir,'extRMSEAnalysis.mat');
        RMSEVersusNUnits{runIndex} = SummaryGetStructs(theDir,'extRMSEVersusNUnits.mat');
        RMSEVersusNPCA{runIndex} = SummaryGetStructs(theDir,'extRMSEVersusNPCA.mat');
        ClassificationVersusNUnits{runIndex} = SummaryGetStructs(theDir,'extClassificationVersusNUnits.mat');
        ClassificationVersusNPCA{runIndex} = SummaryGetStructs(theDir,'extClassificationVersusNPCA.mat');

    end
else
    for runIndex = 1:length(theDirs)
        theDir = fullfile(extractedDataRootDir,theDirs(runIndex).name,'');
        decodeInfoOut{runIndex} = ExtractedEngine(theDir,decodeInfoIn);
    end
end

save(saveFile,'-v7.3');

%% Load the saved analyses
clear decodeInfoIn decodeInfoOut
loadedData = load(saveFile);
close all

%% Plot params for summary plots.
OVERRIDE_FIGINFO = true;
if (OVERRIDE_FIGINFO)
    loadedData.decodeInfoIn = SetFigParams(loadedData.decodeInfoIn,'popdecode');
end

%% Summary plots
rmseLower = 0.20;

% RMSE Versus Fit Scale
ExtractedSummaryRMSEVsNUnitsFitScalePlot(summaryDir,loadedData.decodeInfoIn,loadedData.decodeInfoOut);

%% Write out summary text file
% outputSummaryStructs = [outputSummaryTextStructs_BR_V1 outputSummaryTextStructs_ST_V1 outputSummaryTextStructs_JD_V4 outputSummaryTextStructs_SY_V4];
% summaryFilename =  fullfile(summaryDir,['Summary'  '_' loadedData.decodeInfoIn.dataType '_' loadedData.decodeInfoIn.paintShadowFitType '.txt'],'');
% WriteStructsToText(summaryFilename,outputSummaryStructs);


