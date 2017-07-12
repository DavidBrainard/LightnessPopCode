function decodeInfo = GetTheDecoderRegressionParams(decodeInfo,contrasts,responses)
% decodeInfo = GetTheDecoderRegressionParams(decodeInfo,contrasts,responses)
%
% Get the regression part of the decoder, without the static nonlinearity
%
% 10/31/13  dhb  Happy holloween.
% 11/9/15   dhb  Supress rank deficient warning, but print out message of our own.
%           dhb  Don't print out warning.

nContrasts = length(contrasts);

switch decodeInfo.type
    case {'aff' 'betacdf', 'betadoublecdf', 'smoothing'}
        X = [responses ones(nContrasts,1)];
        if (rank(responses) < size(responses,2))
            % fprintf('\tResponse matrix is not of full rank (rank = %d, column size = %d)\n',rank(responses),size(responses,2))
        end
        S = warning('off','MATLAB:rankDeficientMatrix');
        decodeInfo.b = X\contrasts;
        warning(S.state,S.identifier);
    case {'svmreg'}
        X = [responses ones(nContrasts,1)];
        
        decodeInfo.svmOpts = ['-s ' num2str(decodeInfo.svmSvmType) ' -t ' num2str(decodeInfo.svmKernalType)]; 
        if (decodeInfo.svmQuiet)
            decodeInfo.svmOpts =  [decodeInfo.svmOpts ' -q'];
        end
        if (~isempty(decodeInfo.svmNu))
            decodeInfo.svmOpts = [decodeInfo.svmOpts ' -n ' num2str(decodeInfo.svmNu)];
        end
        if (~isempty(decodeInfo.svmGamma))
            decodeInfo.svmOpts = [decodeInfo.svmOpts ' -g ' num2str(decodeInfo.svmGamma)];
        end
        if (~isempty(decodeInfo.svmDegree))
            decodeInfo.svmOpts = [decodeInfo.svmOpts  ' -d ' num2str(decodeInfo.svmDegree)];
        end
        decodeInfo.svmModel = svmtrain(contrasts, X, decodeInfo.svmOpts);
        [temp,accuracy] = svmpredict(rand(size(contrasts)),X,decodeInfo.svmModel,'');
        figure; clf;
        plot(contrasts,temp,'ro','MarkerSize',6,'MarkerFaceColor','r');
        drawnow;
        
    otherwise
        error('Unknown decoder type specified');
end
end