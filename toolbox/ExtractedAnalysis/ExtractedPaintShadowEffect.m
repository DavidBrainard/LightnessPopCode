function ExtractedPaintShadowEffect(doIt,decodeInfo,theData)
% ExtractedPaintShadowEffect(doIt,doPaintShadowEffect,decodeInfo,theData)
%
% Do the basic paint/shadow decoding and get paint shadow effect.
%
% 3/29/16  dhb  Pulled this out as a function
% 11/06/17 dhb  Change sign of p/s effect.

%% Are we doing it?
switch (doIt)
    case 'always'
    case 'never'
        return;
    case 'ifmissing'
        if (exist(fullfile(decodeInfo.writeDataDir,'extPaintShadowEffect.mat'),'file'))
            return;
        end
end

%% Shuffle just once in this whole function, if desired
%
%
% With the 'none' options as set here, this does nothing, just returns
% the passed intensities and responses.
%
% I no longer remember why we would want to do this at this point in the
% code, nor why the option would be hard coded here rather than passed down
% to here.  But am leaving this block in case we remember why we wanted it,
% at some future date.
clear decodeInfoTemp
decodeInfoTemp.trialShuffleType = 'none';
decodeInfoTemp.paintShadowShuffleType = 'none';
[paintIntensities,paintResponses,shadowIntensities,shadowResponses] = ...
    PaintShadowShuffle(decodeInfo,theData.paintIntensities,theData.paintResponses,theData.shadowIntensities,theData.shadowResponses);

%% Build decoder on both
clear decodeInfoTemp d
decodeInfoTemp.nUnits = decodeInfo.nUnits;
decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
decodeInfoTemp.decodeJoint = 'both';
decodeInfoTemp.type = decodeInfo.type;
decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
[~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
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
    FindPaintShadowEffect(decodeInfoTemp,d.paintGroupedIntensities,d.shadowGroupedIntensities,d.paintMeans,d.shadowMeans);
decodeSave.decodeBoth = d;

% PLOT: decoded intensities
decodingfig = figure; clf;
%set(gcf,'Position',decodeInfo.sqPosition);
%set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.paintSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'r'); %,'LineWidth',decodeInfo.lineWidth);
h=plot(d.fineSpacedIntensities(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),d.shadowSmooth(d.fineSpacedIntensities > decodeInfo.minFineGrainedIntensities),'b'); %,'LineWidth',decodeInfo.lineWidth);
h=errorbar(d.paintGroupedIntensities, d.paintMeans, d.paintSEMs, 'ro');
%set(h,'MarkerFaceColor','r','MarkerSize',decodeInfo.markerSize-6);
h=errorbar(d.shadowGroupedIntensities, d.shadowMeans, d.shadowSEMs, 'bo');
%set(h,'MarkerFaceColor','b','MarkerSize',decodeInfo.markerSize-6);
h=plot(d.paintGroupedIntensities, d.paintMeans, 'ro','MarkerFaceColor','r'); % ,'MarkerSize',decodeInfo.markerSize);
h=plot(d.shadowGroupedIntensities, d.shadowMeans, 'bo','MarkerFaceColor','b'); %,'MarkerSize',decodeInfo.markerSize);
h = legend({'Paint','Shadow'},'Location','NorthWest'); %,'FontSize',decodeInfo.legendFontSize);
%lfactor = 0.5;
%lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
xlabel('Stimulus Luminance'); %,'FontSize',decodeInfo.labelFontSize);
ylabel('Decoded Luminance'); %,'FontSize',decodeInfo.labelFontSize);
text(0.8,0.00,sprintf('RMSE: %0.2f',d.theRMSE)); %,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize);
%title(titleRootStr,'FontSize',decodeInfo.titleFontSize);
plot([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],[decodeInfo.intensityLimLow decodeInfo.intensityLimHigh],'k:'); %,'LineWidth',decodeInfo.lineWidth);
axis([decodeInfo.intensityLimLow decodeInfo.intensityLimHigh decodeInfo.intensityLimLow decodeInfo.intensityLimHigh]);
set(gca,'XTick',decodeInfo.intensityTicks,'XTickLabel',decodeInfo.intensityTickLabels);
set(gca,'YTick',decodeInfo.intensityTicks,'YTickLabel',decodeInfo.intensityYTickLabels);
axis square
a=get(gca,'ticklength');
set(gca,'ticklength',[a(1)*2,a(2)*2]);
set(gca,'tickdir','out');
box off
drawnow;
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeBothDecoding'];
FigureSave(figName,decodingfig,decodeInfo.figType);
exportfig(decodingfig,[figName '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

% PLOT: Inferred matches with a fit line
predmatchfig = figure; clf;
%set(gcf,'Position',decodeInfo.sqPosition);
%set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
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
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectDecodeBothInferredMatches'];
FigureSave(figName,predmatchfig,decodeInfo.figType);
exportfig(predmatchfig,[figName '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

%% Build shifted decoder on both with shadow intensity shifts, no PCA
shadowShiftInValues = linspace(sqrt(0.7), sqrt(1.3), 20);
decodeSave.decodeShift = DoShiftedDecodings(decodeInfo,paintIntensities,shadowIntensities,paintResponses,shadowResponses,shadowShiftInValues,'none',[]);

% PLOT: Envelope of p/s effect across the shifted decodings

% Set envelope threshold for coloring.
% This value should match the value for the same variable that is also
% coded into routine PaintShadowEffectSummaryPlots. That one determines which
% points are used to determine the envelope range.
if (decodeInfo.envelopeThreshold ~= 1.05)
    error('Check that you really want envelopeThreshold set to something other than its paper value of 1.05');
end
temp = decodeSave.decodeShift;
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
%set(gcf,'Position',decodeInfo.sqPosition);
%set(gca,'FontName',decodeInfo.fontName,'FontSize',decodeInfo.axisFontSize,'LineWidth',decodeInfo.axisLineWidth);
hold on;
if (~isempty(useIndex))
    plot(tempRMSE(useIndex),-log10(tempPaintShadowEffect),'ko','MarkerFaceColor','k'); %,'MarkerSize',decodeInfo.markerSize-6);
    minRMSE = min(tempRMSE(useIndex));
    for kk = 1:length(useIndex)
        if (tempRMSE(useIndex(kk)) < decodeInfo.envelopeThreshold*minRMSE)
            plot(tempRMSE(useIndex(kk)),-log10(tempPaintShadowEffect(kk)),'go','MarkerFaceColor','g'); %,'MarkerSize',decodeInfo.markerSize-6);
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
figName = [decodeInfo.figNameRoot '_extPaintShadowEffectRMSEEnvelope'];
drawnow;
FigureSave(figName,rmseenvelopefig,decodeInfo.figType);
exportfig(rmseenvelopefig,[figName '.eps'],'Format','eps','Width',4,'Height',4,'FontMode','fixed','FontSize',10,'color','cmyk');

%% Store the data for return
decodeInfo.paintShadowEffect = decodeSave;

%% Save the data
save(fullfile(decodeInfo.writeDataDir,'extPaintShadowEffect'),'decodeSave','-v7.3');


        
  
        

        
       