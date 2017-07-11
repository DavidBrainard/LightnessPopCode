function [paintShadowEffect,repSim,RMSEAnalysis,RMSEVersusNUnits,RMSEVersusNPCA,ClassificationVersusNUnits,ClassificationVersusNPCA] = SummarizeRunOne(varargin)
% [paintShadowEffect,repSim,RMSEAnalysis,RMSEVersusNUnits,RMSEVersusNPCA,ClassificationVersusNUnits,ClassificationVersusNPCA] = SummarizeRunOne(varargin)
%
% Make summary plots based on the data extracted by the main pass through the data.
%
% 3/09/16   dhb  Made this version.

%% Clear
close all;

%% Random number generator seed
rng('shuffle');

% Set up decodeInfoIn from args
[decodeInfoIn] = ParseDecodeInfo(varargin{:});

%% Set up summary file directory
summaryRootDir = fullfile(getpref('LightnessPopCode','outputBaseDir'),'xSummary');
if (~exist(summaryRootDir))
    mkdir(summaryRootDir);
end
    
%% Set up file names
condStr = MakePopDecodeConditionStr(decodeInfoIn);
summaryDir = fullfile(summaryRootDir,condStr,'');
if (~exist(summaryDir,'dir'))
    mkdir(summaryDir);
end
%saveFile = fullfile(summaryDir,['Output' '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType],'');

%% Find preprocessed data basic location and get all the directories
preprocessedDataDir = fullfile(getpref('LightnessPopCode','outputBaseDir'),'xPreprocessedData');
if (~exist(preprocessedDataDir,'dir'))
    error('Preprocessed data base dir doesn''t exist');
end
preprocessedDataRootDir = fullfile(preprocessedDataDir,condStr,'');
if (~exist(preprocessedDataRootDir,'dir'))
    error('Preprocessed data condition dir doesn''t exist');
end

%% Find extracted output basic location and get all the directories
extractedDataDir = fullfile(getpref('LightnessPopCode','outputBaseDir'),'xExtractedPlots');
if (~exist(extractedDataDir,'dir'))
    error('Extracted analysis output base dir doesn''t exist');
end
extractedDataRootDir = fullfile(extractedDataDir,condStr,'');
if (~exist(extractedDataRootDir,'dir'))
    error('Extracted analysis output condition dir doesn''t exist');
end
curDir = pwd; cd(extractedDataRootDir);
theExtractedDirsRaw = dir('*00*');
cd(curDir);

% Filter for dirs that actually have valid output
outIndex = 1;
for inIndex = 1:length(theExtractedDirsRaw)
    if (exist(fullfile(extractedDataRootDir,theExtractedDirsRaw(inIndex).name,'extPaintShadowEffect.mat'),'file'))
        theExtractedDirs(outIndex) = theExtractedDirsRaw(inIndex);
        outIndex = outIndex + 1;
    else
        fprintf('No valid data in %s\n',theExtractedDirsRaw(inIndex).name);
    end
end

%% Get all the processed data so we plot or otherwise analyze them.
for runIndex = 1:length(theExtractedDirs)
    % We can have more proprocessed dirs than extracted dirs, but there
    % should be a preprocessed dir with the same name as the
    % corresponding extracted dir.  Set up both.
    thePreprocessedDir = fullfile(preprocessedDataRootDir,theExtractedDirs(runIndex).name,'');
    theExtractedDir = fullfile(extractedDataRootDir,theExtractedDirs(runIndex).name,'');
    
    % Basic information we'll need for indexing is stored with the
    % preprocessed data.  Grab that.
    basicInfo(runIndex) = SummarizeGetExtractedStructs(thePreprocessedDir,'basicInfo.mat');
    
    % Get the output of the various analyses that get run over the
    % preprocessed data.
    if (decodeInfoIn.doSummaryPaintShadowEffect)
        paintShadowEffect(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extPaintShadowEffect.mat');
    else
        paintShadowEffect(runIndex) = NaN;
    end
    if (decodeInfoIn.doSummaryRepSim)
        repSim(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRepSim.mat');
    else
        repSim(runIndex) = NaN;
    end
    if (decodeInfoIn.doSummaryRMSEAnalysis)
        RMSEAnalysis(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEAnalysis.mat');
    else
        RMSEAnalysis(runIndex) = NaN;
    end
    if (decodeInfoIn.doSummaryRMSEVersusNUnits)
        RMSEVersusNUnits(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEVersusNUnits.mat');
    else
        RMSEVersusNUnits(runIndex) = NaN;
    end
    if (decodeInfoIn.doSummaryRMSEVersusNPCA)
        RMSEVersusNPCA(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEVersusNPCA.mat');
    else
        RMSEVersusNPCA(runIndex) = NaN;
    end
    if (decodeInfoIn.doSummaryClassificationVersusNUnits)    
        ClassificationVersusNUnits(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extClassificationVersusNUnits.mat');
     else
        ClassificationVersusNUnits(runIndex) = NaN;
    end
    if (decodeInfoIn.doSummaryClassificationVersusNPCA)
        if (exist(fullfile(theExtractedDir,'extClassificationVersusNPCA .mat'),'file'))
            unix(['mv ' fullfile(theExtractedDir,'extClassificationVersusNPCA\ .mat') ' ' fullfile(theExtractedDir,'extClassificationVersusNPCA.mat')]);
        end
        ClassificationVersusNPCA(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extClassificationVersusNPCA.mat');
     else
        ClassificationVersusNPCA(runIndex) = NaN;
    end
end

    
%% Figure parameters
figParams = SetFigParams([],'popdecode');

%% Call routines to make nice summary plots
if (decodeInfoIn.doSummaryPaintShadowEffect)
    if (length(basicInfo) ~= length(paintShadowEffect))
        error('Data length mismatch');
    end
    PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams);
end
if (decodeInfoIn.doSummaryRepSim)
    RepSimSummaryPlots(basicInfo,paintShadowEffect,repSim,summaryDir,figParams);
end
if (decodeInfoIn.doSummaryRMSEAnalysis)
    if (length(basicInfo) ~= length(RMSEAnalysis))
        error('Data length mismatch');
    end
end
if (decodeInfoIn.doSummaryRMSEVersusNUnits)
    if (length(basicInfo) ~= length(RMSEVersusNUnits))
        error('Data length mismatch');
    end
end
if (decodeInfoIn.doSummaryRMSEVersusNPCA)
    if (length(basicInfo) ~= length(RMSEVersusNPCA))
        error('Data length mismatch');
    end
    RMSEVersusNPCASummaryPlots(basicInfo,RMSEVersusNPCA,summaryDir,figParams);
end
if (decodeInfoIn.doSummaryClassificationVersusNUnits)
    if (length(basicInfo) ~= length(ClassificationVersusNUnits))
        error('Data length mismatch');
    end
end
if (decodeInfoIn.doSummaryClassificationVersusNPCA)
    if (length(basicInfo) ~= length(ClassificationVersusNPCA))
        error('Data length mismatch');
    end
    ClassificationVersusNPCASummaryPlots(basicInfo,paintShadowEffect,ClassificationVersusNPCA,summaryDir,figParams)
end




