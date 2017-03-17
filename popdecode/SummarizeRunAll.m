% SummarizeRunAll
%
% Collect up the extracted data analyses of individual conditions and make
% summary plots.
%
% 3/25/14  dhb  Wrote it.

% Clear
clear; close all;

%% Make sure we're running from our directory
myDir = fileparts(mfilename('fullpath'));
cd(myDir);

%% Original paint/shadow
argList = SetupConditionArgs('basic');
SummarizeRunOne(argList{:});
close all