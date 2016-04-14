function [decodeInfoIn,COMPUTE] = ParseDecodeInfo(varargin)
% [decodeInfoIn,COMPUTE] = ParseDecodeInfo(varargin)
%
% Set up the decodeInfoIn structure.
%
% 3/8/16  dhb  Pulled this out.

% Check for the number of arguments and parse optional args.
%
% The arg strings match the fields set in the decodeInfo structure
% below, with the exception of COMPUTE which is not a field in
% that structure.
%
% Defaults are given here.  Options are described in comments
% with each field/variable below.
narginchk(0, Inf);
parser = inputParser;
parser.addParamValue('dataType','spksrt',@ischar);
parser.addParamValue('type','aff',@ischar);
parser.addParamValue('classifyType','no',@ischar);
parser.addParamValue('classifyReduce','',@ischar);
parser.addParamValue('pcaType','no',@ischar);
parser.addParamValue('pcaKeep',10,@isnumeric);
parser.addParamValue('rfAnalysisType','no',@ischar);
parser.addParamValue('reallyDoIRFPlots',false,@islogical);
parser.addParamValue('reallyDoRFPlots',false,@islogical);
parser.addParamValue('decodeJoint','both',@ischar);
parser.addParamValue('decodeOffset',0,@isnumeric);
parser.addParamValue('trialShuffleType','notshf',@ischar);
parser.addParamValue('paintShadowShuffleType','nopsshf',@ischar);
parser.addParamValue('decodeIntensityFitType','betacdf',@ischar);
parser.addParamValue('paintCondition',1,@isnumeric);
parser.addParamValue('shadowCondition',2,@isnumeric);
parser.addParamValue('paintShadowFitType','intcpt',@ischar);
parser.addParamValue('looType','ot',@ischar);
parser.addParamValue('classifyLooType','no',@ischar);
parset.addParamValue('classifyNFolds',10,@isnumeric);
parser.addParamValue('excludeSYelectrodes','sykp',@ischar);
parser.addParamValue('errType','mean',@ischar);
parser.addParamValue('minTrials',20,@isnumeric);
parser.addParamValue('filterRangeLower',0.2,@isnumeric);
parser.addParamValue('doIndElectrodeRFPlots',false,@islogical);
parser.addParamValue('COMPUTE',true,@islogical);
parser.addParamValue('plotV4Only',false,@islogical);
parser.addParamValue('DATASTYLE','new',@ischar);

parser.parse(varargin{:});

% Compute for each individual data file, or just read what was already done and do 
% the summary analysis?  Usefule because the file-by-file stuff takes some time,
% and often we are screwing around with the summarizing code and don't need to
% redo everything just to get that part fixed up.
COMPUTE = parser.Results.COMPUTE;

% Type of input
%   'spksrt'             - After Doug did the manual spike sorting
decodeInfoIn.dataType = parser.Results.dataType;

% Type of decoder
%
% The decoder maps the multivariate electrode responses to a 
% decoded intensity.  There are various ways to do this, of
% varying degrees of fanciness.  At present, affine is simple
% enough that we think we understand how it works.  The rest
% are in arious degrees of experimentatal development.
%   'aff'                  - Decoder uses multivariate affine regression.
%   'betacdf'
%   'betadoublecdf'
%   'smoothing'
decodeInfoIn.type = parser.Results.type;

% Type of classifier
%
% The classifier maps the multivariate electrode responses to predict
% whether the image is paint or shadow.  There are various ways to do this, of
% varying degrees of fanciness.  At present, 
%   'mvma'                     - Matlab's svm classifier, on all trials
%   'mvmb'                     - Matlab's svm classifier, just blank trials
%   'mvmh'                     - Matlab's svm classifier, on higher intensities
%   'svma'                     - LIBSVM's svm classifier, on all trials
%   'svmb'                     - LIBSVM's svm classifier, just blank trials
%   'svmh'                     - LIBSVM's svm classifier, on higher intensities
%   'nna'                      - Nearest neighbor classification on all trials
%   'nnb'                      - Nearest neighbor classificatoin on just blank trials.
%   'nnn'                      - Nearest neighbor on higher intensities.
%   'no'                       - Don't do the stinkin' classification.
decodeInfoIn.classifyType = parser.Results.classifyType;

% Data reduction before classification
%   'ignoredecode'             - Only use data orthogonal to decode direction.
%   ''                         - No reduction
decodeInfoIn.classifyReduce = parser.Results.classifyReduce;

