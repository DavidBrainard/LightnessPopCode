function [dataStruct] = LV4AnalyzeStaircaseDataFileWithSummary(protocol, subject, iteration, dataDir, figDir, psychoAnalysisParams)
% [dataStruct] = LV4AnalyzeStaircaseDataFileWithSummary(protocol, subject, iteration, datadir, figDir, psychoAnalysisParams)
%
% Input:
% protocol (string) - The protocol data directory.
% subject (string) - The name of the subject.
% iteration (scalar) - The iteration of the data file.  All data files are
%     appended with an integer value, use this number.
% dataDir - Path to top level data directory subdir
% figDir - Path to top level fig directory
% analysisParams - Analysis structure
%
% 7/14/13  dhb  New version returns summary info, and packs data into a substructure.
% 10/10/13 dhb  Handle multiple images with same name in different directories.
% 11/3/13  dhb  Apparently still need some more handling of multiple images with same name in different directories.

%% Keep figures from accumulating
close all;

%% Dynamically add the program code to the path if it isn't already on it.
% We do this so we have access to the enumeration classes for this
% experiment.
codeDir = fullfile(fileparts(fileparts(which(mfilename))), 'code');
if isempty(strfind(path, codeDir))
    fprintf('- Adding %s dynamically to the path...', mfilename);
    addpath(RemoveSVNPaths(genpath(codeDir)), '-end');
    fprintf('Done\n');
end

%% Figure out where the top level data directory is.
%dataDir = fullfile(fileparts(fileparts(which(mfilename))), 'data', dataSubDir);

%% Figure out where the image configuration file is
stimulusDefinitionsFile = fullfile(fileparts(fileparts(which(mfilename))), 'stimuli', 'StimulusDefinitions.txt');
stimulusDefinitionsStruct = ReadStructsFromText(stimulusDefinitionsFile);

%% Construct the data file name we want to analyze.
simpleFileName = sprintf('%s-%s-%d.mat', subject, protocol, iteration);
figProtocolDir = fullfile(figDir,protocol,'');
if (~exist(figProtocolDir,'dir'))
    mkdir(figProtocolDir);
end
figFileDir = fullfile(figProtocolDir,subject,'');
if (~exist(figFileDir,'dir'))
    mkdir(figFileDir);
end
figFileName = sprintf('%s-%s-%d', subject, protocol, iteration);
dataFileName = fullfile(dataDir, protocol, subject, simpleFileName);

%% Make sure the file exists.
assert(logical(exist(dataFileName, 'file')), 'LV4AnalyzeStaircaseDataFile:FileNotFound', ...
    'Cannot find file: %s', dataFileName);

%% Load the data.
data = load(dataFileName);

%% Regenerate the staircase objects found in data.params
UseClassesDev;
[M, N] = size(data.params.st);
for row = 1:M
    for col = 1:N
        % Generate dummy object
        newObject = Staircase('standard', 0, 'StepSizes', [0 0 0 0], 'NUp', 0, 'NDown', 0);
        
        % Reload it with values found in data.params.st{row,col}
        newObject = loadObject(newObject, data.params.st{row,col});
        data.params.st{row,col} = newObject;
    end
end

%% Report some facts about the images

% Extract data
nStimTypes = size(data.params.st,1);
nInterleavedStaircases = size(data.params.st,2);
numTrialsPerStaircase = data.params.numTrialsPerStaircase;

% Parse protocol name to get a number of key parameters.
C = textscan(protocol,'c%d_%[pntshd]_rot%d_shad%d_blk%d_cen%d_vs_%[pntshd]_rot%d_shad%d_blk%d_cen%d_t%d');
dataStruct.condNumber = C{1};
dataStruct.ref.type = C{2}{1};
dataStruct.ref.rot = C{3};
dataStruct.ref.shadowSize= C{4};
dataStruct.ref.blk = C{5};
dataStruct.ref.cen = C{6};
dataStruct.test.type = C{7}{1};
dataStruct.test.rot = C{8};
dataStruct.test.shadowSize= C{9};
dataStruct.test.blk= C{10};
dataStruct.test.cen= C{11};
dataStruct.timeCond= C{12};

