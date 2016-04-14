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
% 4/14/16   dhb  Change filled in letter from 'd' to 'g', I think that is
%                what it should be.

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

% Set up to read data.  We only deal with spikesorted data.
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
% If there is no Letterflip field, then they were all 'g';
if (isfield(theData,'Letterflip'))
    theLetterflips = double(theData.Letterflip);
else
    theLetterflips = double('g')*ones(size(theData.sizeX));
end

theSizesCenterXsCenterYs = [theData.sizeX theData.centerX theData.centerY theLetterflips];
theUniqueSizesCenterXsCenterYsFlips = unique(theSizesCenterXsCenterYs,'rows');
useSizes = theUniqueSizesCenterXsCenterYsFlips(:,1);
useCenterXs = theUniqueSizesCenterXsCenterYsFlips(:,2);
useCenterYs = theUniqueSizesCenterXsCenterYsFlips(:,3);
useFlips = char(theUniqueSizesCenterXsCenterYsFlips(:,4));

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
    
    %% Get the actual electrode numbers/units that correspond to
    % each response.
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
        otherwise
            error('Unknown data file type');
    end
    
    %% Get rid of any trials with NaNs
    [paintIntensities,paintResponses] = ReduceForNaNs(paintIntensities,paintResponses);
    [shadowIntensities,shadowResponses] = ReduceForNaNs(shadowIntensities,shadowResponses);
    
    %% Shuffle if desired.  The shuffling propagates through everything.
    [paintIntensities,paintResponses,shadowIntensities,shadowResponses,decodeInfoIn] = PaintShadowShuffle(decodeInfoIn,paintIntensities,paintResponses,shadowIntensities,shadowResponses);

    %% PCA if desired.This also propagates.
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
end
    
 

