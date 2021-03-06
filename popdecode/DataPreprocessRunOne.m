function outputSummaryStructs = DataPreprocessRunOne(varargin)
% outputSummaryStructs = DataPreprocessRunOne(varargin)
%
% Do the basic data preprocessing of all the data files
% for a condition as described by the options created though
% the call to ParseDecodeInfo.
%
% 10/31/13  dhb  Wrote it.
% 2/24/14   dhb  Add intercept only decode option
% 3/16/14   dhb  Comments.  Change 'contrast' to 'intensity'
% 3/25/14   dhb  Made this a function, optional arg passing.

%% Clear
close all;

%% Random number generator seed
rng(51);

%% Set up decodeInfoIn from args
decodeInfoIn = ParseDecodeInfo(varargin{:});

%% Set up files to run
%
% Initialize
outIndex = 1;
theFiles = {};
theRFFiles = {};
decodeInfoRun = {}; 

% List all the conditions
ListAllConditions;

%% Run 'em
if (exist('IsCluster','file') & IsCluster)
    parfor runIndex = 1:length(theFiles)
        DataPreprocessEngine(theFiles{runIndex},theRFFiles{runIndex},decodeInfoInRun{runIndex});
    end
else
    for runIndex = 1:length(theFiles)
        DataPreprocessEngine(theFiles{runIndex},theRFFiles{runIndex},decodeInfoInRun{runIndex});
    end
end