% Go through stimulus definitions structs and find images that match the above for the reference and test image.  Each should be unique.
% We need to do this because the filenames don't specify all the parameters we might care about (they got pretty long as it is), but
% sometimes we vary some of the other parameters and want to know.  
%
% This scheme will fall upon hard times if the condition filenames don't end up uniquely specifying images within a block
% of conditions.  But we'll deal with that when the times comes, if it ever does.
imageDefRoot = {stimulusDefinitionsStruct.outputRoot};
imageDefRot = [stimulusDefinitionsStruct.rotationDeg];
imageDefBlackRefl = [stimulusDefinitionsStruct.blackRefl];
imageDefCenterRefl = [stimulusDefinitionsStruct.centerRefl];
imageDefShadowSize = [stimulusDefinitionsStruct.shadowSteepness];
index = find(imageDefRot == double(dataStruct.ref.rot) & ...
    imageDefBlackRefl == double(dataStruct.ref.blk)/100 & ...
    imageDefCenterRefl == double(dataStruct.ref.cen)/100 & ...
    imageDefShadowSize == double(dataStruct.ref.shadowSize));
if (isempty(index))
    error('No stimulus image definitions match those extracted from condition file name');
end
gotIt = false;
for i = 1:length(index)
    imageRoot = imageDefRoot{index(i)};
    if (strcmp(imageRoot,data.params.stimuliDir))
        if (~gotIt)
            ourRefIndex = index(i);
            gotIt = true;
        else
            %error('Non unique image match');
        end
    end
end
if (~gotIt)
    error('No stimulus image definitions match those extracted from condition file name');
end

index = find(imageDefRot == double(dataStruct.test.rot) & ...
    imageDefBlackRefl == double(dataStruct.test.blk)/100 & ...
    imageDefCenterRefl == double(dataStruct.test.cen)/100 & ...
    imageDefShadowSize == double(dataStruct.test.shadowSize));
if (isempty(index))
    error('No stimulus image definitions match those extracted from condition file name');
end
gotIt = false;
for i = 1:length(index)
    imageRoot = imageDefRoot{index(i)};
    if (strcmp(imageRoot,data.params.stimuliDir))
        if (~gotIt)
            ourTestIndex = index(i);
            gotIt = true;
        else
            %error('Non unique image match');
        end
    end
end
if (~gotIt)
    error('No stimulus image definitions match those extracted from condition file name');
end

% Get a few more useful parameters out of the stimulus definition structure
dataStruct.ref.brightLight = stimulusDefinitionsStruct(ourRefIndex).brightLight;
dataStruct.ref.blobSd =  stimulusDefinitionsStruct(ourRefIndex).blobSd;
dataStruct.ref.nChecks = stimulusDefinitionsStruct(ourRefIndex).nChecks;
dataStruct.ref.backgroundRefl = stimulusDefinitionsStruct(ourRefIndex).backgroundRefl;
dataStruct.ref.whiteRefl = stimulusDefinitionsStruct(ourRefIndex).whiteRefl;
dataStruct.test.brightLight = stimulusDefinitionsStruct(ourTestIndex).brightLight;
dataStruct.test.blobSd =  stimulusDefinitionsStruct(ourTestIndex).blobSd;
dataStruct.test.nChecks = stimulusDefinitionsStruct(ourTestIndex).nChecks;
dataStruct.test.backgroundRefl = stimulusDefinitionsStruct(ourTestIndex).backgroundRefl;
dataStruct.test.whiteRefl = stimulusDefinitionsStruct(ourTestIndex).whiteRefl;

