% CopyOverFigures
%
% This script copies over figures made by the various analysis scripts and
% renames them to match the figure numbers in the paper describing this
% work.
%
% You need to have set up the input and output directories for this to work
% properly.  See configuration/LightnessPopCodeLocalHookTemplate.  If you
% use the ToolboxToolbox (gitHub.com/toolboxHub) then the process of
% executing this script becomes more automated.

% 06/14/17  dhb  Wrote it.

%% Get directory to fill up with the figure parts
figureDir = getpref('LightnessPopCode','figureDirCVLasso');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Analysis output base dir
outputBaseDir = getpref('LightnessPopCode','outputBaseDir');

%% Physiology
%
% Cd to popdecode.  Run ProprocessRunAll; ExtractedRunAll; SummarizeRunAll;

% Figure 7: Decoding and neural paint/shadow effect
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','JD130904lightness0001_300px_15cx_-25cy_i');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothDecoding.eps') ' ' fullfile(figureDir,'Figure7A_CVLasso_ExampleDecoding1.eps')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothInferredMatches.eps') ' ' fullfile(figureDir,'Figure7B_CVLasso_ExamplePaintShadowEffect1.eps')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140703lightness0001_115px_-15cx_-72cy_g');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothDecoding.eps') ' ' fullfile(figureDir,'Figure7C_CVLasso_ExampleDecoding2.eps')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothInferredMatches.eps') ' ' fullfile(figureDir,'Figure7D_CVLasso_ExamplePaintShadowEffect2.eps')];
unix(copyCmd);

% Figure 8: Envelope decoding
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140703lightness0001_115px_-15cx_-72cy_g/');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectRMSEEnvelope.eps') ' ' fullfile(figureDir,'Figure8A_CVLasso_SingleSessionEnvelope.eps')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xSummary','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','PaintShadowEffect');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'summaryPaintShadowEnvelopeVsRMSE_V1.eps') ' ' fullfile(figureDir,'Figure8B_CVLasso_PaintShadowEffectSummary.eps')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xSummary','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','PaintShadowEffect');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'summaryPaintShadowEnvelopeVsRMSE_V4.eps') ' ' fullfile(figureDir,'Figure8C_CVLasso_PaintShadowEffectSummary.eps')];
unix(copyCmd);

% Figure 8, reviewer version with all RMSE
analysisOutputFigDir = fullfile(outputBaseDir,'xSummary','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','PaintShadowEffect');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'summaryPaintShadowEnvelopeVsRMSE_V1_AllRMSE.eps') ' ' fullfile(figureDir,'Figure8B_ReviewerAllRMSE_CVLasso_PaintShadowEffectSummary.eps')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xSummary','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','PaintShadowEffect');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'summaryPaintShadowEnvelopeVsRMSE_V4_AllRMSE.eps') ' ' fullfile(figureDir,'Figure8C_ReviewerAllRMSE_CVLasso_PaintShadowEffectSummary.eps')];
unix(copyCmd);

% Figure X, reviewer figure non-zero weights histogram
analysisOutputFigDir = fullfile(outputBaseDir,'xSummary','fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','PaintShadowEffect');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'summaryNonZeroElectrodes.pdf') ' ' fullfile(figureDir,'FigureX_Reviewer_CVLasso_NonzeroWeightsHist.pdf')];
unix(copyCmd);

% Figure Y, comparison of RMSE
analysisOutputFigDir = fullfile(outputBaseDir,'xSummary','xCompare');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Compare_Standard_CVLasso_RMSE.pdf') ' ' fullfile(figureDir,'FigureY_Reviewer_CVLasso_CompareRMSE.pdf')];
unix(copyCmd);
