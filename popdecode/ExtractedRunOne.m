function ExtractedRunOne(varargin)
% ExtractedRunOne(varargin)
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
[decodeInfoIn] = ParseDecodeInfo(varargin{:});
    
%% Set up file names
condStr = MakePopDecodeConditionStr(decodeInfoIn);
titleStr = strrep(condStr,'_',' ');

%% Find preprocessed data basic location
extractedDataDir = '../../PennOutput/xPreprocessedData';
if (~exist(extractedDataDir,'dir'))
    error('Preprocessed data base dir doesn''t exist');
end
extractedDataRootDir = fullfile(extractedDataDir,condStr,'');
if (~exist(extractedDataRootDir,'dir'))
    error('Preprocessed data condition dir doesn''t exist');
end

%% Get all the files and run whatever we want to do on them
curDir = pwd; cd(extractedDataRootDir);
theDirs = dir('*00*');
cd(curDir);
if (exist('IsCluster','file') & IsCluster)
    parfor runIndex = 1:length(theDirs)
        theDir = fullfile(extractedDataRootDir,theDirs(runIndex).name,'');
        decodeInfoOut{runIndex} = ExtractedEngine(theDir,decodeInfoIn);
    end
else
    for runIndex = 1:length(theDirs)
        theDir = fullfile(extractedDataRootDir,theDirs(runIndex).name,'');
        decodeInfoOut{runIndex} = ExtractedEngine(theDir,decodeInfoIn);
    end
end
