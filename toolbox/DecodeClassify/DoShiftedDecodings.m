function decodeShift = DoShiftedDecodings(decodeInfo,paintIntensities,shadowIntensities,paintResponses,shadowResponses,shadowShiftInValues,pcaType,nPCAComponents)
%DoShiftedDecodings  Decode with gain shifts of input intensities
%    decodeShift = DoShiftedDecodings(decodeInfo,paintIntensities,shadowIntentities,paintResponses,shadowResponses,shadowShiftInValues)
%
% Loop through and decode with shifts of gain on inputs (paintIntensities/shadowShiftInValues, shadowIntensities*shadowShiftInValues).

%% Set up for possible PCA by getting mean responses for each intensity
%
% The idea is not to have the PCA output driven by noise.
for dc = 1:length(decodeInfo.uniqueIntensities)
    theIntensity = decodeInfo.uniqueIntensities(dc);
    paintIndex = find(paintIntensities == theIntensity);
    shadowIndex = find(shadowIntensities == theIntensity);
    meanPaintResponses(dc,:) = mean(paintResponses(paintIndex,:),1);
    meanShadowResponses(dc,:) = mean(shadowResponses(shadowIndex,:),1);
end

%% Handle PCA by rewriting responses as appropriate.
switch pcaType
    case 'none'
    case 'both'
        clear decodeInfoPCA
        decodeInfoPCA.pcaType = 'ml';
        [~,~,pcaBasis,meanResponse] = PaintShadowPCA(decodeInfoPCA,meanPaintResponses,meanShadowResponses);
        paintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,pcaBasis,meanResponse);
        shadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,pcaBasis,meanResponse);
        paintResponses = paintPCAResponses(:,1:nPCAComponents);
        shadowResponses = shadowPCAResponses(:,1:nPCAComponents);
    case 'paint'     
        clear decodeInfoPCA
        decodeInfoPCA.pcaType = 'ml';
        [~,~,pcaBasis,meanResponse] =  PaintShadowPCA(decodeInfoPCA,meanPaintResponses,[]);
        paintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,pcaBasis,meanResponse);
        shadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,pcaBasis,meanResponse);
        paintResponses = paintPCAResponses(:,1:nPCAComponents);
        shadowResponses = shadowPCAResponses(:,1:nPCAComponents);
    case 'shadow'
        clear decodeInfoPCA
        decodeInfoPCA.pcaType = 'ml';
        [~,~,pcaBasis,meanResponse] =  PaintShadowPCA(decodeInfoPCA,meanShadowResponses,[]);
        paintPCAResponses = PCATransform(decodeInfoPCA,paintResponses,pcaBasis,meanResponse);
        shadowPCAResponses = PCATransform(decodeInfoPCA,shadowResponses,pcaBasis,meanResponse);
        paintResponses = paintPCAResponses(:,1:nPCAComponents);
        shadowResponses = shadowPCAResponses(:,1:nPCAComponents);
end

%% Loop and decode for the various gains
for ii = 1:length(shadowShiftInValues)
    clear decodeInfoTemp d
    decodeInfoTemp.shadowShiftIn = shadowShiftInValues(ii);
    decodeInfoTemp.nUnits = decodeInfo.nUnits;
    decodeInfoTemp.nRandomVectorRepeats = decodeInfo.nRandomVectorRepeats;
    decodeInfoTemp.decodeJoint = decodeInfo.decodeJoint;
    decodeInfoTemp.type = decodeInfo.type;
    decodeInfoTemp.decodeLOOType = decodeInfo.decodeLOOType;
    decodeInfoTemp.decodeNFolds = decodeInfo.decodeNFolds;
    decodeInfoTemp.nFinelySpacedIntensities = decodeInfo.nFinelySpacedIntensities;
    decodeInfoTemp.decodedIntensityFitType = decodeInfo.decodedIntensityFitType;
    decodeInfoTemp.inferIntensityLevelsDiscrete = decodeInfo.inferIntensityLevelsDiscrete;
    decodeInfoTemp.paintShadowFitType = decodeInfo.paintShadowFitType;
    [~,~,d.paintPreds,d.shadowPreds] = PaintShadowDecode(decodeInfoTemp, ...
        paintIntensities,paintResponses/decodeInfoTemp.shadowShiftIn,shadowIntensities*decodeInfoTemp.shadowShiftIn,shadowResponses);
    d.shadowShiftIn = decodeInfoTemp.shadowShiftIn;
    
    % Compute error with respect to shifted intensities
    d.paintRMSE = sqrt(mean((paintIntensities(:)/decodeInfoTemp.shadowShiftIn-d.paintPreds(:)).^2));
    d.shadowRMSE = sqrt(mean((shadowIntensities(:)*decodeInfoTemp.shadowShiftIn-d.shadowPreds(:)).^2));
    d.theRMSE = sqrt(mean(([paintIntensities(:)/decodeInfoTemp.shadowShiftIn ; shadowIntensities(:)*decodeInfoTemp.shadowShiftIn]-[d.paintPreds(:) ; d.shadowPreds(:)]).^2));
    d.nullRMSE = sqrt(mean(([paintIntensities(:)/decodeInfoTemp.shadowShiftIn ; shadowIntensities(:)*decodeInfoTemp.shadowShiftIn]- ...
        mean([paintIntensities(:)/decodeInfoTemp.shadowShiftIn ; shadowIntensities(:)*decodeInfoTemp.shadowShiftIn])).^2));
    d.paintMean = mean(d.paintPreds(:));
    d.shadowMean = mean(d.shadowPreds(:));
    d.shadowMinusPaintMean = mean(d.shadowPreds(:))-mean(d.paintPreds(:));
    d.nPCACompnents = nPCAComponents;
    
    % Compute paint-shadow effect with respect to unshifted intensities
    [d.paintMeans,d.paintSEMs,~,~,~,d.paintGroupedIntensities] = ...
        sortbyx(paintIntensities,d.paintPreds);
    [d.shadowMeans,d.shadowSEMs,~,~,~,d.shadowGroupedIntensities] = ...
        sortbyx(shadowIntensities,d.shadowPreds);
    [d.paintShadowEffect,d.paintSmooth,d.shadowSmooth,d.paintMatchesSmooth,d.shadowMatchesSmooth, ...
        d.paintMatchesDiscrete,d.shadowMatchesDiscrete,d.shadowMatchesDiscretePred,d.fineSpacedIntensities] = ...
        FindPaintShadowEffect(decodeInfoTemp,d.paintGroupedIntensities,d.shadowGroupedIntensities,d.paintMeans,d.shadowMeans);
    decodeShift(ii) = d;
end