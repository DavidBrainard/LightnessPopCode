% ExtractedRunAllConditions
%
% Do the whole kit and kaboodle of extracted analyses.
%
% This is the "Extracted" version, which runs on the .mat files that are
% dumped out by the original pass through the data.  This version exists
% just so some things can be broken out and tracked a little more simply.
%
% 3/25/14  dhb  Wrote it.

% Clear
clear; close all;

%% Make sure we're running from our directory
myDir = fileparts(mfilename('fullpath'));
cd(myDir);

%% Set path
SetAnalysisPath;

%% Compute or just plot?
runAllCompute = true;

%% Original paint/shadow
ExtractedRunOneCondition(...
    'dataType','spksrt', ...
    'type','aff', ...
    'classifyType','mvma', ...
    'rfAnalysisType','no', ...
    'pcaType','no', ...
    'trialShuffleType','notshf', ...
	'paintShadowShuffleType','nopsshf', ...    
    'decodeIntensityFitType','betacdf', ...
    'paintCondition', 1, ...
    'shadowCondition', 2, ...
    'paintShadowFitType', 'intcpt',  ...
    'excludeSYelectrodes','sykp', ...
    'errType', 'mean', ...
    'minTrials',20, ...
    'filterRangeLower',0.2, ...
    'doIndElectrodeRFPlots',true, ...
    'reallyDoIRFPlots',false, ...
    'reallyDoRFPlots',false, ...
    'COMPUTE', runAllCompute, ...
    'plotV4Only', false, ...
    'DATASTYLE', 'new' ...
    );
close all

