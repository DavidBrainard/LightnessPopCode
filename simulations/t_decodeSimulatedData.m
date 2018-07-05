%% t_decodeSimulatedData
%
% Description:
%    Try our various decoders on simulated data
%
% 05/09/18  dhb  Wrote it.

%% Clear and close
clear; close all;

%% Stimulus parameters
nIntensities = 15;
nTrialsPerLuminance = 10;

%% Neural parameters
%
% Converstion between gain and p/s effect
%    psGain = 1/(10^-psEffect)
%    psEffect = -log10(1/psGain)
paintShadowEffectLow = 0.04;
paintShadowEffectHigh = 0.08;
paintShadowGainLow = 1/(10^-paintShadowEffectLow);
paintShadowGainHigh = 1/(10^-paintShadowEffectHigh);
nNeuronsModulatedByDiskAndContext = 20;
nNeuronsModulatedByDiskOnly = 20;
nNeuronsModulatedByContextOnly = 20;
nNeuronsNotModulated = 0;

% Ranges for uniform draw of neuron gains and exponents.
neuronGainLow = 0.8;
neuronGainHigh = 1.2;
neuronExpLow = 0.3;
neuronExpHigh = 0.5;

% Multiplicative fraction that sets simulatd noise sd as a function
% of simulated mean response.
responseNoiseSdFraction = 0.5;

%% Number of simulations, etc.
nSimulations = 20;
doBootstrap = false;
nBootstraps = 25;

%% What to train on
%   'both'
%   'paint'
%   'shadow'
TRAIN = 'both';

%% Type of regression
%   'aff'
%   'fitrlinear'
%   'fitrcvlasso'
%   'fitcvridge'
%   'lassoglm1'
%   'maxlikely'
TYPE = 'aff';

