% ExtractedRunAll
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

%% Original paint/shadow
argList = SetupConditionArgs('basic');

%% Control explicitly which conditions we summarize
%
% Overriding defaults
argList = {argList{:}, ...
    'doExtractedPaintShadowEffect',false, ...
    'doExtractedRepSim',false, ...
    'doExtractedRMSEAnalysis',false, ...
    'doExtractedRMSEVersusNUnits',false, ...
    'doExtractedRMSEVersusNPCA',true, ...
    'doExtractedClassificationVersusNUnits',false, ...
    'doExtractedClassificationVersusNPCA',false, ...
    };

ExtractedRunOne(argList{:});
close all

