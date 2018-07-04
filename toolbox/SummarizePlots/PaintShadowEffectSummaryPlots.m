function PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams)
% PaintShadowEffectSummaryPlots(basicInfo,paintShadowEffect,summaryDir,figParams)
%
% Summary plots of the basic paint/shadow effect.
%
% Note that we include sessions based on the decode both RMSE, no matter
% how we are decoding.  This is because the logic is that a session is
% either good or bad, independent of what is being analyzed.
%
% The envelope threshold and RMSE thresholds used to make the plot are set here, rather than as
% a parameter.  And the mean psychophysical paint-shadow effect [-log10(gain) = 0.06]
% is also coded by hand.  Probably that's bad coding practice, but sometimes we
% just need to get the job done.
%
% We decided by eye that an RMSE threshold of 0.2 seems about right.
%
% 4/19/16  dhb  Wrote it.
% 11/06/17 dhb  Change sign of p/s effect.

%% Additional parameters
figParams.bumpSizeForMean = 6;
figureSubdir = 'PaintShadowEffect';
figureDir = fullfile(summaryDir,figureSubdir,'');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Check filterMaxRMSE
%
% Can set it by hand after this check if you want to see effect of varying.
if (basicInfo(1).filterMaxRMSE ~= 0.2)
    error('Check that you really want filterMaxRMSE set to something other than its paper value of 0.2');
end
%basicInfo(1).filterMaxRMSE = 0.24;

%% PLOT: Envelope summaries in their multiple version glory
booleanShiftedRMSEInclude = DoTheShiftedPlot(basicInfo,paintShadowEffect,figParams,figureDir,'decodeShift','');


%% PLOT: Paint/shadow effect from decoding on both paint and shadow
%
% Get the decode both results from the top level structure, and also get
% the boolean for inclusion based on decoded RMSE.
paintShadowEffectDecodeBoth = SubstructArrayFromStructArray(paintShadowEffect,'decodeBoth');
if (length(basicInfo) ~= length(paintShadowEffectDecodeBoth))
    error('Length mismatch on struct arrays that should be the same');
end
[~,booleanRMSEInclude] = GetFilteringIndex(paintShadowEffectDecodeBoth,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});

% Make the figure
paintShadowEffectDecodeBothFig = PaintShadowEffectFigure(basicInfo,paintShadowEffectDecodeBoth,booleanRMSEInclude,figParams);

% Another version
DoThePSEffectVersusPlot(basicInfo,paintShadowEffectDecodeBoth,figParams,figureDir);

