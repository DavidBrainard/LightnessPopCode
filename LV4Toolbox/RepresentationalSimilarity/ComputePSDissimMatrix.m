function dissimMatrix = ComputePSDissimMatrix(decodeInfo,theData)
%
%
% Get population response dissimilarity matrix from the data.
%
% This assumes that there are matching intensities across paint and shadow,
% which I think is always true in out datasets.
%
% 3/29/16  dhb  Pulled this out.

%% Get similarity matrix based on mean responses as a point of
% departure.
for dc = 1:length(decodeInfo.uniqueIntensities)
    theIntensity = decodeInfo.uniqueIntensities(dc);
    paintIndex = find(theData.paintIntensities == theIntensity);
    shadowIndex = find(theData.shadowIntensities == theIntensity);
    meanPaintResponses(dc,:) = mean(theData.paintResponses(paintIndex,:),1);
    meanShadowResponses(dc,:) = mean(theData.shadowResponses(shadowIndex,:),1);
end
dataMatrixForCorr = [meanPaintResponses ; meanShadowResponses];
corrMatrix = corrcoef(dataMatrixForCorr');
dissimMatrix = 1-corrMatrix; dissimMatrix = dissimMatrix+dissimMatrix';

