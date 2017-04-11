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

% Overriding defaults
argList = {argList{:}, ...
    'doSummaryPaintShadowEffect',true, ...
    'doSummaryRepSim',false, ...
    'doSummaryRMSEAnalysis',false, ...
    'doSummaryRMSEVersusNUnits',false, ...
    'doSummaryRMSEVersusNPCA',true, ...
    'doSummaryClassificationVersusNUnits',false, ...
    'doSummaryClassificationVersusNPCA',false, ...
    };

% Do it
[paintShadowEffectAff,repSimAff,RMSEAnalysisAff,RMSEVersusNUnitsAff,RMSEVersusNPCAAff,ClassificationVersusNUnitsAff,ClassificationVersusNPCAff] = SummarizeRunOne(argList{:});
close all

%% Original paint/shadow, max likeli decoder
argList = SetupConditionArgs('basic_ml');

% Overriding defaults
argList = {argList{:}, ...
    'doSummaryPaintShadowEffect',true, ...
    'doSummaryRepSim',false, ...
    'doSummaryRMSEAnalysis',false, ...
    'doSummaryRMSEVersusNUnits',false, ...
    'doSummaryRMSEVersusNPCA',true, ...
    'doSummaryClassificationVersusNUnits',false, ...
    'doSummaryClassificationVersusNPCA',false, ...
    };

% Do it
[paintShadowEffectML,repSimML,RMSEAnalysisML,RMSEVersusNUnitsML,RMSEVersusNPCAML, ClassificationVersusNUnitsML, ClassificationVersusNPCML] = SummarizeRunOne(argList{:});
close all

%% Make a plot of RMSE for affine versus ML decoder
tempBothAff = [paintShadowEffectAff.decodeBoth];
tempBothML = [paintShadowEffectML.decodeBoth];
figure; clf; hold on
plot([RMSEVersusNPCAAff.bestRMSE],[RMSEVersusNPCAML.bestRMSE],'ko','MarkerSize',6,'MarkerFaceColor','k');
plot([tempBothAff.paintRMSE],[tempBothML.paintRMSE],'ro','MarkerSize',6,'MarkerFaceColor','r');
plot([tempBothAff.shadowRMSE],[tempBothML.shadowRMSE],'bo','MarkerSize',6,'MarkerFaceColor','b');
plot([0 0.4],[0 0.4],'k:')
axis('square');
xlim([0 0.4]);
ylim([0 0.4]);