%% Get some statistics on the contextual images.  This loads in the blank image
% and computes on it.
for i = 1:data.params.numStims
    fprintf('\n\tImage %d, %s\n',i,data.params.stimInfo(i).imageName);
    fileName = fullfile(data.params.stimuliDir,[data.params.stimInfo(i).imageName '.mat']);
    imageData = load(fileName);
    
    % Get image data
    meanImageValue = mean(mean(imageData.theImage));
    meanProbeLocationValue = mean(mean(imageData.theImage(imageData.probeIndex)));
    temp = imageData.theImage;
    temp(imageData.probeIndex) = NaN;
    meanNotProbeLocationValue = nanmean(nanmean(temp));
    
    dataStruct.imageSizeX(i) = size(imageData.theImage,2);
    dataStruct.imageSizeY(i) = size(imageData.theImage,1);
    dataStruct.numberProbePixels(i) = length(imageData.probeIndex);
    dataStruct.meanImageValue(i) = meanImageValue;
    dataStruct.meanProbeLocationValue(i) = meanProbeLocationValue;
    dataStruct.meanNotProbeLocationValue(i) = meanNotProbeLocationValue;
    fprintf('\tImage size = %d (h) by %d (v) pixels\n',dataStruct.imageSizeX(i),dataStruct.imageSizeY(i));
    fprintf('\tNumber of probe pixels = %d\n',dataStruct.numberProbePixels(i));
    fprintf('\tImage mean = %0.3f, probe location mean = %0.3f, not probe location mean = %0.3f\n',dataStruct.meanImageValue(i),...
        dataStruct.meanProbeLocationValue(i),dataStruct.meanNotProbeLocationValue(i));
    fprintf('\tSpecified blank color = %0.3f\n',imageData.blankcolor);
end

