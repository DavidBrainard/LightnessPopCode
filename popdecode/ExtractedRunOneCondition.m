function outputSummaryStructs = ExtractedRunAndPlotLightnessDecode(varargin)
% outputSummaryStructs = ExtractedRunAndPlotLightnessDecode(varargin)
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
%
% Save after each call so we can recover from partial runs.
if (COMPUTE)
    curDir = pwd; cd(extractedDataRootDir);
    theDirs = dir('*00*');
    cd(curDir); 
    if (exist('IsCluster','file') & IsCluster)
        parfor runIndex = 1:length(theFiles)
            theDir = fullfile(extractedDataRootDir,theDirs(runIndex).name,'');
            decodeInfoOut{runIndex} = ExtractedRunAndPlotLightnessDecode(theDir,decodeInfoIn);
            %save(saveFile,'-v7.3');
        end
    else
        runIndex = 1:length(theFiles)
            theDir = fullfile(extractedDataRootDir,theDirs(runIndex).name,'');
            decodeInfoOut{runIndex} = ExtractedRunAndPlotLightnessDecode(theDir,decodeInfoIn);
            save(saveFile,'-v7.3');
        end
    end
end
%save(saveFile,'-v7.3');

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


