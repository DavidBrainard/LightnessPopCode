% Compare some aspects of what happens across different decoding methods
%
% 05/26/18  dhb  Wrote first version.

%% Clear
clear; close all;

%% Save directory
saveDir = fullfile('/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary','xCompare');
if (~exist(saveDir,'dir'))
    mkdir(saveDir);
end

%% Define diretories to compare
method1 = 'Standard';
switch (method1)
    case 'Standard'
        directory1 = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
end

method2 = 'CVLasso';
switch (method2)
    case 'Shuffle'
        directory2 = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/aff_cls-mvmaSMO_pca-no_intshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
    case 'CVLasso'
        directory2  = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
    case 'CVRidge'
        directory2  = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/fitrcvridge_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
    case 'PoissonML'
        directory2  = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/maxlikelypoiss_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
end

%% Load data
data1 = load(fullfile(directory1,'paintShadowEffectStructArray'));
data2 = load(fullfile(directory2,'paintShadowEffectStructArray'));

%% Get RMSEs
basicInfo = data1.basicInfo;
paintShadowEffect1 = [data1.paintShadowEffect(:)];
decodeBoth1 = [paintShadowEffect1(:).decodeBoth];
rmse1 = [decodeBoth1(:).theRMSE];
for kk = 1:length(paintShadowEffect1)
    decodeShift1(kk,:) = paintShadowEffect1(kk).decodeShift;
end

paintShadowEffect2 = [data2.paintShadowEffect(:)];
decodeBoth2 = [paintShadowEffect2(:).decodeBoth];
rmse2 = [decodeBoth2(:).theRMSE];
for kk = 1:length(paintShadowEffect2)
    decodeShift2(kk,:) = paintShadowEffect2(kk).decodeShift;
end

%% Plot RMSE versus RMSE
rmseCompareFig = figure; clf; hold on;
plot(rmse1,rmse2,'ko','MarkerFaceColor','k','MarkerSize',8);
plot([0 0.3],[0 0.3],'k:')
xlabel(sprintf('%s RMSE',method1));
ylabel(sprintf('%s RMSE',method2));
axis('square');
axis([0.05 0.3 0.05 0.3]);
figFilename = sprintf('Compare_%s_%s_RMSE',method1,method2);
FigureSave(fullfile(saveDir,figFilename),rmseCompareFig,'pdf');

%% Figure 8 plot combined across the two regression methods
% 
% This code is stripped out of PaintShadowEffectSummaryPlots,
% and then modified to combine across multiple methods.  A
% bit of a kluge, but I think it is doing the right thing.
envelopeThreshold = 1.05;
if (length(paintShadowEffect1) ~= length(paintShadowEffect2))
    error('Ugh');
end
for ii = 1:length(paintShadowEffect1)
    
    % Find all cases where the paint-shadow effect isn't empty and
    % collect them up along with corresponding RMSEs.
    inIndex = 1;
    envelopePaintShadowEffects = [];
    envelopeRMSEs = [];
    temp = decodeShift1(ii,:);
    for kk = 1:length(temp)
        if ~isempty(temp(kk).paintShadowEffect)
            envelopePaintShadowEffects(inIndex) = temp(kk).paintShadowEffect;
            envelopeRMSEs(inIndex) = temp(kk).theRMSE;
            inIndex = inIndex + 1;
        else
            %envelopePaintShadowEffects = [];
            %envelopeRMSEs = [];
        end
    end
    temp = decodeShift2(ii,:);
    for kk = 1:length(temp)
        if ~isempty(temp(kk).paintShadowEffect)
            envelopePaintShadowEffects(inIndex) = temp(kk).paintShadowEffect;
            envelopeRMSEs(inIndex) = temp(kk).theRMSE;
            inIndex = inIndex + 1;
        else
            %envelopePaintShadowEffects = [];
            %envelopeRMSEs = [];
        end
    end
    
    % If there was at least one paint-shadow effect that wasn't empty,
    % analyze and accumulate.
    if (~isempty(envelopeRMSEs))
        [bestRMSE(ii),bestIndex] = min(envelopeRMSEs);
        normEnvelopeRMSEs = envelopeRMSEs/bestRMSE(ii);
        index = find(normEnvelopeRMSEs < envelopeThreshold);
        minPaintShadowEffect(ii) = min(envelopePaintShadowEffects(index));
        maxPaintShadowEffect(ii) = max(envelopePaintShadowEffects(index));
        meanPaintShadowEffect(ii) = mean(envelopePaintShadowEffects(index));
        bestPaintShadowEffect(ii) = envelopePaintShadowEffects(bestIndex);
    else
        bestRMSE(ii) = NaN;
        minPaintShadowEffect(ii) = NaN;
        maxPaintShadowEffect(ii) = NaN;
        meanPaintShadowEffect(ii) = NaN;
        bestPaintShadowEffect(ii) = NaN;
    end
