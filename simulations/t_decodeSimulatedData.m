%% t_decodeSimulatedData
%
% Description:
%    Try our various decoders on simulated data
%
% 05/09/18  dhb  Wrote it.

%% Clear and close
clear; close all;

%% Parameters
nIntensities = 15;
nTrialsPerLuminance = 10;
paintShadowGain = 1.5;
nNeurons = 100;
neuron1Gain = 2;
neuron2Gain = 1.2;
neuron1Exp = 1;
neuron2Exp = 1;
responseNoiseSd = 0.2;

%% Set up luminances across trials
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

%% First two neurons have responses that are related to luminances
neuron1PaintResponses = (neuron1Gain*paintIntensities).^neuron1Exp + normrnd(0,responseNoiseSd,nPaintTrials,1);
neuron2PaintResponses = (neuron2Gain*paintIntensities).^neuron2Exp + normrnd(0,responseNoiseSd,nPaintTrials,1);
neuron1ShadowResponses = (paintShadowGain*neuron1Gain*shadowIntensities).^neuron1Exp + normrnd(0,responseNoiseSd,nShadowTrials,1);
neuron2ShadowResponses = (paintShadowGain*neuron2Gain*shadowIntensities).^neuron2Exp  + normrnd(0,responseNoiseSd,nShadowTrials,1);

%% Rest of neurons have responses that are pure noise
nOtherNeurons = nNeurons-2;
neuronOtherPaintResponses = normrnd(0,responseNoiseSd,nPaintTrials,nOtherNeurons);
neuronOtherShadowResponses = normrnd(0,responseNoiseSd,nShadowTrials,nOtherNeurons);

%% Neural response matrix (nTrials by nNeurons for paint and shadow)
paintResponses = [neuron1PaintResponses neuron2PaintResponses neuronOtherPaintResponses];
shadowResponses = [neuron1ShadowResponses neuron2ShadowResponses neuronOtherShadowResponses];

%% Set decoding parameters
%
% Types
%   'aff'
%   'fitrlinear'
%   'fitrcvlasso'
%   'fitcvridge'
%   'maxlikely'
decodeInfo.type = 'fitrlinear';
decodeInfo.decodeJoint = 'both';
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

%% Our standard decoding and digesting block of code (rom
% ExtractedPaintShadowEffect)
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

%% PLOT: decoded intensities
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
% exportfig(decodingfig,[figName '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

%% PLOT: Inferred matches with a fit line
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
% exportfig(predmatchfig,[figName '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');