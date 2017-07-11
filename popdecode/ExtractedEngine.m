function decodeInfoOut = ExtractedEngine(readDataDir,decodeInfoIn)
% decodeInfoOut = ExtractedEngine(theDir,decodeInfoIn)
%
% Work on data extracted by earlier big program.  Streamlines a bit for new
% things.
%
% 3/8/16  dhb  Wrote from earlier stuff.
% 6/15/17 dhb  Freeze rng seed before each analysis.

%% Basic initialization
close all;

%% Start getting info to pass on back
decodeInfoOut = decodeInfoIn;

%% Plot info
%
% Condition and title strings
decodeInfoOut.readDataDir = readDataDir;
condStr = MakePopDecodeConditionStr(decodeInfoIn);
titleBaseStr = strrep(condStr,'_',' ');
[~,filename] = fileparts(readDataDir);
decodeInfoOut.titleStr = LiteralUnderscore({filename ; ...
    ['''Shadow'' condition ' num2str(decodeInfoIn.shadowCondition) ', ''paint'' condition ' num2str(decodeInfoIn.paintCondition)]; ...
    titleBaseStr ...
    });

% Where to put extracted plots.  This can differ from where the data come
% from, if we like.
extractedPlotBaseDir = fullfile(getpref('LightnessPopCode','outputBaseDir'),'xExtractedPlots');
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
decodeInfoOut.figNameRoot = fullfile(extractedPlotDir,'Fig');
decodeInfoOut.writeDataDir = extractedPlotDir;

%% Filter right here to just look at a particular session
theTempName = 'JD130831';
if (~strcmp(filename(1:8),theTempName))
    return;
end

%% Read in extracted data
curDir = pwd; cd(readDataDir);
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
    fprintf('\tWorking on condition %s\n',readDataDir);
    
    % General stuff
    %
    % The switch gives us control for quicker debugging, and we also set
    % other parameters here.
    decodeInfoOut.uniqueIntensities = unique([theData.paintIntensities ; theData.shadowIntensities]);
    decodeInfoOut.nUnits = size(theData.paintResponses,2);
    decodeInfoOut.nFitMaxUnits = 40;
    runType = 'SLOWER';
    switch (runType)
        case 'FAST'
            decodeInfoOut.verbose = true;
            decodeInfoOut.nNUnitsToStudy = 3;
            decodeInfoOut.nRepeatsPerNUnits = 2;
            decodeInfoOut.nRandomVectorRepeats = 5;
            decodeInfoOut.decodeLOOType = 'no';
            decodeInfoOut.decodeNFolds = 10;
            decodeInfoOut.classifyLOOType = 'no';
            decodeInfoOut.classifyNFolds = 10;
            decodeInfoOut.classifyPCADimsToTry = [6];
        case 'SLOWER'
            decodeInfoOut.verbose = true;
            decodeInfoOut.nNUnitsToStudy = 25;
            decodeInfoOut.nRepeatsPerNUnits = 50;
            decodeInfoOut.nRandomVectorRepeats = 50;
            decodeInfoOut.decodeLOOType = 'kfold';
            decodeInfoOut.decodeNFolds = 10;
            decodeInfoOut.classifyLOOType = 'kfold';
            decodeInfoOut.classifyNFolds = 10;
            decodeInfoOut.classifyPCADimsToTry = [6];
        case 'REAL'
            decodeInfoOut.verbose = true;
            decodeInfoOut.nNUnitsToStudy = 30;
            decodeInfoOut.nRepeatsPerNUnits = 500;
            decodeInfoOut.nRandomVectorRepeats = 100;
            decodeInfoOut.decodeLOOType = 'kfold';
            decodeInfoOut.decodeNFolds = 10;
            decodeInfoOut.classifyLOOType = 'kfold';
            decodeInfoOut.classifyNFolds = 10;
            decodeInfoOut.classifyPCADimsToTry = [6];
    end
    tstart = tic;
    
    % *******
    % Paint shadow effect
    rng(1001);
    if (decodeInfoIn.doExtractedPaintShadowEffect)  
        ExtractedPaintShadowEffect('always',decodeInfoOut,theData);
    end
    
    % *******
    % Representational similarity
    rng(1002);
    if (decodeInfoIn.doExtractedRepSim)
        ExtractedRepSim('always',decodeInfoOut,theData);
    end
    
    % *******
    % Analyze how paint and shadow RMSE/Prediction compare with each other when
    % decoder is built with both, built with paint only, built with shadow
    % only, is chosen randomly, is built to classify, etc.
    rng(1003);
    if (decodeInfoIn.doExtractedRMSEAnalysis)
        ExtractedRMSEAnalysis('always',decodeInfoOut,theData);
    end
    
    % *******
    % Analyze decoding as a function of the number of units used to build
    % decoder.
    rng(1004);
    if (decodeInfoIn.doExtractedRMSEVersusNUnits)
        ExtractedRMSEVersusNUnits('always',decodeInfoOut,theData);
    end
    
    % *******
    % Study decoding performance as a function of number of PCA dimensions
    if (decodeInfoIn.doExtractedRMSEVersusNPCA)
        ExtractedRMSEVersusNPCA('always',decodeInfoOut,theData);
    end
    
    % *******
    % Study classification performance as a function of the number of units
    rng(1005);
    if (decodeInfoIn.doExtractedClassificationVersusNUnits) 
        ExtractedClassificationVersusNUnits('always',decodeInfoOut,theData);
    end
    
    % *******
    % Study classification performance as a function of number of PCA dimensions
    rng(1006);
    if (decodeInfoIn.doExtractedClassificationVersusNPCA) 
        ExtractedClassificationVersusNPCA('always',decodeInfoOut,theData);
    end
    
    % Save the output for this directory.  Good for checkpointing
    decodeInfoOut.runTime = toc(tstart);
    curDir = pwd; cd(readDataDir);
    decodeSave = decodeInfoOut;
    save('extEngine','decodeSave','-v7.3');
    cd(curDir);

end
end