end

% Figure out V1 versus V4
booleanSessionOK = ~isnan(bestRMSE);
booleanRMSE = bestRMSE <= basicInfo(1).filterMaxRMSE;
[~,booleanSubjectBR] = GetFilteringIndex(basicInfo,{'subjectStr'},{'BR'});
[~,booleanSubjectST] = GetFilteringIndex(basicInfo,{'subjectStr'},{'ST'});
[~,booleanSubjectJD] = GetFilteringIndex(basicInfo,{'subjectStr'},{'JD'});
[~,booleanSubjectSY] = GetFilteringIndex(basicInfo,{'subjectStr'},{'SY'});
booleanV1 = booleanSubjectBR | booleanSubjectST;
booleanV4 = booleanSubjectJD | booleanSubjectSY;

% Compute number of sessions included in summary plot for each subject
numberSessionsBR = length(find(booleanSubjectBR));
numberRMSEOKSessionsBR = length(find(booleanSubjectBR & booleanRMSE));
fprintf('Subject BR: including %d of %d sessions\n',numberRMSEOKSessionsBR,numberSessionsBR);
numberSessionsST = length(find(booleanSubjectST));
numberRMSEOKSessionsST = length(find(booleanSubjectST & booleanRMSE));
fprintf('Subject ST: including %d of %d sessions\n',numberRMSEOKSessionsST,numberSessionsST);
numberSessionsJD = length(find(booleanSubjectJD));
numberRMSEOKSessionsJD = length(find(booleanSubjectJD & booleanRMSE));
fprintf('Subject JD: including %d of %d sessions\n',numberRMSEOKSessionsJD,numberSessionsJD);
numberSessionsSY = length(find(booleanSubjectSY));
numberRMSEOKSessionsSY = length(find(booleanSubjectSY & booleanRMSE));
fprintf('Subject SY: including %d of %d sessions\n',numberRMSEOKSessionsSY,numberSessionsSY);
fprintf('Overall: including %d of %d sessions\n', ...
    numberRMSEOKSessionsBR+numberRMSEOKSessionsST+numberRMSEOKSessionsJD+numberRMSEOKSessionsSY, ...
    numberSessionsBR+numberSessionsST+numberSessionsJD+numberSessionsSY);

%% Information printout
numberTrials = [];
numberElectrodesBR = [];
numberElectrodesST = [];
numberElectrodesJD = [];
numberElectrodesSY = [];
for ii = 1:length(booleanRMSE)
    if (booleanSessionOK(ii))
        sessionOKStr = 'Yes';
    else
        sessionOKStr = 'No';
    end
    if (booleanRMSE(ii) & booleanSessionOK(ii))
        includedStr = 'Yes';
        numberTrials = [numberTrials basicInfo(ii).nPaintTrials+basicInfo(ii).nShadowTrials];
        if (booleanSubjectBR(ii))
            numberElectrodesBR = [numberElectrodesBR size(basicInfo(ii).paintResponses,2)];
        elseif(booleanSubjectST(ii))
            numberElectrodesST = [numberElectrodesST size(basicInfo(ii).paintResponses,2)];
        elseif(booleanSubjectJD(ii))
            numberElectrodesJD = [numberElectrodesJD size(basicInfo(ii).paintResponses,2)];
        elseif(booleanSubjectSY(ii))
            numberElectrodesSY = [numberElectrodesSY size(basicInfo(ii).paintResponses,2)];
        else
            error('Unknown monkey');
        end
    else
        includedStr = 'No';
    end
end

% Say which version we are
figureSuffix = sprintf('%s_%s',method1,method2);
fprintf('\n*****EnvelopeSummary%s*****\n',figureSuffix);

% Info about good sessions
fprintf('There were %d sessions analyzed out of a total of %d sessions\n',length(find(booleanRMSE & booleanSessionOK)),length(booleanRMSE));
fprintf('\t%d V1 sessions (%d BR, %d ST)\n', ...
    length(find(booleanV1 & booleanRMSE & booleanSessionOK)),length(find(booleanSubjectBR & booleanRMSE & booleanSessionOK)),length(find(booleanSubjectST & booleanRMSE & booleanSessionOK)));
fprintf('\t%d V1 sessions (%d JD, %d SY)\n', ...
    length(find(booleanV4 & booleanRMSE & booleanSessionOK)),length(find(booleanSubjectJD & booleanRMSE & booleanSessionOK)),length(find(booleanSubjectSY & booleanRMSE & booleanSessionOK)));