% Type of pca
%
% We can do pca on the responses before analyzing.
%   'sdn'                - LIBSVM's pca.
%   'no'                 - Don't do pca.
decodeInfoIn.pcaType = parser.Results.pcaType;
decodeInfoIn.pcaKeep = parser.Results.pcaKeep;

% Type of RF analysis
%   'std'                 - Our standard analysis.
%   'no'                       - Don't do it.
%
% The second one here controls not only plots but also some analyses
% that are naturally associated with those plots.  So it is a bit
% misnamed.  We can indpendently control whether the plots are drawn
% and saved, as just below
decodeInfoIn.rfAnalysisType = parser.Results.rfAnalysisType;
decodeInfoIn.doIndElectrodeRFPlots = parser.Results.doIndElectrodeRFPlots;

% Control whether we dump out individual plots.  This is very time
% consuming so it is nice to turn it off if we just want the summary
% RF analyses
decodeInfoIn.reallyDoIRFPlots = parser.Results.reallyDoIRFPlots;
decodeInfoIn.reallyDoRFPlots = parser.Results.reallyDoRFPlots;

% Use paint, shadow, or both for building decoder?
%
% Not all of these are currently implemented all the way through.
% An informative error should get thrown if you try one that isn't.
%   'both'                    - Build decoder using paint and shadow trials
%   'paint'                   - Build decoder using paint trials only
%   'shadow'                  - Build decoder using shadow trials only
%   'bothbestsingle'          - Build decoder using paint and shadow trials, find and choose best single electrode for decoding intensity.
%   'bothbestdouble'          - Build decoder using paint and shadow trials, find and choose best two electrodes for decoding intensity.
decodeInfoIn.decodeJoint = parser.Results.decodeJoint;

% Numerical value to apply to subtract from shadow intensities before
% decoding.
%
% This is passed as a positive integer, and the passed value
% is divided by 100 here.
decodeInfoIn.decodeOffset = parser.Results.decodeOffset/100;

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

% Control what gets plotted in the summary plots
decodeInfoIn.plotV4Only = parser.Results.plotV4Only;

% What data to read
decodeInfoIn.DATASTYLE = parser.Results.DATASTYLE;

% Paint/shadow fit type
%
% This controls how summarize the inferred matches between
% paint and shadow.  Currently we are using intercept because
% the affine does not appear to be well-identified.
%    'aff'               - Fit inferred match plot with a line with free slope and intercept.
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

% Leave one out type
%   'no'                   - LOO is just non-LOO predictions.
%   'ot'                   - Leave out one trial at a time.
%   'oi'                   - Leave out one intensity at a time.
decodeInfoIn.looType = parser.Results.looType;

% Classify leave one out type
%   'no'                   - LOO is just non-LOO predictions.
%   'ot'                   - Leave out one trial at a time.
%   'kfold'                - K-fold cross-validation
decodeInfoIn.classifyLOOType = parser.Results.classifyLOOType;
decodeInfoIn.classifyKFold = parser.Results.classifyNFolds;

% Exclude SY electrodes
%   'sykp'                    - Keep all electrodes
%   'syexp'                   - Exclude SY peripheral electrodes
%   'syexf'                   - Exclude SY foveal electrodes
decodeInfoIn.excludeSYelectrodes = parser.Results.excludeSYelectrodes;

% Error measure type
% 
% What gets minimized when we train the decoder.
%   'mean'                 - Mean error over trials of same intensity.
%   'median'               - Median error over trials of same intensity.
%
% Note that the median method only affects what
% happens for decoding methods based on fmincon
% search, which is not all of them.
decodeInfoIn.errType = parser.Results.errType;

% Debugging plots?
decodeInfoIn.debugPlots = true;

% Minimum number of trials needed to go forward with a session.
decodeInfoIn.minTrials = parser.Results.minTrials;
decodeInfoIn.filterRangeLower = parser.Results.filterRangeLower;

% Which stimulus intensities to leave out of the analysis.
%
% For 'h' classifier analysis, we restrict to high intensities for
% classification, but not for decoding.
decodeInfoIn.blankIntensity = 105;
decodeInfoIn.leaveOutIntensities = [decodeInfoIn.blankIntensity 0 5 10 15];
decodeInfoIn.minFineGrainedIntensities = 0.20;
switch (decodeInfoIn.classifyType)
    case {'nnh' 'svmh' 'mvmh'}
        decodeInfoIn.leaveOutClassifyIntensities = [decodeInfoIn.blankIntensity 0 5 10 20 25 30 35 40 45];
    otherwise
        decodeInfoIn.leaveOutClassifyIntensities = decodeInfoIn.leaveOutIntensities;
end

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
