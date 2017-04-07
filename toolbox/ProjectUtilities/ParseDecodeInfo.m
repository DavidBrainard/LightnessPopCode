function [decodeInfoIn] = ParseDecodeInfo(varargin)
% [decodeInfoIn] = ParseDecodeInfo(varargin)
%
% Set up the decodeInfoIn structure.
%
% 3/8/16  dhb  Pulled this out.

% Check for the number of arguments and parse optional args.
%
% The arg strings match the fields set in the decodeInfo structure
% below.
%
% Defaults are given here.  Options are described in comments
% with each field/variable below.
narginchk(0, Inf);
p = inputParser;
p.addParamValue('dataType','spksrt',@ischar);
p.addParamValue('type','aff',@ischar);
p.addParamValue('classifyType','no',@ischar);
p.addParamValue('pcaType','no',@ischar);
p.addParamValue('rfAnalysisType','no',@ischar);
p.addParamValue('reallyDoIRFPlots',false,@islogical);
p.addParamValue('reallyDoRFPlots',false,@islogical);
p.addParamValue('decodeJoint','both',@ischar);
p.addParamValue('trialShuffleType','notshf',@ischar);
p.addParamValue('paintShadowShuffleType','nopsshf',@ischar);
p.addParamValue('decodeIntensityFitType','betacdf',@ischar);
p.addParamValue('paintCondition',1,@isnumeric);
p.addParamValue('shadowCondition',2,@isnumeric);
p.addParamValue('paintShadowFitType','intcpt',@ischar);
p.addParamValue('decodeNFolds',10,@isnumeric);
p.addParamValue('excludeSYelectrodes','sykp',@ischar);
p.addParamValue('minTrials',5,@isnumeric);
p.addParamValue('filterMaxRMSE',0.25,@isnumeric);

% Which extracted analyses to do
p.addParamValue('doExtractedPaintShadowEffect',true,@islogical);
p.addParamValue('doExtractedRepSim',false,@islogical);
p.addParamValue('doExtractedRMSEAnalysis',false,@islogical);
p.addParamValue('doExtractedRMSEVersusNUnits',false,@islogical);
p.addParamValue('doExtractedRMSEVersusNPCA',false,@islogical);
p.addParamValue('doExtractedClassificationVersusNUnits',false,@islogical);
p.addParamValue('doExtractedClassificationVersusNPCA',false,@islogical);

% Which summary analyses to do
p.addParamValue('doSummaryPaintShadowEffect',true,@islogical);
p.addParamValue('doSummaryRepSim',false,@islogical);
p.addParamValue('doSummaryRMSEAnalysis',false,@islogical);
p.addParamValue('doSummaryRMSEVersusNUnits',false,@islogical);
p.addParamValue('doSummaryRMSEVersusNPCA',false,@islogical);
p.addParamValue('doSummaryClassificationVersusNUnits',false,@islogical);
p.addParamValue('doSummaryClassificationVersusNPCA',false,@islogical);

p.parse(varargin{:});

% Type of input
%   'spksrt'             - After Doug did the manual spike sorting
decodeInfoIn.dataType = p.Results.dataType;

% Type of decoder
%
% The decoder maps the multivariate electrode responses to a 
% decoded intensity.  There are various ways to do this, of
% varying degrees of fanciness.  At present, affine ('aff')
% is simple enough that we think we understand how it works.  The rest
% are in various degrees of experimentatal development.
%   'aff'                  - Decoder uses multivariate affine regression.
%   'svmreg'               - SVM regression
%   'maxlikely'            - Max likelihood based        
%   'maxlikelyfano'        - Max likelihood based, multiplicative noise model
%   'mlbayes'              - Bayes based
%   'mlbayesfano'          - Bayes based, multiplicative noise model
decodeInfoIn.type = p.Results.type;

% Type of classifier
%
% The classifier maps the multivariate electrode responses to predict
% whether the image is paint or shadow.  There are various ways to do this, of
% varying degrees of fanciness.  At present, 
%   'mvma'                     - Matlab's svm classifier, on all trials
%   'svma'                     - LIBSVM's svm classifier, on all trials
%   'nna'                      - Nearest neighbor classification on all trials
%   'no'                       - Don't do the stinkin' classification.
decodeInfoIn.classifyType = p.Results.classifyType;

% Type of pca
%
% We can do pca on the responses before analyzing.
%   'ml'                 - Matlab's pca.
%   'no'                 - Don't do pca.
decodeInfoIn.pcaType = p.Results.pcaType;

% Use paint, shadow, or both for building decoder?
%
% Not all of these are currently implemented all the way through.
% An informative error should get thrown if you try one that isn't.
%   'both'                    - Build decoder using paint and shadow trials
%   'paint'                   - Build decoder using paint trials only
%   'shadow'                  - Build decoder using shadow trials only
decodeInfoIn.decodeJoint = p.Results.decodeJoint;

% Shuffle trials?
%  
% Optional shuffling of trials.  Paint and shadow trials shuffled separately.
%   'notshf'          - Don't shuffle
%   'intshf'          - Shuffle within test intensity
%   'alltshf'         - Shuffle all trials
%   'notshfpca'       - Don't shuffle, do do pca.
decodeInfoIn.trialShuffleType = p.Results.trialShuffleType;

% Paint/shadow shuffle
%  
% Optional shuffling of paint and shadow trials.  If on, happens after
% trial shuffling.
%   'nopsshf'         - Don't shuffle
%   'psshf'           - Shuffle within test intensity
decodeInfoIn.paintShadowShuffleType = p.Results.paintShadowShuffleType;