fprintf('Mean number of trials per included session: %0.1f, +/- %0.1f std\n',mean(numberTrials),std(numberTrials));
fprintf('Mean number of electrodes per included session:\n');
fprintf('\tBR: %0.1f, +/- %0.1f std\n',mean(numberElectrodesBR),std(numberElectrodesBR));
fprintf('\tST: %0.1f, +/- %0.1f std\n',mean(numberElectrodesST),std(numberElectrodesST));
fprintf('\tJD: %0.1f, +/- %0.1f std\n',mean(numberElectrodesJD),std(numberElectrodesJD));
fprintf('\tSY: %0.1f, +/- %0.1f std\n',mean(numberElectrodesSY),std(numberElectrodesSY));

% A little print out of where intervals fall
%
% We haven't yet taken the -log10, so we compare to 1 but printout relative
% to zero. Effects greater than 1 before taking the -log10 are less than 0.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE);
fractionStraddle = length(index1)/length(find(booleanRMSE));
fprintf('\n%0.1f%% of %d sessions (%d) have p/s interval that straddle 0\n',round(1000*fractionStraddle)/10,length(index1),length(find(booleanRMSE)));
index2 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE);
fractionBelow = length(index2)/length(find(booleanRMSE));
fprintf('%0.1f%% of %d sessions (%d) have p/s interval strictly less than 0\n',round(1000*fractionBelow)/10,length(index2),length(find(booleanRMSE)));
index3 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE);
fractionAbove = length(index3)/length(find(booleanRMSE));
fprintf('%0.1f%% of %d sessions (%d) have p/s interval strictly greater than 0\n',round(1000*fractionAbove)/10,length(index3),length(find(booleanRMSE)));

% A little print out of where intervals fall, V1. Effects greater than 1
% before taking the -log10 are less than 0.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV1));
fprintf('\n%0.1f%% of %d V1 sessions (%d) have p/s interval that straddle 0\n',round(1000*fractionStraddle)/10,length(index1),length(find(booleanRMSE & booleanV1)));
index2 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV1));
fprintf('%0.1f%% of %d V1 sessions (%d) have p/s interval strictly less than 0\n',round(1000*fractionBelow)/10,length(index2),length(find(booleanRMSE & booleanV1)));
index3 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV1);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV1));
fprintf('%0.1f%% of %d V1 sessions (%d) have p/s interval strictly greater than 0\n',round(1000*fractionAbove)/10,length(index3),length(find(booleanRMSE & booleanV1)));

% A little print out of where intervals fall, V4.  Effects greater than 1
% before taking the -log10 are less than 0.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV4));
fprintf('\n%0.1f%% of %d V4 sessions (%d) have p/s interval that straddle 0\n',round(1000*fractionStraddle)/10,length(index1),length(find(booleanRMSE & booleanV4)));
index2 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV4));
fprintf('%0.1f%% of %d V4 sessions (%d) have p/s interval strictly less than 0\n',round(1000*fractionBelow)/10,length(index2),length(find(booleanRMSE & booleanV4)));
index3 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV4);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV4));
fprintf('%0.1f%% of %d V4 sessions (%d) have p/s interval strictly greater than 0\n',round(1000*fractionAbove)/10,length(index3),length(find(booleanRMSE & booleanV4)));

% A little print out of where intervals fall, JD. Effects greater than 1
% before taking the -log10 are less than 0.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4 & booleanSubjectJD);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV4 & booleanSubjectJD));
fprintf('\n%0.1f%% of %d JD (V4) sessions have p/s interval that straddle 0\n',round(1000*fractionStraddle)/10,length(find(booleanRMSE & booleanV4 & booleanSubjectJD)));
index2 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4 & booleanSubjectJD);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV4 & booleanSubjectJD));
fprintf('%0.1f%% of %d JD (V4) sessions have p/s interval strictly less than 0\n',round(1000*fractionBelow)/10,length(find(booleanRMSE & booleanV4 & booleanSubjectJD)));
index3 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV4 & booleanSubjectJD);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV4 & booleanSubjectJD));
fprintf('%0.1f%% of %d JD (V4) sessions have p/s interval strictly greater than 0\n',round(1000*fractionAbove)/10,length(find(booleanRMSE & booleanV4 & booleanSubjectJD)));

