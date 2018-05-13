function decodeInfo = GetTheDecoderRegressionParams(decodeInfo,contrasts,responses)
% decodeInfo = GetTheDecoderRegressionParams(decodeInfo,contrasts,responses)
%
% Get the regression part of the decoder, without the static nonlinearity
%
% 10/31/13  dhb  Happy holloween.
% 11/9/15   dhb  Supress rank deficient warning, but print out message of our own.
%           dhb  Don't print out warning.
% 05/09/18  dhb  Add regularized regression via fitrlinear.

nContrasts = length(contrasts);

switch decodeInfo.type
    case {'aff'}
        X = [responses ones(nContrasts,1)];
        if (rank(responses) < size(responses,2))
            % fprintf('\tResponse matrix is not of full rank (rank = %d, column size = %d)\n',rank(responses),size(responses,2))
        end
        S = warning('off','MATLAB:rankDeficientMatrix');
        decodeInfo.b = X\contrasts;
        warning(S.state,S.identifier);
        
    case 'fitrlinear'
        % This is by default a form of SVM regression
        X = [responses ones(nContrasts,1)];
        regFitResults = fitrlinear(X,contrasts,'FitBias',false);
        decodeInfo.b = regFitResults.Beta;
        
    case 'fitrcvlasso'
        X = responses;
        
        % Cross validation step, to choose best lambda.
        lambda = logspace(-5,1,25);
        regFitResultsCV = fitrlinear(X',contrasts, ...
            'ObservationsIn','columns','KFold',5,'Lambda',lambda, ...
            'Learner','leastsquares','Solver','sparsa','Regularization','lasso', ...
            'FitBias',true);
        mseCVLambda = kfoldLoss(regFitResultsCV);
        [~,rindex] = min(mseCVLambda);
        
        % Do all the lambdas here so we can snag and return the number of
        % non-zero coeffs for each. Costs a little time, but could be
        % useful for diagnostics later.
        regFitResults = fitrlinear(X',contrasts, ...
            'ObservationsIn','columns','Lambda',lambda, ...
            'Learner','leastsquares','Solver','sparsa','Regularization','lasso', ...
            'FitBias',true);
        numNZCoef = sum(regFitResults.Beta~=0);
        decodeInfo.b = [regFitResults.Beta(:,rindex) ; regFitResults.Bias(rindex)];
        decodeInfo.numNZCoef = numNZCoef(rindex);
        decodeInfo.useLambda = lambda(rindex);
        decodeInfo.lambda = lambda;
        decodeInfo.mseCVLambda = mseCVLambda;
        decodeInfo.numNZCoefLambda = numNZCoef;
        
        %{
        tempFig = figure; hold on;
        [h,hL1,hL2] = plotyy(log10(lambda),log10(mseCV),log10(lambda),log10(numNZCoef));
        hL1.Marker = 'o';
        hL2.Marker = 'o';
        plot(log10(lambda(rindex)),log10(mseCV(rindex)),'kx');
        plot(log10(lambda(rindex)),log10(numNZCoef(rindex)),'kx');
        ylabel(h(1),'log_{10} Cross-Validated MSE')
        ylabel(h(2),'log_{10} Number Nonzero Reg Coeffs')
        xlabel('log_{10} Lasso Lambda')
        title(sprintf('Number NZ coeefs: %d\n',numNZCoef(rindex)));
        pause
        close(tempFig);
        %}
        
    case 'fitrcvridge'
        X = responses;
        
        % Cross validation step, to choose best lambda.
        lambda = logspace(-5,1,25);
        regFitResultsCV = fitrlinear(X',contrasts, ...
            'ObservationsIn','columns','KFold',5,'Lambda',lambda, ...
            'Learner','leastsquares','Solver','lbfgs','Regularization','ridge', ...
            'FitBias',true);
        mseCVLambda = kfoldLoss(regFitResultsCV);
        [~,rindex] = min(mseCVLambda);
        
        % Do all the lambdas here so we can snag and return the number of
        % non-zero coeffs for each. Costs a little time, but could be
        % useful for diagnostics later.
        regFitResults = fitrlinear(X',contrasts,'Lambda',lambda, ...
            'ObservationsIn','columns', ...
            'Learner','leastsquares','Solver','lbfgs','Regularization','ridge', ...
            'FitBias',true);
        numNZCoef = sum(regFitResults.Beta~=0);
        decodeInfo.b = [regFitResults.Beta(:,rindex) ; regFitResults.Bias(rindex)];
        decodeInfo.numNZCoef = numNZCoef(rindex);
        decodeInfo.useLambda = lambda(rindex);
        decodeInfo.lambda = lambda;
        decodeInfo.mseCVLambda = mseCVLambda;
        decodeInfo.numNZCoefLambda = numNZCoef;
        
    case 'lassoglm1'
        X = responses;
        
        % Fit the model
        model = 'normal';
        link = 0.6;
        [BCV,FitInfoCV] = lassoglm(X,contrasts, model, 'Link', link,  ...
            'NumLambda', 25, 'CV', 5);
        rindex = FitInfoCV.IndexMinDeviance;
        [B,FitInfo] = lassoglm(X,contrasts, model,  ...
            'Lambda', FitInfoCV.Lambda(rindex));
        
        % Save answer
        decodeInfo.b = [B ; FitInfo.Intercept];
        decodeInfo.numNZCoef = sum(B~=0);
        decodeInfo.useLambda = FitInfoCV.Lambda(rindex);
        decodeInfo.lambda = FitInfoCV.Lambda;
        decodeInfo.mseCVLambda = FitInfoCV.Deviance;

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