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
figureDir = getpref('LightnessPopCode','figureOutputDir');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Analysis output base dir
outputBaseDir = getpref('LightnessPopCode','outputBaseDir');

%% Psychophysics
%
% Cd to psychoanalysis.  Run AnalyzeOriginalPaintShadow.  For full analysis, set 
% COMPUTE = true near the top.  To just remake the figures, set COMPUTE = false.

% Figure1: Stimulus figure.
stimulusBaseDir = getpref('LightnessPopCode','stimulusInputBaseDir');
stimulusDir = fullfile(stimulusBaseDir,'parametricConditions2/Eimgs_rot0_shad4_blk40_cen40');
copyCmd = ['cp ' fullfile(stimulusDir,'aPaintSqrt_Eimgs_rot0_shad4_blk40_cen40_Probe50_Diam70_Blob0_Chk140.jpg') ' ' fullfile(figureDir,'Figure1_Stimuli_Paint.jpg')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(stimulusDir,'aShadowSqrt_Eimgs_rot0_shad4_blk40_cen40_Probe50_Diam70_Blob0_Chk140.jpg') ' ' fullfile(figureDir,'Figure1_Stimuli_Shadow.jpg')];
unix(copyCmd);

% Figure2: Psychophysical data
analysisOutputFigDir = fullfile(outputBaseDir,'xPsychoBasic','parametricConditions2','c32_pnt_rot0_shad4_blk40_cen40_vs_shd_rot0_shad4_blk40_cen40_t1/aqr/');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'aqr-c32_pnt_rot0_shad4_blk40_cen40_vs_shd_rot0_shad4_blk40_cen40_t1-2_exampleOne.eps') ' ' fullfile(figureDir,'Figure2A_PsychometricFunctionExample.eps')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Summary_gain_aqr_32_example.eps') ' ' fullfile(figureDir,'Figure2B_PaintShadowEffectExample.eps')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xPsychoSummary','gain');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'OriginalPaintShadowGainsWithControl.eps') ' ' fullfile(figureDir,'Figure2C_PaintShadowEffectSummary.eps')];
unix(copyCmd);

% Figure 5B: Average psychophyical probability correct figure
analysisOutputFigDir = fullfile(outputBaseDir,'xPsychoSummary','Gain');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'OriginalPaintShadowAverageProbCorrect.eps') ' ' fullfile(figureDir,'Figure5B_AveragePsychoProbCorrect.eps')];
unix(copyCmd);

%% Physiology
%
% Cd to popdecode.  Run ProprocessRunAll; ExtractedRunAll; SummarizeRunAll;

% Figure 6: PCA projection example, panels B-D.  These are figures similar
% to ones Marlene made, but hers are cross-validated and we used those in the 
% paper.
%
% analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140424lightness0001_225px_-1cx_-80cy_g');
% copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extRMSEVersusNPCAPaintShadowMeanOnPCABoth1_2.pdf') ' ' fullfile(figureDir,'Figure6B_MeanOnPCABoth.pdf')];
% unix(copyCmd);
% copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extRMSEVersusNPCAPaintShadowMeanOnPCAPaintOnly1_2.pdf') ' ' fullfile(figureDir,'Figure6C_MeanOnPCAPaint.pdf')];
% unix(copyCmd);
% copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extRMSEVersusNPCAPaintShadowMeanOnPCAShadowOnly1_2.pdf') ' ' fullfile(figureDir,'Figure6D_MeanOnPCAShadow.pdf')];
% unix(copyCmd);

% Figure 8: Decoding and neural paint/shadow effect
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','JD130904lightness0001_300px_15cx_-25cy_i');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothDecoding.eps') ' ' fullfile(figureDir,'Figure8A_ExampleDecoding1.eps')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothInferredMatches.eps') ' ' fullfile(figureDir,'Figure8B_ExamplePaintShadowEffect1.eps')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140703lightness0001_115px_-15cx_-72cy_g');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothDecoding.eps') ' ' fullfile(figureDir,'Figure8C_ExampleDecoding2.eps')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothInferredMatches.eps') ' ' fullfile(figureDir,'Figure8D_ExamplePaintShadowEffect2.eps')];
unix(copyCmd);

% Figure 9: Envelope decoding
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140703lightness0001_115px_-15cx_-72cy_g/');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectRMSEEnvelope.eps') ' ' fullfile(figureDir,'Figure9A_SingleSessionEnvelope.eps')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xSummary','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','PaintShadowEffect');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'summaryPaintShadowEnvelopeVsRMSE.eps') ' ' fullfile(figureDir,'Figure9B_PaintShadowEffectSummary.eps')];
unix(copyCmd);

