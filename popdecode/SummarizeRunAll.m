% SummarizeRunAll
%
% Collect up the extracted data analyses of individual conditions and make
% summary plots.
%
% 3/25/14  dhb  Wrote it.

% Clear
clear; close all;

%% Specify which analsyses to do

%% Make sure we're running from our directory
myDir = fileparts(mfilename('fullpath'));
cd(myDir);

%% Original paint/shadow
argList = SetupConditionArgs('basic');
argList = {argList{:}, ...
    'doSummaryPaintShadowEffect',true, ...
    'doSummaryRepSim',false, ...
    'doSummaryRMSEAnalysis',false, ...
    'doSummaryRMSEVersusNUnits',false, ...
    'doSummaryRMSEVersusNPCA',false, ...
    'doSummaryClassificationVersusNUnits',false, ...
    'doSummaryClassificationVersusNPCA',false, ...
    };
[paintShadowEffectAff,repSimAff,RMSEAnalysisAff,RMSEVersusNUnitsAff,RMSEVersusNPCAAff,ClassificationVersusNUnitsAff,ClassificationVersusNPCAff] = SummarizeRunOne(argList{:});
close all

