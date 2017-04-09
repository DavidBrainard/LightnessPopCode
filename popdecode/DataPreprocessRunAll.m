% DataPreprocessRunAll
%
% Run data proprocessing over the whole data set, extracting just
% the variables of interest after any massaging that is necessary.
%
% 3/25/14  dhb  Wrote it.
% 4/15/16  dhb  Now this is just data preprocessing.

% Clear
clear; close all;

%% Make sure we're running from our directory
myDir = fileparts(mfilename('fullpath'));
cd(myDir);

%% Original paint/shadow
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:});
% close all;

%% Maximum likelihood decoding
argList = SetupConditionArgs('basic_ml');
DataPreprocessRunOne(argList{:});
close all;



