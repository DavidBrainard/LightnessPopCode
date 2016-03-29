function err = ComputeDecodingError(decodeInfo,contrasts,predictions)
% err = ComputeDecodingError(decodeInfo,contrasts,predictions)
%
% Compute prediciton error in a consistent manner across 
% conditions.
%
% 10/31/13  dhb  Pulled it out.

%% Tuck away rmse paint prediction error in percent
switch (decodeInfo.errType)
    case 'mean'
        err = 100*sqrt(mean((contrasts-predictions).^2));
    case 'median'
        err = 100*sqrt(median((contrasts-predictions).^2));
    otherwise
        error('Unknown error type specified');
end