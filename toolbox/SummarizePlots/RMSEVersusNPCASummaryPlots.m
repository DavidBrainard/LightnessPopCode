function RMSEVersusNPCASummaryPlots(basicInfo,RMSEVersusNPCA,summaryDir,figParams)
% RMSEVersusNPCASummaryPlots(basicInfo,RMSEVersusNPCA,summaryDir,figParams)
%
% Summary plots of RMSE versus NPCA components, in various combinations.
%
% 4/2/17  dhb  Wrote it.

%% Additional parameters
figParams.bumpSizeForMean = 6;
figureSubdir = 'RMSEVersusNPCA';
figureDir = fullfile(summaryDir,figureSubdir,'');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Simple checks
if (length(basicInfo) ~= length(RMSEVersusNPCA))
    error('Length mismatch on struct arrays that should be the same');
end

%% PLOT: Paint/shadow effect from decoding on paint
%
% Get the decode both results from the top level structure.
RMSEVersusNPCABestRMSE = SubstructArrayFromStructArray(RMSEVersusNPCA,'bestRMSE');
RMSEVersusNPCAFitScale = SubstructArrayFromStructArray(RMSEVersusNPCA,'fitScale');
RMSEVersusNPCAFitAsymp = SubstructArrayFromStructArray(RMSEVersusNPCA,'fitAsymp');


% paintOnlyPaintBestRMSE
% paintOnlyPaintNullRMSE
% paintOnlyPaintFitScale
% paintOnlyPaintFitAsymp


% Make the plot
RMSEVersusNPCATestFig = figure; clf;
plot(RMSEVersusNPCABestRMSE,RMSEVersusNPCAFitAsymp,'ro');
title({'Test'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'summaryRMSEVersusNPCATest','');
FigureSave(figFilename,RMSEVersusNPCATestFig,figParams.figType);

RMSEVersusNPCAScaleVsRMSEFig = figure; clf;
plot(RMSEVersusNPCAFitAsymp,RMSEVersusNPCAFitScale,'ro');
xlabel('Aysmptotic Decoding RMSE');
ylabel('Exponential Fit Scale Parameter');
xlim([0 0.30]);
ylim([0 10]);
title({'Test'},'FontName',figParams.fontName,'FontSize',figParams.titleFontSize);
figFilename = fullfile(figureDir,'RMSEVersusNPCAScaleVsRMSE','');
FigureSave(figFilename,RMSEVersusNPCAScaleVsRMSEFig,figParams.figType);

end

