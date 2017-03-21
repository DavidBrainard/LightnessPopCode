function ExtractedRunOne(varargin)
% ExtractedRunOne(varargin)
%
% Make plots based on the data extracted by the main pass through the data.
%
% 3/09/16   dhb  Made this version.

%% Clear
close all;

%% Random number generator seed
ClockRandSeed;

% Set up decodeInfoIn from args
[decodeInfoIn] = ParseDecodeInfo(varargin{:});
    
%% Set up file names
condStr = MakePopDecodeConditionStr(decodeInfoIn);

%% Find preprocessed data basic location
preprocessedDataDir = fullfile(getpref('LightnessPopCode','outputBaseDir'),'xPreprocessedData');
if (~exist(preprocessedDataDir,'dir'))
    error('Preprocessed data base dir doesn''t exist');
end
preprocessedDataRootDir = fullfile(preprocessedDataDir,condStr,'');
if (~exist(preprocessedDataRootDir,'dir'))
    error('Preprocessed data condition dir doesn''t exist');
end

%% Get all of the preprocessed directories
%
% This little magic depends on knowing the form of the
% directory names.
curDir = pwd; cd(preprocessedDataRootDir);
thePreprocessedDirs = dir('*00*');
cd(curDir);

%% Run the extracted analysis over each preprocessed directory
allowParfor = true;
if (allowParfor & exist('IsCluster','file') & IsCluster)
    parfor runIndex = 1:length(thePreprocessedDirs)
        theDir = fullfile(preprocessedDataRootDir,thePreprocessedDirs(runIndex).name,'');
        decodeInfoOut{runIndex} = ExtractedEngine(theDir,decodeInfoIn);
    end
else
    for runIndex = 1:length(thePreprocessedDirs)
        theDir = fullfile(preprocessedDataRootDir,thePreprocessedDirs(runIndex).name,'');
        decodeInfoOut{runIndex} = ExtractedEngine(theDir,decodeInfoIn);
    end
end
