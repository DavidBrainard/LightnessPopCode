% SetAnalysisPath
%
% Set the path for these analyses
%
% 7/4/13  dhb  Wrote it

%% Start fresh
%startup;

%% Get the name of the m-file we're running.
mFileName = mfilename;
myDir = fileparts(which(mFileName));
pathDir = fullfile(myDir,'..','LV4Toolbox','');
AddToMatlabPathDynamically(pathDir);