%% Loop over simulations
for ss = 1:nSimulations
    % Close up any figures
    close all
    
    % Set up luminances across trials
    theIntensities = linspace(0.2,1,nIntensities);
    nPaintTrials = nIntensities*nTrialsPerLuminance;
    nShadowTrials = nPaintTrials;
    paintIntensities = zeros(nPaintTrials,1);
    shadowIntensities = zeros(nShadowTrials,1);
    lumIndex = 1;
    for ll = 1:nIntensities
        for nn = 1:nTrialsPerLuminance
            paintIntensities(lumIndex) = theIntensities(ll);
            shadowIntensities(lumIndex) = theIntensities(ll);
            lumIndex = lumIndex+1;
        end
    end
    
    % Generate simulated neural data
    %
    % Some neurons are modulated by the disk intensity and context
    neuronIndex = 1;
    for nn = 1:nNeuronsModulatedByDiskAndContext
        neuronGain(neuronIndex) = unifrnd(neuronGainLow,neuronGainHigh);
        neuronExp(neuronIndex) = unifrnd(neuronExpLow,neuronExpHigh);
        paintShadowGain(neuronIndex) = unifrnd(paintShadowGainLow,paintShadowGainHigh);
        paintResponsesRaw(:,neuronIndex) = (neuronGain(neuronIndex)*paintIntensities/sqrt(paintShadowGain(neuronIndex))).^neuronExp(neuronIndex);
        shadowResponsesRaw(:,neuronIndex) = (sqrt(paintShadowGain(neuronIndex))*neuronGain(neuronIndex)*shadowIntensities).^neuronExp(neuronIndex);
        
        paintResponses(:,neuronIndex) = paintResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*paintResponsesRaw(:,neuronIndex));
        shadowResponses(:,neuronIndex) = shadowResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*shadowResponsesRaw(:,neuronIndex));
        
        neuronIndex = neuronIndex + 1;
    end
    
    % Some by disk intensity only
    for nn = 1:nNeuronsModulatedByDiskOnly
        neuronGain(neuronIndex) = unifrnd(neuronGainLow,neuronGainHigh);
        neuronExp(neuronIndex) = unifrnd(neuronExpLow,neuronExpHigh);
        paintShadowGain(neuronIndex) = unifrnd(paintShadowGainLow,paintShadowGainHigh);
        paintResponsesRaw(:,neuronIndex) = (neuronGain(neuronIndex)*paintIntensities).^neuronExp(neuronIndex);
        shadowResponsesRaw(:,neuronIndex) = (neuronGain(neuronIndex)*shadowIntensities).^neuronExp(neuronIndex);
        
        paintResponses(:,neuronIndex) = paintResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*paintResponsesRaw(:,neuronIndex));
        shadowResponses(:,neuronIndex) = shadowResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*shadowResponsesRaw(:,neuronIndex));
        
        neuronIndex = neuronIndex + 1;
    end
    
    % Some by context only
    for nn = nNeuronsModulatedByContextOnly
        neuronGain(neuronIndex) = unifrnd(neuronGainLow,neuronGainHigh);
        neuronExp(neuronIndex) = unifrnd(neuronExpLow,neuronExpHigh);
        paintShadowGain(neuronIndex) = unifrnd(paintShadowGainLow,paintShadowGainHigh);
        paintResponsesRaw(:,neuronIndex) = (neuronGain(neuronIndex)*mean(paintIntensities)/sqrt(paintShadowGain(neuronIndex))).^neuronExp(neuronIndex);
        shadowResponsesRaw(:,neuronIndex) = (sqrt(paintShadowGain(neuronIndex))*neuronGain(neuronIndex)*mean(paintIntensities)).^neuronExp(neuronIndex);
        
        paintResponses(:,neuronIndex) = paintResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*paintResponsesRaw(:,neuronIndex));
        shadowResponses(:,neuronIndex) = shadowResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*shadowResponsesRaw(:,neuronIndex));
        
        neuronIndex = neuronIndex + 1;
        
    end
    
    % And some are not modulated ata all
    for nn = nNeuronsNotModulated
        neuronGain(neuronIndex) = unifrnd(neuronGainLow,neuronGainHigh);
        neuronExp(neuronIndex) = unifrnd(neuronExpLow,neuronExpHigh);
        paintShadowGain(neuronIndex) = unifrnd(paintShadowGainLow,paintShadowGainHigh);
        paintResponsesRaw(:,neuronIndex) = (neuronGain(neuronIndex)*mean(paintIntensities)).^neuronExp(neuronIndex);
        shadowResponsesRaw(:,neuronIndex) = (neuronGain(neuronIndex)*mean(shadowIntensities)).^neuronExp(neuronIndex);
        
        paintResponses(:,neuronIndex) = paintResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*paintResponsesRaw(:,neuronIndex));
        shadowResponses(:,neuronIndex) = shadowResponsesRaw(:,neuronIndex) + normrnd(0,responseNoiseSdFraction*shadowResponsesRaw(:,neuronIndex));
        
        neuronIndex = neuronIndex + 1;
        
    end
    
    % Set decoding parameters
    decodeInfo.type = TYPE;
    decodeInfo.decodeJoint = TRAIN;
    decodeInfo.decodeLOOType = 'kfold';
    decodeInfo.decodeNFolds = 10;
    decodeInfo.decodedIntensityFitType = 'betacdf';
    decodeInfo.paintShadowFitType = 'gain';
    decodeInfo.inferIntensityLevelsDiscrete = [25 35 45 55 65 75]/100;
    decodeInfo.nFinelySpacedIntensities = 1000;
    decodeInfo.minFineGrainedIntensities = 0.20;
    
    decodeInfo.intensityLimLow = -0.05;
    decodeInfo.intensityLimHigh = 1.05;
    decodeInfo.intensityTicks = [0.0 0.25 0.5 0.75 1.0];
    decodeInfo.intensityTickLabels = {'0.00' '0.25' '0.50' '0.75' '1.00'};
    decodeInfo.intensityYTickLabels = {'0.00 ' '0.25 ' '0.50 ' '0.75 ' '1.00 '};
    
    % Standard decoding and digesting block of code (from ExtractedPaintShadowEffect)
    [~,~,d.paintPreds,d.shadowPreds,dTmp] = PaintShadowDecode(decodeInfo, ...
        paintIntensities,paintResponses,shadowIntensities,shadowResponses);
    d.paintRMSE = sqrt(mean((paintIntensities(:)-d.paintPreds(:)).^2));
    d.shadowRMSE = sqrt(mean((shadowIntensities(:)-d.shadowPreds(:)).^2));
    d.theRMSE = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-[d.paintPreds(:) ; d.shadowPreds(:)]).^2));
    d.nullRMSE = sqrt(mean(([paintIntensities(:) ; shadowIntensities(:)]-mean([paintIntensities(:) ; shadowIntensities(:)])).^2));
    d.paintMean = mean(d.paintPreds(:));
    d.shadowMean = mean(d.shadowPreds(:));
    d.shadowMinusPaintMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
    [d.paintMeans,d.paintSEMs,~,~,~,d.paintGroupedIntensities] = ...
        sortbyx(paintIntensities,d.paintPreds);
    [d.shadowMeans,d.shadowSEMs,~,~,~,d.shadowGroupedIntensities] = ...
        sortbyx(shadowIntensities,d.shadowPreds);
    [d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
        d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
        FindPaintShadowEffect(decodeInfo,d.paintGroupedIntensities,d.shadowGroupedIntensities,d.paintMeans,d.shadowMeans);
    
    % Plot decoded intensities in from of Figure 7A.
    decodingfig = figure; clf;
    hold on;
    h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'r');
    h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'b');
    h=errorbar(d.paintGroupedIntensities, d.paintMeans, d.paintSEMs, 'ro');
    h=errorbar(d.shadowGroupedIntensities, d.shadowMeans, d.shadowSEMs, 'bo');
    h=plot(d.paintGroupedIntensities, d.paintMeans, 'ro','MarkerFaceColor','r');
    h=plot(d.shadowGroupedIntensities, d.shadowMeans, 'bo','MarkerFaceColor','b');
    xlabel('Stimulus Luminance');
    ylabel('Decoded Luminance');
    text(0.8,0.00,sprintf('RMSE: %0.2f',d.theRMSE));
    plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:');
    axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh]);
    set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
    set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
    legend({'Paint','Shadow'},'Location','NorthWest');
    axis square
    a=get(gca,'ticklength');
    set(gca,'ticklength',[a(1)*2,a(2)*2]);
    set(gca,'tickdir','out');
    box off
    drawnow;
    % figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeBothDecoding'];
    % FigureSave(figName,decodingfig,decodeInfo.figType);
    
    % Plot inferred matches in form of Figure 7B.
    predmatchfig = figure; clf;
    hold on;
    if (~isempty(d.paintMatchesDiscrete) & ~isempty(d.shadowMatchesDiscrete))
        h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscrete,'bo','MarkerFaceColor','b'); %,'MarkerSize',decodeInfo.markerSize);
        h=plot(d.paintMatchesDiscrete,d.shadowMatchesDiscretePred,'b'); %,'LineWidth',decodeInfo.lineWidth);
    end
    xlabel('Decoded Paint Luminance'); %,'FontSize',decodeInfo.labelFontSize);
    ylabel('Matched Decoded Shadow Luminance'); %,'FontSize',decodeInfo.labelFontSize);
    switch (decodeInfo.paintShadowFitType)
        case 'intcpt'
            text(0,1,(sprintf('Paint/Shadow Effect: %0.3f',d.paintShadowEffect))); %,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
        case 'gain'
            if (abs(-log10(d.paintShadowEffect)) <= 0.005)
                text(0,1,(sprintf('Paint/Shadow Effect: %0.3f',-log10(d.paintShadowEffect)))); %,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
            else
                text(0,1,(sprintf('Paint/Shadow Effect: %0.2f',-log10(d.paintShadowEffect)))); %,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
            end
        otherwise
            error('Unknown paint/shadow fit type');
    end
    plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:'); %,'LineWidth',decodeInfo.lineWidth);
    axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh])
    set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
    set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
    axis square
    a=get(gca,'ticklength');
    set(gca,'ticklength',[a(1)*2,a(2)*2]);
    set(gca,'tickdir','out');
    box off
    drawnow;
    % figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeBothInferredMatches'];
    % FigureSave(figName,predmatchfig,decodeInfo.figType);
    
    % Bootstrap
    if (doBootstrap)
        for ii = 1:nBootstraps
            
            % Sample paint data with replacement, respecting independent variable
            b.UniquePaintIntensities = unique(paintIntensities);
            b.PaintIntensities = [];
            b.PaintResponses = [];
            for bb = 1:length(b.UniquePaintIntensities)
                b.thisPaintIntensityIndices = find(paintIntensities == b.UniquePaintIntensities(bb));
                b.randomPaintIndices = randi(length(b.thisPaintIntensityIndices),length(b.thisPaintIntensityIndices),1);
                b.tempPaintIntensities = paintIntensities(b.thisPaintIntensityIndices(b.randomPaintIndices));
                b.tempPaintResponses = paintResponses(b.thisPaintIntensityIndices(b.randomPaintIndices),:);
                b.PaintIntensities = [b.PaintIntensities ; b.tempPaintIntensities];
                b.PaintResponses = [b.PaintResponses ; b.tempPaintResponses];
            end
            
            % Sample shadow data with replacement, respecting independent variable
            b.UniqueShadowIntensities = unique(shadowIntensities);
            b.ShadowIntensities = [];
            b.ShadowResponses = [];
            for bb = 1:length(b.UniqueShadowIntensities)
                b.thisShadowIntensityIndices = find(shadowIntensities == b.UniqueShadowIntensities(bb));
                b.randomShadowIndices = randi(length(b.thisShadowIntensityIndices),length(b.thisShadowIntensityIndices),1);
                b.tempShadowIntensities = shadowIntensities(b.thisShadowIntensityIndices(b.randomShadowIndices));
                b.tempShadowResponses = shadowResponses(b.thisShadowIntensityIndices(b.randomShadowIndices),:);
                b.ShadowIntensities = [b.ShadowIntensities ; b.tempShadowIntensities];
                b.ShadowResponses = [b.ShadowResponses ; b.tempShadowResponses];
            end
            
            b.TheIntensities = [b.PaintIntensities ; b.ShadowIntensities];
            b.TheResponses = [b.PaintResponses ; b.ShadowResponses];
            b.DecodeInfo = DoTheDecode(decodeInfo,b.TheIntensities,b.TheResponses);
            b.PaintPreds = DoTheDecodePrediction(b.DecodeInfo,b.PaintResponses);
            b.ShadowPreds = DoTheDecodePrediction(b.DecodeInfo,b.ShadowResponses);
            
            [b.paintMeans,b.paintSEMs,~,~,~,b.paintGroupedIntensities] = ...
                sortbyx(b.PaintIntensities,b.PaintPreds);
            [b.shadowMeans,b.shadowSEMs,~,~,~,b.shadowGroupedIntensities] = ...
                sortbyx(b.ShadowIntensities,b.ShadowPreds);
            temp = FindPaintShadowEffect(b.DecodeInfo,b.paintGroupedIntensities,b.shadowGroupedIntensities,b.paintMeans,b.shadowMeans);
            if (isempty(temp))
                temp = NaN;
            end
            [b.PaintShadowEffect(ii)] = temp;
        end
        d.bPaintShadowEffect = b.PaintShadowEffect;
    end
    
    % Shifted decoders
    shadowShiftInValues = linspace(0.79433, 1.2589, 30);
    decodeInfo.uniqueIntensities = unique([paintIntensities ; shadowIntensities]);
    decodeInfo.nUnits = size(paintResponses,2);
    decodeInfo.nRandomVectorRepeats = 5;
    decodeInfo.envelopeThreshold = 1.05;
    decodeShift = DoShiftedDecodings(decodeInfo,paintIntensities,shadowIntensities,paintResponses,shadowResponses,shadowShiftInValues,'none',[]);
    
    % Plot envelope of p/s effect across the shifted decodings in form of
    % 8A.
    %
    % Set envelope threshold for coloring.
    % This value should match the value for the same variable that is also
    % coded into routine PaintShadowEffectSummaryPlots. That one determines which
    % points are used to determine the envelope range.
    if (decodeInfo.envelopeThreshold ~= 1.05)
        error('Check that you really want envelopeThreshold set to something other than its paper value of 1.05');
    end
    temp = decodeShift;
    tempPaintShadowEffect = [temp.paintShadowEffect];
    tempRMSE = [temp.theRMSE];
    clear useIndex tempPaintShadowEffect
    inIndex = 1;
    useIndex = [];
    for kk = 1:length(temp)
        if ~isempty(temp(kk).paintShadowEffect)
            useIndex(inIndex) = kk;
            tempPaintShadowEffect(inIndex) = temp(kk).paintShadowEffect;
            inIndex = inIndex + 1;
        end
    end
    rmseenvelopefig = figure; clf;
    hold on;
    if (~isempty(useIndex))
        plot(tempRMSE(useIndex),-log10(tempPaintShadowEffect),'s','Color',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]); %,'MarkerSize',decodeInfo.markerSize-6);
        minRMSE = min(tempRMSE(useIndex));
        for kk = 1:length(useIndex)
            if (tempRMSE(useIndex(kk)) < decodeInfo.envelopeThreshold*minRMSE)
                plot(tempRMSE(useIndex(kk)),-log10(tempPaintShadowEffect(kk)),'ko','MarkerFaceColor','k'); %,'MarkerSize',decodeInfo.markerSize-6);
            end
        end
    end
    xlabel('Decoding RMSE'); %,'FontSize',decodeInfo.labelFontSize);
    ylabel('Paint-Shadow Effect'); %,'FontSize',decodeInfo.labelFontSize);
    xlim([0 0.2]);
    ylim([-0.15 0.15]);
    set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
    a=get(gca,'ticklength');
    set(gca,'ticklength',[a(1)*2,a(2)*2]);
    set(gca,'tickdir','out');
    axis('square');
    box off
    % figName = [decodeInfo.figNameRoot '_extPaintShadowEffectRMSEEnvelope'];
    % FigureSave(figName,rmseenvelopefig,decodeInfo.figType);
    
    paintShadowEffect(ss).decodeBoth = d;
    paintShadowEffect(ss).decodeShift = decodeShift;
    
