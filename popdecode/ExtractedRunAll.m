% ExtractedRunAll
%
% Do the whole kit and kaboodle of extracted analyses.
%
% This is the "Extracted" version, which runs on the .mat files that are
% dumped out by the original pass through the data.  This version exists
% just so some things can be broken out and tracked a little more simply.
%
% 3/25/14  dhb  Wrote it.

%% Clear
clear; close all;

%% Default random number generator
rng('default'); 

%% Make sure we're running from our directory
myDir = fileparts(mfilename('fullpath'));
cd(myDir);

%% Original paint/shadow, linear decode
%
% This can do lots of analyses that we did not end up using,
% calls to those routines set to false here to save time and
% clutter.
argList = SetupConditionArgs('basic');
argList = {argList{:}, ...
    'doExtractedPaintShadowEffect',true, ...
    'doExtractedRepSim',false, ...
    'doExtractedRMSEAnalysis',false, ...
    'doExtractedRMSEVersusNUnits',false, ...
    'doExtractedRMSEVersusNPCA',false, ...
    'doExtractedClassificationVersusNUnits',false, ...
    'doExtractedClassificationVersusNPCA',false, ...
    };
ExtractedRunOne(argList{:});
close all

%% Original paint/shadow, max likely decode
%
% This can do lots of analyses that we did not end up using,
% calls to those routines set to false here to save time and
% clutter.
argList = SetupConditionArgs('basic_ml');
argList = {argList{:}, ...
    'doExtractedPaintShadowEffect',true, ...
    'doExtractedRepSim',false, ...
    'doExtractedRMSEAnalysis',false, ...
    'doExtractedRMSEVersusNUnits',false, ...
    'doExtractedRMSEVersusNPCA',false, ...
    'doExtractedClassificationVersusNUnits',false, ...
    'doExtractedClassificationVersusNPCA',false, ...
    };
ExtractedRunOne(argList{:});
close all

