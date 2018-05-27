% Compare some aspects of what happens across different decoding methods
%
% 05/26/18  dhb  Wrote first version.

%% Clear
clear; close all;

%% Save directory
saveDir = fullfile('/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary','xCompare');
if (~exist(saveDir,'dir'))
    mkdir(saveDir);
end

%% Define diretories to compare
method1 = 'Standard';
switch (method1)
    case 'Standard'
        directory1 = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/aff_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
end

method2 = 'Shuffle';
switch (method2)
    case 'Shuffle'
        directory2 = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/aff_cls-mvmaSMO_pca-no_intshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
    case 'CVLasso'
        directory2  = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/fitrcvlasso_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
    case 'CVRidge'
        directory2  = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/fitrcvridge_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
    case 'PoissonML'
        directory2  = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput/xSummary/maxlikelypoiss_cls-mvmaSMO_pca-no_notshf_nopsshf_sykp_ft-gain_2_1/PaintShadowEffect';
end

%% Load data
data1 = load(fullfile(directory1,'paintShadowEffectStructArray'));
data2 = load(fullfile(directory2,'paintShadowEffectStructArray'));

%% Get RMSEs
paintShadowEffect1 = [data1.paintShadowEffect(:)];
decodeBoth1 = [paintShadowEffect1(:).decodeBoth];
rmse1 = [decodeBoth1(:).theRMSE];
paintShadowEffect2 = [data2.paintShadowEffect(:)];
decodeBoth2 = [paintShadowEffect2(:).decodeBoth];
rmse2 = [decodeBoth2(:).theRMSE];

%% Plot RMSE versus RMSE
rmseCompareFig = figure; clf; hold on;
plot(rmse1,rmse2,'ko','MarkerFaceColor','k','MarkerSize',8);
plot([0 0.3],[0 0.3],'k:')
xlabel(sprintf('%s RMSE',method1));
ylabel(sprintf('%s RMSE',method2));
axis('square');
axis([0.05 0.3 0.05 0.3]);
figFilename = sprintf('Compare_%s_%s_RMSE',method1,method2);
FigureSave(fullfile(saveDir,figFilename),rmseCompareFig,'pdf');

