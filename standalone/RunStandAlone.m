% RunStandAlone
%
% Example that shows how to call into my decoding functions to arrive
% at the paint/shadow effect, but without all of my management overhead.
%
% 1/22/15  dhb  Wrote it.

% Clear
clear; close all;

%% Set path and current working directory
myDir = fileparts(mfilename('fullpath'));
cd(myDir);
pathDir = fullfile(myDir,'..','LV4Toolbox','');
AddToMatlabPathDynamically(pathDir);
pathDir = fullfile(myDir,'..','popdecode','');
AddToMatlabPathDynamically(pathDir);

%% Load sample data
% This is just paint intensities, paint responses, shadowIntensities, and shadowResponses
% all as vectors.  NaNs have been stripped out.
sampleData = load('sampleData');
paintIntensities = sampleData.paintIntensities;
shadowIntensities = sampleData.shadowIntensities;
paintResponses = sampleData.paintResponses;
shadowResponses = sampleData.shadowResponses;

%% Set up parameters structure by hand
decodeInfoIn = SetUpParameters;

%% Build the decoder and decode
[~,~,paintPredsLOO,shadowPredsLOO,decodeInfoIn] = PaintShadowDecode(decodeInfoIn,...
    paintIntensities,paintResponses, ...
    shadowIntensities,shadowResponses);
paintLOORMSE = sqrt(mean((paintIntensities(:)-paintPredsLOO(:)).^2));
shadowLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPredsLOO(:)).^2));

%% Get prediction means and standard errors for each intensity
%[paintPredictMeans,~,~,~,~,paintGroupedIntensities]=sortbyx(paintIntensities,paintPreds);
%[shadowPredictMeans,shadowPredictSEMs,~,~,~,shadowGroupedIntensities]=sortbyx(shadowIntensities,shadowPreds);
[paintPredictMeansLOO,paintPredictSEMsLOO,~,~,~,paintGroupedIntensitiesLOO]=sortbyx(paintIntensities,paintPredsLOO);
[shadowPredictMeansLOO,shadowPredictSEMsLOO,~,~,~,shadowGroupedIntensitiesLOO]=sortbyx(shadowIntensities,shadowPredsLOO);

%% Fit the decoded shadow and paint data with a smooth curve.  Then infer intensity matches.
%
% Get min and max of stimulus intensity range studied.  We expect, generally, for these to
% be the same for paint and shadow, and currently throw an error if they are not.  I don't
% think any code will break in that case, but it seems to me that the reason the two differ
% should be looked into so the error condition enforces it for now.
paintMin = min(paintIntensities); paintMax = max(paintIntensities);
shadowMin = min(shadowIntensities); shadowMax = max(shadowIntensities);
if (paintMin ~= shadowMin || paintMax ~= shadowMax)
    error('Same range of stimulus intensities was not used for paint and shadow');
end
intensityMin = max([paintMin shadowMin]); intensityMax = min([paintMax shadowMax]);
if (intensityMin > intensityMax)
    error('This would be a weird condition, so we check for it.');
end
fineSpacedIntensities = linspace(intensityMin,intensityMax,decodeInfoIn.nFinelySpacedIntensities)';
paintLOOFitObject = FitDecodedIntensities(decodeInfoIn,paintGroupedIntensitiesLOO,paintPredictMeansLOO');
paintLOOSmooth = PredictDecodedIntensities(decodeInfoIn,paintLOOFitObject,fineSpacedIntensities);
shadowLOOFitObject = FitDecodedIntensities(decodeInfoIn,shadowGroupedIntensitiesLOO,shadowPredictMeansLOO');
shadowLOOSmooth = PredictDecodedIntensities(decodeInfoIn,shadowLOOFitObject,fineSpacedIntensities);
[paintLOOMatchesSmooth,shadowLOOMatchesSmooth,paintLOOMatchesDiscrete,shadowLOOMatchesDiscrete,paintLOODecodeDiscrete,shadowLOODecodeDiscrete] = ...
    InferIntensityMatches(decodeInfoIn,paintLOOFitObject,shadowLOOFitObject,intensityMin,intensityMax);
paintShadowDecodeMeanDifferenceDiscrete = mean(paintLOODecodeDiscrete-shadowLOODecodeDiscrete);

%% Summarize intensity matches with a line through the discrete level matches.
paintShadowMbSmooth = mean(shadowLOOMatchesSmooth') - mean(paintLOOMatchesSmooth');
paintShadowMb = mean(shadowLOOMatchesDiscrete') - mean(paintLOOMatchesDiscrete');
shadowMatchesDiscreteAffinePred = paintLOOMatchesDiscrete' + paintShadowMb;

%% Plot of decoding
figure; clf; hold on
plot(paintGroupedIntensitiesLOO,paintPredictMeansLOO,'go');
plot(fineSpacedIntensities,paintLOOSmooth,'g');
plot(shadowGroupedIntensitiesLOO,shadowPredictMeansLOO,'ko');
plot(fineSpacedIntensities,shadowLOOSmooth,'k');
axis('square'); axis([0 1 0 1]);

% Plot of paint/shadow effect summary
figure; clf; hold on
plot(paintLOOMatchesDiscrete,shadowLOOMatchesDiscrete,'ro');
plot([0 1],[0 1],'k:');
plot(paintLOOMatchesDiscrete,shadowMatchesDiscreteAffinePred,'r');
axis('square'); axis([0 1 0 1]);
fprintf('Paint shadow effect is %0.2f\n',paintShadowMb);
