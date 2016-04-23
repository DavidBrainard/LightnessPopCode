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
[decodeInfoIn] = ParseDecodeInfo(varargin{:});

%% Set up summary file directory
summaryRootDir = '../../PennOutput/xSummary';
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
preprocessedDataDir = '../../PennOutput/xPreprocessedData';
if (~exist(preprocessedDataDir,'dir'))
    error('Preprocessed data base dir doesn''t exist');
end
preprocessedDataRootDir = fullfile(preprocessedDataDir,condStr,'');
if (~exist(preprocessedDataRootDir,'dir'))
    error('Preprocessed data condition dir doesn''t exist');
end

%% Find extracted output basic location and get all the directories
extractedDataDir = '../../PennOutput/xExtractedPlots';
if (~exist(extractedDataDir,'dir'))
    error('Extracted analysis output base dir doesn''t exist');
end
extractedDataRootDir = fullfile(extractedDataDir,condStr,'');
if (~exist(extractedDataRootDir,'dir'))
    error('Extracted analysis output condition dir doesn''t exist');
end
curDir = pwd; cd(extractedDataRootDir);
theExtractedDirs = dir('*00*');
cd(curDir);

%% Get all the processed data so we plot or otherwise analyze them.
%
% There are two identical loops here, one for when we're on a cluster
% (parfor) and one for when we are not.  The code should be identical
% within each loop.
if (exist('IsCluster','file') & IsCluster)
    parfor runIndex = 1:length(theExtractedDirs)
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
        paintShadowEffect(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extPaintShadowEffect.mat');
        repSim(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRepSim.mat');
        RMSEAnalysis(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEAnalysis.mat');
        RMSEVersusNUnits(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEVersusNUnits.mat');
        %RMSEVersusNPCA(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEVersusNPCA.mat');
        %ClassificationVersusNUnits(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extClassificationVersusNUnits.mat');
        %ClassificationVersusNPCA(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extClassificationVersusNPCA.mat');
    end
else
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
        paintShadowEffect(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extPaintShadowEffect.mat');
        repSim(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRepSim.mat');
        RMSEAnalysis(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEAnalysis.mat');
        RMSEVersusNUnits(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEVersusNUnits.mat');
        %RMSEVersusNPCA(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extRMSEVersusNPCA.mat');
        %ClassificationVersusNUnits(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extClassificationVersusNUnits.mat');
        %ClassificationVersusNPCA(runIndex) = SummarizeGetExtractedStructs(theExtractedDir,'extClassificationVersusNPCA.mat');
    end
end

% Check that everyone is the same length
if (length(basicInfo) ~= length(paintShadowEffect))
    error('Data length mismatch');
end
if (length(basicInfo) ~= length(repSim))
    error('Data length mismatch');
end
if (length(basicInfo) ~= length(RMSEAnalysis))
    error('Data length mismatch');
end
if (length(basicInfo) ~= length(RMSEVersusNUnits))
    error('Data length mismatch');
end
% if (length(basicInfo) ~= length(RMSEVersusNPCA))
%     error('Data length mismatch');
% end
% if (length(basicInfo) ~= length(ClassificationVersusNUnits))
%     error('Data length mismatch');
% end
% if (length(basicInfo) ~= length(ClassificationVersusNPCA))
%     error('Data length mismatch');
% end

%% Figure parameters
figParams = SetFigParams([],'popdecode');

%% Call routines to make nice summary plots

% Paint/Shadow Effect
%PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams);
RepSimSummaryPlots(basicInfo,paintShadowEffect,repSim,summaryDir,figParams);



