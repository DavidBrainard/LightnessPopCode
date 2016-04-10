function decodeInfoOut = RunAndPlotLightnessDecode(filename,rfFilename,decodeInfoIn)
% decodeInfoOut = RunAndPlotLightnessDecode(filename,rfFilename,decodeInfoIn)
%
% Lightness decoder.  Original provided by Doug and Marlene.
%
% 10/28/13  dhb  Started to look through.
% 11/11/13  dhb  Tidy up.
% 2/24/14   dhb  Add intercept only fit option.
% 3/16/14   dhb  Change 'contrast' to 'intensity' everywhere, because that is what we represent currently.
%                But note that we label this as 'luminance' in the plots (it is normalized luminance) and
%                that we may eventually plot in terms of contrast, in which case we'll probably overload
%                the variable name.
%           dhb  Plot intensities on [0-1] scale.
% 3/23/14   dhb  Count good trials after reducing for NaNs.
% 4/20/14   dhb  Started to add RF mapping analyses, based on code provided by Doug.
% 12/19/15  dhb  Fix up SY foveal/peripheral exclusion convention.

%% Basic initialization
close all;

%% Directories
%
% Data assumed to live in subdir xData with in a folder corresponding
% to filename.
condStr = MakePopDecodeConditionStr(decodeInfoIn);
titleStr = strrep(condStr,'_',' ');

switch (decodeInfoIn.DATASTYLE)
    case 'new'
        plotBaseDir = '../../PennOutput/xPlots';
    otherwise
        error('Unknown data style');
end
if (~exist(plotBaseDir,'dir'))
    mkdir(plotBaseDir);
end
plotRootDir = fullfile(plotBaseDir,condStr,'');
if (~exist(plotRootDir,'dir'))
    mkdir(plotRootDir);
end

% Deterimine which type of data to read, the early 'unsorted' files or
% the spike sorted data.  Both are in the same format, so the only
% change needed is to produce the correct filename.
%
% The filename choices are not particularly evokative.
switch (decodeInfoIn.dataType)
    case 'spksrt'
        switch (decodeInfoIn.DATASTYLE)
            case 'new'
                if (exist('IsCluster','file') & IsCluster)
                    dataDir = '/home/dhb/data/LightnessV4/Pitt/Data';
                else
                    dataDir = '/Users1/Shared/Matlab/Experiments/LightnessV4/Pitt/Data';
                end
                reducedDataFilename = fullfile(dataDir,[filename '_ReducedData_Share']);
            otherwise
                error('Unknown data style');
        end
    otherwise
        error('Unknown data file type');
end
theData = load(reducedDataFilename);
fprintf('Working on file %s\n',reducedDataFilename);

%% Fix stimulus position data for cross-session variation in coding conventions
%
% Different conventions for coding the location of
% the stimulus in different lightness runs.  This
% gets patched up here.  There is a field called
% FixPos in the data file, and this tells us where
% the fixation position was, relative to the coordinates
% used to specify the stimulus.  We subtract this from
% the nominal center position of the stimulus to get
% position of the stimulus relative to fixation, which is
% what we care about.  See email from Doug on 8/9/15 for
% more info.
%
% This puts the data in the same frame as the RF data, and
% also makes it correct in terms of absolute position on
% the retina when we convert to degrees.
%
% I am not 100% sure that this field is conistently in the old data files, so
% if this code breaks and you're using old format data files that would be a place to look.
theData.centerX = theData.centerX - theData.FixPos(1);
theData.centerY = theData.centerY - theData.FixPos(2);

%% Get sizes and center locations run in this file.
%
% This was originally done as a bit dark coding magic, as there are
% a number of different cases that we have to suss
% out. The various checks below attempt to make sure
% that we don't do anything too stupid.
%
% The OLDWAY code also does not handle the fact that in some sessions there
% are inverted trials intermixed with non-inverted trials.  But we handle
% that in the new way of doing it below.
OLDWAY = false;
if (OLDWAY)
    theUniqueSizes = unique(theData.sizeX);
    numUniqueSizes = numel(theUniqueSizes);
    theUniqueCenterXs=unique(theData.centerX);
    numCenterXs=numel(theUniqueCenterXs);
    theUniqueCenterYs=unique(theData.centerY);
    numCenterYs=numel(theUniqueCenterYs);
    
    % Check that we understand data format
    if (length(theUniqueSizes) > 1)
        if (length(theUniqueCenterXs) > 1 || length(theUniqueCenterYs) > 1)
            error('Expect only one center location if more than one size');
        end
    end
    if (length(theUniqueCenterXs) ~= length(theUniqueCenterYs))
        if (length(theUniqueCenterXs) > 1 && length(theUniqueCenterYs) == 1)
            theUniqueCenterYs = theUniqueCenterYs*ones(size(theUniqueCenterXs));
        elseif (length(theUniqueCenterYs) > 1 && length(theUniqueCenterXs) == 1)
            theUniqueCenterXs = theUniqueCenterXs*ones(size(theUniqueCenterYs));
        else
            error('Cannot match up center x and y location data');
        end
    end
    if (length(theUniqueCenterXs) > 1)
        if (length(theUniqueSizes) > 1)
            error('Expect only one size if more than one location');
        end
    end
    
    % Get sizes and centers into equally sized arrays
    useSizes = theUniqueSizes;
    if (length(useSizes) > 1)
        useCenterXs = theUniqueCenterXs*ones(size(useSizes));
        useCenterYs = theUniqueCenterYs*ones(size(useSizes));
    else
        useCenterXs = theUniqueCenterXs;
        useCenterYs = theUniqueCenterYs;
    end
    if (length(theUniqueCenterXs) > 1)
        useSizes = theUniqueSizes*ones(size(useCenterXs));
    end
    if (length(useSizes) ~= length(useCenterXs) || length(useSizes) ~= length(useCenterYs))
        error('Logic error in constructing size and center use variables');
    end
    
    % But this way seems much cleaner.
    %
    % Also need to handle case where there are flipped stimulus trials.
else
    % If there is no Letterflip field, then they were all 'g';
    if (isfield(theData,'Letterflip'))
        theLetterflips = double(theData.Letterflip);
    else
        theLetterflips = double('d')*ones(size(theData.sizeX));
    end
    
    theSizesCenterXsCenterYs = [theData.sizeX theData.centerX theData.centerY theLetterflips];
    theUniqueSizesCenterXsCenterYsFlips = unique(theSizesCenterXsCenterYs,'rows');
    useSizes = theUniqueSizesCenterXsCenterYsFlips(:,1);
    useCenterXs = theUniqueSizesCenterXsCenterYsFlips(:,2);
    useCenterYs = theUniqueSizesCenterXsCenterYsFlips(:,3);
    useFlips = char(theUniqueSizesCenterXsCenterYsFlips(:,4));
end

% Get list of whether each trial was paint or shadow
thePaintShadowConditions = floor(theData.suffix/1000);