% A little print out of where intervals fall, SY. Effects greater than 1
% before taking the -log10 are less than 0.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4 & booleanSubjectSY);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV4 & booleanSubjectSY));
fprintf('\n%0.1f%% of %d SY (V4) sessions have p/s interval that straddle 0\n',round(1000*fractionStraddle)/10,length(find(booleanRMSE & booleanV4 & booleanSubjectSY)));
index2 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV4 & booleanSubjectSY);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV4 & booleanSubjectSY));
fprintf('%0.1f%% of %d SY (V4) sessions have p/s interval strictly less than 0\n',round(1000*fractionBelow)/10,length(find(booleanRMSE & booleanV4 & booleanSubjectSY)));
index3 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV4 & booleanSubjectSY);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV4 & booleanSubjectSY));
fprintf('%0.1f%% of %d SY (V4) sessions have p/s interval strictly greater than 0\n',round(1000*fractionAbove)/10,length(find(booleanRMSE & booleanV4 & booleanSubjectSY)));

% A little print out of where intervals fall, BR. Effects greater than 1
% before taking the -log10 are less than 0.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1 & booleanSubjectBR);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV1 & booleanSubjectBR));
fprintf('\n%0.1f%% of %d BR (V1) sessions have p/s interval that straddle 0\n',round(1000*fractionStraddle)/10,length(find(booleanRMSE & booleanV1 & booleanSubjectBR)));
index2 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1 & booleanSubjectBR);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV1 & booleanSubjectBR));
fprintf('%0.1f%% of %d BR (V1) sessions have p/s interval strictly less than 0\n',round(1000*fractionBelow)/10,length(find(booleanRMSE & booleanV1 & booleanSubjectBR)));
index3 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV1 & booleanSubjectBR);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV1 & booleanSubjectBR));
fprintf('%0.1f%% of %d BR (V1) sessions have p/s interval strictly greater than 0\n',round(1000*fractionAbove)/10,length(find(booleanRMSE & booleanV1 & booleanSubjectBR)));

% A little print out of where intervals fall, ST. Effects greater than 1
% before taking the -log10 are less than 0.
index1 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1 & booleanSubjectST);
fractionStraddle = length(index1)/length(find(booleanRMSE & booleanV1 & booleanSubjectST));
fprintf('\n%0.1f%% of %d ST (V1) sessions have p/s interval that straddle 0\n',round(1000*fractionStraddle)/10,length(find(booleanRMSE & booleanV1 & booleanSubjectST)));
index2 = find(minPaintShadowEffect > 1 & maxPaintShadowEffect > 1 & booleanRMSE & booleanV1 & booleanSubjectST);
fractionBelow = length(index2)/length(find(booleanRMSE & booleanV1 & booleanSubjectST));
fprintf('%0.1f%% of %d ST (V1) sessions have p/s interval strictly less than 0\n',round(1000*fractionBelow)/10,length(find(booleanRMSE & booleanV1 & booleanSubjectST)));
index3 = find(minPaintShadowEffect < 1 & maxPaintShadowEffect < 1 & booleanRMSE & booleanV1 & booleanSubjectST);
fractionAbove = length(index3)/length(find(booleanRMSE & booleanV1 & booleanSubjectST));
fprintf('%0.1f%% of %d ST (V1) sessions have p/s interval strictly greater than 0\n',round(1000*fractionAbove)/10,length(find(booleanRMSE & booleanV1 & booleanSubjectST)));

% And printout where the best RMSE p/s effects are.  Best effect greater
% than 1 before taking the -log10 is a p/s less than 0 after taking
% -log10.
index1 = find(bestPaintShadowEffect > 1 & booleanRMSE);
fractionBestUnder = length(index1)/length(find(booleanRMSE));
fprintf('\n%0.1f%% of %d sessions have best p/s effect less than 0\n',round(100*fractionBestUnder),length(find(booleanRMSE)));
index1 = find(bestPaintShadowEffect > 1 & booleanRMSE & booleanV1);
fractionBestUnder = length(index1)/length(find(booleanRMSE & booleanV1));
fprintf('%0.1f%% of %d V1 sessions have best p/s effect less than 0\n',round(100*fractionBestUnder),length(find(booleanRMSE & booleanV1)));
index1 = find(bestPaintShadowEffect > 1 & booleanRMSE & booleanV4);
fractionBestUnder = length(index1)/length(find(booleanRMSE & booleanV4));
fprintf('%0.1f%% of %d V4 sessions have best p/s effect less than 0\n',round(100*fractionBestUnder),length(find(booleanRMSE & booleanV4)));

