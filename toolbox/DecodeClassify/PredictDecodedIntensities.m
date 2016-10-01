function predictedIntensities = PredictDecodedIntensities(decodeInfoIn,fitObject,inputIntensities)
% predictedIntensities = PredictDecodedIntensities(decodeInfoIn,fitObject,inputIntensities)
%
% Get fit intensities, given fit parameters already obtained.
%
% See also FitDecodedIntensities.
%
% 3/24/14  dhb  Pulled it out

% Fit the decoded shadow and paint data with a smooth curve
switch (decodeInfoIn.decodedIntensityFitType)
    case {'smoothingspline' 'betacdf'}
        predictedIntensities = feval(fitObject,inputIntensities);
    otherwise
        error('Unknown decodeIntensityFitType specified');
end