%% Loop over size and center conditions in the file
%
% We analyze all of them.
for nn1 = 1:length(useSizes)
    OK = true;
    decodeInfoOutTemp = decodeInfoIn;
    decodeInfoOutTemp.filename = filename;
    decodeInfoOutTemp.theCheckerboardSizePixels = useSizes(nn1);
    decodeInfoOutTemp.theCenterXPixels = useCenterXs(nn1);
    decodeInfoOutTemp.theCenterYPixels = useCenterYs(nn1);
    decodeInfoOutTemp.flip = useFlips(nn1);
    decodeInfoOutTemp.theCheckerboardSizeDegs = decodeInfoOutTemp.theCheckerboardSizePixels*decodeInfoOutTemp.degreesPerPixel;
    decodeInfoOutTemp.theCenterXDegs = decodeInfoOutTemp.theCenterXPixels*decodeInfoOutTemp.degreesPerPixel;
    decodeInfoOutTemp.theCenterYDegs = decodeInfoOutTemp.theCenterYPixels*decodeInfoOutTemp.degreesPerPixel;
    decodeInfoOutTemp.theCheckerboardSizePixels = decodeInfoOutTemp.theCheckerboardSizePixels;
    decodeInfoOutTemp.theCenterXPixels = decodeInfoOutTemp.theCenterXPixels;
    decodeInfoOutTemp.theCenterYPixels = decodeInfoOutTemp.theCenterYPixels;
    [~,sizeLocStr] = MakePopDecodeConditionStr(decodeInfoOutTemp);
    titleSizeLocStr = strrep(sizeLocStr,'_',' ');
    
    % Where figures will go
    plotDir = fullfile(plotRootDir,[filename '_' sizeLocStr]);
    if (~exist(plotDir,'dir'))
        mkdir(plotDir);
    end
    figNameRoot = fullfile(plotDir,[filename '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);
    
    % Note that these containing dirs get made even when we don't have any RF data.
    switch (decodeInfoIn.DATASTYLE)
        case 'new'
            rfSummaryDir = fullfile(plotDir,'xRFSummaryStuff');
            rfPlotDir = fullfile(plotDir,'xRFPlots','');
        case 'old'
            rfSummaryDir = fullfile(plotDir,'xRFSummaryStOld');
            rfPlotDir = fullfile(plotDir,'xRFPlOld','');
        otherwise
            error('Unknown data style');
    end
    if (~exist(rfSummaryDir,'dir'))
        mkdir(rfSummaryDir);
    end
    if (~exist(rfPlotDir,'dir'))
        mkdir(rfPlotDir);
    end
    rfSummaryNameRoot = fullfile(rfSummaryDir,[filename '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);
    rfFigNameRoot = fullfile(rfPlotDir,[filename '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);
    
    %% Get indices for the trials we'll analyze
    %
    % Get indices for correct trials
    % Here this refers to whether the monkey maintains
    % fixation for long enough.
    correctIndex = theData.outcome==150;
    
    % Match size and location to passed specification
    paintTrialIndex = find(theData.sizeX==decodeInfoOutTemp.theCheckerboardSizePixels & theData.centerX==decodeInfoOutTemp.theCenterXPixels & theData.centerY==decodeInfoOutTemp.theCenterYPixels & ...
        theLetterflips == decodeInfoOutTemp.flip & correctIndex & thePaintShadowConditions==decodeInfoIn.paintCondition);
    shadowTrialIndex = find(theData.sizeX==decodeInfoOutTemp.theCheckerboardSizePixels & theData.centerX==decodeInfoOutTemp.theCenterXPixels & theData.centerY==decodeInfoOutTemp.theCenterYPixels & ...
        theLetterflips == decodeInfoOutTemp.flip & correctIndex &thePaintShadowConditions==decodeInfoIn.shadowCondition);
    
    %% Turn the stimulus suffices to actual intensities.
    % The intensities end up on a scale from [0-100] which
    % we then convert to [0-1] just below.
    paintIntensities = (theData.suffix(paintTrialIndex)-1000*decodeInfoIn.paintCondition);
    shadowIntensities = (theData.suffix(shadowTrialIndex)-1000*decodeInfoIn.shadowCondition);
    
    %% Get the spike counts for each trial.
    %
    % Doug indicates that the electrode choices are per data file and
    % don't depend on center location or stimulus size, within session.
    % We just check to make sure some things we believe
    % are true of the data format really are true.  Here is what Doug
    % writes about the data file format (March 30, 2014):
    %     First, I spike sort every channel on the array. Sometimes, a
    %     channel has more than one unit on it.
    % 
    %     .numunits is the total number of units from a file. .units tells
    %     you the channel number and the unit number on each channel
    %     (second column).  this always starts at 1. sometimes there is a
    %     second one - that would be numbered 2.
    % 
    %     After that, I perform a statistical test to see if each unit
    %     responded to the stimuli at all (compare the period after the
    %     stimulus came on to the period right before it appeared while the
    %     animal fixated).
    % 
    %     .SpikeCountAll has the responses for all sorted units to all
    %     trials. .SpikeCount has the responses just from channels that
    %     responded significantly to our stimuli.
    % 
    %     .ChListIDX is the index that was used to pare .SpikeCount down
    %     from .SpikeCountAll
    % 
    %     .ChList is the channel name of each unit that passed the test as
    %     well as the sort number (i.e, first unit or second unit).
    % 
    %     .ChList is the  subset of .units that passed our statistical
    %     test.
    % 
    %     Ultimately, we care both what channel the signals came from as
    %     well as what sorted unit it was.
    % 
    %     .ChList or .ChListIDX can both be useful for what you are asking
    %     - it depends if you are starting with .SpikeCountAll or
    %     .SpikeCount in the other file.
    paintResponses = theData.SpikeCount(:,paintTrialIndex)';
    shadowResponses = theData.SpikeCount(:,shadowTrialIndex)';
    
    % Check
    if (any(theData.SpikeCountAll(theData.ChListIDX,paintTrialIndex)' ~= theData.SpikeCount(:,paintTrialIndex)'))
        error('Do not understand data file format');
    end
    if (any(theData.SpikeCountAll(theData.ChListIDX,shadowTrialIndex)' ~= theData.SpikeCount(:,shadowTrialIndex)'))
        error('Do not understand data file format');
    end
    
    % Exclude foveal electrodes for SY if desired.
    switch (decodeInfoIn.excludeSYelectrodes)
        % Keep them all.  Do nothing more.
        case 'sykp'

        % Exclude foveal or peripheral electrodes for SY.  Here is what Doug writes about
        % how to do this (11/9/15):
        %     Array 2 was more foveal than Array 1.  So, our thought is to
        %     see if the results change when we exclude the units that came
        %     from Array 2.  An obvious effect of removing these channels
        %     is that the decoded range should decrease for some (foveal)
        %     stimulus locations.
        % 
        %     There are a couple ways to handle this indexing. My
        %     suggestion is to use 'Array1list' to index the list of all
        %     spike counts  'SpikeCountAll'.
        % 
        %     The trick here is that Array1list  gives the name of the
        %     channels (electrode) on Array 1, but SpikeCountAll has every
        %     sorted unit which includes multiple units from the same
        %     channel (electrode).
        % 
        %     You will want to find the rows (units) in SpikeCountAll that
        %     come from the channels (electrodes) on Array 1.  The variable
        %     'SortedChannels' will help you do that.
        % 
        %     SortedChannels is the same length as SpikeCountAll and has
        %     two columns. column 1 is the electrode (channel) that the
        %     data came from. Column 2 is the sort code (starts at 1 and
        %     increments up).
        % 
        %     So, find the rows with data from the electrodes on array and
        %     index SpikeCountAll with that.
        % Turns out (12/19) that everything in the above is correct except
        % that the array labeling was reversed.
        %     The convention I have used in the SYlayout.mat file is such that :
        %     array 1 contains the more foveal RFs  (ie, channels 8 and 10)
        %     array 2 contains the more eccentric RFs (ie, channels 1 and 4)
        % I verified that the channel numbers in the e.g. match up with the
        % 12/19 statement.
        case 'syexp'
            if (strcmp(decodeInfoIn.subjectStr,'SY'))
                SYarraylayout = load(fullfile(dataDir,'..','SYarraylayout.mat'));
                                
                excludedSpikeCount = [];
                excludedSpikeCountIndex = 0;
                % Go through all of the units in SpikeCountAll and decide
                % whether they were a) ones that responded significantly to
                % the stimuli and b) were on array 1.
                for sc = 1:length(theData.SortedChannels)
                    keepThisOne = true;
                    
                    % Did this channel respond significantly?
                    tempIdx = find(theData.ChListIDX == sc);
                    if (length(tempIdx) == 0)
                        keepThisOne = false;
                    elseif (length(tempIdx) > 1)
                        error('This should not happen');
                    end

                    % Is this channel on array 1?
                    thisElectrodeNum = theData.SortedChannels(sc,1);
                    tempIdx = find(SYarraylayout.Array1list == thisElectrodeNum);
                    if (length(tempIdx) == 0)
                        keepThisOne = false;
                    elseif (length(tempIdx) > 1)
                        error('This should not happen, either');
                    end
                    
                    % Accumulate if its good
                    if (keepThisOne)
                        excludedSpikeCountIndex = excludedSpikeCountIndex + 1;
                        excludedSpikeCount(excludedSpikeCountIndex,:) = theData.SpikeCountAll(sc,:);
                    end
                end
                
                % Pull out paint and shadow trials for this condition
                paintResponses = excludedSpikeCount(:,paintTrialIndex)';
                shadowResponses = excludedSpikeCount(:,shadowTrialIndex)';
            end 
        case 'syexf'
            if (strcmp(decodeInfoIn.subjectStr,'SY'))
                SYarraylayout = load(fullfile(dataDir,'..','SYarraylayout.mat'));

                excludedSpikeCount = [];
                excludedSpikeCountIndex = 0;
                % Go through all of the units in SpikeCountAll and decide
                % whether they were a) ones that responded significantly to
                % the stimuli and b) were on array 1.
                for sc = 1:length(theData.SortedChannels)
                    keepThisOne = true;
                    
                    % Did this channel respond significantly?
                    tempIdx = find(theData.ChListIDX == sc);
                    if (length(tempIdx) == 0)
                        keepThisOne = false;
                    elseif (length(tempIdx) > 1)
                        error('This should not happen');
                    end

                    % Is this channel on array 1?
                    thisElectrodeNum = theData.SortedChannels(sc,1);
                    tempIdx = find(SYarraylayout.Array2list == thisElectrodeNum);
                    if (length(tempIdx) == 0)
                        keepThisOne = false;
                    elseif (length(tempIdx) > 1)
                        error('This should not happen, either');
                    end
                    
                    % Accumulate if its good
                    if (keepThisOne)
                        excludedSpikeCountIndex = excludedSpikeCountIndex + 1;
                        excludedSpikeCount(excludedSpikeCountIndex,:) = theData.SpikeCountAll(sc,:);
                    end
                end
                
                % Pull out paint and shadow trials for this condition
                paintResponses = excludedSpikeCount(:,paintTrialIndex)';
                shadowResponses = excludedSpikeCount(:,shadowTrialIndex)';
            end    
            
        % Uh-oh
        otherwise
            error('Unknown option for excudeSYelectrodes specified');
    end
    
    %% Get classify responses
    switch (decodeInfoIn.classifyType)
        % Use all responses used for the decoding for the classification.
        % Because the decoding doesn't use all responses, some get left out
        % here.
        case {'mvma' 'svma' 'nna'}
            paintIntensitiesClassify = paintIntensities;
            shadowIntensitiesClassify = shadowIntensities;
            paintResponsesClassify = paintResponses;
            shadowResponsesClassify = shadowResponses;
            if (~isempty(decodeInfoIn.leaveOutIntensities))
                for clo = 1:length(decodeInfoIn.leaveOutIntensities)
                    paintIntensitiesClassify(paintIntensitiesClassify==decodeInfoIn.leaveOutIntensities(clo)) = NaN;
                    shadowIntensitiesClassify(shadowIntensitiesClassify==decodeInfoIn.leaveOutIntensities(clo)) = NaN;
                end
                paintResponsesClassify = paintResponses;
                shadowResponsesClassify = shadowResponses;
            end
            
        % Use the only the specified responses for classification. 
        % This code starts with all of them but pulls out a specified list.
        case {'mvmh' 'svmh' 'nnh' }
            paintIntensitiesClassify = paintIntensities;
            shadowIntensitiesClassify = shadowIntensities;
            paintResponsesClassify = paintResponses;
            shadowResponsesClassify = shadowResponses;
            if (~isempty(decodeInfoIn.leaveOutClassifyIntensities))
                for clo = 1:length(decodeInfoIn.leaveOutClassifyIntensities)
                    paintIntensitiesClassify(paintIntensities==decodeInfoIn.leaveOutClassifyIntensities(clo)) = NaN;
                    shadowIntensitiesClassify(shadowIntensities==decodeInfoIn.leaveOutClassifyIntensities(clo)) = NaN;
                end
            end
            
        % Use just the blanks for other cases
        otherwise
            paintIntensitiesClassify = paintIntensities(paintIntensities==decodeInfoIn.blankIntensity);
            shadowIntensitiesClassify = shadowIntensities(shadowIntensities==decodeInfoIn.blankIntensity);
            paintResponsesClassify = paintResponses(paintIntensities==decodeInfoIn.blankIntensity,:);
            shadowResponsesClassify = shadowResponses(shadowIntensities==decodeInfoIn.blankIntensity,:);
    end
    
    
    %% Convert trials we're not using in intensity decoding (typically blanks and decrements) to NaN so that we don't analyze them.
    if (~isempty(decodeInfoIn.leaveOutIntensities))
        for clo = 1:length(decodeInfoIn.leaveOutIntensities)
            paintIntensities(paintIntensities==decodeInfoIn.leaveOutIntensities(clo)) = NaN;
            shadowIntensities(shadowIntensities==decodeInfoIn.leaveOutIntensities(clo)) = NaN;
        end
    end
    
    %% Scale intensities to range 0-1 not 0-100.  More convenient
    % conceptually.
    %
    % Be sure to do this after any filtering of intensities above.
    paintIntensities = paintIntensities/100;
    shadowIntensities = shadowIntensities/100;
    paintIntensitiesClassify = paintIntensitiesClassify/100;
    shadowIntensitiesClassify = shadowIntensitiesClassify/100;
    
    %% Get the actual electrode numbers/units that correspond to
    % each response.  This depends on whether we are using raw
    % or spike sorted data.
    %
    % There is only one set of spike sorting done for each session,
    % so we don't need to handle things separately for different
    % choices of center location and size within session.
    switch (decodeInfoIn.dataType)
        case 'spksrt'
            % Doug writes about the spike sorting:
            %   First, I spike sort every channel on the array. Sometimes, a channel has more than one unit on it.
            %     .numunits is the total number of units from a file.
            %     .units tells you the channel number and the unit number on each channel (second column).
            %   This always starts at 1.sometimes there is a second one - that would be numbered 2
            %   After that, I perform a statistical test to see if each unit responded to the stimuli at all
            %   (compare the period after the stimulus came on to the period right before it appeared while the animal fixated).
            %     .SpikeCountAll has the responses for all sorted units to all trials.
            %     .SpikeCount has the responses just from channels that responded significantly to our stimuli.
            %     .ChListIDX is the index that was used to pare .SpikeCount down from .SpikeCountAll
            %     .ChList is the channel name of each unit that passed the test as well as the sort number
            %     (i.e, first unit or second unit), and represents the  subset of .units that passed our statistical test.
            %   Ultimately, we care both what channel the signals came from as well as what sorted unit it was.
            decodeInfoOutTemp.actualElectrodeNumbers = theData.ChList(:,1);
            decodeInfoOutTemp.actualUnitNumbers = theData.ChList(:,2);
            decodeInfoOutTemp.channelIndex = theData.ChListIDX;
            if (length(decodeInfoOutTemp.actualElectrodeNumbers) ~= size(theData.SpikeCount,1))
                error('Unit numbering inconsistency');
            end
        case 'unsorted'
            if (~strcmp(decodeInfoIn.DATASTYLE,'old'))
                error('Unsorted data analysis only works for old data style');
            end
            % For unsorted data files, the list of electrodes appears to in
            % array GoodChList.
            decodeInfoOutTemp.actualElectrodeNumbers = theData.GoodChList;
            decodeInfoOutTemp.actualUnitNumbers = ones(size(theData.GoodChList));
            decodeInfoOutTemp.channelIndex = 1:length(theData.GoodChList);
            if (length(decodeInfoOutTemp.actualElectrodeNumbers) ~= size(theData.SpikeCount,1))
                error('Do not understand how electrodes are being coded in data file');
            end
        otherwise
            error('Unknown data file type');
    end
    
    %% Get rid of any trials with NaNs
    [paintIntensities,paintResponses] = ReduceForNaNs(paintIntensities,paintResponses);
    [shadowIntensities,shadowResponses] = ReduceForNaNs(shadowIntensities,shadowResponses);
    [paintIntensitiesClassify,paintResponsesClassify] = ReduceForNaNs(paintIntensitiesClassify,paintResponsesClassify);
    [shadowIntensitiesClassify,shadowResponsesClassify] = ReduceForNaNs(shadowIntensitiesClassify,shadowResponsesClassify);
    
    %% Shuffle if desired.  The shuffling propagates through everything.
    [paintIntensities,paintResponses,shadowIntensities,shadowResponses,decodeInfoIn] = PaintShadowShuffle(decodeInfoIn,paintIntensities,paintResponses,shadowIntensities,shadowResponses);
    [paintIntensitiesClassify,paintResponsesClassify,shadowIntensitiesClassify,shadowResponsesClassify,decodeInfoIn] = ...
        PaintShadowShuffle(decodeInfoIn,paintIntensitiesClassify,paintResponsesClassify,shadowIntensitiesClassify,shadowResponsesClassify);
    
    %% PCA if desired.
    [paintResponses,shadowResponses,decodeInfoIn] = PaintShadowPCA(decodeInfoIn,paintResponses,shadowResponses);
    
    %% Save what we want to save for second pass analyses
    decodeInfoOutTemp.paintIntensities = paintIntensities;
    decodeInfoOutTemp.paintResponses = paintResponses;
    decodeInfoOutTemp.shadowIntensities = shadowIntensities;
    decodeInfoOutTemp.shadowResponses = shadowResponses;
    decodeInfoOutTemp.nPaintTrials = length(decodeInfoOutTemp.paintIntensities);
    decodeInfoOutTemp.nShadowTrials = length(decodeInfoOutTemp.shadowIntensities);
    curDir = pwd; cd(plotDir);
    save paintShadowData paintIntensities paintResponses shadowIntensities shadowResponses
    cd(curDir);
    
    %% Check that there are enough trials left to analyze
    if (decodeInfoOutTemp.nPaintTrials < decodeInfoIn.minTrials)
        OK = false;
    end
    if (decodeInfoOutTemp.nShadowTrials < decodeInfoIn.minTrials)
        OK = false;
    end
    
    %% Only process if there are enough good data.
    if (OK)
        fprintf('\tWorking on condition %s\n',titleSizeLocStr);
        
        %% Intensity response functions for paint and shadow for each electrode
        [paintIRFResponses,shadowIRFResponses,paintIRFStes,shadowIRFStes,paintIRFStds,shadowIRFStds,paintIRFIntensities,shadowIRFIntensities,decodeInfoIn] = PaintShadowIntensityResponse(decodeInfoIn,paintIntensities,paintResponses,shadowIntensities,shadowResponses);
        
        %% Decode and predict
        %
        % We do everyting on the LOO return variables, which are not LOO if decodeInfoIn.looType = 'no'.
        %
        % We subtract the offset (generally 0) from the shadow intensities to explore whether decoding
        % to the psychophysics and/or reflectance values changes anything.
        [~,~,paintPredsLOO,shadowPredsLOO,decodeInfoIn] = PaintShadowDecode(decodeInfoIn, ...
            paintIntensities,paintResponses,shadowIntensities-decodeInfoIn.decodeOffset,shadowResponses);
        switch(decodeInfoIn.type)
            case 'betacdf'
                %fprintf('\tBeta cdf A: %0.2f, B: %0.2f, scalar: %0.2f\n',decodeInfoIn.betacdfA,decodeInfoIn.betacdfB,decodeInfoIn.betacdfScale);
            case 'betadoublecdf'
                %fprintf('\tBeta cdf A1: %0.2f, B1: %0.2f, A2: %0.2f, B2: %0.2f, scalar: %0.2f\n',...
                %    decodeInfoIn.betacdfA1,decodeInfoIn.betacdfB1,decodeInfoIn.betacdfA2,decodeInfoIn.betacdfB2,decodeInfoIn.betacdfScale);
        end
        decodeInfoIn.paintLOORMSE = sqrt(mean((paintIntensities(:)-paintPredsLOO(:)).^2));
        decodeInfoIn.shadowLOORMSE = sqrt(mean((shadowIntensities(:)-shadowPredsLOO(:)).^2));
        
        % Save some stuff computed in PaintShadowDecode that we'd like to
        % analyze in the summary analysis.  This doesn't get computed for
        % every possible input settings, so we have some conditionals to
        % make sure it is there.
        if (isfield(decodeInfoIn,'paintShadowDecodeAngle'))
            decodeInfoOutTemp.electrodeWeights = decodeInfoIn.paintElectrodeWeights;
            decodeInfoOutTemp.affineTerms = decodeInfoIn.paintAffineTerms;
            decodeInfoOutTemp.paintElectrodeWeights = decodeInfoIn.paintElectrodeWeights;
            decodeInfoOutTemp.paintAffineTerms = decodeInfoIn.paintAffineTerms;
            decodeInfoOutTemp.shadowElectrodeWeights = decodeInfoIn.shadowElectrodeWeights;
            decodeInfoOutTemp.shadowAffineTerms = decodeInfoIn.shadowAffineTerms;
            decodeInfoOutTemp.paintShadowDecodeAngle = decodeInfoIn.paintShadowDecodeAngle;
        end
        
        %% Get prediction means and standard errors for each intensity
        %[paintPredictMeans,~,~,~,~,paintGroupedIntensities]=sortbyx(paintIntensities,paintPreds);
        %[shadowPredictMeans,shadowPredictSEMs,~,~,~,shadowGroupedIntensities]=sortbyx(shadowIntensities,shadowPreds);
        [paintPredictMeansLOO,paintPredictSEMsLOO,~,~,~,paintGroupedIntensitiesLOO]=sortbyx(paintIntensities,paintPredsLOO);
        [shadowPredictMeansLOO,shadowPredictSEMsLOO,~,~,~,shadowGroupedIntensitiesLOO]=sortbyx(shadowIntensities,shadowPredsLOO);
        
        %% Fit the decoded shadow and paint data with a smooth curve.  Then infer intensity matches.
        %
        % Get min and max of stimulus intensity range studied.  We expect, generally, for these to
        % be the same for paint and shadow, and currently throw an error if they are not.  I don't
        % think any code will break in that case, but it seems to me that the reason the two differ
        % should be looked into so the error condition enforces it for now.
        paintMin = min(paintIntensities); paintMax = max(paintIntensities);
        shadowMin = min(shadowIntensities); shadowMax = max(shadowIntensities);
        if (paintMin ~= shadowMin || paintMax ~= shadowMax)
            error('Same range of stimulus intensities was not used for paint and shadow');
        end
        intensityMin = max([paintMin shadowMin]); intensityMax = min([paintMax shadowMax]);
        if (intensityMin > intensityMax)
            error('This would be a weird condition, so we check for it.');
        end
        fineSpacedIntensities = linspace(intensityMin,intensityMax,decodeInfoIn.nFinelySpacedIntensities)';
        paintLOOFitObject = FitDecodedIntensities(decodeInfoIn,paintGroupedIntensitiesLOO,paintPredictMeansLOO');
        paintLOOSmooth = PredictDecodedIntensities(decodeInfoIn,paintLOOFitObject,fineSpacedIntensities);
        shadowLOOFitObject = FitDecodedIntensities(decodeInfoIn,shadowGroupedIntensitiesLOO,shadowPredictMeansLOO');
        shadowLOOSmooth = PredictDecodedIntensities(decodeInfoIn,shadowLOOFitObject,fineSpacedIntensities);
        [paintLOOMatchesSmooth,shadowLOOMatchesSmooth,paintLOOMatchesDiscrete,shadowLOOMatchesDiscrete,paintLOODecodeDiscrete,shadowLOODecodeDiscrete] = ...
            InferIntensityMatches(decodeInfoIn,paintLOOFitObject,shadowLOOFitObject,intensityMin,intensityMax);
        paintShadowDecodeMeanDifferenceDiscrete = mean(paintLOODecodeDiscrete-shadowLOODecodeDiscrete);
        
        %% Summarize intensity matches with a line through the discrete level matches.
        switch (decodeInfoIn.paintShadowFitType)
            case 'aff'
                paintShadowMbSmooth = [paintLOOMatchesSmooth' ones(length(paintLOOMatchesSmooth),1)]\shadowLOOMatchesSmooth';
                paintShadowMb = [paintLOOMatchesDiscrete' ones(length(paintLOOMatchesDiscrete),1)]\shadowLOOMatchesDiscrete';
                shadowMatchesDiscreteAffinePred = [paintLOOMatchesDiscrete' ones(length(paintLOOMatchesDiscrete),1)]*paintShadowMb;
            case 'intcpt'
                paintShadowMbSmooth = mean(shadowLOOMatchesSmooth') - mean(paintLOOMatchesSmooth');
                paintShadowMb = mean(shadowLOOMatchesDiscrete') - mean(paintLOOMatchesDiscrete');
                shadowMatchesDiscreteAffinePred = paintLOOMatchesDiscrete' + paintShadowMb;
            otherwise
                error('Unknown paint/shadow fit type');
        end
        
        %% Look at intensity versus affine predictions and the fit nonlinear relation between them
        % This comparison is for the full paint data set, so may differ some from what we'd get
        % for the LOO analyses.  Note that the LOO paint predictions themselvels are based on LOO fits
        % of the non-linearity.
        %
        % First get affine predictions, which we don't necessarily have here, then make the comparison
        %
        % This whole section is mainly for debugging the effect of having the non-linearity in the decoder.
        % It might be that is should be computed inside some other routine, or that it should go away
        % eventually.
        decodeInfoTemp = decodeInfoIn;
        decodeInfoTemp.type = 'aff';
        decodeInfoTemp = GetTheDecoderRegressionParams(decodeInfoTemp,paintIntensities,paintResponses);
        affinePreds = DoThePrediction(decodeInfoTemp,paintResponses);
        [paintPredictMeansAffine,~,~,~,~,paintGroupedIntensitiesAffine]=sortbyx(paintIntensities,affinePreds);
        clear affinePreds
        
        nlx = linspace(0,1,100);
        switch (decodeInfoIn.type)
            case {'aff', 'svmreg', 'maxlikely' 'maxlikelyfano' 'mlbayes' 'mlbayesfano'}
                nly = nlx;
            case 'betacdf'
                nly = decodeInfoIn.betacdfScale*betacdf(nlx,decodeInfoIn.betacdfA,decodeInfoIn.betacdfB);
            case 'betadoublecdf'
                nly = decodeInfoIn.betacdfScale*betadouble(betacdf(nlx,decodeInfoIn.betacdfA1,decodeInfoIn.betacdfB1),decodeInfoIn.betacdfA2,decodeInfoIn.betacdfB2);
            case 'smoothing'
                nly = feval(decodeInfoIn.fit,nlx')';
            otherwise
                error('Unknown type specified');
        end
        
        %% Classify and predict
        %
        % If no classifier is specified (decodeInfoIn.classifyType == 'no'), the called routine PaintShadowClassify returns NaNs as the predictions.
        % More generally, PaintShadowClassify handles the classifyType
        % dependencies.
        [~,~,paintClassifyPredsLOO,shadowClassifyPredsLOO,decodeInfoIn] = PaintShadowClassify(decodeInfoIn,paintIntensitiesClassify,paintResponsesClassify,...
            shadowIntensitiesClassify,shadowResponsesClassify);
        paintClassifyLOOPerformance = length(find(paintClassifyPredsLOO == decodeInfoIn.paintLabel))/length(paintClassifyPredsLOO);
        shadowClassifyLOOPerformance = length(find(shadowClassifyPredsLOO == decodeInfoIn.shadowLabel))/length(shadowClassifyPredsLOO);
        
        %% Plots
        SingleSessionSummaryPlots;
        
        %% Fill in some summary info, more is done below
        decodeInfoOutTemp.decodePaintRange = max(paintPredictMeansLOO)-min(paintPredictMeansLOO);
        decodeInfoOutTemp.decodeShadowRange = max(shadowPredictMeansLOO)-min(shadowPredictMeansLOO);
        decodeInfoOutTemp.decodePaintMean = mean(paintPredictMeansLOO);
        decodeInfoOutTemp.decodeShadowMean = mean(shadowPredictMeansLOO);
        decodeInfoOutTemp.paintLOORMSE = decodeInfoIn.paintLOORMSE;
        decodeInfoOutTemp.shadowLOORMSE = decodeInfoIn.shadowLOORMSE;
        
        %% Datavis analysis
        DoDataVisAnalysis;
        
    else
        fprintf('\tNo good data for condition %s\n',titleSizeLocStr);
    end
    
    %% Fill in output summary info
    if (OK)
        % Perhaps all these fields should have LOO in their names, but they don't.
        switch (decodeInfoIn.paintShadowFitType)
            case 'aff'
                decodeInfoOutTemp.decodeSlope = paintShadowMb(1);
                decodeInfoOutTemp.decodeIntercept = paintShadowMb(2);
                decodeInfoOutTemp.decodeSlopeSmooth = paintShadowMbSmooth(1);
                decodeInfoOutTemp.decodeInterceptSmooth = paintShadowMbSmooth(2);
            case 'intcpt'
                decodeInfoOutTemp.decodeSlope = NaN;
                decodeInfoOutTemp.decodeIntercept = paintShadowMb(1);
                decodeInfoOutTemp.decodeSlopeSmooth = NaN;
                decodeInfoOutTemp.decodeInterceptSmooth = paintShadowMbSmooth(1);
            otherwise
                error('Unknown paint/shadow fit type');
        end
        decodeInfoOutTemp.meanPaintMatchesDiscrete = mean(paintLOOMatchesDiscrete);
        decodeInfoOutTemp.meanShadowMatchesDiscrete = mean(shadowLOOMatchesDiscrete);
        decodeInfoOutTemp.paintShadowDecodeMeanDifferenceDiscrete = paintShadowDecodeMeanDifferenceDiscrete;
        decodeInfoOutTemp.paintClassifyLOOPerformance = paintClassifyLOOPerformance;
        decodeInfoOutTemp.shadowClassifyLOOPerformance = shadowClassifyLOOPerformance;
        decodeInfoOutTemp.decodeVis = decodeVis;
    else
        decodeInfoOutTemp.paintLOORMSE = NaN;
        decodeInfoOutTemp.shadowLOORMSE = NaN;
        decodeInfoOutTemp.decodePaintRange = NaN;
        decodeInfoOutTemp.decodeShadowRange = NaN;
        decodeInfoOutTemp.decodePaintMean = NaN;
        decodeInfoOutTemp.decodeShadowMean = NaN;
        switch (decodeInfoIn.paintShadowFitType)
            case 'aff'
                decodeInfoOutTemp.decodeSlope = NaN;
                decodeInfoOutTemp.decodeIntercept = NaN;
                decodeInfoOutTemp.decodeSlopeSmooth = NaN;
                decodeInfoOutTemp.decodeInterceptSmooth = NaN;
            case 'intcpt'
                decodeInfoOutTemp.decodeSlope = NaN;
                decodeInfoOutTemp.decodeIntercept = NaN;
                decodeInfoOutTemp.decodeSlopeSmooth = NaN;
                decodeInfoOutTemp.decodeInterceptSmooth = NaN;
            otherwise
                error('Unknown paint/shadow fit type');
        end
        decodeInfoOutTemp.meanPaintMatchesDiscrete = NaN;
        decodeInfoOutTemp.meanShadowMatchesDiscrete = NaN;
        decodeInfoOutTemp.paintShadowDecodeMeanDifferenceDiscrete = NaN;
        decodeInfoOutTemp.paintClassifyLOOPerformance = NaN;
        decodeInfoOutTemp.shadowClassifyLOOPerformance = NaN;
        decodeInfoOutTemp.decodeVis = NaN;
    end
    clear summaryStructs summaryStructTemp
    
    %% Text summary file for this session.  Report information for each electrode, plus some
    % other things that might be useful to have in the same file.
    switch (decodeInfoOutTemp.pcaType)
        case {'no'}
            nElectrodes = size(paintResponses,2);
            
        case {'sdn'}
            nElectrodes = decodeInfoOutTemp.pcaKeep;
            
        otherwise
            error('Unknown PCA type specified');
    end
    
    for e = 1:nElectrodes
        summaryStructTemp.nominalElectrodeNum = e;
        summaryStructTemp.actualElectrodeNum = decodeInfoOutTemp.actualElectrodeNumbers(e);
        summaryStructTemp.actualUnitNum = decodeInfoOutTemp.actualUnitNumbers(e);
        summaryStructTemp.channelIndex = decodeInfoOutTemp.channelIndex(e);
        
        % What we save depends on decoding type info as well as whether there
        % was sufficient data to analyze at all.
        if (OK)
            summaryStructTemp.enoughData = 'yes';
            
            % Type specific info
            switch (decodeInfoIn.type)
                case {'aff'}
                    switch (decodeInfoIn.decodeJoint)
                        case {'both'}
                            if (length(decodeInfoIn.electrodeWeights) ~= nElectrodes)
                                error('Mismatch in number of electrodes count');
                            end
                            summaryStructTemp.bestSingleElectrode = NaN;
                            summaryStructTemp.bestSecondElectrode = NaN;
                            summaryStructTemp.electrodeWeight = decodeInfoIn.electrodeWeights(e);
                            summaryStructTemp.affineTerm = decodeInfoIn.affineTerms(e);
                        case {'bothbestsingle'}
                            if (length(decodeInfoIn.electrodeWeights) ~= nElectrodes)
                                error('Mismatch in number of electrodes count');
                            end
                            summaryStructTemp.bestSingleElectrode = decodeInfoIn.bestJ;
                            summaryStructTemp.bestSecondElectrode = NaN;
                            summaryStructTemp.electrodeWeight = decodeInfoIn.electrodeWeights(e);
                            summaryStructTemp.affineTerms = decodeInfoIn.affineTerms(e);
                        case {'bothbestdouble'}
                            summaryStructTemp.bestSingleElectrode = decodeInfoIn.bestJ;
                            summaryStructTemp.bestSecondElectrode = decodeInfoIn.bestK;
                        otherwise
                    end
            end
        else
            summaryStructTemp.enoughData = 'no';
            switch (decodeInfoIn.type)
                case {'aff'}
                    summaryStruct.bestElectrode = NaN;
                    summaryStructTemp.electrodeWeight = NaN;
                    summaryStructTemp.affineTerm = NaN;
                otherwise
            end
        end
        
        % This info OK whether we decoded or not
        summaryStructTemp.dataType = decodeInfoOutTemp.dataType;
        summaryStructTemp.type = decodeInfoOutTemp.type;
        summaryStructTemp.pcaType = decodeInfoOutTemp.pcaType;
        summaryStructTemp.pcaKeep = decodeInfoOutTemp.pcaKeep;
        summaryStructTemp.decodedIntensityFitType = decodeInfoOutTemp.decodedIntensityFitType;
        summaryStructTemp.paintShadowFitType = decodeInfoOutTemp.paintShadowFitType;
        summaryStructTemp.looType = decodeInfoOutTemp.looType;
        summaryStructTemp.errType = decodeInfoOutTemp.errType;
        summaryStructTemp.arrayPosition = decodeInfoOutTemp.titleInfoStr;
        summaryStructTemp.theCheckerboardSizeDegs = decodeInfoOutTemp.theCheckerboardSizeDegs;
        summaryStructTemp.theCenterXDegs = decodeInfoOutTemp.theCenterXDegs;
        summaryStructTemp.theCenterYDegs = decodeInfoOutTemp.theCenterYDegs;
        summaryStructTemp.theCheckerboardSizePixels = decodeInfoOutTemp.theCheckerboardSizePixels;
        summaryStructTemp.theCenterXPixels = decodeInfoOutTemp.theCenterXPixels;
        summaryStructTemp.theCenterYPixels = decodeInfoOutTemp.theCenterYPixels;
        summaryStructTemp.paintCondition = decodeInfoOutTemp.paintCondition;
        summaryStructTemp.shadowCondition = decodeInfoOutTemp.shadowCondition;
        summaryStructTemp.nPaintTrials = decodeInfoOutTemp.nPaintTrials;
        summaryStructTemp.nShadowTrials = decodeInfoOutTemp.nShadowTrials;
        summaryStructTemp.decodePaintRange = decodeInfoOutTemp.decodePaintRange;
        summaryStructTemp.decodeShadowRange = decodeInfoOutTemp.decodeShadowRange;
        summaryStructTemp.paintLOORMSE = decodeInfoOutTemp.paintLOORMSE;
        summaryStructTemp.shadowLOORMSE = decodeInfoOutTemp.shadowLOORMSE;
        summaryStructTemp.decodePaintMean = decodeInfoOutTemp.decodePaintMean;
        summaryStructTemp.decodeShadowMean = decodeInfoOutTemp.decodeShadowMean;
        summaryStructTemp.paintShadowDecodeMeanDifferenceDiscrete = decodeInfoOutTemp.paintShadowDecodeMeanDifferenceDiscrete;
        summaryStructTemp.decodeSlope = decodeInfoOutTemp.decodeSlope;
        summaryStructTemp.decodeIntercept = decodeInfoOutTemp.decodeIntercept;
        summaryStructTemp.paintClassifyLOOPerformance = decodeInfoOutTemp.paintClassifyLOOPerformance;
        summaryStructTemp.shadowClassifyLOOPerformance = decodeInfoOutTemp.shadowClassifyLOOPerformance;
        summaryStructs(e) = summaryStructTemp;
    end
    summaryFilename = [figNameRoot '_summary.txt'];
    WriteStructsToText(summaryFilename,summaryStructs);
    
    %% RF analyses happen here, if we have RF data
    %
    % See if there is data.  Here we count on a fixed format
    % for basic filenames: monkey initials (2 chars) followed
    % by numerical date (6 chars).
    %
    % This is set up so that we can specify a path to RF information
    % collected on another day if we want.  By default this is empty
    % and causes us to find the RF info in the same directory as the
    % lightness data.  Writing code that crosses days is a little tricky
    % because we have to worry that the sorting may not have come out
    % quite the same.
    
    % Don't do RF analysis if there was no other data to look at
    if (OK)
        
        % Set this to zero so there is a value there even if we don't do RF analysis
        decodeInfoOutTemp.weightedIRFSpikeDiffDifference = 0;
        
        % Now deal with things
        switch(decodeInfoIn.rfAnalysisType)
            case 'std'
                % Electrode info from lightness data
                actualElectrodeNums = [summaryStructs.actualElectrodeNum];
                actualUnitNums = [summaryStructs.actualUnitNum];
                channelIndices = [summaryStructs.channelIndex];
                
                switch (decodeInfoIn.DATASTYLE)
                    case 'new'
                        theRFDataFilename = fullfile(dataDir,rfFilename);
                        if (strcmp(rfFilename,'no'))
                            theRFData = [];
                            DORFANALYSIS = false;
                        else
                            theRFData = load(theRFDataFilename);
                            DORFANALYSIS = true;
                            
                            if (decodeInfoIn.sameDayRF)
                                % Check that sameDayRF field matches up with
                                % filename prefixes.  This should always be
                                % true.
                                if (~strcmp(filename(1:8),rfFilename(1:8)))
                                    error('RF same day filename inconsistency');
                                end
                                
                                % Check spike sorting consistency between RF
                                % and lightness data.  There might be a more
                                % sophisticaed way to do this.
                                sortingDifference = theData.ChList-theRFData.channels(channelIndices,:);
                                if (~max(abs(sortingDifference)) == 0)
                                    error('Spike sorting inconsistency for same day RF data');
                                end
                            end
                        end
                    case 'old'
                        theRFDataFilename = 'no';
                        theRFData = [];
                        DORFANALYSIS = false;
                    otherwise
                        error('Unkown data style');
                end
                
                % IRF plots.  I think this is under the RF plot section because
                % it gives us spike rates in a form that we can use to weight
                % individual units when we are thinking about RF structure.
                if (decodeInfoIn.doIndElectrodeRFPlots)
                    wgtSummaryStructs = [];
                    wgtSummaryAbsWeights = [];
                    minIntensitySpikes = [];
                    maxIntensitySpikes = [];
                    spikeRange = [];
                    meanStds = [];
                    meanSnr = [];
                    meanPaintIRFSpikes = [];
                    meanShadowIRFSpikes = [];
                    for ci = 1:length(paintIRFIntensities)
                        % Get min and max spike rates for this units IRF
                        minIntensitySpikes(ci) = mean([paintIRFResponses{ci}(1) shadowIRFResponses{ci}(1)]);
                        maxIntensitySpikes(ci) = mean([paintIRFResponses{ci}(end) ; shadowIRFResponses{ci}(end)]);
                        spikeRange(ci) = maxIntensitySpikes(ci)-minIntensitySpikes(ci);
                        meanStds(ci) = mean([paintIRFStds{ci}(:) ; shadowIRFStds{ci}(:)]);
                        meanSnr(ci) = abs(spikeRange(ci))/meanStds(ci);
                        meanPaintIRFSpikes(ci) = mean(paintIRFResponses{ci}(:));
                        meanShadowIRFSpikes(ci) = mean(shadowIRFResponses{ci}(:));
                        
                        % Make a plot of this unit's IRF
                        if (decodeInfoIn.reallyDoIRFPlots)
                            irfFig = figure; clf; hold on
                            set(gcf,'Position',decodeInfoIn.sqPosition);
                            set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
                            hold on;
                            h=errorbar(paintIRFIntensities{ci}, paintIRFResponses{ci}, paintIRFStes{ci}, paintPredictSEMsLOO, 'go');
                            set(h,'MarkerFaceColor','g','MarkerSize',decodeInfoIn.markerSize);
                            h=errorbar(shadowIRFIntensities{ci}, shadowIRFResponses{ci}, shadowIRFStes{ci}, shadowPredictSEMsLOO, 'ko');
                            set(h,'MarkerFaceColor','k','MarkerSize',decodeInfoIn.markerSize);
                            plot(paintIRFIntensities{ci},paintIRFResponses{ci},'go','MarkerFaceColor','g','MarkerSize',decodeInfoIn.markerSize);
                            plot(paintIRFIntensities{ci},paintIRFResponses{ci},'g','LineWidth',decodeInfoIn.lineWidth');
                            plot(shadowIRFIntensities{ci},shadowIRFResponses{ci},'ko','MarkerFaceColor','k','MarkerSize',decodeInfoIn.markerSize);
                            plot(shadowIRFIntensities{ci},shadowIRFResponses{ci},'k','LineWidth',decodeInfoIn.lineWidth');
                            h = legend({'Paint','Shadow'},4,'FontSize',decodeInfoIn.legendFontSize,'Location','NorthWest');
                            lfactor = 0.5;
                            lpos = get(h,'Position'); set(h,'Position',[lpos(1) lpos(2)-lfactor*lpos(4) (1+lfactor)*lpos(3) (1+lfactor)*lpos(4)]);
                            xlabel('Disk Luminance','FontSize',decodeInfoIn.labelFontSize);
                            ylabel('Response (spikes/sec)','FontSize',decodeInfoIn.labelFontSize);
                            title({titleRootStr{:}  ['Electrode ' num2str(actualElectrodeNums(ci)) ' Unit ' num2str(actualUnitNums(ci)) ' RF'] [' ']}','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.titleFontSize);
                            axis([decodeInfoIn.intensityLimLow decodeInfoIn.intensityLimHigh decodeInfoIn.spikeLimLow decodeInfoIn.spikeLimHigh]);
                            set(gca,'XTick',decodeInfoIn.intensityTicks,'XTickLabel',decodeInfoIn.intensityTickLabels);
                            set(gca,'YTick',decodeInfoIn.spikeTicks,'YTickLabel',decodeInfoIn.spikeTickLabels);
                            axis square
                            drawnow;
                            figName = [rfFigNameRoot '_Electrode' num2str(actualElectrodeNums(ci)) '_Unit' num2str(actualUnitNums(ci)) '_IRF'];
                            FigureSave(figName,irfFig,decodeInfoIn.figType);
                            close(irfFig);
                        end
                        
                        % Build up summary structure
                        wgtSummaryAbsWeights(ci) = abs(decodeInfoIn.electrodeWeights(ci));
                        wgtSummaryStructs(ci).AbsWeight = wgtSummaryAbsWeights(ci);
                        wgtSummaryStructs(ci).Weight = decodeInfoIn.electrodeWeights(ci);
                        wgtSummaryStructs(ci).nominalElectrodeNum = ci;
                        wgtSummaryStructs(ci).actualElectrodeNum = num2str(actualElectrodeNums(ci));
                        wgtSummaryStructs(ci).actualUnitNum = num2str(actualUnitNums(ci));
                        wgtSummaryStructs(ci).minItensitySpikes = minIntensitySpikes(ci);
                        wgtSummaryStructs(ci).maxIntensitySpikes = maxIntensitySpikes(ci);
                        wgtSummaryStructs(ci).spikeRange = spikeRange(ci);
                        wgtSummaryStructs(ci).meanStds = meanStds(ci);
                        wgtSummaryStructs(ci).meanSnr = meanSnr(ci);
                        wgtSummaryStructs(ci).meanPaintIRFSpikes = meanPaintIRFSpikes(ci);
                        wgtSummaryStructs(ci).meanShadowIRFSpikes = meanShadowIRFSpikes(ci);
                        wgtSummaryStructs(ci).meanIRFSpikeDiff = meanPaintIRFSpikes(ci)-meanShadowIRFSpikes(ci);
                    end
                    
                    % Compute electrode weighted paint-shadow spike difference
                    decodeInfoOutTemp.weightedIRFSpikeDifference = [wgtSummaryStructs(:).Weight]*(meanPaintIRFSpikes-meanShadowIRFSpikes)';
                    
                    % Write out summary structure that links weights to IRF plots and RF plots
                    [~,index] = sort(wgtSummaryAbsWeights,2,'descend');
                    WriteStructsToText([rfSummaryNameRoot '_WgtSummary' '.txt'],wgtSummaryStructs(index));
                    
                    % Plot relation between electrode weight and decoded range.
                    wgtVRangeFig = figure; clf; hold on;
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
                    plot(spikeRange,[wgtSummaryStructs(:).Weight],  'ro','LineWidth',2,'MarkerSize',4,'MarkerFaceColor','r');
                    xlabel('Electrode Response Range','FontSize',decodeInfoIn.labelFontSize);
                    ylabel('Electrode Weight','FontSize',decodeInfoIn.labelFontSize);
                    axis square
                    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
                    figName = [rfSummaryNameRoot '_wgtVRange'];
                    drawnow;
                    FigureSave(figName,wgtVRangeFig,decodeInfoIn.figType);
                    
                    % Plot relation between electrode weight and electrode snr.
                    wgtVSNRFig = figure; clf; hold on;
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
                    plot(meanSnr,abs([wgtSummaryStructs(:).Weight]),'ro','LineWidth',2,'MarkerSize',4,'MarkerFaceColor','r');
                    xlabel('Electrode SNR','FontSize',decodeInfoIn.labelFontSize);
                    ylabel('Absolute Electrode Weight','FontSize',decodeInfoIn.labelFontSize);
                    axis square
                    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
                    figName = [rfSummaryNameRoot '_wgtVSNR'];
                    drawnow;
                    FigureSave(figName,wgtVRangeFig,decodeInfoIn.figType);
                    
                    % Plot paint shadow difference in the IRFs versus electrode weight.
                    spikeDiffVWgtFig = figure; clf; hold on;
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);
                    plot(([wgtSummaryStructs(:).Weight]),meanPaintIRFSpikes-meanShadowIRFSpikes,'ro','LineWidth',2,'MarkerSize',decodeInfoIn.markerSize,'MarkerFaceColor','r');
                    plot(([wgtSummaryStructs(:).Weight]),zeros(size([wgtSummaryStructs(:).Weight])),'k:','LineWidth',1);
                    plot([0 0],[min(meanPaintIRFSpikes-meanShadowIRFSpikes) max(meanPaintIRFSpikes-meanShadowIRFSpikes)],'k:','LineWidth',1);
                    xlabel('Electrode Weight','FontSize',decodeInfoIn.labelFontSize);
                    ylabel('Paint-Shadow Mean Spike Rate','FontSize',decodeInfoIn.labelFontSize);
                    %ylim([-20 20]);
                    axis square
                    title(titleRootStr,'FontSize',decodeInfoIn.titleFontSize);
                    figName = [rfSummaryNameRoot '_spikeDiffVWgt'];
                    drawnow;
                    FigureSave(figName,spikeDiffVWgtFig,decodeInfoIn.figType);
                end
                
                % If we have RF data, then we do the RF analysis
                if (DORFANALYSIS)
                    % Can check a second list of good channels for old style
                    % data, but this isn't available with the new style.  That
                    % seems OK because the consistency check never failed with
                    % the old data.
                    switch (decodeInfoIn.DATASTYLE)
                        case 'new'
                        case 'old'
                            error('Should not be here, because we are not doing RF analysis with old data style.');
                        otherwise
                            error('Unkown data style');
                    end
                    
                    % Get the rf structure on each spikesorted RF unit
                    %
                    % We get this info whether or not the RF data lines up
                    % unit by unit with the lightness data.
                    theRFChannelInfo = theRFData.channels;
                    nGoodLightnessChannels = length(channelIndices);
                    for ci = 1:nGoodLightnessChannels
                        
                        % Clear flag, just to make sure we always take a path through
                        % the conditionals below that sets it.
                        clear doThisRF
                        
                        % If the RF data are from the same day, then there
                        % should be perfect agreement in the spike sorting and
                        % we check that because that's the kind of people we
                        % are.
                        if (decodeInfoIn.sameDayRF)
                            channelIndex = channelIndices(ci);
                            if (theRFChannelInfo(channelIndex,1) ~= actualElectrodeNums(ci))
                                error('Electrode number identity inconsistency');
                            end
                            if (theRFChannelInfo(channelIndex,2) ~= actualUnitNums(ci))
                                error('Unit number identity inconsistency');
                            end
                            doThisRF = true;
                            
                            % Otherwise, we find the channel that corresponds to
                            % the same electrode and unit.  And if there is no
                            % matching electrode with the same unit, just use the same electrode.
                            %                    %
                            % This could cause us to count the same
                            % data from one electrode more than once in the
                            % population RF, but I think that is OK and as sensbile
                            % as anything else.
                            %
                            % And if we don't have the same electrode, don't
                            % compute RF for this electrode.  We can still charge
                            % on to compute an average population RF for the
                            % electrodes we have.
                        else
                            channelIndex = find(theRFData.channels(:,1) == actualElectrodeNums(ci) & ...
                                theRFData.channels(:,2) == actualUnitNums(ci));
                            if (length(channelIndex) == 1)
                                doThisRF = true;
                            elseif (length(channelIndex) > 1)
                                error('More than one electrode/unit match.  Should not happen');
                            elseif (length(channelIndex) == 0)
                                channelIndex = find(theRFData.channels(:,1) == actualElectrodeNums(ci));
                                if (length(channelIndex) == 1)
                                    doThisRF = true;
                                elseif (length(channelIndex) > 1)
                                    error('Need to handle this case, no matching unit but more than one unit on electrode');
                                elseif (length(channelIndex) == 0)
                                    % This electrode isn't good in the RF
                                    % matching data, so don't compute for it.
                                    doThisRF = false;
                                end
                            end
                        end
                        
                        % Get the RF for this lightness electrode/unit, if we have good data.
                        if (doThisRF)
                            decodeInfoOutTemp.theRFGridMapStructs{ci} = GetRFGridMap(channelIndex,theRFData);
                            if (decodeInfoIn.doIndElectrodeRFPlots & decodeInfoIn.reallyDoRFPlots)
                                % Make a plot of this unit grid
                                gridFig = figure; clf; hold on;
                                set(gcf,'Position',decodeInfoIn.sqPosition);
                                set(gca,'FontName','Helvetica','FontSize',decodeInfoIn.axisFontSize);
                                %imagesc(theRFGridMapStructs{ci}.xPositions,theRFGridMapStructs{ci}.yPositions,theRFGridMapStructs{ci}.thisgrid);
                                imagesc(theRFGridMapStructs{ci}.xPositions,theRFGridMapStructs{ci}.yPositions,theRFGridMapStructs{ci}.thisgrid, ...
                                    [decodeInfoIn.spikeLimLow decodeInfoIn.spikeLimHigh]);
                                set(gca,'Ydir','normal')
                                colormap jet
                                colorbar
                                axis('square');
                                title({titleRootStr{:} ['Electrode ' num2str(actualElectrodeNums(ci)) ' Unit ' num2str(actualUnitNums(ci)) ' RF']}','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.titleFontSize);
                                %text(summaryStructs(1).theCenterXPixels,summaryStructs(1).theCenterYPixels,'X','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.rfXFontSize);
                                stimBottomLeftCornerX = summaryStructs(1).theCenterXPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                                stimBottomLeftCornerY = summaryStructs(1).theCenterYPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                                rectangle('Position',[stimBottomLeftCornerX,stimBottomLeftCornerY,summaryStructs(1).theCheckerboardSizePixels,summaryStructs(1).theCheckerboardSizePixels])
                                xlim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]); ylim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]);
                                drawnow;
                                figName = [rfFigNameRoot '_Electrode' num2str(actualElectrodeNums(ci)) '_Unit' num2str(actualUnitNums(ci)) '_RF'];
                                FigureSave(figName,gridFig,decodeInfoIn.figType);
                                plot(summaryStructs(1).theCenterXPixels,summaryStructs(1).theCenterYPixels,'ko','MarkerSize',12,'MarkerFaceColor','k');
                                drawnow;
                                figName = [rfFigNameRoot '_Electrode' num2str(actualElectrodeNums(ci)) '_Unit' num2str(actualUnitNums(ci)) '_DOT'];
                                FigureSave(figName,gridFig,decodeInfoIn.figType);
                                close(gridFig);
                            end
                        else
                            decodeInfoOutTemp.theRFGridMapStructs{ci} = [];
                        end
                    end
                    
                    % Analyze the population RFs and make/save some pretty pictures.
                    %
                    % There are various ways to normalize.  Unnormalized, which
                    % is just in terms of the actual spikes on each unit, seems
                    % most sensible to em right now, for a population RF.
                    decodeInfoOutTemp.populationRFUnweightedUnnormalized = zeros(decodeInfoOutTemp.theRFGridMapStructs{1}.nY,decodeInfoOutTemp.theRFGridMapStructs{1}.nX);
                    decodeInfoOutTemp.populationRFUnweightedNormalized = zeros(decodeInfoOutTemp.theRFGridMapStructs{1}.nY,decodeInfoOutTemp.theRFGridMapStructs{1}.nX);
                    decodeInfoOutTemp.locationcounts = {};
                    nGoodRFChannels = 0;
                    for ci = 1:nGoodLightnessChannels
                        if (~isempty(decodeInfoOutTemp.theRFGridMapStructs{ci}))
                            % Bump counter of number of channels where we have
                            % data.
                            nGoodRFChannels = nGoodRFChannels + 1;
                            
                            % Accumulate all trials spike counts at each
                            % location into a cell array.
                            for xx = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nX
                                for yy = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nY
                                    decodeInfoOutTemp.locationcounts{yy,xx,nGoodRFChannels} = ...
                                        decodeInfoOutTemp.theRFGridMapStructs{ci}.locationcounts{yy,xx};
                                end
                            end
                            
                            % Sum average rates at each location
                            decodeInfoOutTemp.populationRFUnweightedUnnormalized = decodeInfoOutTemp.populationRFUnweightedUnnormalized + ...
                                decodeInfoOutTemp.theRFGridMapStructs{ci}.thisgrid;
                            decodeInfoOutTemp.populationRFUnweightedNormalized = decodeInfoOutTemp.populationRFUnweightedNormalized + ...
                                decodeInfoOutTemp.theRFGridMapStructs{ci}.normgrid ;
                        end
                    end
                    decodeInfoOutTemp.populationRFUnweightedUnnormalized = decodeInfoOutTemp.populationRFUnweightedUnnormalized/nGoodRFChannels;
                    decodeInfoOutTemp.populationRFUnweightedNormalized = decodeInfoOutTemp.populationRFUnweightedNormalized/nGoodRFChannels;
                    
                    % Decide whether each location produces a significant
                    % response or not.  Use least responsive location as a proxy
                    % for the baseline response, and then ask whether each other location
                    % produces a statistically different response than we obtained at
                    % that location.
                    %
                    % First find least responsive location, assessed in terms
                    % of average response over electrodes.
                    minLocationResponse = Inf;
                    minLocationX = [];
                    minLocationY = [];
                    for xx = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nX
                        for yy = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nY
                            if (decodeInfoOutTemp.populationRFUnweightedUnnormalized(yy,xx) < minLocationResponse)
                                minLocationResponse = decodeInfoOutTemp.populationRFUnweightedUnnormalized(yy,xx);
                                minLocationX = xx;
                                minLocationY = yy;
                            end
                        end
                    end
                    
                    % Get trial-by-trial average accross electrodes, so that we
                    % can do a sensible statistical test.
                    %
                    % Note that on some trials run, the monkey failed to fixate,
                    % etc.  These are coded as NaN and we need to exclude these
                    % trials.
                    for xx = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nX
                        for yy = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nY
                            % Check that number of trials is same on all
                            % electrodes for a given location.  A failure here
                            % would reveal something about the data format that
                            % I don't understand.
                            nLocationTrials(yy,xx) = length(decodeInfoOutTemp.locationcounts{yy,xx,1});
                            for ll = 1:nGoodRFChannels
                                if (length(decodeInfoOutTemp.locationcounts{yy,xx,ll}) ~= nLocationTrials(yy,xx))
                                    error('Number of trials at location not consistent across electrodes');
                                end
                            end
                            
                            % Get summed spike count over electrodes on each
                            % trial for each location.  Exclude bad trials.
                            nGoodLocationTrials(yy,xx) = 0;
                            for tt = 1:nLocationTrials(yy,xx)
                                for ll = 1:nGoodRFChannels
                                    % If there is a NaN, it should mean that a
                                    % trial is bad, so it should be bad on all
                                    % the electrodes.  Check this to make sure
                                    % everything makes sense.
                                    if (isnan(decodeInfoOutTemp.locationcounts{yy,xx,ll}(tt)))
                                        for ll1 = 1:nGoodRFChannels
                                            if (~isnan(decodeInfoOutTemp.locationcounts{yy,xx,ll1}(tt)))
                                                error('Trial coded bad on one electrode but not on another');
                                            end
                                        end
                                        
                                        % If there isn't a NaN, accumulate over electrodes for this trial.
                                    else
                                        if (ll == 1)
                                            nGoodLocationTrials(yy,xx) = nGoodLocationTrials(yy,xx) + 1;
                                            sumLocationSpikes{yy,xx}(nGoodLocationTrials(yy,xx)) = ...
                                                decodeInfoOutTemp.locationcounts{yy,xx,ll}(tt);
                                            
                                        else
                                            sumLocationSpikes{yy,xx}(nGoodLocationTrials(yy,xx)) = ...
                                                sumLocationSpikes{yy,xx}(nGoodLocationTrials(yy,xx)) + ...
                                                decodeInfoOutTemp.locationcounts{yy,xx,ll}(tt);
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    % Now do t-tests as to whether the spikes for a location
                    % differ significantly from the minimum location.
                    % Use a Bonferonni corrected p-value to determine
                    % significance, based on number of locations.
                    decodeInfoOutTemp.basePVal = 0.05;
                    decodeInfoOutTemp.criticalPVal = decodeInfoOutTemp.basePVal/(decodeInfoOutTemp.theRFGridMapStructs{1}.nX*decodeInfoOutTemp.theRFGridMapStructs{1}.nY);
                    decodeInfoOutTemp.locationSigVals = zeros(decodeInfoOutTemp.theRFGridMapStructs{1}.nY,decodeInfoOutTemp.theRFGridMapStructs{1}.nX);
                    decodeInfoOutTemp.locationSigMap = zeros(decodeInfoOutTemp.theRFGridMapStructs{1}.nY,decodeInfoOutTemp.theRFGridMapStructs{1}.nX);
                    decodeInfoOutTemp.nSigRFLocatons = 0;
                    for xx = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nX
                        for yy = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nY
                            [~,decodeInfoOutTemp.locationSigVals(yy,xx)] = ttest2(sumLocationSpikes{yy,xx},sumLocationSpikes{minLocationY,minLocationX});
                            if (decodeInfoOutTemp.locationSigVals(yy,xx) < decodeInfoOutTemp.criticalPVal)
                                decodeInfoOutTemp.locationSigMap(yy,xx) = 1;
                                decodeInfoOutTemp.nSigRFLocatons = decodeInfoOutTemp.nSigRFLocatons + 1;
                            end
                        end
                    end
                    
                    % Collect some statistics about relation between sigificant
                    % locations and the stimulus.
                    decodeInfoOutTemp.minRFDistToStimCenter = Inf;
                    for xx = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nX
                        for yy = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nY
                            if (decodeInfoOutTemp.locationSigVals(yy,xx))
                                RFDistToStimCenter = sqrt((...
                                    (decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions(xx)-decodeInfoOutTemp.theCenterXPixels)^2 + ...
                                    (decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions(yy)-decodeInfoOutTemp.theCenterYPixels)^2 ...
                                    ));
                                if (RFDistToStimCenter < decodeInfoOutTemp.minRFDistToStimCenter)
                                    decodeInfoOutTemp.minRFDistToStimCenter = RFDistToStimCenter;
                                end
                            end
                        end
                    end
                    
                    % Make plot of location significance map.
                    %
                    % Note the call to set for 'Ydir, to fix the weird y-axis direction that is Matlab's imagesc plotting default.
                    rfSigFig = figure; clf; hold on
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName','Helvetica','FontSize',decodeInfoIn.axisFontSize);
                    imagesc(decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions,decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions,0*decodeInfoOutTemp.populationRFUnweightedUnnormalized)
                    set(gca,'Ydir','normal')
                    colormap jet
                    colorbar
                    for xx = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nX
                        for yy = 1:decodeInfoOutTemp.theRFGridMapStructs{1}.nY
                            if (decodeInfoOutTemp.locationSigMap(yy,xx))
                                plot(decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions(xx), ...
                                    decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions(yy), ...
                                    'ro','MarkerFaceColor','r','MarkerSize',decodeInfoIn.markerSize-14);
                            end
                        end
                    end
                    axis('square');
                    title({titleRootStr{:} 'Population RF Unweighted Unnormalized'}','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.titleFontSize);
                    text(summaryStructs(1).theCenterXPixels,summaryStructs(1).theCenterYPixels,'X','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.rfXFontSize)
                    stimBottomLeftCornerX = summaryStructs(1).theCenterXPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    stimBottomLeftCornerY = summaryStructs(1).theCenterYPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    rectangle('Position',[stimBottomLeftCornerX,stimBottomLeftCornerY,summaryStructs(1).theCheckerboardSizePixels,summaryStructs(1).theCheckerboardSizePixels])
                    xlim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]); ylim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]);
                    drawnow;
                    figName = [rfFigNameRoot '_LocationSigMap'];
                    FigureSave(figName,rfSigFig,decodeInfoIn.figType);
                    
                    % Make plot of population RF as well as of where
                    % checkerboard falls on them. Unnormalized version.
                    %
                    % Note the call to set for 'Ydir, to fix the weird y-axis direction that is Matlab's imagesc plotting default.
                    popFig = figure; clf;
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName','Helvetica','FontSize',decodeInfoIn.axisFontSize);
                    imagesc(decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions,decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions,decodeInfoOutTemp.populationRFUnweightedUnnormalized)
                    set(gca,'Ydir','normal')
                    colormap jet
                    colorbar
                    axis('square');
                    title({titleRootStr{:} 'Population RF Unweighted Unnormalized'}','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.titleFontSize);
                    text(summaryStructs(1).theCenterXPixels,summaryStructs(1).theCenterYPixels,'X','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.rfXFontSize)
                    stimBottomLeftCornerX = summaryStructs(1).theCenterXPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    stimBottomLeftCornerY = summaryStructs(1).theCenterYPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    rectangle('Position',[stimBottomLeftCornerX,stimBottomLeftCornerY,summaryStructs(1).theCheckerboardSizePixels,summaryStructs(1).theCheckerboardSizePixels])
                    xlim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]); ylim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]);
                    drawnow;
                    figName = [rfFigNameRoot '_RFUwgtUnrm'];
                    FigureSave(figName,popFig,decodeInfoIn.figType);
                    
                    % Normalized
                    popFig = figure; clf;
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName','Helvetica','FontSize',decodeInfoIn.axisFontSize);
                    imagesc(decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions,decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions,decodeInfoOutTemp.populationRFUnweightedNormalized)
                    set(gca,'Ydir','normal')
                    colormap jet
                    colorbar
                    axis('square');
                    title({titleRootStr{:} 'Population RF Unweighted Normalized'}','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.titleFontSize);
                    text(summaryStructs(1).theCenterXPixels,summaryStructs(1).theCenterYPixels,'X','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.rfXFontSize)
                    stimBottomLeftCornerX = summaryStructs(1).theCenterXPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    stimBottomLeftCornerY = summaryStructs(1).theCenterYPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    rectangle('Position',[stimBottomLeftCornerX,stimBottomLeftCornerY,summaryStructs(1).theCheckerboardSizePixels,summaryStructs(1).theCheckerboardSizePixels])
                    xlim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]); ylim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]);
                    drawnow;
                    figName = [rfFigNameRoot '_RFUwgtNrm'];
                    FigureSave(figName,popFig,decodeInfoIn.figType);
                    
                    % Fit the population RF data with a circular Guassian
                    % receptive field.  Fit both versions.
                    [dataToFitXMesh,dataToFitYMesh] = meshgrid(decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions,decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions);
                    dataToFitRFMeshUnweightedUnnormalized = decodeInfoOutTemp.populationRFUnweightedUnnormalized;
                    gaussianRFResultsUnweightedUnnormalized = FitGaussianToRF(dataToFitXMesh,dataToFitYMesh,dataToFitRFMeshUnweightedUnnormalized);
                    dataToFitRFMeshUnweightedNormalized = decodeInfoOutTemp.populationRFUnweightedNormalized;
                    gaussianRFResultsUnweightedNormalized = FitGaussianToRF(dataToFitXMesh,dataToFitYMesh,dataToFitRFMeshUnweightedNormalized);
                    
                    % Mesh plot of the fit, unnormalized
                    popFitMeshFig = figure; clf; hold on;
                    plot3(dataToFitXMesh(:),dataToFitYMesh(:),dataToFitRFMeshUnweightedUnnormalized(:),'ro','MarkerFaceColor','r','MarkerSize',20)
                    h = mesh(dataToFitXMesh,dataToFitYMesh,gaussianRFResultsUnweightedUnnormalized.fit);
                    set(h,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.5)
                    set(h,'EdgeColor',[0.25 0.25 0.25],'EdgeAlpha',0.5)
                    view([-30 60]);
                    xlabel('X');
                    ylabel('Y');
                    zlabel('Unnormalized RF');
                    drawnow;
                    figName = [rfFigNameRoot '_RFUwgtUnrmFit'];
                    FigureSave(figName,popFitMeshFig,'png');
                    saveas(popFitMeshFig,figName,'fig');
                    
                    % Mesh plot of the fit, normalized
                    popFitMeshFig = figure; clf; hold on;
                    plot3(dataToFitXMesh(:),dataToFitYMesh(:),dataToFitRFMeshUnweightedNormalized(:),'ro','MarkerFaceColor','r','MarkerSize',20)
                    h = mesh(dataToFitXMesh,dataToFitYMesh,gaussianRFResultsUnweightedNormalized.fit);
                    set(h,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.5)
                    set(h,'EdgeColor',[0.25 0.25 0.25],'EdgeAlpha',0.5)
                    view([-30 60]);
                    xlabel('X');
                    ylabel('Y');
                    zlabel('Normalized RF');
                    drawnow;
                    figName = [rfFigNameRoot '_RFUwgtNrmFit'];
                    FigureSave(figName,popFitMeshFig,'png');
                    saveas(popFitMeshFig,figName,'fig');
                    
                    % Plot of the fit and stimulus, unnormalized
                    popFitFig = figure; clf;
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName','Helvetica','FontSize',decodeInfoIn.axisFontSize);
                    imagesc(decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions,decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions,gaussianRFResultsUnweightedUnnormalized.fit)
                    set(gca,'Ydir','normal')
                    colormap jet
                    colorbar
                    axis('square');
                    title({titleRootStr{:} 'Population RF Unweighted Unnormalized Fit'}','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.titleFontSize);
                    text(summaryStructs(1).theCenterXPixels,summaryStructs(1).theCenterYPixels,'X','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.rfXFontSize)
                    stimBottomLeftCornerX = summaryStructs(1).theCenterXPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    stimBottomLeftCornerY = summaryStructs(1).theCenterYPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    rectangle('Position',[stimBottomLeftCornerX,stimBottomLeftCornerY,summaryStructs(1).theCheckerboardSizePixels,summaryStructs(1).theCheckerboardSizePixels])
                    xlim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]); ylim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]);
                    drawnow;
                    figName = [rfFigNameRoot '_RFUwgtUnrmFit'];
                    FigureSave(figName,popFitFig,decodeInfoIn.figType);
                    
                    % Normalized
                    popFitFig = figure; clf;
                    set(gcf,'Position',decodeInfoIn.sqPosition);
                    set(gca,'FontName','Helvetica','FontSize',decodeInfoIn.axisFontSize);
                    imagesc(decodeInfoOutTemp.theRFGridMapStructs{1}.xPositions,decodeInfoOutTemp.theRFGridMapStructs{1}.yPositions,gaussianRFResultsUnweightedNormalized.fit)
                    set(gca,'Ydir','normal')
                    colormap jet
                    colorbar
                    axis('square');
                    title({titleRootStr{:} 'Population RF Unweighted Normalized Fit'}','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.titleFontSize);
                    text(summaryStructs(1).theCenterXPixels,summaryStructs(1).theCenterYPixels,'X','FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.rfXFontSize)
                    stimBottomLeftCornerX = summaryStructs(1).theCenterXPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    stimBottomLeftCornerY = summaryStructs(1).theCenterYPixels-(summaryStructs(1).theCheckerboardSizePixels/2);
                    rectangle('Position',[stimBottomLeftCornerX,stimBottomLeftCornerY,summaryStructs(1).theCheckerboardSizePixels,summaryStructs(1).theCheckerboardSizePixels])
                    xlim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]); ylim([decodeInfoIn.rfPlotLimLow decodeInfoIn.rfPlotLimHigh]);
                    drawnow;
                    figName = [rfFigNameRoot '_RFUwgtNrmFit'];
                    FigureSave(figName,popFitFig,decodeInfoIn.figType);
                    
                    % No RF data available, skip RF analysis
                else
                    %fprintf('No RF data for this date\n');
                end
            case 'no'
                
            otherwise
                error('Unkown RF analysis type');
        end
    end
    
    %% Store the final decodeInfoOut for this condition
    decodeInfoOutTemp = rmfield(decodeInfoOutTemp,'paintResponses');
    decodeInfoOutTemp = rmfield(decodeInfoOutTemp,'shadowResponses');
    if (isfield(decodeInfoOutTemp,'paintPCA'))
        decodeInfoOutTemp = rmfield(decodeInfoOutTemp,'paintPCA');
    end
    if (isfield(decodeInfoOutTemp,'shadowPCA'))
        decodeInfoOutTemp = rmfield(decodeInfoOutTemp,'shadowPCA');
    end
    decodeInfoOut{nn1} = decodeInfoOutTemp;
end