%% Figure.  Trials where comparison was judged lighter are plotted as
% solid symbols, and where it was judged darker as open symbols.
% Different staircases are plotted in different colors.
colors = ['r' 'g' 'b' 'k' 'y' 'c'];
psychoFig = figure;
set(gca,'FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.axisFontSize,'LineWidth',psychoAnalysisParams.axisLineWidth);
set(psychoFig,'Position',[100 100 2000 round(560/420*2000)]);
if (psychoAnalysisParams.generateExampleFigure)
    psychoExampleFig1 = figure;
    set(psychoExampleFig1,'Position',[100 100 2000 round(560/420*2000)]);
end
nPlotRows = 2;
nPlotCols = nStimTypes/nPlotRows;
for s = 1:nStimTypes
    valuesStair{s} = [];
    responsesStair{s} = [];
    stairFig = figure; clf;
    stimID(s) = data.params.stimBlock(s).stimID;
    refIntensity(s) = data.params.stimBlock(s).refIntensity;
    for k = 1:nInterleavedStaircases
        % The pseStair values are pretty much meaningless unless you
        % are trying to debug the staircase code itself.
        pseStair(s,k) = getThresholdEstimate(data.params.st{s,k});
        
        % Get staircase values.
        [valuesSingleStair{s,k},responsesSingleStair{s,k}] = getTrials(data.params.st{s,k});
        
        % Note that the pse's extracted from the staircase are pretty close to
        % their simulated value (which here is zero and indicated by a horizontal
        % black line in the plot).
        subplot(nInterleavedStaircases,1,k); hold on
        xvalues = 1:numTrialsPerStaircase;
        plot(xvalues,zeros(size(xvalues)),'k','LineWidth',2);
        index = find(responsesSingleStair{s,k} == 0);
        plot(xvalues,valuesSingleStair{s,k},[colors(k) '-']);
        plot(xvalues,valuesSingleStair{s,k},[colors(k) 'o'],'MarkerFaceColor',colors(k),'MarkerSize',6);
        if (~isempty(index))
            plot(xvalues(index),valuesSingleStair{s,k}(index),[colors(k) 'o'],'MarkerFaceColor','w','MarkerSize',6);
        end
        plot(xvalues,refIntensity(s)*ones(1,numTrialsPerStaircase),colors(k));
        
        xlabel('Trial Number','FontSize',16);
        ylabel('Level','FontSize',16);
        ylim([0 1]);
        title(sprintf('Staircase plot %d, %d, stimID = %d, refIntensity = %0.2f',s,k,stimID(s),refIntensity(s)),'FontSize',16);
        valuesStair{s} = [valuesStair{s} valuesSingleStair{s,k}];
        responsesStair{s} = [responsesStair{s} responsesSingleStair{s,k}];
    end
    curDir = pwd;
    cd(figFileDir);
    if (~exist('xStaircasePlots','dir'))
        mkdir('xStaircasePlots');
    end
    cd('xStaircasePlots');
    FigureSave([figFileName '_StimType' num2str(s)],gcf,psychoAnalysisParams.figType);
    cd(curDir)
    
    % Fit psychometric function
    [~,interpStimuli{s},pInterp{s},pse(s),loc25(s),loc75(s)] = FitPsychometricData(valuesStair{s}',responsesStair{s}',ones(size(responsesStair{s}')));

    % Aggregated trials
    [meanValues{s},nAbove{s},nTrials{s}] = GetAggregatedStairTrials(valuesStair{s},responsesStair{s},5);
    figure(psychoFig);
    subplot(nPlotRows,nPlotCols,s); hold on
    set(gca,'FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.axisFontSize);
    plot(meanValues{s},nAbove{s}./nTrials{s},'ro','MarkerSize',psychoAnalysisParams.markerSize,'MarkerFaceColor','r');
    plot(interpStimuli{s},pInterp{s},'r','LineWidth',psychoAnalysisParams.lineWidth);
    plot([refIntensity(s) refIntensity(s)],[0 0.1],'g','LineWidth',psychoAnalysisParams.lineWidth);
    plot([loc25(s) loc75(s)],[0.05 0.05],'r','LineWidth',psychoAnalysisParams.lineWidth);
    plot([pse(s) pse(s)],[0 0.1],'r','LineWidth',psychoAnalysisParams.lineWidth);
    xlabel('Comparison Disk Luminance','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
    ylabel('Fraction Comparison Judged Lighter','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
    title(sprintf('stimID = %d, refIntensity = %0.2f',stimID(s),refIntensity(s)),'FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.titleFontSize);
    xlim([psychoAnalysisParams.intensityLimLow psychoAnalysisParams.intensityLimHigh]);
    ylim([psychoAnalysisParams.fractionLimLow psychoAnalysisParams.fractionLimHigh]);
    set(gca,'XTick',psychoAnalysisParams.intensityTicks,'XTickLabel',psychoAnalysisParams.intensityTickLabels);
    set(gca,'YTick',psychoAnalysisParams.intensityTicks,'YTickLabel',psychoAnalysisParams.intensityYTickLabels);
    
    if (psychoAnalysisParams.generateExampleFigure)
        % All staircases example, set up for presentations
        figure(psychoExampleFig1);
        subplot(nPlotRows,nPlotCols,s); hold on
        set(gca,'FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.axisFontSize,'LineWidth',psychoAnalysisParams.axisLineWidth);
        plot(meanValues{s},nAbove{s}./nTrials{s},'b^','MarkerSize',psychoAnalysisParams.markerSize,'MarkerFaceColor','b');
        plot(interpStimuli{s},pInterp{s},'b','LineWidth',psychoAnalysisParams.lineWidth);
        plot([refIntensity(s) refIntensity(s)],[0 0.1],'k','LineWidth',psychoAnalysisParams.lineWidth);
        %plot([loc25(s) loc75(s)],[0.05 0.05],'r','LineWidth',psychoAnalysisParams.lineWidth);
        plot([pse(s) pse(s)],[0 0.1],'b','LineWidth',psychoAnalysisParams.lineWidth);
        if (s >= 1 && s <= 3)
            xlabel('Shadow Disk Luminance','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
            ylabel('Fraction Shadow Disk Judged Lighter','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
            title('Reference Disk in Paint','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
        else
            xlabel('Paint Disk Luminance','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
            ylabel('Fraction Paint Disk Judged Lighter','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
            title('Reference Disk in Shadow','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
        end
        xlim([psychoAnalysisParams.intensityLimLow psychoAnalysisParams.intensityLimHigh]);
        ylim([psychoAnalysisParams.fractionLimLow psychoAnalysisParams.fractionLimHigh]);
        set(gca,'XTick',psychoAnalysisParams.intensityTicks,'XTickLabel',psychoAnalysisParams.intensityTickLabels);
        set(gca,'YTick',psychoAnalysisParams.intensityTicks,'YTickLabel',psychoAnalysisParams.intensityYTickLabels);
        
        % Single psychometric function, set up for presentations
        if  (s == psychoAnalysisParams.exampleFigNum)
            psychoExampleFig = figure; clf; hold on
            set(gcf,'Position',psychoAnalysisParams.sqPosition);
            set(gca,'FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.axisFontSize,'LineWidth',psychoAnalysisParams.axisLineWidth);
            plot(meanValues{s},nAbove{s}./nTrials{s},'b^','MarkerSize',psychoAnalysisParams.markerSize,'MarkerFaceColor','b');
            plot(interpStimuli{s},pInterp{s},'b','LineWidth',psychoAnalysisParams.lineWidth);
            plot([refIntensity(s) refIntensity(s)],[0 0.1],'k','LineWidth',psychoAnalysisParams.lineWidth);
            %plot([loc25(s) loc75(s)],[0.05 0.05],'r','LineWidth',psychoAnalysisParams.lineWidth);
            plot([pse(s) pse(s)],[0 0.1],'b','LineWidth',psychoAnalysisParams.lineWidth);
            xlabel('Shadow Disk Luminance (re Display Max)','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
            ylabel('Fraction Shadow Disk Judged Lighter','FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
            %title(sprintf('stimID = %d, refIntensity = %0.2f',stimID(s),refIntensity(s)),'FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.titleFontSize);
            xlim([psychoAnalysisParams.intensityLimLow psychoAnalysisParams.intensityLimHigh]);
            ylim([psychoAnalysisParams.fractionLimLow psychoAnalysisParams.fractionLimHigh]);
            set(gca,'XTick',psychoAnalysisParams.intensityTicks,'XTickLabel',psychoAnalysisParams.intensityTickLabels);
            set(gca,'YTick',psychoAnalysisParams.intensityTicks,'YTickLabel',psychoAnalysisParams.intensityYTickLabels);
            text(0,1,sprintf('PSE: %0.2f',pse(s)),'FontName',psychoAnalysisParams.fontName,'FontSize',psychoAnalysisParams.labelFontSize);
            %axis('square');
        end
    end

    % Return key data, with image1 defined as reference context
    if (stimID(s) == 1)
        dataStruct.data(s).whichFixed = 1;
        dataStruct.data(s).refIntensity = refIntensity(s);
        dataStruct.data(s).testIntensity = pse(s);
    elseif (stimID(s) == 2)
        dataStruct.data(s).whichFixed = 2;
        dataStruct.data(s).refIntensity = pse(s);
        dataStruct.data(s).testIntensity = refIntensity(s);
    else
        error('This code assumes only two contextual images.');
    end
end

% Add title
figure(psychoFig);
[~,h] = suplabel(LiteralUnderscore([protocol ', ' subject ', ' num2str(iteration)]),'t');
set(h,'FontSize',14);

%% Save the plot and close the figure
curDir = pwd;
cd(figFileDir);
FigureSave(figFileName,psychoFig,psychoAnalysisParams.figType);
if (exist('psychoExampleFig','var'))
    FigureSave([figFileName '_exampleOne'],psychoExampleFig,psychoAnalysisParams.figType);
    FigureSave([figFileName '_exampleAll'],psychoExampleFig1,psychoAnalysisParams.figType);
end
cd(curDir);

%% Close all figs.
% Comment ths out to look at the staircase plots.
close all;

end