% And range.  Didn't change sign in computation of range, since it doesn't
% matter.
index1 = find(booleanRMSE);
psRange = mean(log10(maxPaintShadowEffect(index1)) - log10(minPaintShadowEffect(index1)));
fprintf('\nMean p/s effect range %0.3f\n',psRange);
index1 = find(booleanRMSE & booleanV1);
psRange = mean(log10(maxPaintShadowEffect(index1)) - log10(minPaintShadowEffect(index1)));
fprintf('Mean V1 p/s effect range %0.3f\n',psRange);
index1 = find(booleanRMSE & booleanV4);
psRange = mean(log10(maxPaintShadowEffect(index1)) - log10(minPaintShadowEffect(index1)));
fprintf('Mean V4 p/s effect range %0.3f\n',psRange);

% Figure version 1, V1 only.
paintShadowEnvelopeVsRMSEFig_V1 = figure; clf; hold on;
plotV1_BRindex = booleanV1 & booleanRMSE & booleanSessionOK & booleanSubjectBR;
plotV1_STindex = booleanV1 & booleanRMSE & booleanSessionOK & booleanSubjectST;
errorbar(bestRMSE(plotV1_BRindex),-log10(bestPaintShadowEffect(plotV1_BRindex)),...
    abs(log10(maxPaintShadowEffect(plotV1_BRindex))-log10(meanPaintShadowEffect(plotV1_BRindex))),...
    abs(log10(minPaintShadowEffect(plotV1_BRindex))-log10(meanPaintShadowEffect(plotV1_BRindex))),...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(bestRMSE(plotV1_STindex),-log10(bestPaintShadowEffect(plotV1_STindex)),...
    abs(log10(maxPaintShadowEffect(plotV1_STindex))-log10(meanPaintShadowEffect(plotV1_STindex))),...
    abs(log10(minPaintShadowEffect(plotV1_STindex))-log10(meanPaintShadowEffect(plotV1_STindex))),...
    'o','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 basicInfo(1).filterMaxRMSE],[0 0],'k:'); %,'LineWidth',1);
plot([0 basicInfo(1).filterMaxRMSE],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.05 basicInfo(1).filterMaxRMSE]);
ylim([-0.15 0.15]);
set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Minimum Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
legend({'V1, BR', 'V1, ST'},'Location','NorthWest');
figFilename = fullfile(saveDir,['summaryPaintShadowEnvelopeVsRMSE_V1' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig_V1,'pdf');
exportfig(paintShadowEnvelopeVsRMSEFig_V1,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

%% Check by hand one red point
% basicInfo(35).theDataDir
% errorbar(bestRMSE(35),-log10(bestPaintShadowEffect(35)),...
%     abs(log10(maxPaintShadowEffect(35))-log10(meanPaintShadowEffect(35))),...
%     abs(log10(minPaintShadowEffect(35))-log10(meanPaintShadowEffect(35))),...
%     'o','Color',[1 0 0],'MarkerFaceColor',[1 0 0]); %,'MarkerSize',4);

% Figure version 1, V4 only.  Didn't change signs in error bars,
% since the abs() takes care of that.  Did change sign
% of psychophysical effect by hand.
paintShadowEnvelopeVsRMSEFig_V4 = figure; clf; hold on;
plotV4_JDindex = booleanV4 & booleanRMSE & booleanSessionOK & booleanSubjectJD;
plotV4_SYindex = booleanV4 & booleanRMSE & booleanSessionOK & booleanSubjectSY;
errorbar(bestRMSE(plotV4_JDindex),-log10(bestPaintShadowEffect(plotV4_JDindex)),...
    abs(log10(maxPaintShadowEffect(plotV4_JDindex))-log10(meanPaintShadowEffect(plotV4_JDindex))),...
    abs(log10(minPaintShadowEffect(plotV4_JDindex))-log10(meanPaintShadowEffect(plotV4_JDindex))),...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(bestRMSE(plotV4_SYindex),-log10(bestPaintShadowEffect(plotV4_SYindex)),...
    abs(log10(maxPaintShadowEffect(plotV4_SYindex))-log10(meanPaintShadowEffect(plotV4_SYindex))),...
    abs(log10(minPaintShadowEffect(plotV4_SYindex))-log10(meanPaintShadowEffect(plotV4_SYindex))),...
    'o','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 basicInfo(1).filterMaxRMSE],[0 0],'k:'); %,'LineWidth',1);
plot([0 basicInfo(1).filterMaxRMSE],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.05 basicInfo(1).filterMaxRMSE]);
ylim([-0.15 0.15]);
set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Minimum Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
legend({'V4, JD', 'V4, SY'},'Location','NorthWest');
figFilename = fullfile(saveDir,['summaryPaintShadowEnvelopeVsRMSE_V4' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig_V4,'pdf');
exportfig(paintShadowEnvelopeVsRMSEFig_V4,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

