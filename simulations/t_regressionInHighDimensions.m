%% t_regressionInHighDimensions
%
% Description:
%    Try to develop some intuitions about how regression coefficients
%    behave in high dimensions.
%
%    Follows broad ideas introduced by an anonymous reviewer, although 
%    the reviewer provided code in R and modeled a different case.  The
%    code here is more like what we do in the paper.
%
% 05/05/18  dhb  Wrote it.

%% Clear and close
clear; close all;

%% Parameters
nLuminances = 20;
nTrialsPerLuminance = 25;
nNeurons = 100;
neuron1Gain = 1;
neuron2Gain = 1;
responseNoiseSd = 0.01;

%% Set up luminances across trials
theLuminances = linspace(0,1,nLuminances);
nTrials = nLuminances*nTrialsPerLuminance;
theTrialLuminances = zeros(nTrials,1);
lumIndex = 1;
for ll = 1:nLuminances
    for nn = 1:nTrialsPerLuminance
        theTrialLuminances(lumIndex) = theLuminances(ll);
        lumIndex = lumIndex+1;
    end
end

%% First two neurons have responses that are related to luminances
neuron1Responses = neuron1Gain*theTrialLuminances + normrnd(0,responseNoiseSd,nTrials,1);
neuron2Responses = neuron2Gain*theTrialLuminances + normrnd(0,responseNoiseSd,nTrials,1);

%% Rest of neurons have resposnes that are pure noise
nOtherNeurons = nNeurons-2;
neuronOtherResponses = normrnd(0,responseNoiseSd,nTrials,nOtherNeurons);

%% Neural response matrix (nTrials by nNeurons)
neuronResponses = [neuron1Responses neuron2Responses neuronOtherResponses];

%% Compute correlation coefficients between each neuron's responses and luminance
%
% Most are pretty small, two are large. As expected.
for nn = 1:nNeurons
    corrTemp = corrcoef(theTrialLuminances,neuronResponses(:,nn));
    corrsWithLum(nn) = corrTemp(1,2);
end
nHistBins = 20;
figure; clf;
hist(corrsWithLum,nHistBins); xlim([-1 1]);
title('Correlation Histogram');

%% Set percent criteria for analysis below
percentCrits = [25 50 75];

%% Build linear regression decoder for luminance, based on responses
%
% Question is, how are weights distributed?  Most are distributed around
% zero, two are large.  As it should be.
regWeights1 = neuronResponses\theTrialLuminances;
predTrialLuminances = neuronResponses * regWeights1;

% Compute our statistic
regSorted1 = sort(abs(regWeights1));
regSum1 = sum(regSorted1);
reg1Percents = zeros(length(percentCrits),1);
runningSum = 0;
whichCrit = 1;
for ii = 1:nNeurons
    runningSum = runningSum + regSorted1(ii);
    if (runningSum > regSum1*percentCrits(whichCrit)/100)
        reg1Percents(whichCrit) = round(100*ii/nNeurons);
        whichCrit = whichCrit+1;
    end
    if (whichCrit > length(reg1Percents))
        break;
    end
end
fprintf('backslash percentiles (25, 50, 75): ');
for ii = 1:length(percentCrits)
    fprintf('%d%% ',reg1Percents(ii));
end
fprintf('\n');

% Compute our statistic
reg1Percents = GetRegWeightPercentiles(regWeights1,percentCrits);
fprintf('regress (percentCrits) (25, 50, 75): ');
for ii = 1:length(percentCrits)
    fprintf('%d%% ',reg1Percents(ii));
end
fprintf('\n');

%% Try regression using regress, which "sets maximum number of weights to zero"
regWeights2 = regress(theTrialLuminances,neuronResponses);

% Compute our statistic
reg2Percents = GetRegWeightPercentiles(regWeights2,percentCrits);
fprintf('regress percentiles (25, 50, 75): ');
for ii = 1:length(percentCrits)
    fprintf('%d%% ',reg2Percents(ii));
end
fprintf('\n');

%% And using robustfit. This tries to ignore outliers
regWeights3 = robustfit(neuronResponses,theTrialLuminances,[],[],'off');

% Compute our statistic
reg3Percents = GetRegWeightPercentiles(regWeights3,percentCrits);
fprintf('robust percentiles (25, 50, 75): ');
for ii = 1:length(percentCrits)
    fprintf('%d%% ',reg3Percents(ii));
end
fprintf('\n');

%% Try using Matlab's regularized regression
%
% This function has many many options that can affect how it
% tries to regularize.  Just going with the defaults.
regFitResults = fitrlinear(neuronResponses,theTrialLuminances,'FitBias',false);
regWeights4 = regFitResults.Beta;

% Compute our statistic
reg4Percents = GetRegWeightPercentiles(regWeights4,percentCrits);
fprintf('fitrlinear percentiles (25, 50, 75): ')
for ii = 1:length(percentCrits)
    fprintf('%d%% ',reg4Percents(ii));
end
fprintf('\n');

%% Make a histogram of the regression weights.
nHistBins = 20;
figure; clf;
hist([regWeights1 regWeights1 regWeights3 regWeights4],nHistBins);
title('Regression Weight Histogram');
legend({'backslash','regress','robustfit','fitrlinear'},'Location','NorthEast');

