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
responseNoiseSd = 0.05;

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
reg1Percents = GetRegWeightPercentiles(regWeights1,percentCrits);
fprintf('backslash (percentCrits) (25, 50, 75): ');
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

%% Try using Matlab's regularized regression, default params
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

%% Try using Matlab's regularized regression, cross-validated lasso
lambda = logspace(-8,-1,25);
regFitResultsCV = fitrlinear(neuronResponses',theTrialLuminances, ...
    'ObservationsIn','columns','KFold',5,'Lambda',lambda, ...
    'Learner','leastsquares','Solver','sparsa','Regularization','lasso', ...
    'FitBias',false);
mseCV = kfoldLoss(regFitResultsCV);
[~,rindex] = min(mseCV);
regFitResults = fitrlinear(neuronResponses',theTrialLuminances, ...
    'ObservationsIn','columns','Lambda',lambda, ...
    'Learner','leastsquares','Solver','sparsa','Regularization','lasso', ...
    'FitBias',false);
numNZCoef = sum(regFitResults.Beta~=0);
coeffL1Norm = sum(abs(regFitResults.Beta));
coeffL2Norm = sum(regFitResults.Beta.^2);
mse = loss(regFitResults,neuronResponses,theTrialLuminances);
regWeights5 = regFitResults.Beta(:,rindex);

figure; set(gcf,'Position',[1000 360 880 460])
subplot(1,2,1); hold on;
[h,hL1,hL2] = plotyy(log10(lambda),log10(mseCV),log10(lambda),log10(numNZCoef));
hL1.Marker = 'o';
hL2.Marker = 'o';
ylabel(h(1),'log_{10} MSE')
ylabel(h(2),'log_{10} nonzero-coefficient number')
xlabel('log_{10} Lambda')
title(sprintf('MSE: %0.2g, number non zero coefficients: %d',mse(rindex),numNZCoef(rindex)));
subplot(1,2,2); hold on;
[h,hL1,hL2] = plotyy(log10(lambda),log10(coeffL1Norm),log10(lambda),log10(coeffL2Norm));
hL1.Marker = 'o';
hL2.Marker = 'o';
ylabel(h(1),'log_{10} L1 Norm')
ylabel(h(2),'log_{10} L2 Norm')
xlabel('log_{10} Lambda')
title(sprintf('Lasso L1 and L2 norms'));

% Compute our statistic
reg5Percents = GetRegWeightPercentiles(regWeights5,percentCrits);
fprintf('CV lasso percentiles (25, 50, 75): ')
for ii = 1:length(percentCrits)
    fprintf('%d%% ',reg5Percents(ii));
end
fprintf('\n');

%% Try using Matlab's regularized regression, cross-validated ridge
lambda = logspace(-8,-1,25);
regFitResultsCV = fitrlinear(neuronResponses',theTrialLuminances, ...
    'ObservationsIn','columns','KFold',5,'Lambda',lambda, ...
    'Learner','leastsquares','Solver','lbfgs','Regularization','ridge', ...
    'FitBias',false);
mseCV = kfoldLoss(regFitResultsCV);
[~,rindex] = min(mseCV);
regFitResults = fitrlinear(neuronResponses',theTrialLuminances, ...
    'ObservationsIn','columns','Lambda',lambda, ...
    'Learner','leastsquares','Solver','lbfgs','Regularization','ridge', ...
    'FitBias',false);
numNZCoef = sum(regFitResults.Beta~=0);
coeffL1Norm = sum(abs(regFitResults.Beta));
coeffL2Norm = sum(regFitResults.Beta.^2);
mse = loss(regFitResults,neuronResponses,theTrialLuminances);
regWeights6 = regFitResults.Beta(:,rindex);

figure; set(gcf,'Position',[1000 360 880 460])
subplot(1,2,1); hold on;
[h,hL1,hL2] = plotyy(log10(lambda),log10(mseCV),log10(lambda),log10(numNZCoef));
hL1.Marker = 'o';
hL2.Marker = 'o';
ylabel(h(1),'log_{10} MSE')
ylabel(h(2),'log_{10} nonzero-coefficient number')
xlabel('log_{10} Lambda')
title(sprintf('MSE: %0.2g, number non zero coefficients: %d',mse(rindex),numNZCoef(rindex)));
subplot(1,2,2); hold on;
[h,hL1,hL2] = plotyy(log10(lambda),log10(coeffL1Norm),log10(lambda),log10(coeffL2Norm));
hL1.Marker = 'o';
hL2.Marker = 'o';
ylabel(h(1),'log_{10} L1 Norm')
ylabel(h(2),'log_{10} L2 Norm')
xlabel('log_{10} Lambda')
title(sprintf('Ridge L1 and L2 norms'));

% Compute our statistic
reg5Percents = GetRegWeightPercentiles(regWeights5,percentCrits);
fprintf('CV ridge percentiles (25, 50, 75): ')
for ii = 1:length(percentCrits)
    fprintf('%d%% ',reg5Percents(ii));
end
fprintf('\n');

%% Make a histogram of the regression weights.
nHistBins = 20;
figure; clf;
hist([regWeights1 regWeights1 regWeights3 regWeights4 regWeights5 regWeights6],nHistBins);
title('Regression Weight Histogram');
legend({'backslash','regress','robustfit','fitrlinear','cv lasso', 'cv ridge'},'Location','NorthEast');

%% Plot sorted regression weights
figure; clf; hold on
plot(sort(regWeights1),'ko','MarkerSize',8,'MarkerFaceColor','k');
plot(sort(regWeights5),'ro','MarkerSize',8,'MarkerFaceColor','r');
plot(sort(regWeights6),'bo','MarkerSize',8,'MarkerFaceColor','b');
legend({'regress', 'cv lasso', 'cv rigdge'});


