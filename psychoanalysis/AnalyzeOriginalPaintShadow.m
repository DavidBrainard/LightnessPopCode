% AnalyzeOriginalPaintShadow
%
% Run full analysis over original paint shadow image data.
%
% These are conditions 31 and 32 for aqr, baf, and cnj,
% plus conditions 51 and 52 for aqr, cnj, and eje.
%
% This is a little bit 'by hand' but at least the program documents
% what is done here.
%
% 2/22/14  dhb  Wrote it.

%% Clear
clear; close all;

%% Analysis path
SetAnalysisPath;

%% Parameters
analysisFitType = 'intercept';
COMPUTE = false;

%% Figure directory
outputDir = 'xSummary';
if (~exist(outputDir,'file'))
    mkdir(outputDir);
end

%% Make sure all data is processed by current scripts.
if (COMPUTE)
    % AQR - subject 1 for parametric conditions 2
    aqrSummaryDataStructControl{1} = AnalyzeParametricConditions(2,1,31,analysisFitType);
    aqrSummaryDataStructPaintShadow{1} = AnalyzeParametricConditions(2,1,32,analysisFitType);
    
    % AQR - subject 2 for parametric conditions 3
    aqrSummaryDataStructControl{2} = AnalyzeParametricConditions(3,2,51,analysisFitType);
    aqrSummaryDataStructPaintShadow{2} = AnalyzeParametricConditions(3,2,52,analysisFitType);
    
    % BAF - subject 2 for parametric conditions 2
    bafSummaryDataStructControl{1} = AnalyzeParametricConditions(2,2,31,analysisFitType);
    bafSummaryDataStructPaintShadow{1} = AnalyzeParametricConditions(2,2,32,analysisFitType);
    
    % CNJ - - subject 3 for parametric conditions 2
    cnjSummaryDataStructControl{1} = AnalyzeParametricConditions(2,3,31,analysisFitType);
    cnjSummaryDataStructPaintShadow{1} = AnalyzeParametricConditions(2,3,32,analysisFitType);
    
    % CNJ - subject 3 for parametric conditions 3
    cnjSummaryDataStructControl{2} = AnalyzeParametricConditions(3,3,51,analysisFitType);
    cnjSummaryDataStructPaintShadow{2} = AnalyzeParametricConditions(3,3,52,analysisFitType);
    
    % EJE - subject 4 for parametric conditions 3
    ejeSummaryDataStructControl{1} = AnalyzeParametricConditions(3,4,51,analysisFitType);
    ejeSummaryDataStructPaintShadow{1} = AnalyzeParametricConditions(3,4,52,analysisFitType);
    
    %% Collect up the analysis
    theData.analysisFitType = analysisFitType;
    theData.aqrControl = [aqrSummaryDataStructControl{1}{1}.theFit(1) aqrSummaryDataStructControl{2}{1}.theFit(1)];
    theData.aqrControlMean = mean(theData.aqrControl);
    theData.aqrPaintShadow = [aqrSummaryDataStructPaintShadow{1}{1}.theFit(1) aqrSummaryDataStructPaintShadow{2}{1}.theFit(1)];
    theData.aqrPaintShadowMean = mean(theData.aqrPaintShadow);
    
    theData.bafControl = [bafSummaryDataStructControl{1}{1}.theFit(1)];
    theData.bafControlMean = mean(theData.bafControl);
    theData.bafPaintShadow = [bafSummaryDataStructPaintShadow{1}{1}.theFit(1)];
    theData.bafPaintShadowMean = mean(theData.bafPaintShadow);
    
    theData.cnjControl = [cnjSummaryDataStructControl{1}{1}.theFit(1) cnjSummaryDataStructControl{2}{1}.theFit(1)];
    theData.cnjControlMean = mean(theData.cnjControl);
    theData.cnjPaintShadow = [cnjSummaryDataStructPaintShadow{1}{1}.theFit(1) cnjSummaryDataStructPaintShadow{2}{1}.theFit(1)];
    theData.cnjPaintShadowMean = mean(theData.cnjPaintShadow);
    
    theData.ejeControl = [ejeSummaryDataStructControl{1}{1}.theFit(1)];
    theData.ejeControlMean = mean(theData.ejeControl);
    theData.ejePaintShadow = [ejeSummaryDataStructPaintShadow{1}{1}.theFit(1)];
    theData.ejePaintShadowMean = mean(theData.ejePaintShadow);
    
    theData.allControl = [theData.aqrControl theData.bafControl theData.cnjControl theData.ejeControl];
    theData.allPaintShadow = [theData.aqrPaintShadow theData.bafPaintShadow theData.cnjPaintShadow theData.ejePaintShadow];
    
    theData.meanControl = [theData.aqrControlMean theData.bafControlMean theData.cnjControlMean theData.ejeControlMean];
    theData.meanPaintShadow = [theData.aqrPaintShadowMean theData.bafPaintShadowMean theData.cnjPaintShadowMean theData.ejePaintShadowMean];
    
    % Save summary info
    switch (analysisFitType)
        case 'intercept'
            save(fullfile(outputDir,'OriginalPaintShadowIntercept'),'theData');
        otherwise
            error('Unknown analysisFitType specified');
    end
            
