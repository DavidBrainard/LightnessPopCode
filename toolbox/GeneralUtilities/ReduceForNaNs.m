function [intensitiesOut,responsesOut] = ReduceForNaNs(intensitiesIn,responsesIn)
% [intensitiesOut,responsesOut] = ReduceForNaNs(intensitiesIn,responsesIn)
%
% Remove from contrast response data set any trials where either
% contrast or response contains a NaN.
%
% This is not terribly efficient code, but I don't think this
% is a time limiting step in our calculations.
%
% 10/29/13  dhb  Wrote it
% 4/26/14   dhb  Variable renaming.

% NaNs in contrasts
index = find(~isnan(intensitiesIn));
contrastsTemp = intensitiesIn(index);
responsesTemp = responsesIn(index,:);

intensitiesOut = zeros(size(contrastsTemp));
responsesOut = zeros(size(responsesTemp));
nOut = 0;
for i = 1:length(contrastsTemp)
    if (~any(isnan(responsesTemp(i,:))))
        nOut = nOut + 1;
        intensitiesOut(nOut) = contrastsTemp(i);
        responsesOut(nOut,:) = responsesTemp(i,:);
    end
end
intensitiesOut = intensitiesOut(1:nOut);
responsesOut = responsesOut(1:nOut,:);
        



    