end

% Go through each session and extract the range.
envelopeThreshold = 1.05;
plotUnshifted = false;
for ii = 1:length(paintShadowEffect)
    
    % Find all cases where the paint-shadow effect isn't empty and
    % collect them up along with corresponding RMSEs.
    inIndex = 1;
    clear envelopePaintShadowEffects envelopeRMSEs envelopeShiftedRMSEs envelopeUnshiftedRMSEs;
    for kk = 1:length(paintShadowEffect(ii).decodeShift)
        if ~isempty(paintShadowEffect(ii).decodeShift(kk).paintShadowEffect)
            envelopePaintShadowEffects(inIndex) = paintShadowEffect(ii).decodeShift(kk).paintShadowEffect;
            if (plotUnshifted)
                envelopeRMSEs(inIndex) = paintShadowEffect(ii).decodeShift(kk).unshiftedRMSE;
            else
                envelopeRMSEs(inIndex) = paintShadowEffect(ii).decodeShift(kk).theRMSE;
            end
            
            envelopeShiftedRMSEs(inIndex) = paintShadowEffect(ii).decodeShift(kk).theRMSE;
            envelopeUnshiftedRMSEs(inIndex) = paintShadowEffect(ii).decodeShift(kk).unshiftedRMSE;
            
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

%% Plot of luminance targeted decoding
%
% This makes plots of p/s effect from single decoding versus RMSE
filterMaxRMSE = 0.20;
inIndex = 1;
thePaintShadowEffects = [];
theRMSEs = [];
thePSEffectBootstrapSEMs = [];
for ii = 1:length(paintShadowEffect)
    
    % Find all cases where the paint-shadow effect isn't empty and
    % collect them up along with corresponding RMSEs.
    if ~isempty(paintShadowEffect(ii).decodeBoth.paintShadowEffect)
        thePaintShadowEffects(inIndex) = paintShadowEffect(ii).decodeBoth.paintShadowEffect;
        theRMSEs(inIndex) = paintShadowEffect(ii).decodeBoth.theRMSE;
        if (isfield(paintShadowEffect(ii).decodeBoth,'bPaintShadowEffect'))
            thePSEffectBootstrapSEMs(inIndex) = nanstd(paintShadowEffect(ii).decodeBoth.bPaintShadowEffect);
        else
            thePSEffectBootstrapSEMs(inIndex) = NaN;
        end
    else
        thePaintShadowEffects(inIndex) = NaN;
        theRMSEs(inIndex) = NaN;
        thePSEffectBootstrapSEMs(inIndex) = NaN;
    end
    inIndex = inIndex + 1;