else
    % Load summary info
    switch (analysisFitType)
        case 'intercept'
            load(fullfile(outputDir,'OriginalPaintShadowIntercept'),'theData');
        otherwise
            error('Unknown analysisFitType specified');
    end
    if (~strcmp(analysisFitType,theData.analysisFitType))
        error('Loaded data analysisFitType does not match that specified currently');
    end
end

%% Figure parameters
figParams = SetFigParams([],'psychophysics');
%figParams.baseSize = 850;
%figParams.position = [100 100 figParams.baseSize round(420/560*figParams.baseSize)];
%figParams.sqPosition = [100 100 figParams.baseSize figParams.baseSize];
figParams.xLimLow = 0;
figParams.xLimHigh = 7;
figParams.yLimLow = -0.1;
figParams.yLimHigh = 0.02;
figParams.xTicks = [1 2 3 4 5 6];
figParams.xTickLabels = {'AQR (1)' 'AQR (2)' 'BAF (1)' 'CNJ (1)' 'CNJ (2)' 'EJE (1)'};
figParams.yTicks = [-0.1 -0.05 0.0];
figParams.yTickLabels = {'-0.10 ' '-0.05 ' ' 0.00 '};

%% Figures
switch (analysisFitType)
    case 'intercept'
        % Make a figure showing intercepts for paint/shadow conditions.
        interceptFig = figure; clf; hold on
        set(gcf,'Position',figParams.position);
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
        plot(theData.allPaintShadow,'b^','MarkerFaceColor','b','MarkerSize',figParams.markerSize);
        plot(zeros(size(theData.allControl)),'k:','LineWidth',figParams.lineWidth);
        plot(mean(theData.allPaintShadow)*ones(size(theData.allControl)),'b','LineWidth',figParams.lineWidth);
        axis([figParams.xLimLow figParams.xLimHigh figParams.yLimLow figParams.yLimHigh]);
        set(gca,'XTick',figParams.xTicks,'XTickLabel',figParams.xTickLabels,'FontSize',figParams.axisFontSize-3);
        set(gca,'YTick',figParams.yTicks,'YTickLabel',figParams.yTickLabels);
        xlabel('Subject (Replication)','FontSize',figParams.labelFontSize);
        ylabel('Paint/Shadow Effect','FontSize',figParams.labelFontSize);
        % legend({sprintf('Paint/Shadow, Mean %0.2f',mean(theData.allPaintShadow))},'Location','NorthWest','FontSize',figParams.legendFontSize);
        text(0.25,0.012,sprintf('Mean: %0.2f',mean(theData.allPaintShadow)),'FontSize',figParams.legendFontSize);
        FigureSave(fullfile(outputDir,'OriginalPaintShadowIntercepts'),interceptFig,figParams.figType);
        
        % Version with control conditions.
        %
        % Remake whole figure so that legend work right 
        interceptFig1 = figure; clf; hold on
        set(gcf,'Position',figParams.position);
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
        plot(theData.allPaintShadow,'b^','MarkerFaceColor','b','MarkerSize',figParams.markerSize);
        plot(theData.allControl,'k^','MarkerFaceColor','k','MarkerSize',figParams.markerSize);
        plot(zeros(size(theData.allControl)),'k:','LineWidth',figParams.lineWidth);
        plot(mean(theData.allPaintShadow)*ones(size(theData.allControl)),'b','LineWidth',figParams.lineWidth);
        plot(mean(theData.allControl)*ones(size(theData.allControl)),'k','LineWidth',figParams.lineWidth);
        axis([figParams.xLimLow figParams.xLimHigh figParams.yLimLow figParams.yLimHigh]);
        set(gca,'XTick',figParams.xTicks,'XTickLabel',figParams.xTickLabels,'FontSize',figParams.axisFontSize-3);
        set(gca,'YTick',figParams.yTicks,'YTickLabel',figParams.yTickLabels);
        xlabel('Subject (Replication)','FontSize',figParams.labelFontSize);
        ylabel('Paint Shadow Effect','FontSize',figParams.labelFontSize);
        legend({'Paint/Shadow' 'Paint/Paint'},'Location','NorthWest','FontSize',figParams.legendFontSize);
        FigureSave(fullfile(outputDir,'OriginalPaintShadowInterceptsWithControl'),interceptFig1,figParams.figType);
    otherwise
        error('Unknown analysisFitType specified');
end


