% DataPreprocessRunAll
%
% Run data proprocessing over the whole data set, extracting just
% the variables of interest after any massaging that is necessary.
%
% 3/25/14  dhb  Wrote it.
% 4/15/16  dhb  Now this is just data preprocessing.
% 6/15/17  dhb  Check that current data matches a previous version (passed).

% Clear
clear; close all;

%% Make sure we're running from our directory
myDir = fileparts(mfilename('fullpath'));
cd(myDir);

%% Original paint/shadow
argList = SetupConditionArgs('basic');
DataPreprocessRunOne(argList{:});
close all;

% argList = SetupConditionArgs('basicpaint');
% DataPreprocessRunOne(argList{:});
% close all;
% 
% argList = SetupConditionArgs('basicshadow');
% DataPreprocessRunOne(argList{:});
% close all;

% argList = SetupConditionArgs('basic_shuff');
% DataPreprocessRunOne(argList{:});
% close all;

% argList = SetupConditionArgs('fitrlinear');
% DataPreprocessRunOne(argList{:});
% close all;

% argList = SetupConditionArgs('fitrcvlasso');
% DataPreprocessRunOne(argList{:});
% close all;

% argList = SetupConditionArgs('fitrcvridge');
% DataPreprocessRunOne(argList{:});
% close all;

% argList = SetupConditionArgs('poiss_ml');
% DataPreprocessRunOne(argList{:});
% close all;

