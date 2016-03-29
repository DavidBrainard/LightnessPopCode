function fitObject = FitDecodedIntensities(decodeInfoIn,trueIntensities,decodedIntensities)
% fitObject = FitDecodedIntensities(decodeInfoIn,trueIntensities,decodedIntensities)
%
% Fit decoded intensities according to method specified in decodeInfoIn
%
% See also PredictDecodedIntensities
%
% 3/24/14  dhb  Pulled it out


% Fit the decoded shadow and paint data with a smooth curve
switch (decodeInfoIn.decodedIntensityFitType)
    case 'smoothingspline'
        foptions = fitoptions('smoothingspline');
        foptions.SmoothingParam = decodeInfoIn.decodedIntensityFitSmoothingParam;
        fitObject = fit(trueIntensities,decodedIntensities,'smoothingspline',foptions);
    case 'betacdf'
        % Set reasonable bounds on parameters
        x0 = [0.2 0.6 1 1];
        vlb = [0 0 0.1 0.1];
        vub = [1 1 100 100];
        ftype = fittype('a+b*betacdf(x,c,d)');
        foptions = fitoptions('Method','NonlinearLeastSquares','StartPoint',x0,'Lower',vlb,'Upper',vub);
        fitObject = fit(trueIntensities,decodedIntensities,ftype,foptions);
    otherwise
        error('Unknown decodeIntensityFitType specified');
end