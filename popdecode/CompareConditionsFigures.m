%% CompareConditionsFigures
%
% Read summary data from multiple conditions and make some comparisons
%
% 1/14/15  dhb  Wrote it.
% 12/28/15 dhb  Some clean up for new output conventions.

%% Clear and close
clear; close all;

%% V4 only?
plotV4Onlys = [false];

%% Filter range
filterRangeLower = 0.2;

% Do the thing
for plotV4Only = plotV4Onlys
    
    if (plotV4Only)
        v4OnlyString = '_V4';
        v4TitleStr = ' (V4)';
    else
        v4OnlyString = '';
        v4TitleStr = '';
    end
    
    %% Set up directory
    summaryRoot = '../../PennOutput/xSummary';
    theDir = fullfile(summaryRoot,'xCompare',[]);
    if (~exist(theDir,'file'))
        mkdir(theDir);
    end
    
    % Plot defs
    figParams = SetFigParams([],'popdecode');
    figParams.plotColor = 'r';
    figParams.plotSymbol = 'o';
    figParams.paintPlotColor = 'g';
    figParams.shadowPlotColor = 'k';
    
    %% Effect of trial shuffle data
    %
    % Need to run and then fill in output directory roots
    if (false)
        % Read summary files
        mainDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-both_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
            ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
        compareDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-bothbestsingle_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
            ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
        index = find([mainDataStructs(:).decodePaintRange] > filterRangeLower & [mainDataStructs(:).decodeShadowRange] > filterRangeLower & ...
            [compareDataStructs(:).decodePaintRange] > filterRangeLower & [compareDataStructs(:).decodeShadowRange] > filterRangeLower);
        
        % Plot effect on RMSE
        figRMSE = figure; clf; hold on;
        set(gcf,'Position',figParams.sqPosition);
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
        
        xData = [mainDataStructs(:).paintLOORMSE mainDataStructs(:).shadowLOORMSE];
        yData =  [compareDataStructs(:).paintLOORMSE compareDataStructs(:).shadowLOORMSE];
        plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
        
        plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
        xlim([0 0.4]);
        ylim([0 0.4]);
        set(gca,'XTick',[0 0.1 0.2 0.3 0.4]);
        set(gca,'XTickLabel',{'0.0' '0.1' '0.2' '0.3' '0.4'});
        set(gca,'YTick',[0 0.1 0.2 0.3 0.4]);
        set(gca,'YTickLabel',{'0.0 ' '0.1 ' '0.2 ' '0.3 ' '0.4 '});
        xlabel('Decoded RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        ylabel('Intensity Trial Shuffle RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        title({['Effect of Within Intensity Trial Shuffle' v4TitleStr]; ' '}, ...
            'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
        figFilename = fullfile(theDir,['TrialShuffleOnRMSE' v4OnlyString],'');
        FigureSave(figFilename,figRMSE,figParams.figType);
        
        % Plot effect on decode range
        figDecodeRange = figure; clf; hold on;
        set(gcf,'Position',figParams.sqPosition);
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
        
        xDataPaint = [mainDataStructs(:).decodePaintRange];
        xDataShadow = [mainDataStructs(:).decodeShadowRange];
        yDataPaint =  [compareDataStructs(:).decodePaintRange];
        yDataShadow = [compareDataStructs(:).decodeShadowRange];
        plot([xDataPaint xDataShadow],[yDataPaint yDataShadow],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
        plot([xDataPaint(index) xDataShadow(index)],[yDataPaint(index) yDataShadow(index)],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
        
        plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
        xlim([0 1]);
        ylim([0 1]);
        set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1.0]);
        set(gca,'XTickLabel',{'0.0' '0.2' '0.4' '0.6' '0.8' '1.0'});
        set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1.0]);
        set(gca,'YTickLabel',{'0.0 ' '0.2 ' '0.4 ' '0.6 ' '0.8 ' '1.0 '});
        xlabel('Decoded Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        ylabel('Intensity Trial Shuffle Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        title({['Effect of Within Intensity Trial Shuffle' v4TitleStr]; ' '}, ...
            'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
        figFilename = fullfile(theDir,['TrialShuffleOnRange' v4OnlyString],'');
        FigureSave(figFilename,figDecodeRange,figParams.figType);
        
        % Plot effect on decode intercept (aka paint/shadow effect)
        figPaintShadow = figure; clf; hold on;
        set(gcf,'Position',figParams.sqPosition);
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
        
        xData = [mainDataStructs(:).decodeIntercept];
        yData =  [compareDataStructs(:).decodeIntercept];
        plot(xData(index),yData(index),[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
        plot(nanmean(xData(index)),nanmean(yData(index)),'ks','MarkerFaceColor','k','MarkerSize',figParams.markerSize+6);
        
        plot([-1 1],[-1 1],'k:','LineWidth',figParams.lineWidth);
        xlim([-0.4 0.2]);
        ylim([-0.4 0.2]);
        xlabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        ylabel('Intensity Trial Shuffle Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        title({['Effect of Within Intensity Trial Shuffle' v4TitleStr]; ' '}, ...
            'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
        figFilename = fullfile(theDir,['TrialShuffleOnPaintShadowEffect' v4OnlyString],'');
        FigureSave(figFilename,figPaintShadow,figParams.figType);
        
        % Close
        close all;
    end
    
    %% Effect of all versus one
    
    % Read summary files
    clear mainDataStructs compareDataStructs
    mainDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-both_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
        ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
    compareDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-bothbestsingle_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
        ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
    index = find([mainDataStructs(:).decodePaintRange] > filterRangeLower & [mainDataStructs(:).decodeShadowRange] > filterRangeLower & ...
        [compareDataStructs(:).decodePaintRange] > filterRangeLower & [compareDataStructs(:).decodeShadowRange] > filterRangeLower);
    
    % Plot effect on RMSE
    figRMSE = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = [mainDataStructs(:).paintLOORMSE mainDataStructs(:).shadowLOORMSE];
    yData =  [compareDataStructs(:).paintLOORMSE compareDataStructs(:).shadowLOORMSE];
    plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    
    plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
    xlim([0 0.4]);
    ylim([0 0.4]);
    set(gca,'XTick',[0 0.1 0.2 0.3 0.4]);
    set(gca,'XTickLabel',{'0.0' '0.1' '0.2' '0.3' '0.4'});
    set(gca,'YTick',[0 0.1 0.2 0.3 0.4]);
    set(gca,'YTickLabel',{'0.0 ' '0.1 ' '0.2 ' '0.3 ' '0.4 '});
    xlabel('Decoded RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Best Single Electrode RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({['Effect of Using Single Best Electrode' v4TitleStr]; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['SingleElectrodeOnRMSE' v4OnlyString],'');
    FigureSave(figFilename,figRMSE,figParams.figType);
    
    % Plot effect on decode range
    figDecodeRange = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xDataPaint = [mainDataStructs(:).decodePaintRange];
    xDataShadow = [mainDataStructs(:).decodeShadowRange];
    yDataPaint =  [compareDataStructs(:).decodePaintRange];
    yDataShadow = [compareDataStructs(:).decodeShadowRange];
    plot([xDataPaint xDataShadow],[yDataPaint yDataShadow],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
    plot([xDataPaint(index) xDataShadow(index)],[yDataPaint(index) yDataShadow(index)],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    
    plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
    xlim([0 1]);
    ylim([0 1]);
    set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1.0]);
    set(gca,'XTickLabel',{'0.0' '0.2' '0.4' '0.6' '0.8' '1.0'});
    set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1.0]);
    set(gca,'YTickLabel',{'0.0 ' '0.2 ' '0.4 ' '0.6 ' '0.8 ' '1.0 '});
    xlabel('Decoded Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Best Single Electrode Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({['Effect of Using Single Best Electrode' v4TitleStr]; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['SingleElectrodeOnRange' v4OnlyString],'');
    FigureSave(figFilename,figDecodeRange,figParams.figType);
    
    % Plot effect on decode intercept  (aka paint/shadow effect)
    figPaintShadow = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = [mainDataStructs(:).decodeIntercept];
    yData =  [compareDataStructs(:).decodeIntercept];
    plot(xData(index),yData(index),[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    plot(nanmean(xData(index)),nanmean(yData(index)),'ks','MarkerFaceColor','k','MarkerSize',figParams.markerSize+6);
    
    plot([-1 1],[-1 1],'k:','LineWidth',figParams.lineWidth);
    xlim([-0.4 0.2]);
    ylim([-0.4 0.2]);
    xlabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Best Single Electrode Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({['Effect of of Using Single Best Electrode' v4TitleStr]; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['SingleElectrodeOnPaintShadowEffect' v4OnlyString],'');
    FigureSave(figFilename,figPaintShadow,figParams.figType);
    
    % Close
    close all;
    
    %% Effect of all versus two
    
    % Read summary files
    clear mainDataStructs compareDataStructs
    mainDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-both_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
        ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
    compareDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-bothbestdouble_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
        ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
    index = find([mainDataStructs(:).decodePaintRange] > filterRangeLower & [mainDataStructs(:).decodeShadowRange] > filterRangeLower & ...
        [compareDataStructs(:).decodePaintRange] > filterRangeLower & [compareDataStructs(:).decodeShadowRange] > filterRangeLower);
    
    % Plot effect on RMSE
    figRMSE = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = [mainDataStructs(:).paintLOORMSE mainDataStructs(:).shadowLOORMSE];
    yData =  [compareDataStructs(:).paintLOORMSE compareDataStructs(:).shadowLOORMSE];
    plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    
    plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
    xlim([0 0.4]);
    ylim([0 0.4]);
    set(gca,'XTick',[0 0.1 0.2 0.3 0.4]);
    set(gca,'XTickLabel',{'0.0' '0.1' '0.2' '0.3' '0.4'});
    set(gca,'YTick',[0 0.1 0.2 0.3 0.4]);
    set(gca,'YTickLabel',{'0.0 ' '0.1 ' '0.2 ' '0.3 ' '0.4 '});
    xlabel('Decoded RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Best Double Electrode RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({['Effect of Using Two Best Electrodes' v4TitleStr]; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['DoubleElectrodeOnRMSE' v4OnlyString],'');
    FigureSave(figFilename,figRMSE,figParams.figType);
    
    % Plot effect on decode range
    figDecodeRange = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xDataPaint = [mainDataStructs(:).decodePaintRange];
    xDataShadow = [mainDataStructs(:).decodeShadowRange];
    yDataPaint =  [compareDataStructs(:).decodePaintRange];
    yDataShadow = [compareDataStructs(:).decodeShadowRange];
    plot([xDataPaint xDataShadow],[yDataPaint yDataShadow],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
    plot([xDataPaint(index) xDataShadow(index)],[yDataPaint(index) yDataShadow(index)],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    
    plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
    xlim([0 1]);
    ylim([0 1]);
    set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1.0]);
    set(gca,'XTickLabel',{'0.0' '0.2' '0.4' '0.6' '0.8' '1.0'});
    set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1.0]);
    set(gca,'YTickLabel',{'0.0 ' '0.2 ' '0.4 ' '0.6 ' '0.8 ' '1.0 '});
    xlabel('Decoded Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Best Double Electrode Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({['Effect of Using Two Best Electrodes' v4TitleStr]; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['DoubleElectrodeOnRange' v4OnlyString],'');
    FigureSave(figFilename,figDecodeRange,figParams.figType);
    
    % Plot effect on decode intercept  (aka paint/shadow effect)
    figPaintShadow = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = [mainDataStructs(:).decodeIntercept];
    yData =  [compareDataStructs(:).decodeIntercept];
    plot(xData(index),yData(index),[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    plot(nanmean(xData(index)),nanmean(yData(index)),'ks','MarkerFaceColor','k','MarkerSize',figParams.markerSize+6);
    
    plot([-1 1],[-1 1],'k:','LineWidth',figParams.lineWidth);
    xlim([-0.4 0.2]);
    ylim([-0.4 0.2]);
    xlabel('Paint-Shadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Best Double Electrode Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({['Effect of of Using Two Best Electrodes' v4TitleStr]; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['DoubleElectrodeOnPaintShadowEffect' v4OnlyString],'');
    FigureSave(figFilename,figPaintShadow,figParams.figType);
    
    % Close
    close all;
    
    %% PCA
    for pcaNum = [5 10 15 20]
        
        % Read summary files
        clear mainDataStructs compareDataStructs
        mainDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-both_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
            ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
        compareDataStructs = ReadStructsFromText(fullfile(summaryRoot,['dc-aff_cls-mvmaSMO_rf-no_pca-sdn' num2str(pcaNum) '_use-both_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1'],...
            ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
        index = find([mainDataStructs(:).decodePaintRange] > filterRangeLower & [mainDataStructs(:).decodeShadowRange] > filterRangeLower & ...
            [compareDataStructs(:).decodePaintRange] > filterRangeLower & [compareDataStructs(:).decodeShadowRange] > filterRangeLower);
        
        % Plot effect on RMSE
        figRMSE = figure; clf; hold on;
        set(gcf,'Position',figParams.sqPosition);
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
        
        xData = [mainDataStructs(:).paintLOORMSE mainDataStructs(:).shadowLOORMSE];
        yData =  [compareDataStructs(:).paintLOORMSE compareDataStructs(:).shadowLOORMSE];
        plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
        
        plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
        xlim([0 0.4]);
        ylim([0 0.4]);
        set(gca,'XTick',[0 0.1 0.2 0.3 0.4]);
        set(gca,'XTickLabel',{'0.0' '0.1' '0.2' '0.3' '0.4'});
        set(gca,'YTick',[0 0.1 0.2 0.3 0.4]);
        set(gca,'YTickLabel',{'0.0 ' '0.1 ' '0.2 ' '0.3 ' '0.4 '});
        xlabel('Decoded RMSE','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        ylabel(['PCA ' num2str(pcaNum) ' RMSE'],'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        title({['Effect of Using PCA ' num2str(pcaNum) v4TitleStr]; ' '}, ...
            'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
        figFilename = fullfile(theDir,['PCA_' num2str(pcaNum) '_OnRMSE' v4OnlyString],'');
        FigureSave(figFilename,figRMSE,figParams.figType);
        
        % Plot effect on decode range
        figDecodeRange = figure; clf; hold on;
        set(gcf,'Position',figParams.sqPosition);
        set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
        
        xDataPaint = [mainDataStructs(:).decodePaintRange];
        xDataShadow = [mainDataStructs(:).decodeShadowRange];
        yDataPaint =  [compareDataStructs(:).decodePaintRange];
        yDataShadow = [compareDataStructs(:).decodeShadowRange];
        plot([xDataPaint xDataShadow],[yDataPaint yDataShadow],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
        plot([xDataPaint(index) xDataShadow(index)],[yDataPaint(index) yDataShadow(index)],[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
        
        plot([0 1],[0 1],'k:','LineWidth',figParams.lineWidth);
        xlim([0 1]);
        ylim([0 1]);
        set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1.0]);
        set(gca,'XTickLabel',{'0.0' '0.2' '0.4' '0.6' '0.8' '1.0'});
        set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1.0]);
        set(gca,'YTickLabel',{'0.0 ' '0.2 ' '0.4 ' '0.6 ' '0.8 ' '1.0 '});
        xlabel('Decoded Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        ylabel(['PCA ' num2str(pcaNum) ' Range'],'FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
        title({['Effect of Using PCA ' num2str(pcaNum) v4TitleStr]; ' '}, ...
            'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
        figFilename = fullfile(theDir,['PCA_' num2str(pcaNum) '_OnRange' v4OnlyString],'');
        FigureSave(figFilename,figDecodeRange,figParams.figType);
        
        % Close
        close all;
    end
    
    %% Checkerboard size and eccentricity plots for standard decoding
    % We make these are part of the standard summary analysis, but it's
    % easier to remake for the full range of decodings here than to re-run
    % it there.
    clear mainDataStructs compareDataStructs
    mainDataStructs = ReadStructsFromText(fullfile(summaryRoot,'dc-aff_cls-mvmaSMO_rf-no_pca-no_use-both_off-0_notshf_nopsshf_lo-no_clo-no_sykp_ft-intcpt_2_1',...
        ['Summary_spksrt_intcpt' v4OnlyString '.txt']));
    index = find([mainDataStructs(:).decodePaintRange] > filterRangeLower & [mainDataStructs(:).decodeShadowRange] > filterRangeLower);
    
    % Decode range versus size
    figRangeVsSize = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = [mainDataStructs(:).theCheckerboardSizeDegs];
    yDataPaint =  [mainDataStructs(:).decodePaintRange];
    yDataShadow = [mainDataStructs(:).decodeShadowRange];
    plot(xData,yDataPaint,[figParams.paintPlotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.paintPlotColor);
    plot(xData,yDataShadow,[figParams.shadowPlotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.shadowPlotColor);
    
    xlabel('Checkerboard Size (Degs)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Decoded Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({'Decoding as a function of checkerboard size'; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    h = legend({ 'Paint' 'Shadow'},'FontSize',figParams.legendFontSize);
    lfactor = 0.5;
    lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
    figFilename = fullfile(theDir,['Main_RangeVersusSize' v4OnlyString],'');
    FigureSave(figFilename,figRangeVsSize,figParams.figType);
    
    % Decode range versus eccentricity
    figRangeVsEcc = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = sqrt([mainDataStructs(:).theCenterXDegs].^2 + [mainDataStructs(:).theCenterYDegs].^2);
    yDataPaint =  [mainDataStructs(:).decodePaintRange];
    yDataShadow = [mainDataStructs(:).decodeShadowRange];
    plot(xData,yDataPaint,[figParams.paintPlotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.paintPlotColor);
    plot(xData,yDataShadow,[figParams.shadowPlotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.shadowPlotColor);
    
    xlabel('Checkerboard Eccentricity (Degs)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Decoded Range','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({'Decoding as a function of checkerboard ecc'; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    h = legend({ 'Paint' 'Shadow'},'FontSize',figParams.legendFontSize);
    lfactor = 0.5;
    lpos = get(h,'Position'); set(h,'Position',[lpos(1)-lfactor*lpos(3) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
    figFilename = fullfile(theDir,['Main_RangeVersusEcc' v4OnlyString],'');
    FigureSave(figFilename,figRangeVsEcc,figParams.figType);
    
    % PaintShadow versus size
    figPaintShadowVsSize = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = [mainDataStructs(:).theCheckerboardSizeDegs];
    yData = [mainDataStructs(:).decodeIntercept];
    plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
    plot(xData(index),yData(index),[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    plot([0 30],[0 0],'k:','LineWidth',figParams.lineWidth);
    plot([0 30],[nanmean(yData) nanmean(yData)],'r','LineWidth',figParams.lineWidth);
    ylim([-0.3 0.3]);
    
    xlabel('Checkerboard Size (Degs)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('PaintShadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({'PaintShadow as a function of checkerboard size'; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['Main_PaintShadowVersusSize' v4OnlyString],'');
    FigureSave(figFilename,figPaintShadowVsSize,figParams.figType);
    
    % PaintShadow versus eccentricity
    figPaintShadowVsEcc = figure; clf; hold on;
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = sqrt([mainDataStructs(:).theCenterXDegs].^2 + [mainDataStructs(:).theCenterYDegs].^2);
    yData = [mainDataStructs(:).decodeIntercept];
    plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
    plot(xData(index),yData(index),[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    plot([0 5],[0 0],'k:','LineWidth',figParams.lineWidth);
    plot([0 5],[nanmean(yData) nanmean(yData)],'r','LineWidth',figParams.lineWidth);
    ylim([-0.3 0.3]);
    
    xlabel('Checkerboard Eccentricity (Degs)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('PaintShadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({'PaintShadow as a function of checkerboard ecc'; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['Main_PaintShadowVersusEcc' v4OnlyString],'');
    FigureSave(figFilename,figPaintShadowVsEcc,figParams.figType);
    
    % Weighted electrode mean difference versus paint/shadow decode
    % difference.  This should be very similar, modulo differences
    % in the range of stimuli that we look at.
    figWeightedSpikeDiffVersusMeanDifference = figure; clf; hold on
    set(gcf,'Position',figParams.sqPosition);
    set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    
    xData = [mainDataStructs(:).paintShadowDecodeMeanDifferenceDiscrete];
    yData = [mainDataStructs(:).weightedIRFSpikeDifference];
    plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
    plot(xData(index),yData(index),[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    plot([-0.16 0.16],[-0.16 0.15],'k:','LineWidth',figParams.lineWidth);
    xlim([-0.16 0.16]); ylim([-0.16 0.16]);
    set(gca,'YTick',[-0.15 -0.10 -0.05 0 0.05 0.1 0.15]);
    set(gca,'YTick',[-0.15 -0.10 -0.05 0 0.05 0.1 0.15]);
    
    xlabel('Paint Shadow Mean Decode Difference (Discrete)','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    ylabel('Weighted Average Spike Difference','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    title({'Weighted single units consistent with decoding'; ' '}, ...
        'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    figFilename = fullfile(theDir,['Main_WeightedSpikeDiffVersusMeanDifference' v4OnlyString],'');
    FigureSave(figFilename,figWeightedSpikeDiffVersusMeanDifference,figParams.figType);
    
    % Paint shadow mean decode difference versus intercept
    %     figPaintShadowMeanDiffersusIntercept = figure; clf; hold on
    %     set(gcf,'Position',figParams.sqPosition);
    %     set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);
    %
    %     xData = [mainDataStructs(:).decodeIntercept];
    %     yData = [mainDataStructs(:).paintShadowDecodeMeanDifferenceDiscrete];
    %     plot(xData,yData,[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize-6,'MarkerFaceColor',figParams.plotColor);
    %     plot(xData(index),yData(index),[figParams.plotColor figParams.plotSymbol],'MarkerSize',figParams.markerSize,'MarkerFaceColor',figParams.plotColor);
    %     plot([-0.3 0.3],[-0.3 0.3],'k:','LineWidth',figParams.lineWidth);
    %     ylim([-0.3 0.3]);
    %
    %     xlabel('PaintShadow Effect','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    %     ylabel('Mean Paint/Shadow Decode Difference','FontName',figParams.fontName,'FontSize',figParams.labelFontSize);
    %     title({'Mean decoding difference to paint/shadow effect'; ' '}, ...
    %         'FontName',figParams.fontName,'FontSize',figParams.axisFontSize);
    %     figFilename = fullfile(theDir,['Main_PaintShadowMeanDiffersusIntercept' v4OnlyString],'');
    %     FigureSave(figFilename,figPaintShadowMeanDiffersusIntercept,figParams.figType);
    
end