% Add title and save
figure(paintShadowEffectDecodeBothFig);
title({'Paint/Shadow Effect, Decode On Both'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryPaintShadowEffectDecodeBoth','');
FigureSave(figFilename,paintShadowEffectDecodeBothFig,figParams.figType);


% Make a histogram of non-zero electrode weights
if (isfield(paintShadowEffectDecodeBoth,'numNZCoefs'))
    numNZCoefs = [paintShadowEffectDecodeBoth.numNZCoefs];
    for ii = 1:length(numNZCoefs)
        electrodeWeights = paintShadowEffectDecodeBoth(ii).electrodeWeights;
        affineTerms = paintShadowEffectDecodeBoth(ii).affineTerms;
        nElectrodes = length(electrodeWeights);
        numNZCheck = length(find(electrodeWeights ~= 0));
        if (numNZCoefs(ii) ~= numNZCheck)
            fprintf('Inconsistency in number of NZ coeefs, condition %d: %d versus %d, affine term %f\n',ii,numNZCoefs(ii),numNZCheck+affineZero,affineTerms(1));
        end
        fractionNZCoefs(ii) = numNZCheck/nElectrodes;
    end
    nonZeroHistFig = figure; clf;
    set(nonZeroHistFig,'Position',[1000 900 840 400]);
    subplot(1,2,1);
    hist(fractionNZCoefs,20,'k');
    xlabel('Fraction non-zero coefficients');
    ylabel('Count');
    title('Cross-validated lasso regularization');
    figFilename = fullfile(figureDir,'summaryNonZeroElectrodes','');
    subplot(1,2,2);
    plot(numNZCoefs,fractionNZCoefs,'ko','MarkerFaceColor','k','MarkerSize',8);
    xlabel('Number non-zero coefficients');
    ylabel('Fraction non-zero coefficients');
    FigureSave(figFilename,nonZeroHistFig,figParams.figType);
    exportfig(nonZeroHistFig,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');
    
    useLambdaFig = figure; clf;
    useLambda = [paintShadowEffectDecodeBoth.useLambda];
    useLambdaFig = figure; clf;
    hist(log10(useLambda),20,'k');
end

%% Print out null RMSE over included sessions
fprintf('Null model (guess mean) RMSE over included sessions (mean value over sessions): %0.2f\n',mean([paintShadowEffectDecodeBoth(booleanRMSEInclude).nullRMSE]));

%% We'd like to understand something about how best (non-shifted) decoder weights are distributed across electrodes
switch(basicInfo(1).type)
    case {'aff', 'fitrlinear', 'fitrcvlasso', 'fitrcvridge'}
        if (strcmp(basicInfo(1).decodeJoint,'both'))
            for ii = 1:length(paintShadowEffect)
                regPercents = GetRegWeightPercentiles(paintShadowEffect(ii).decodeBoth.electrodeWeights(:),[25 50 75]);
                fractionElectrodesForAreaFraction25(ii) = regPercents(1);
                fractionElectrodesForAreaFraction50(ii) = regPercents(2);
                fractionElectrodesForAreaFraction75(ii) = regPercents(3);
            end
            
            % Report fraction
            fprintf('Mean fraction of electrodes for 0.25 of absolute total no-shift decoding weight: %0.2f; standard dev: %0.2f\n', ...
                mean(fractionElectrodesForAreaFraction25(booleanShiftedRMSEInclude)),std(fractionElectrodesForAreaFraction25(booleanShiftedRMSEInclude)));
            fprintf('Mean fraction of electrodes for 0.50 of absolute total no-shift decoding weight: %0.2f; standard dev: %0.2f\n', ...
                mean(fractionElectrodesForAreaFraction50(booleanShiftedRMSEInclude)),std(fractionElectrodesForAreaFraction50(booleanShiftedRMSEInclude)));
            fprintf('Mean fraction of electrodes for 0.75 of absolute total no-shift decoding weight: %0.2f; standard dev: %0.2f\n', ...
                mean(fractionElectrodesForAreaFraction75(booleanShiftedRMSEInclude)),std(fractionElectrodesForAreaFraction75(booleanShiftedRMSEInclude)));
        end
end

end

%% Function to actually make the figure
function [theFigure,booleanRMSE] = PaintShadowEffectFigure(basicInfo,paintShadowEffectIn,booleanRMSE,figParams)

% Open figure
theFigure = figure; clf; hold on
tempPosition = figParams.position;
tempPosition(3) = 1000;
set(gcf,'Position',tempPosition);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
startX = 1;

% Get data for JD (V4) and add to plot
whichSubject = 'JD';
figParams.plotSymbol = 'o';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Get data for SY (V4) and add to plot
whichSubject = 'SY';
figParams.plotSymbol = 's';
figParams.plotColor = 'r';
figParams.outlineColor = 'r';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
[~,booleanRMSE] = GetFilteringIndex(paintShadowEffectIn,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Get data for BR (V1) and add to plot
whichSubject = 'BR';
figParams.plotSymbol = 's';
figParams.plotColor = 'k';
figParams.outlineColor = 'k';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
[~,booleanRMSE] = GetFilteringIndex(paintShadowEffectIn,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Get data for ST (V1) and add to plot
whichSubject = 'ST';
figParams.plotSymbol = '^';
figParams.plotColor = 'k';
figParams.outlineColor = 'k';
[~,booleanSubject] = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
[~,booleanRMSE] = GetFilteringIndex(paintShadowEffectIn,{'paintRMSE' 'shadowRMSE'},{basicInfo(1).filterMaxRMSE basicInfo(1).filterMaxRMSE}, {'<=' '<='});
indexKeep = find(booleanSubject & booleanRMSE);
paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintRMSE',indexKeep);
shadowRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'shadowRMSE',indexKeep);
paintShadowEffectArray = FilterAndGetFieldFromStructArray(paintShadowEffectIn,'paintShadowEffect',indexKeep);
plot(startX:startX+length(paintShadowEffectArray)-1,paintShadowEffectArray,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.outlineColor);
plot(startX:startX+length(paintShadowEffectArray)-1,mean(paintShadowEffectArray(~isnan(paintShadowEffectArray)))*ones(size(1:length(paintShadowEffectArray))), ...
    figParams.plotColor,'LineWidth',figParams.lineWidth);
startX = startX + length(paintShadowEffectArray);

% Add psychophysics to summary plot
%
% The script ../psychoanalysis/AnalyzeOriginalPaintShadow produces the output files we need.
% You, the user, are responsible for ensuring that the analysis done there
% is commensurate with what we are reporting from the neural recordings
% here.
if (basicInfo(1).paintCondition == 1 && basicInfo(1).shadowCondition == 2)
    figParams.plotSymbol = 'v';
    figParams.plotColor = 'b';
    thePsychoFile = fullfile(getpref('LightnessPopCode','outputBaseDir'),'xPsychoSummary','Gain','OriginalPaintShadow');
    thePsychoData = load(thePsychoFile);
    psychoPaintShadowEffect = thePsychoData.theData.allPaintShadow;
    plot(startX:startX+length(psychoPaintShadowEffect)-1,psychoPaintShadowEffect,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize+1,'MarkerFaceColor',figParams.plotColor);
    plot(startX:startX+length(psychoPaintShadowEffect)-1,...
        mean(psychoPaintShadowEffect)*ones(size(startX:startX+length(psychoPaintShadowEffect)-1)),figParams.plotColor,'LineWidth',figParams.lineWidth);
    startX = startX + length(psychoPaintShadowEffect) + 2;
end

% Save the figure
figure(theFigure);
switch (basicInfo(1).paintShadowFitType)
    case 'gain'
        plot([1 startX],[1 1],'k:','LineWidth',figParams.lineWidth);
        ylim([figParams.gainLimLow figParams.gainLimHigh]);
    case 'intcpt'
        plot([1 startX],[0 0],'k:','LineWidth',figParams.lineWidth);
        ylim([figParams.interceptLimLow figParams.interceptLimHigh]);
end
xlim([0 startX+1]);
set(gca,'YTick',figParams.interceptTicks);
set(gca,'YTickLabel',figParams.interceptTickLabels);
set(gca,'XTickLabel',{});
ylabel('Paint/Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);

end

%% Function to do the envelope summary plot
function booleanRMSE = DoTheShiftedPlot(basicInfo,paintShadowEffect,figParams,figureDir,shiftName,figureSuffix)

% This makes plots that try to summarize how much we can move the
% paint-shadow effect around without much of a hit in terms of RMSE.
% The threshold here is the hit (as a fractional increase) that we can
% tolerate, we then look at the range of p/s effects within that RMSE
% range.
%
% This value should match the value for the same variable that is also
% coded into routine ExtractedPaintShadowEffect. That one determines which
% points in the single session envelope plot get colored green.
envelopeThreshold = basicInfo.envelopeThreshold;
if (envelopeThreshold ~= 1.05)
    error('Check that you really want envelopeThreshold set to something other than its paper value of 1.05');
end

% Change this to plot unshifted or shifted RMSE
% There was a moment when I thought this might be
% a useful thing to plot, but in the end I didn't
% think so.
plotUnshifted = false;

% Go through each session and extract the range.
for ii = 1:length(paintShadowEffect)
    % Get the decode shift structure from that session
    eval(['temp = paintShadowEffect(ii).' shiftName ';']);
    
    % Find all cases where the paint-shadow effect isn't empty and
    % collect them up along with corresponding RMSEs.
    inIndex = 1;
    clear envelopePaintShadowEffects envelopeRMSEs envelopeShiftedRMSEs envelopeUnshiftedRMSEs;
    for kk = 1:length(temp)
        if ~isempty(temp(kk).paintShadowEffect)
            envelopePaintShadowEffects(inIndex) = temp(kk).paintShadowEffect;
            if (plotUnshifted)
                envelopeRMSEs(inIndex) = temp(kk).unshiftedRMSE;
            else
                envelopeRMSEs(inIndex) = temp(kk).theRMSE;
            end
            
            envelopeShiftedRMSEs(inIndex) = temp(kk).theRMSE;
            envelopeUnshiftedRMSEs(inIndex) = temp(kk).unshiftedRMSE;
            
            inIndex = inIndex + 1;
        else
            %envelopePaintShadowEffects = [];
            %envelopeRMSEs = [];
        end
    end
    
    % If there was at least one paint-shadow effect that wasn't empty,
    % analyze and accumulate.
    if (exist('envelopeRMSEs','var'))
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

% Write out good sessions into a text file
allFilenames = {paintShadowEffect.theDataDir};
filenamesFilename = fullfile(figureDir,['summaryPaintShadowRMSEGood' figureSuffix '.txt'],'');
fid = fopen(filenamesFilename,'w');
for ii = 1:length(booleanRMSE)
    if (booleanRMSE(ii))
        [a,b] = fileparts(allFilenames{ii});
        fprintf(fid,'%s\n',b);
    end
end
fclose(fid);

% Write information about all sessions into a file
allFilenames = {paintShadowEffect.theDataDir};
filenamesFilename = fullfile(figureDir,['summaryPaintShadowAllSessions' figureSuffix '.txt'],'');
fid = fopen(filenamesFilename,'w');
fprintf(fid,'Session\tSessionOK\tIncluded\tSubject\tArea\tNumber Electrodes\tNumber Trials\tNumberPaintTrials\tNumberShadowTrials\n');
numberTrials = [];
numberElectrodesBR = [];
numberElectrodesST = [];
numberElectrodesJD = [];
numberElectrodesSY = [];
for ii = 1:length(booleanRMSE)
    [a,b] = fileparts(allFilenames{ii});
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
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\n',b,sessionOKStr,includedStr,basicInfo(ii).subjectStr,basicInfo(ii).titleInfoStr, ...
        size(basicInfo(ii).paintResponses,2),basicInfo(ii).nPaintTrials+basicInfo(ii).nShadowTrials,basicInfo(ii).nPaintTrials,basicInfo(ii).nShadowTrials);
end
fclose(fid);

%% Information printout

% Say which version we are
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

% Figure version 1.
%
% Function errorbar plots neg errorbar first and pos errorbar second.
%
% The "max" and "min" in the range of paint shadow effects refer to the
% old convention where numbers greater than 1 were opposite the
% psychophysics and numbers less than one were in the same direction.
%
% So the "max" is the negative end of the range.  Didn't explicitly
% multiply both terms by -1 in computation of error bar length since
% there is an abs around the whole thing.
%
% Did change sign of psychophysical effect by hand.
paintShadowEnvelopeVsRMSEFig = figure; clf; hold on;
plotV1index = booleanV1 & booleanRMSE & booleanSessionOK;
plotV4index = booleanV4 & booleanRMSE & booleanSessionOK;
errorbar(bestRMSE(plotV1index),-log10(bestPaintShadowEffect(plotV1index)),...
    abs(log10(maxPaintShadowEffect(plotV1index))-log10(bestPaintShadowEffect(plotV1index))),...
    abs(log10(minPaintShadowEffect(plotV1index))-log10(bestPaintShadowEffect(plotV1index))),...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(bestRMSE(plotV4index),-log10(bestPaintShadowEffect(plotV4index)),...
    abs(log10(maxPaintShadowEffect(plotV4index))-log10(bestPaintShadowEffect(plotV4index))),...
    abs(log10(minPaintShadowEffect(plotV4index))-log10(bestPaintShadowEffect(plotV4index))),...
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
legend({'V1', 'V4'},'Location','NorthWest');
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeVsRMSE' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig,figParams.figType);
exportfig(paintShadowEnvelopeVsRMSEFig,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

% Figure version 1, V1 only.  
paintShadowEnvelopeVsRMSEFig_V1 = figure; clf; hold on;
plotV1_BRindex = booleanV1 & booleanRMSE & booleanSessionOK & booleanSubjectBR;
plotV1_STindex = booleanV1 & booleanRMSE & booleanSessionOK & booleanSubjectST;
errorbar(bestRMSE(plotV1_BRindex),-log10(bestPaintShadowEffect(plotV1_BRindex)),...
    abs(log10(maxPaintShadowEffect(plotV1_BRindex))-log10(bestPaintShadowEffect(plotV1_BRindex))),...
    abs(log10(minPaintShadowEffect(plotV1_BRindex))-log10(bestPaintShadowEffect(plotV1_BRindex))),...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(bestRMSE(plotV1_STindex),-log10(bestPaintShadowEffect(plotV1_STindex)),...
    abs(log10(maxPaintShadowEffect(plotV1_STindex))-log10(bestPaintShadowEffect(plotV1_STindex))),...
    abs(log10(minPaintShadowEffect(plotV1_STindex))-log10(bestPaintShadowEffect(plotV1_STindex))),...
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
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeVsRMSE_V1' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig_V1,figParams.figType);
exportfig(paintShadowEnvelopeVsRMSEFig_V1,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');
fprintf('Mean size of V1 range bars: %0.3f\n',mean(abs(log10(maxPaintShadowEffect([plotV1_BRindex | plotV1_STindex]))-log10(minPaintShadowEffect([plotV1_BRindex | plotV1_STindex])))));

%% Check by hand one red point
% basicInfo(35).theDataDir
% errorbar(bestRMSE(35),-log10(bestPaintShadowEffect(35)),...
%     abs(log10(maxPaintShadowEffect(35))-log10(bestPaintShadowEffect(35))),...
%     abs(log10(minPaintShadowEffect(35))-log10(bestPaintShadowEffect(35))),...
%     'o','Color',[1 0 0],'MarkerFaceColor',[1 0 0]); %,'MarkerSize',4);

% Figure version 1, V4 only.  Didn't change signs in error bars,
% since the abs() takes care of that.  Did change sign
% of psychophysical effect by hand.
paintShadowEnvelopeVsRMSEFig_V4 = figure; clf; hold on;
plotV4_JDindex = booleanV4 & booleanRMSE & booleanSessionOK & booleanSubjectJD;
plotV4_SYindex = booleanV4 & booleanRMSE & booleanSessionOK & booleanSubjectSY;
errorbar(bestRMSE(plotV4_JDindex),-log10(bestPaintShadowEffect(plotV4_JDindex)),...
    abs(log10(maxPaintShadowEffect(plotV4_JDindex))-log10(bestPaintShadowEffect(plotV4_JDindex))),...
    abs(log10(minPaintShadowEffect(plotV4_JDindex))-log10(bestPaintShadowEffect(plotV4_JDindex))),...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(bestRMSE(plotV4_SYindex),-log10(bestPaintShadowEffect(plotV4_SYindex)),...
    abs(log10(maxPaintShadowEffect(plotV4_SYindex))-log10(bestPaintShadowEffect(plotV4_SYindex))),...
    abs(log10(minPaintShadowEffect(plotV4_SYindex))-log10(bestPaintShadowEffect(plotV4_SYindex))),...
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
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeVsRMSE_V4' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig_V4,figParams.figType);
exportfig(paintShadowEnvelopeVsRMSEFig_V4,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');
fprintf('Mean size of V4 range bars: %0.3f\n',mean(abs(log10(maxPaintShadowEffect([plotV4_JDindex | plotV4_SYindex]))-log10(minPaintShadowEffect([plotV4_JDindex | plotV4_SYindex])))));

% Figure version 1, V1 only, no RMSE exclusion.  Didn't change signs in error bars,
% since the abs() takes care of that.  Did change sign
% of psychophysical effect by hand.
paintShadowEnvelopeVsRMSEFig_V1_AllRMSE = figure; clf; hold on;
plotV1_BRindex = booleanV1 & booleanSessionOK & booleanSubjectBR;
plotV1_STindex = booleanV1 & booleanSessionOK & booleanSubjectST;
errorbar(bestRMSE(plotV1_BRindex),-log10(bestPaintShadowEffect(plotV1_BRindex)),...
    abs(log10(maxPaintShadowEffect(plotV1_BRindex))-log10(bestPaintShadowEffect(plotV1_BRindex))),...
    abs(log10(minPaintShadowEffect(plotV1_BRindex))-log10(bestPaintShadowEffect(plotV1_BRindex))),...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(bestRMSE(plotV1_STindex),-log10(bestPaintShadowEffect(plotV1_STindex)),...
    abs(log10(maxPaintShadowEffect(plotV1_STindex))-log10(bestPaintShadowEffect(plotV1_STindex))),...
    abs(log10(minPaintShadowEffect(plotV1_STindex))-log10(bestPaintShadowEffect(plotV1_STindex))),...
    'o','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 0.3],[0 0],'k:'); %,'LineWidth',1);
plot([0 0.3],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.0 0.3]);
ylim([-0.5 0.5]);
set(gca,'YTick',[-0.5 -0.4 -0.3 -.2 -.10 0 .1 .2 0.3 0.4 0.5],'YTickLabel',{'-0.50 ' '-0.40 ' '-0.30 ' '-0.20 ' '-0.10 ' '0.00 ' '0.10 ' '0.20 ' '0.30 ' '0.4 ' '0.50 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Minimum Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
legend({'V1, BR', 'V1, ST'},'Location','NorthWest');
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeVsRMSE_V1_AllRMSE' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig_V1_AllRMSE,figParams.figType);
exportfig(paintShadowEnvelopeVsRMSEFig_V1_AllRMSE,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

% Figure version 1, V4 only, no RMSE exclusion.  Didn't change signs in error bars,
% since the abs() takes care of that.  Did change sign
% of psychophysical effect by hand.
paintShadowEnvelopeVsRMSEFig_V4_AllRMSE = figure; clf; hold on;
plotV4_JDindex = booleanV4 & booleanSessionOK & booleanSubjectJD;
plotV4_SYindex = booleanV4 & booleanSessionOK & booleanSubjectSY;
errorbar(bestRMSE(plotV4_JDindex),-log10(bestPaintShadowEffect(plotV4_JDindex)),...
    abs(log10(maxPaintShadowEffect(plotV4_JDindex))-log10(bestPaintShadowEffect(plotV4_JDindex))),...
    abs(log10(minPaintShadowEffect(plotV4_JDindex))-log10(bestPaintShadowEffect(plotV4_JDindex))),...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(bestRMSE(plotV4_SYindex),-log10(bestPaintShadowEffect(plotV4_SYindex)),...
    abs(log10(maxPaintShadowEffect(plotV4_SYindex))-log10(bestPaintShadowEffect(plotV4_SYindex))),...
    abs(log10(minPaintShadowEffect(plotV4_SYindex))-log10(bestPaintShadowEffect(plotV4_SYindex))),...
    'o','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 0.3],[0 0],'k:'); %,'LineWidth',1);
plot([0 0.3],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.0  0.3]);
ylim([-0.5 0.5]);
set(gca,'YTick',[-0.5 -0.4 -0.3 -.2 -.10 0 .1 .2 0.3 0.4 0.5],'YTickLabel',{'-0.50 ' '-0.40 ' '-0.30 ' '-0.20 ' '-0.10 ' '0.00 ' '0.10 ' '0.20 ' '0.30 ' '0.4 ' '0.50 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Minimum Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
legend({'V4, JD', 'V4, SY'},'Location','NorthWest');
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeVsRMSE_V4_AllRMSE' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig_V4_AllRMSE,figParams.figType);
exportfig(paintShadowEnvelopeVsRMSEFig_V4_AllRMSE,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

% Figure version 2
paintShadowEnvelopeSortedFig = figure; clf;
tempPosition = figParams.position;
tempPosition(3) = 1000;
set(gcf,'Position',tempPosition);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
subplot(1,2,1); hold on
[~,index] = sort(minPaintShadowEffect,'ascend');
plot(-log10(minPaintShadowEffect(index)),'r','LineWidth',2);
plot(-log10(maxPaintShadowEffect(index)),'b','LineWidth',2);
plot(0*ones(size(minPaintShadowEffect)),'k:','LineWidth',1);
ylim([-0.6 0.6]);
xlabel('Sorted Session Index','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
title({'Sorted by Lower Limit' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);

subplot(1,2,2); hold on
[~,index] = sort(maxPaintShadowEffect,'descend');
plot(-log10(minPaintShadowEffect(index)),'r','LineWidth',2);
plot(-log10(maxPaintShadowEffect(index)),'b','LineWidth',2);
plot(0*ones(size(minPaintShadowEffect)),'k:','LineWidth',1);
ylim([-0.6 0.6]);
xlabel('Sorted Session Index','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
ylabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
title({'Sorted by Upper Limit' ; ''},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeSorted' figureSuffix],'');
FigureSave(figFilename,paintShadowEnvelopeSortedFig,figParams.figType);

end

%% Function to do p/s effect versus RMSE
function DoThePSEffectVersusPlot(basicInfo,paintShadowEffect,figParams,figureDir)

% This makes plots of p/s effect from single decoding versus RMSE

for ii = 1:length(paintShadowEffect)
    
    % Find all cases where the paint-shadow effect isn't empty and
    % collect them up along with corresponding RMSEs.
    inIndex = 1;
    thePaintShadowEffects = [];
    theRMSEs = [];
    thePSEffectBootstrapSEMs = [];
    for kk = 1:length(paintShadowEffect)
        if ~isempty(paintShadowEffect(kk).paintShadowEffect)
            thePaintShadowEffects(inIndex) = paintShadowEffect(kk).paintShadowEffect;
            theRMSEs(inIndex) = paintShadowEffect(kk).theRMSE;
            thePSEffectBootstrapSEMs(inIndex) = nanstd(paintShadowEffect(kk).bPaintShadowEffect);
        else
            thePaintShadowEffects(inIndex) = NaN;
            theRMSEs(inIndex) = NaN;
            thePSEffectBootstrapSEMs(inIndex) = NaN;
        end
        inIndex = inIndex + 1;
    end
end

% Figure out V1 versus V4
booleanSessionOK = ~isnan(theRMSEs);
booleanRMSE = theRMSEs <= basicInfo(1).filterMaxRMSE;
[~,booleanSubjectBR] = GetFilteringIndex(basicInfo,{'subjectStr'},{'BR'});
[~,booleanSubjectST] = GetFilteringIndex(basicInfo,{'subjectStr'},{'ST'});
[~,booleanSubjectJD] = GetFilteringIndex(basicInfo,{'subjectStr'},{'JD'});
[~,booleanSubjectSY] = GetFilteringIndex(basicInfo,{'subjectStr'},{'SY'});
booleanV1 = booleanSubjectBR | booleanSubjectST;
booleanV4 = booleanSubjectJD | booleanSubjectSY;

% Figure V1 only.  
paintShadowEffectVsRMSEFig_V1 = figure; clf; hold on;
plotV1_BRindex = booleanV1 & booleanRMSE & booleanSessionOK & booleanSubjectBR;
plotV1_STindex = booleanV1 & booleanRMSE & booleanSessionOK & booleanSubjectST;
errorbar(theRMSEs(plotV1_BRindex),-log10(thePaintShadowEffects(plotV1_BRindex)),thePSEffectBootstrapSEMs(plotV1_BRindex), ...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(theRMSEs(plotV1_STindex),-log10(thePaintShadowEffects(plotV1_STindex)),thePSEffectBootstrapSEMs(plotV1_STindex), ...
    'o','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 basicInfo(1).filterMaxRMSE],[0 0],'k:'); %,'LineWidth',1);
plot([0 basicInfo(1).filterMaxRMSE],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.05 basicInfo(1).filterMaxRMSE]);
ylim([-0.15 0.15]);
set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
legend({'V1, BR', 'V1, ST'},'Location','NorthWest');
figFilename = fullfile(figureDir,['summaryPaintShadowEffectVsRMSE_V1'],'');
FigureSave(figFilename,paintShadowEffectVsRMSEFig_V1,figParams.figType);
exportfig(paintShadowEffectVsRMSEFig_V1,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

% FigureV4 only.
paintShadowEffectVsRMSEFig_V4 = figure; clf; hold on;
plotV4_JDindex = booleanV4 & booleanRMSE & booleanSessionOK & booleanSubjectJD;
plotV4_SYindex = booleanV4 & booleanRMSE & booleanSessionOK & booleanSubjectSY;
errorbar(theRMSEs(plotV4_JDindex),-log10(thePaintShadowEffects(plotV4_JDindex)),thePSEffectBootstrapSEMs(plotV4_JDindex), ...
    's','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',4);
errorbar(theRMSEs(plotV4_SYindex),-log10(thePaintShadowEffects(plotV4_SYindex)),thePSEffectBootstrapSEMs(plotV4_SYindex), ...
    'o','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 basicInfo(1).filterMaxRMSE],[0 0],'k:'); %,'LineWidth',1);
plot([0 basicInfo(1).filterMaxRMSE],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.05 basicInfo(1).filterMaxRMSE]);
ylim([-0.15 0.15]);
set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
legend({'V4, JD', 'V4, SY'},'Location','NorthWest');
figFilename = fullfile(figureDir,['summaryPaintShadowEffecVsRMSE_V4'],'');
FigureSave(figFilename,paintShadowEffectVsRMSEFig_V4,figParams.figType);
exportfig(paintShadowEffectVsRMSEFig_V4,[figFilename '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');


end