% How to fit the decoded intensity function for each context
%   'smoothingspline'
%   'betcdf'
decodeInfoIn.decodedIntensityFitType = p.Results.decodeIntensityFitType;
decodeInfoIn.decodedIntensityFitSmoothingParam = 0.995;

% Conditions 
% 
% The coding here matches what was used in the physiological
% recordings.
%   1                        - Original paint images
%   2                        - Original shadow images
%   3                        - New paint images
%   4                        - New shadow images
decodeInfoIn.paintCondition = p.Results.paintCondition;
decodeInfoIn.shadowCondition = p.Results.shadowCondition;

% What data to read
decodeInfoIn.DATASTYLE = 'new';

% Paint/shadow fit type
%
% This controls how summarize the inferred matches between
% paint and shadow.  Currently we are using intercept because
% the affine does not appear to be well-identified.
%    'intcpt'            - Fit inferred match plot with a line of slope 1 and free intercept.
decodeInfoIn.paintShadowFitType = p.Results.paintShadowFitType;
decodeInfoIn.nFinelySpacedIntensities = 1000;
decodeInfoIn.inferIntensityLevelsDiscrete = [25 35 45 55 65 75]/100;

% Decoder method specific
decodeInfoIn.smoothingParam = 0.995;
decodeInfoIn.svmSvmType = 4;
decodeInfoIn.svmKernalType = 0;
decodeInfoIn.svmNu = [];
decodeInfoIn.svmDegree = [];
decodeInfoIn.svmGamma = [];
decodeInfoIn.svmQuiet = false;

% Classifier method specific
decodeInfoIn.LIBSVM_QUIET = true;
decodeInfoIn.SVM_LOOPROGRESS = true;
%decodeInfoIn.MVM_ALG = 'ISDA';
decodeInfoIn.MVM_ALG = 'SMO';
decodeInfoIn.MVM_COMPARECLASS = false;

% Exclude SY electrodes
%   'sykp'                    - Keep all electrodes
%   'syexp'                   - Exclude SY peripheral electrodes
%   'syexf'                   - Exclude SY foveal electrodes
decodeInfoIn.excludeSYelectrodes = p.Results.excludeSYelectrodes;

% Debugging plots?
decodeInfoIn.debugPlots = true;

% Minimum number of trials needed to go forward with a session.
decodeInfoIn.minTrials = p.Results.minTrials;
decodeInfoIn.filterMaxRMSE = p.Results.filterMaxRMSE;

% Which stimulus intensities to leave out of the analysis.
%
% For 'h' classifier analysis, we restrict to high intensities for
% classification, but not for decoding.
decodeInfoIn.blankIntensity = 105;
decodeInfoIn.leaveOutIntensities = [decodeInfoIn.blankIntensity 0 5 10 15];
decodeInfoIn.minFineGrainedIntensities = 0.20;

% Plot params
decodeInfoIn = SetFigParams(decodeInfoIn,'popdecode');

% Stimulus parameters for monkey experiments.
%
% In the stimulus files, the size is given as the
% size of one side of the checkerboard in units of
% pixels, and positions are given as pixels from fixation.
%  [0,0] is fixation
%  Positive x is to right of fixation from monkey's viewpoint.
%  Positive y is above fixation from monkey's viewpoint.
decodeInfoIn.monitorPixelsPerInch = 61;
decodeInfoIn.monitorDistanceInches = 54/2.54;
decodeInfoIn.degreesPerPixel = rad2deg(2*atan((1/decodeInfoIn.monitorPixelsPerInch)/(2*decodeInfoIn.monitorDistanceInches)));

% This used to do something, but doesn't anymore.  But defining it here
% keeps some code the references the field from crashing when it passes the
% value on to another structure.
decodeInfoIn.doIndElectrodeRFPlots = false;

decodeInfoIn.doExtractedPaintShadowEffect = p.Results.doExtractedPaintShadowEffect;
decodeInfoIn.doExtractedRepSim = p.Results.doExtractedRepSim;
decodeInfoIn.doExtractedRMSEAnalysis = p.Results.doExtractedRMSEAnalysis;
decodeInfoIn.doExtractedRMSEVersusNUnits = p.Results.doExtractedRMSEVersusNUnits;
decodeInfoIn.doExtractedRMSEVersusNPCA = p.Results.doExtractedRMSEVersusNPCA;
decodeInfoIn.doExtractedClassificationVersusNUnits = p.Results.doExtractedClassificationVersusNUnits;
decodeInfoIn.doExtractedClassificationVersusNPCA = p.Results.doExtractedClassificationVersusNPCA;

decodeInfoIn.doSummaryPaintShadowEffect = p.Results.doSummaryPaintShadowEffect;
decodeInfoIn.doSummaryRepSim = p.Results.doSummaryRepSim;
decodeInfoIn.doSummaryRMSEAnalysis = p.Results.doSummaryRMSEAnalysis;
decodeInfoIn.doSummaryRMSEVersusNUnits = p.Results.doSummaryRMSEVersusNUnits;
decodeInfoIn.doSummaryRMSEVersusNPCA = p.Results.doSummaryRMSEVersusNPCA;
decodeInfoIn.doSummaryClassificationVersusNUnits = p.Results.doSummaryClassificationVersusNUnits;
decodeInfoIn.doSummaryClassificationVersusNPCA = p.Results.doSummaryClassificationVersusNPCA;
