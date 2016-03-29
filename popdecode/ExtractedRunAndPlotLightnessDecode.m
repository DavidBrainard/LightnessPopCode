function decodeInfoOut = ExtractedRunAndPlotLightnessDecode(theDir,decodeInfoIn)
% decodeInfoOut = EExtractedRunAndPlotLightnessDecode(theDir,decodeInfoIn)
%
% Work on data extracted by earlier big program.  Streamlines a bit for new
% things.
%
% 3/8/16  dhb  Wrote from earlier stuff.

%% Basic initialization
close all;

%% Start getting info to pass on back
decodeInfoOut = decodeInfoIn;

%% Plot info
%
% Condition and title strings
condStr = MakePopDecodeConditionStr(decodeInfoIn);
titleBaseStr = strrep(condStr,'_',' ');
[~,filename] = fileparts(theDir);
decodeInfoOut.titleStr = LiteralUnderscore({filename ; ...
    ['''Shadow'' condition ' num2str(decodeInfoIn.shadowCondition) ', ''paint'' condition ' num2str(decodeInfoIn.paintCondition)]; ...
    titleBaseStr ...
    });

% Where to put extracted plots
extractedPlotBaseDir = '../../PennOutput/xPlots';
if (~exist(extractedPlotBaseDir,'dir'))
    mkdir(extractedPlotBaseDir);
end
extractedPlotRootDir = fullfile(extractedPlotBaseDir,condStr,'');
if (~exist(extractedPlotRootDir,'dir'))
    mkdir(extractedPlotRootDir);
end
extractedPlotDir = fullfile(extractedPlotRootDir,filename);
if (~exist(extractedPlotDir,'dir'))
    mkdir(extractedPlotDir);
end
filenameFig = [];
for ii = 1:length(filename)
    if (filename(ii) == '_')
        break;
    end
    filenameFig(ii) = filename(ii);
end
decodeInfoOut.figNameRoot = fullfile(extractedPlotDir,[filenameFig '_' decodeInfoIn.dataType '_' decodeInfoIn.paintShadowFitType]);

%% Read in extracted data
curDir = pwd; cd(theDir);
theData = load('paintShadowData');
cd(curDir);

%% Check that there are enough trials left to analyze
decodeInfoOut.OK = true;
nPaintTrials = length(theData.paintIntensities);
nShadowTrials = length(theData.shadowIntensities);
if (nPaintTrials < decodeInfoIn.minTrials)
    decodeInfoOut.OK = false;
end
if (nShadowTrials < decodeInfoIn.minTrials)
    decodeInfoOut.OK = false;
end

%% Only process if there are enough good data.
decodeInfoOut.filename = filename;
decodeInfoOut.subjectStr = filename(1:2);
if (decodeInfoOut.OK)
    fprintf('\tWorking on condition %s\n',theDir);
    
    % General stuff
    %
    % The switch gives us control for quicker debugging.
    decodeInfoOut.uniqueIntensities = unique([theData.paintIntensities ; theData.shadowIntensities]);
    decodeInfoOut.nUnits = size(theData.paintResponses,2);
    runType = 'FAST';
    switch (runType)
        case 'FAST'
            decodeInfoOut.nNUnitsToStudy = 3;
            decodeInfoOut.nRepeatsPerNUnits = 2;
            decodeInfoOut.nRandomVectorRepeats = 5;
            decodeInfoOut.ndecodeLOOType = 'no';
            decodeInfoOut.classifyLOOType = 'no';
        case 'SLOWER'
            decodeInfoOut.nNUnitsToStudy = 25;
            decodeInfoOut.nRepeatsPerNUnits = 50;
            decodeInfoOut.nRandomVectorRepeats = 50;
            decodeInfoOut.ndecodeLOOType = 'no';
            decodeInfoOut.classifyLOOType = 'no';
        case 'REAL'
            decodeInfoOut.nNUnitsToStudy = 25;
            decodeInfoOut.nRepeatsPerNUnits = 100;
            decodeInfoOut.nRandomVectorRepeats = 100;
            decodeInfoOut.ndecodeLOOType = 'ot';
            decodeInfoOut.classifyLOOType = 'foo';
    end
    
    % *******
    % Representational similarity
    decodeInfoOut = ExtractedRepresentationalSimilarity(decodeInfoOut,theData);
    
    % *******
    % Analyze how paint and shadow RMSE/Prediction compare with each other when
    % decoder is built with both, built with paint only, built with shadow
    % only, is chosen randomly, is built to classify, etc.
    decodeInfoOut = ExtractedRMSEAnalysis(decodeInfoOut,theData);
    
    % *******
    % Analyze decoding as a function of the number of units used to build
    % decoder.
    decodeInfoOut = ExtractedRMSEVersusNUnits(decodeInfoOut,theData);
    
    % *******
    % Study decoding performance as a function of number of PCA dimensions
    decodeInfoOut = ExtractedRMSEVersusNPCA(decodeInfoOut,theData);
    
    % *******
    % Study classification performance as a function of the number of units
    decodeInfoOut = ExtractedClassificationVersusNUnits(decodeInfoOut,theData);
    
    % *******
    % Study classification performance as a function of number of PCA dimensions
    decodeInfoOut = ExtractedClassificationVersusNPCA(decodeInfoOut,theData);

end
end



