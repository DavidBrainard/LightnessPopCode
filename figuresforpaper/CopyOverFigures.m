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

% setpref('LightnessPopCode','physiologyInputBaseDir',physiologyInputBaseDir);
% setpref('LightnessPopCode','psychoInputBaseDir',psychoInputBaseDir);
% setpref('LightnessPopCode','stimulusInputBaseDir',stimulusInputBaseDir);
% setpref('LightnessPopCode','stimulusDefInputBaseDir',stimulusDefInputBaseDir);

%% Get directory to fill up with the figure parts
figureDir = getpref('LightnessPopCode','figureOutputDir');
if (~exist(figureDir,'dir'))
    mkdir(figureDir);
end

%% Analysis output base dir
outputBaseDir = getpref('LightnessPopCode','outputBaseDir');

%% Psychophysics

% Figure1: Stimulus figure.
stimulusBaseDir = getpref('LightnessPopCode','stimulusInputBaseDir');
stimulusDir = fullfile(stimulusBaseDir,'parametricConditions2/Eimgs_rot0_shad4_blk40_cen40');
copyCmd = ['cp ' fullfile(stimulusDir,'aPaintSqrt_Eimgs_rot0_shad4_blk40_cen40_Probe50_Diam70_Blob0_Chk140.jpg') ' ' fullfile(figureDir,'Figure1_Stimuli_Paint.jpg')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(stimulusDir,'aShadowSqrt_Eimgs_rot0_shad4_blk40_cen40_Probe50_Diam70_Blob0_Chk140.jpg') ' ' fullfile(figureDir,'Figure1_Stimuli_Shadow.jpg')];
unix(copyCmd);

% Figure2: Psychophysical data
analysisOutputFigDir = fullfile(outputBaseDir,'xPsychoBasic','parametricConditions2','c32_pnt_rot0_shad4_blk40_cen40_vs_shd_rot0_shad4_blk40_cen40_t1/aqr/');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'aqr-c32_pnt_rot0_shad4_blk40_cen40_vs_shd_rot0_shad4_blk40_cen40_t1-2_exampleOne.pdf') ' ' fullfile(figureDir,'Figure2A_PsychometricFunctionExample.pdf')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Summary_gain_aqr_32_example.pdf') ' ' fullfile(figureDir,'Figure2B_PaintShadowEffectExample.pdf')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xPsychoSummary','gain');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'OriginalPaintShadowGainsWithControl.pdf') ' ' fullfile(figureDir,'Figure2C_PaintShadowEffectSummary.pdf')];
unix(copyCmd);

% Figure 5B: Average psychophyical probability correct figure
analysisOutputFigDir = fullfile(outputBaseDir,'xPsychoSummary','Gain');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'OriginalPaintShadowAverageProbCorrect.pdf') ' ' fullfile(figureDir,'Figure5B_AveragePsychoProbCorrect.pdf')];
unix(copyCmd);

%% Physiology

% Figure 6: PCA projection example, panels B-D.  We might replace these
% with panels that Marlene produces
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140703lightness0001_115px_-15cx_-72cy_g');
analysisOutputFigDir = fullfile('/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/zPennOutputOld','xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140703lightness0001_115px_-15cx_-72cy_g');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extRMSEVersusNPCAPaintShadowMeanOnPCAShadowOnly1_2.pdf') ' ' fullfile(figureDir,'Figure6B_ExampleDecoding1.pdf')];
unix(copyCmd);

% Figure 7: Decoding and neural paint/shadow effect
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','JD130904lightness0001_300px_15cx_-25cy_i');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothDecoding.pdf') ' ' fullfile(figureDir,'Figure7A_ExampleDecoding1.pdf')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothInferredMatches.pdf') ' ' fullfile(figureDir,'Figure7B_ExamplePaintShadowEffect1.pdf')];
unix(copyCmd);
analysisOutputFigDir = fullfile(outputBaseDir,'xExtractedPlots','aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1','ST140703lightness0001_115px_-15cx_-72cy_g');
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothDecoding.pdf') ' ' fullfile(figureDir,'Figure7C_ExampleDecoding2.pdf')];
unix(copyCmd);
copyCmd = ['cp ' fullfile(analysisOutputFigDir,'Fig_extPaintShadowEffectDecodeBothInferredMatches.pdf') ' ' fullfile(figureDir,'Figure7D_ExamplePaintShadowEffect2.pdf')];
unix(copyCmd);