end

% Figure out which to plot
booleanSessionOK = ~isnan(theRMSEs);
booleanRMSE = theRMSEs <= filterMaxRMSE;

% Figure
paintShadowEffectVsRMSEFig = figure; clf; hold on;
plotIndex = booleanRMSE & booleanSessionOK;
errorbar(theRMSEs(plotIndex),-log10(thePaintShadowEffects(plotIndex)),thePSEffectBootstrapSEMs(plotIndex), ...
    's','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 filterMaxRMSE],[0 0],'k:'); %,'LineWidth',1);
plot([0 filterMaxRMSE],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.05 filterMaxRMSE]);
ylim([-0.15 0.15]);
set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
% figFilename = fullfile(figureDir,['summaryPaintShadowEffectVsRMSE_V1'],'');
% FigureSave(figFilename,paintShadowEffectVsRMSEFig,figParams.figType);

%% Plot of shifted analysis
%
% Figure out sessions to plot
booleanSessionOK = ~isnan(bestRMSE);
booleanRMSE = bestRMSE <= filterMaxRMSE;
plotIndex = booleanRMSE & booleanSessionOK;

% Envelope summary plot
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
errorbar(bestRMSE(plotIndex),-log10(bestPaintShadowEffect(plotIndex)),...
    abs(log10(maxPaintShadowEffect(plotIndex))-log10(bestPaintShadowEffect(plotIndex))),...
    abs(log10(minPaintShadowEffect(plotIndex))-log10(bestPaintShadowEffect(plotIndex))),...
    's','Color',[0 0 0],'MarkerFaceColor',[0 0 0]); %,'MarkerSize',4);
plot([0 filterMaxRMSE],[0 0],'k:'); %,'LineWidth',1);
plot([0 filterMaxRMSE],[0.064 0.064],'k'); %,'LineWidth',1);
xlim([0.05 filterMaxRMSE]);
ylim([-0.15 0.15]);
set(gca,'YTick',[-.15 -.10 -.05 0 .05 .1 .15],'YTickLabel',{'-0.15 ' '-0.10 ' '-0.05  ' '0.00 ' '0.05 ' '0.10 ' '0.15 '});
ylabel('Paint-Shadow Effect'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
xlabel('Minimum Decoding RMSE'); %,'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
% figFilename = fullfile(figureDir,['summaryPaintShadowEnvelopeVsRMSE' figureSuffix],'');
% FigureSave(figFilename,paintShadowEnvelopeVsRMSEFig,figParams.figType);
