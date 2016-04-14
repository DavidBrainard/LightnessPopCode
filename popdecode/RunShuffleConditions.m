% RunShuffleConditions
%
% Run a set of fully shuffled conditions
%
% 3/25/14  dhb  Wrote it.

%% Dirs for storing shuffled stuff, out of the way
if (~exist('xPlots/xShufflePlots','dir'))
    mkdir('xPlots/xShufflePlots');
end
if (~exist('xSummary/xShuffleSummary','dir'))
    mkdir('xSummary/xShuffleSummary');
end
nShuffleRuns = 10;

%% Original/Paint shadow, various shuffles
%
% Set range threshold to 0 so that we can look at decoded range for all
% runs, even when decoding is basically flat.

for s = 1:nShuffleRuns
        tempStruct = RunOneCondition(...
        'dataType','spksrt', ...
        'type','aff', ...
        'decodeJoint','both', ...
        'trialShuffleType','alltshf', ...
        'paintShadowShuffleType','psshf', ...
        'decodeIntensityFitType','betacdf', ...
        'paintCondition', 1, ...
        'shadowCondition', 2, ...
        'paintShadowFitType', 'intcpt',  ...
        'decodeLOOType', 'ot', ...
        'errType', 'mean', ...
        'minTrials',20, ...
        'filterRangeLower',0.0,  ...
        'COMPUTE', true ...
        );
    unix(['rm -rf xPlots/xShufflePlots/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['mv xPlots/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1 xPlots/xShufflePlots/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['rm -rf xSummary/xShuffleSummary/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['mv xSummary/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1 xSummary/xShuffleSummary/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    close all;
    
    index = find(strcmp({tempStruct.arrayPosition},'V4'));
    summaryStructTemp.decodeInterceptV4 = tempStruct(index(1)).meanDecodeIntercept;
    summaryStructTemp.decodeInterceptSmoothV4 = tempStruct(index(1)).meanDecodeInterceptSmooth;
    summaryStructTemp.paintShadowDecodeMeanDifferenceDiscreteV4 = tempStruct(index(1)).meanPaintShadowDecodeMeanDifferenceDiscrete;
    index = find(strcmp({tempStruct.arrayPosition},'V1'));
    summaryStructTemp.decodeInterceptV1 = tempStruct(index(1)).meanDecodeIntercept;
    summaryStructTemp.decodeInterceptSmoothV1 = tempStruct(index(1)).meanDecodeInterceptSmooth;
    summaryStructTemp.paintShadowDecodeMeanDifferenceDiscreteV1 = tempStruct(index(1)).meanPaintShadowDecodeMeanDifferenceDiscrete;
    summaryStructs(s) = summaryStructTemp;
end
WriteStructsToText('xSummary/xShuffleSummary/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1.txt',summaryStructs);
clear summaryStructs

for s = 1:nShuffleRuns
    tempStruct = RunOneCondition(...
        'dataType','spksrt', ...
        'type','aff', ...
        'decodeJoint','both', ...
        'trialShuffleType','alltshf', ...
        'paintShadowShuffleType','nopsshf', ...
        'decodeIntensityFitType','betacdf', ...
        'paintCondition', 1, ...
        'shadowCondition', 2, ...
        'paintShadowFitType', 'intcpt',  ...
        'decodeLOOType', 'ot', ...
        'errType', 'mean', ...
        'minTrials',20, ...
        'filterRangeLower',0.0,  ...
        'COMPUTE', true ...
        );
    unix(['rm -rf xPlots/xShufflePlots/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['mv xPlots/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1 xPlots/xShufflePlots/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['rm -rf xSummary/xShuffleSummary/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['mv xSummary/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1 xSummary/xShuffleSummary/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    close all;
    
    index = find(strcmp({tempStruct.arrayPosition},'V4'));
    summaryStructTemp.decodeInterceptV4 = tempStruct(index(1)).meanDecodeIntercept;
    summaryStructTemp.decodeInterceptSmoothV4 = tempStruct(index(1)).meanDecodeInterceptSmooth;
    summaryStructTemp.paintShadowDecodeMeanDifferenceDiscreteV4 = tempStruct(index(1)).meanPaintShadowDecodeMeanDifferenceDiscrete;
    index = find(strcmp({tempStruct.arrayPosition},'V1'));
    summaryStructTemp.decodeInterceptV1 = tempStruct(index(1)).meanDecodeIntercept;
    summaryStructTemp.decodeInterceptSmoothV1 = tempStruct(index(1)).meanDecodeInterceptSmooth;
    summaryStructTemp.paintShadowDecodeMeanDifferenceDiscreteV1 = tempStruct(index(1)).meanPaintShadowDecodeMeanDifferenceDiscrete;
    summaryStructs(s) = summaryStructTemp;
end
WriteStructsToText('xSummary/xShuffleSummary/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1.txt',summaryStructs);
clear summaryStructs

for s = 1:nShuffleRuns
    tempStruct = RunOneCondition(...
        'dataType','spksrt', ...
        'type','aff', ...
        'decodeJoint','both', ...
        'trialShuffleType','notshf', ...
        'paintShadowShuffleType','psshf', ...
        'decodeIntensityFitType','betacdf', ...
        'paintCondition', 1, ...
        'shadowCondition', 2, ...
        'paintShadowFitType', 'intcpt',  ...
        'decodeLOOType', 'ot', ...
        'errType', 'mean', ...
        'minTrials',20, ...
        'filterRangeLower',0.0,  ...
        'COMPUTE', true ...
        );
    unix(['rm -rf xPlots/xShufflePlots/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['mv xPlots/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1 xPlots/xShufflePlots/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['rm -rf xSummary/xShuffleSummary/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    unix(['mv xSummary/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1 xSummary/xShuffleSummary/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1_run' num2str(s)]);
    close all;
    
    index = find(strcmp({tempStruct.arrayPosition},'V4'));
    summaryStructTemp.decodeInterceptV4 = tempStruct(index(1)).meanDecodeIntercept;
    summaryStructTemp.decodeInterceptSmoothV4 = tempStruct(index(1)).meanDecodeInterceptSmooth;
    summaryStructTemp.paintShadowDecodeMeanDifferenceDiscreteV4 = tempStruct(index(1)).meanPaintShadowDecodeMeanDifferenceDiscrete;
    index = find(strcmp({tempStruct.arrayPosition},'V1'));
    summaryStructTemp.decodeInterceptV1 = tempStruct(index(1)).meanDecodeIntercept;
    summaryStructTemp.decodeInterceptSmoothV1 = tempStruct(index(1)).meanDecodeInterceptSmooth;
    summaryStructTemp.paintShadowDecodeMeanDifferenceDiscreteV1 = tempStruct(index(1)).meanPaintShadowDecodeMeanDifferenceDiscrete;
    summaryStructs(s) = summaryStructTemp;
end
WriteStructsToText('xSummary/xShuffleSummary/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1.txt',summaryStructs);
clear summaryStructs


