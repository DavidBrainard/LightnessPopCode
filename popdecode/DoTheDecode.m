function decodeInfo = DoTheDecode(decodeInfo,intensities,responses)
% decodeInfo = DoTheDecode(decodeInfo,intensities,responses)
%
% Build the decoder and return appropriate info about it.
%
% 3/23/14  dhb  Factorized this out.

% Get/check dimensions
[nIntensities,nResponses] = size(responses);
if (length(intensities) ~= nIntensities)
    error('nIntensities mismatch');
end

% Build the decoder according to passed type
switch decodeInfo.type
    case {'aff' 'svmreg'};
        decodeInfo = GetTheDecoderRegressionParams(decodeInfo,intensities,responses);
    case {'maxlikely' 'maxlikelyfano' 'mlbayes' 'mlbayesfano'}
        decodeInfo = GetTheDecoderMaxLikelyParams(decodeInfo,intensities,responses);
    case 'betacdf'
        % Prevent numerical issues with normal inverse cdf
        intensities(intensities < 0.001) = 0.001;
        intensities(intensities > 0.999) = 0.999;
        
        % Set reasonable bounds on parameters
        x0 = [1 1 1];
        vlb = [0.1 0.1 0.1];
        vub = [100  100 10];
        options = optimset('fmincon');
        options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set');
        x = fmincon(@(x)DecoderErrorFunction(x,decodeInfo,intensities,responses),x0,[],[],[],[],vlb,vub,[],options);
        
        % Extract final params
        decodeInfo.betacdfA = x(1);
        decodeInfo.betacdfB = x(2);
        decodeInfo.betacdfScale = x(3);
        decodeInfo = GetTheDecoderRegressionParams(decodeInfo,intensities,responses);
        
    case 'betadoublecdf'
        % Prevent numerical issues with normal inverse cdf
        intensities(intensities < 0.001) = 0.001;
        intensities(intensities > 0.999) = 0.999;
        
        % Search options
        options = optimset('fmincon');
        options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
        
        % Set power function part with betacdf fixed
        x0 = [1 1 1 1 1];
        vlb = [1 1 0.1 0.1 0.1];
        vub = [1 1 100 100 10];
        x = fmincon(@(x)DecoderErrorFunction(x,decodeInfo,intensities,responses),x0,[],[],[],[],vlb,vub,[],options);
        
        % Set betacdf with power function fixed
        x0 = [1 1 x(3) x(4) x(5)];
        vlb = [0.1 0.1 x(3) x(4) x(5)];
        vub = [1 1 x(3) x(4) x(5)];
        x = fmincon(@(x)DecoderErrorFunction(x,decodeInfo,intensities,responses),x0,[],[],[],[],vlb,vub,[],options);
        
        % Do full fit
        x0 = x;
        vlb = [0.1 0.1 0.1 0.1 0.1];
        vub = [100 100 100 100 10];
        x = fmincon(@(x)DecoderErrorFunction(x,decodeInfo,intensities,responses),x0,[],[],[],[],vlb,vub,[],options);
        bestX = x;
                
        % Multiple start point method.  Didn't seem to help but might work better
        % with a different functional form
        if (0)
            vlb = [0.1 0.1 0.1 0.1 0.1];
            vub = [100 100 100 100 10];
            A1Starts = [1];
            B1Starts = [1];
            A2Starts = [1 2];
            B2Starts = [1 2];
            bestErr = Inf;
            bestX = [NaN NaN NaN NaN NaN];
            nStarts = length(A1Starts)*length(B1Starts)*length(A2Starts)*length(B2Starts);
            nSearched = 0;
            for i = 1:length(A1Starts)
                for j = 1:length(B1Starts)
                    for k = 1:length(A2Starts)
                        for l = 1:length(B2Starts)
                            x0 = [A1Starts(i) B1Starts(j) A2Starts(k) B2Starts(l) 1];
                            x = fmincon(@(x)DecoderErrorFunction(x,decodeInfo,intensities,responses),x0,[],[],[],[],vlb,vub,[],options);
                            theErr = DecoderErrorFunction(x,decodeInfo,intensities,responses);
                            if (theErr < bestErr)
                                bestX = x;
                                bestErr = theErr;
                            end
                            nSearched = nSearched + 1;
                            fprintf('Search %d of %d, current error %0.1f, best error = %0.1f\n',nSearched,nStarts,theErr,bestErr);
                        end
                    end
                end
            end
        end
        
        % Extract final params
        decodeInfo.betacdfA1 = bestX(1);
        decodeInfo.betacdfB1 = bestX(2);
        decodeInfo.betacdfA2 = bestX(3);
        decodeInfo.betacdfB2 = bestX(4);
        decodeInfo.betacdfScale = bestX(5);
        decodeInfo = GetTheDecoderRegressionParams(decodeInfo,intensities,responses);
        
    case 'smoothing'
        % Do the affine prediction
        decodeInfoTemp = decodeInfo;
        decodeInfoTemp.type = 'aff';
        decodeInfoTemp = GetTheDecoderRegressionParams(decodeInfoTemp,intensities,responses);
        affinePreds = DoTheDecodePrediction(decodeInfoTemp,responses);
        [ameans,astes,~,~,~,axs]=sortbyx(intensities,affinePreds);
        
        % Do the smoothing spline
        method = 'smoothingspline';
        foptions = fitoptions(method);
        switch (method)
            case 'smoothingspline'
                foptions.SmoothingParam = decodeInfo.smoothingParam;
        end
        decodeInfo.fit = fit([0 ; ameans'],[0 ; axs],method,foptions);
        decodeInfo = GetTheDecoderRegressionParams(decodeInfo,intensities,responses);
        
    otherwise
        error('Unknown type specified');
end

end









