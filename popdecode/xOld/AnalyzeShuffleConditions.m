% AnalyzeShuffleConditions
%
% Read in ths shuffle data summaries and print
% out some basic interesting things about them.
%
% 3/25/14  dhb  Wrote it.

%% Clear
clear all; close all;

%% Original/Paint shadow, various shuffles
%
% Set range threshold to 0 so that we can look at decoded range for all
% runs, even when decoding is basically flat.

fprintf('affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1\n');
summaryStructs = ReadStructsFromText('xSummary/xShuffleSummary/affine_both_alltrialshuffle_paintshadowshuffle_onetrial_2_1.txt');
decodeInterceptV4 = [summaryStructs.decodeInterceptV4];
decodeInterceptV4 = decodeInterceptV4(~isnan(decodeInterceptV4));
[h,p] = ttest(decodeInterceptV4,0);
fprintf('\tDecode intercept V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptV4),std(decodeInterceptV4)/sqrt(length(decodeInterceptV4)),p);

decodeInterceptSmoothV4 = [summaryStructs.decodeInterceptSmoothV4];
decodeInterceptSmoothV4 = [summaryStructs.decodeInterceptSmoothV4];
decodeInterceptSmoothV4 = decodeInterceptSmoothV4(~isnan(decodeInterceptSmoothV4));
[h,p] = ttest(decodeInterceptSmoothV4,0);
fprintf('\tDecode intercept smooth V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptSmoothV4),std(decodeInterceptSmoothV4)/sqrt(length(decodeInterceptSmoothV4)),p);

paintShadowDecodeMeanDifferenceDiscreteV4 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV4];
paintShadowDecodeMeanDifferenceDiscreteV4 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV4];
paintShadowDecodeMeanDifferenceDiscreteV4 = paintShadowDecodeMeanDifferenceDiscreteV4(~isnan(paintShadowDecodeMeanDifferenceDiscreteV4));
[h,p] = ttest(paintShadowDecodeMeanDifferenceDiscreteV4,0);
fprintf('\tPaint shadow decode diff V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(paintShadowDecodeMeanDifferenceDiscreteV4),std(paintShadowDecodeMeanDifferenceDiscreteV4)/sqrt(length(paintShadowDecodeMeanDifferenceDiscreteV4)),p);

decodeInterceptV1 = [summaryStructs.decodeInterceptV1];
decodeInterceptV1 = decodeInterceptV1(~isnan(decodeInterceptV1));
[h,p] = ttest(decodeInterceptV1,0);
fprintf('\tDecode intercept V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptV1),std(decodeInterceptV1)/sqrt(length(decodeInterceptV1)),p);

decodeInterceptSmoothV1 = [summaryStructs.decodeInterceptSmoothV1];
decodeInterceptSmoothV1 = [summaryStructs.decodeInterceptSmoothV1];
decodeInterceptSmoothV1 = decodeInterceptSmoothV1(~isnan(decodeInterceptSmoothV1));
[h,p] = ttest(decodeInterceptSmoothV1,0);
fprintf('\tDecode intercept smooth V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptSmoothV1),std(decodeInterceptSmoothV1)/sqrt(length(decodeInterceptSmoothV1)),p);

paintShadowDecodeMeanDifferenceDiscreteV1 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV1];
paintShadowDecodeMeanDifferenceDiscreteV1 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV1];
paintShadowDecodeMeanDifferenceDiscreteV1 = paintShadowDecodeMeanDifferenceDiscreteV1(~isnan(paintShadowDecodeMeanDifferenceDiscreteV1));
[h,p] = ttest(paintShadowDecodeMeanDifferenceDiscreteV1,0);
fprintf('\tPaint shadow decode diff V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(paintShadowDecodeMeanDifferenceDiscreteV1),std(paintShadowDecodeMeanDifferenceDiscreteV1)/sqrt(length(paintShadowDecodeMeanDifferenceDiscreteV1)),p);

fprintf('affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1\n');
summaryStructs = ReadStructsFromText('xSummary/xShuffleSummary/affine_both_alltrialshuffle_nopaintshadowshuffle_onetrial_2_1.txt');
decodeInterceptV4 = [summaryStructs.decodeInterceptV4];
decodeInterceptV4 = decodeInterceptV4(~isnan(decodeInterceptV4));
[h,p] = ttest(decodeInterceptV4,0);
fprintf('\tDecode intercept V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptV4),std(decodeInterceptV4)/sqrt(length(decodeInterceptV4)),p);

decodeInterceptSmoothV4 = [summaryStructs.decodeInterceptSmoothV4];
decodeInterceptSmoothV4 = [summaryStructs.decodeInterceptSmoothV4];
decodeInterceptSmoothV4 = decodeInterceptSmoothV4(~isnan(decodeInterceptSmoothV4));
[h,p] = ttest(decodeInterceptSmoothV4,0);
fprintf('\tDecode intercept smooth V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptSmoothV4),std(decodeInterceptSmoothV4)/sqrt(length(decodeInterceptSmoothV4)),p);

paintShadowDecodeMeanDifferenceDiscreteV4 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV4];
paintShadowDecodeMeanDifferenceDiscreteV4 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV4];
paintShadowDecodeMeanDifferenceDiscreteV4 = paintShadowDecodeMeanDifferenceDiscreteV4(~isnan(paintShadowDecodeMeanDifferenceDiscreteV4));
[h,p] = ttest(paintShadowDecodeMeanDifferenceDiscreteV4,0);
fprintf('\tPaint shadow decode diff V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(paintShadowDecodeMeanDifferenceDiscreteV4),std(paintShadowDecodeMeanDifferenceDiscreteV4)/sqrt(length(paintShadowDecodeMeanDifferenceDiscreteV4)),p);

decodeInterceptV1 = [summaryStructs.decodeInterceptV1];
decodeInterceptV1 = decodeInterceptV1(~isnan(decodeInterceptV1));
[h,p] = ttest(decodeInterceptV1,0);
fprintf('\tDecode intercept V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptV1),std(decodeInterceptV1)/sqrt(length(decodeInterceptV1)),p);

decodeInterceptSmoothV1 = [summaryStructs.decodeInterceptSmoothV1];
decodeInterceptSmoothV1 = [summaryStructs.decodeInterceptSmoothV1];
decodeInterceptSmoothV1 = decodeInterceptSmoothV1(~isnan(decodeInterceptSmoothV1));
[h,p] = ttest(decodeInterceptSmoothV1,0);
fprintf('\tDecode intercept smooth V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptSmoothV1),std(decodeInterceptSmoothV1)/sqrt(length(decodeInterceptSmoothV1)),p);

paintShadowDecodeMeanDifferenceDiscreteV1 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV1];
paintShadowDecodeMeanDifferenceDiscreteV1 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV1];
paintShadowDecodeMeanDifferenceDiscreteV1 = paintShadowDecodeMeanDifferenceDiscreteV1(~isnan(paintShadowDecodeMeanDifferenceDiscreteV1));
[h,p] = ttest(paintShadowDecodeMeanDifferenceDiscreteV1,0);
fprintf('\tPaint shadow decode diff V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(paintShadowDecodeMeanDifferenceDiscreteV1),std(paintShadowDecodeMeanDifferenceDiscreteV1)/sqrt(length(paintShadowDecodeMeanDifferenceDiscreteV1)),p);


fprintf('affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1\n');
summaryStructs = ReadStructsFromText('xSummary/xShuffleSummary/affine_both_notrialshuffle_paintshadowshuffle_onetrial_2_1.txt');
decodeInterceptV4 = [summaryStructs.decodeInterceptV4];
decodeInterceptV4 = decodeInterceptV4(~isnan(decodeInterceptV4));
[h,p] = ttest(decodeInterceptV4,0);
fprintf('\tDecode intercept V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptV4),std(decodeInterceptV4)/sqrt(length(decodeInterceptV4)),p);

decodeInterceptSmoothV4 = [summaryStructs.decodeInterceptSmoothV4];
decodeInterceptSmoothV4 = [summaryStructs.decodeInterceptSmoothV4];
decodeInterceptSmoothV4 = decodeInterceptSmoothV4(~isnan(decodeInterceptSmoothV4));
[h,p] = ttest(decodeInterceptSmoothV4,0);
fprintf('\tDecode intercept smooth V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptSmoothV4),std(decodeInterceptSmoothV4)/sqrt(length(decodeInterceptSmoothV4)),p);

paintShadowDecodeMeanDifferenceDiscreteV4 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV4];
paintShadowDecodeMeanDifferenceDiscreteV4 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV4];
paintShadowDecodeMeanDifferenceDiscreteV4 = paintShadowDecodeMeanDifferenceDiscreteV4(~isnan(paintShadowDecodeMeanDifferenceDiscreteV4));
[h,p] = ttest(paintShadowDecodeMeanDifferenceDiscreteV4,0);
fprintf('\tPaint shadow decode diff V4: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(paintShadowDecodeMeanDifferenceDiscreteV4),std(paintShadowDecodeMeanDifferenceDiscreteV4)/sqrt(length(paintShadowDecodeMeanDifferenceDiscreteV4)),p);

decodeInterceptV1 = [summaryStructs.decodeInterceptV1];
decodeInterceptV1 = decodeInterceptV1(~isnan(decodeInterceptV1));
[h,p] = ttest(decodeInterceptV1,0);
fprintf('\tDecode intercept V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptV1),std(decodeInterceptV1)/sqrt(length(decodeInterceptV1)),p);

decodeInterceptSmoothV1 = [summaryStructs.decodeInterceptSmoothV1];
decodeInterceptSmoothV1 = [summaryStructs.decodeInterceptSmoothV1];
decodeInterceptSmoothV1 = decodeInterceptSmoothV1(~isnan(decodeInterceptSmoothV1));
[h,p] = ttest(decodeInterceptSmoothV1,0);
fprintf('\tDecode intercept smooth V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(decodeInterceptSmoothV1),std(decodeInterceptSmoothV1)/sqrt(length(decodeInterceptSmoothV1)),p);

paintShadowDecodeMeanDifferenceDiscreteV1 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV1];
paintShadowDecodeMeanDifferenceDiscreteV1 = [summaryStructs.paintShadowDecodeMeanDifferenceDiscreteV1];
paintShadowDecodeMeanDifferenceDiscreteV1 = paintShadowDecodeMeanDifferenceDiscreteV1(~isnan(paintShadowDecodeMeanDifferenceDiscreteV1));
[h,p] = ttest(paintShadowDecodeMeanDifferenceDiscreteV1,0);
fprintf('\tPaint shadow decode diff V1: %0.2f +/- %0.3f, t-test different from 0: p = %0.3f\n',...
    mean(paintShadowDecodeMeanDifferenceDiscreteV1),std(paintShadowDecodeMeanDifferenceDiscreteV1)/sqrt(length(paintShadowDecodeMeanDifferenceDiscreteV1)),p);

