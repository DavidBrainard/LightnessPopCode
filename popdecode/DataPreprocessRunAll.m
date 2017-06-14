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
argList = SetupConditionArgs('basic');
DataPreprocessRunOne(argList{:});
close all;

% %% Maximum likelihood decoding
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','maxlikely');
% close all;
% 
% %% Maximum likelihood decoding fano
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','maxlikelyfano');
% close all;
% 
% %% Maximum likelihood decoding mean variance
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','maxlikelymeanvar');
% close all;
% 
% %% Maximum likelihood decoding Poisson var
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','maxlikelypoiss');
% close all;
% 
% %% Maximum likelihood decoding Bayes
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','mlbayes');
% close all;
% 
% %% Maximum likelihood decoding Bayes fano
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','mlbayesfano');
% close all;
% 
% %% Maximum likelihood decoding Bayes mean variance
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','mlbayesmeanvar');
% close all;
% 
% %% Maximum likelihood decoding Bayes Poisson var
% argList = SetupConditionArgs('basic');
% DataPreprocessRunOne(argList{:},'type','mlbayespoiss');
% close all;