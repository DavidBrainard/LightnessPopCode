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
parser = inputParser;
parser.addParamValue('dataType','spksrt',@ischar);
parser.addParamValue('type','aff',@ischar);
parser.addParamValue('classifyType','no',@ischar);
parser.addParamValue('pcaType','no',@ischar);
parser.addParamValue('pcaKeep',10,@isnumeric);
parser.addParamValue('rfAnalysisType','no',@ischar);
parser.addParamValue('reallyDoIRFPlots',false,@islogical);
parser.addParamValue('reallyDoRFPlots',false,@islogical);
parser.addParamValue('decodeJoint','both',@ischar);
parser.addParamValue('trialShuffleType','notshf',@ischar);
parser.addParamValue('paintShadowShuffleType','nopsshf',@ischar);
parser.addParamValue('decodeIntensityFitType','betacdf',@ischar);
parser.addParamValue('paintCondition',1,@isnumeric);
parser.addParamValue('shadowCondition',2,@isnumeric);
parser.addParamValue('paintShadowFitType','intcpt',@ischar);
parser.addParamValue('decodeNFolds',10,@isnumeric);
parser.addParamValue('excludeSYelectrodes','sykp',@ischar);
parser.addParamValue('minTrials',5,@isnumeric);
parser.addParamValue('filterMaxRMSE',0.25,@isnumeric);
parser.parse(varargin{:});

% Type of input
%   'spksrt'             - After Doug did the manual spike sorting
decodeInfoIn.dataType = parser.Results.dataType;

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
decodeInfoIn.type = parser.Results.type;

% Type of classifier
%
% The classifier maps the multivariate electrode responses to predict
% whether the image is paint or shadow.  There are various ways to do this, of
% varying degrees of fanciness.  At present, 
%   'mvma'                     - Matlab's svm classifier, on all trials
%   'svma'                     - LIBSVM's svm classifier, on all trials
%   'nna'                      - Nearest neighbor classification on all trials
%   'no'                       - Don't do the stinkin' classification.
decodeInfoIn.classifyType = parser.Results.classifyType;

% Type of pca
%
% We can do pca on the responses before analyzing.
%   'ml'                 - Matlab's pca.
%   'no'                 - Don't do pca.
decodeInfoIn.pcaType = parser.Results.pcaType;
decodeInfoIn.pcaKeep = parser.Results.pcaKeep;

% Use paint, shadow, or both for building decoder?
%
% Not all of these are currently implemented all the way through.
% An informative error should get thrown if you try one that isn't.
%   'both'                    - Build decoder using paint and shadow trials
%   'paint'                   - Build decoder using paint trials only
%   'shadow'                  - Build decoder using shadow trials only
decodeInfoIn.decodeJoint = parser.Results.decodeJoint;

% Shuffle trials?
%  
% Optional shuffling of trials.  Paint and shadow trials shuffled separately.
%   'notshf'          - Don't shuffle
%   'intshf'          - Shuffle within test intensity
%   'alltshf'         - Shuffle all trials
%   'notshfpca'       - Don't shuffle, do do pca.
decodeInfoIn.trialShuffleType = parser.Results.trialShuffleType;

% Paint/shadow shuffle
%  
% Optional shuffling of paint and shadow trials.  If on, happens after
% trial shuffling.
%   'nopsshf'         - Don't shuffle
%   'psshf'           - Shuffle within test intensity
decodeInfoIn.paintShadowShuffleType = parser.Results.paintShadowShuffleType;

% How to fit the decoded intensity function for each context
%   'smoothingspline'
%   'betcdf'
decodeInfoIn.decodedIntensityFitType = parser.Results.decodeIntensityFitType;
decodeInfoIn.decodedIntensityFitSmoothingParam = 0.995;

% Conditions 
% 
% The coding here matches what was used in the physiological
% recordings.
%   1                        - Original paint images
%   2                        - Original shadow images
%   3                        - New paint images
%   4                        - New shadow images
decodeInfoIn.paintCondition = parser.Results.paintCondition;
decodeInfoIn.shadowCondition = parser.Results.shadowCondition;

% What data to read
decodeInfoIn.DATASTYLE = 'new';

% Paint/shadow fit type
%
% This controls how summarize the inferred matches between
% paint and shadow.  Currently we are using intercept because
% the affine does not appear to be well-identified.
%    'intcpt'            - Fit inferred match plot with a line of slope 1 and free intercept.
decodeInfoIn.paintShadowFitType = parser.Results.paintShadowFitType;
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
decodeInfoIn.excludeSYelectrodes = parser.Results.excludeSYelectrodes;

% Debugging plots?
decodeInfoIn.debugPlots = true;

% Minimum number of trials needed to go forward with a session.
decodeInfoIn.minTrials = parser.Results.minTrials;
decodeInfoIn.filterMaxRMSE = parser.Results.filterMaxRMSE;

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
