function results = FitGaussianToRF(xMesh,yMesh,rfDataMesh)
% results = FitGaussianToRF(xMesh,yMesh,rfDataMesh)
% 
% Fit Gaussian surface with an additive offset to RF data.
%
% The engine is lsqcurvefit.  A grid search on starting points
% is used with the best fit returned, as an attempt to minimize
% effects of local minima.
%
% Output struct results returns the fit as well as its parameters.
%   results.fit      -- the fit
%   results.err      -- error of fit, returned by lsqcurvefit
%   results.meanX    -- x dimension mean
%   results.meanY    -- y dimension mean
%   results.sigmaX   -- x dimension standard deviation
%   results.sigmaY   -- y dimension standard deviation
%   results.A        -- multiplicative scalar
%   results.B        -- additive offset
%
% See also ComputeRFGaussian.
%
% 8/9/15  dhb  Wrote it.
    
%% Initial parameters
meanX0 = mean(xMesh(:));
meanY0 = mean(yMesh(:));
sigmaX0 = (max(xMesh(:))-min(xMesh(:)))/4;
sigmaY0 = (max(yMesh(:))-min(yMesh(:)))/4;
A0 = 2*max(rfDataMesh(:));
B0 = 0.5*min(rfDataMesh(:));
x0 = [meanX0 meanY0 sigmaX0 sigmaY0 A0 B0];

%% Parameter bounds.
lb = [min(xMesh(:)) min(yMesh(:)) 0 0 0 0];
ub = [max(xMesh(:)) max(yMesh(:)) 16*sigmaX0 16*sigmaY0 4*A0 A0];

%% Put data into correct format
xData(:,:,1) = xMesh;
xData(:,:,2) = yMesh;
yData = rfDataMesh;

%% Use lsqcurvefit to do the work on best initial guess
options = optimoptions('lsqcurvefit','Display','off','MaxFunEvals',1000);
[x,srcherr] = lsqcurvefit(@ComputeRFGaussian,x0,xData,yData,lb,ub,options);
bestX = x;
bestErr = srcherr;

%% Gridsearch to see if we can do better
aFactors = [0.5 1 2]; nAFactors = length(aFactors);
stdFactors = [1 4 8]; nStdFactors = length(stdFactors);
nX = size(xMesh,1);
nY = size(xMesh,2);
for xx = 1:nX
    for yy = 1:nY
        meanX0 = xMesh(xx,yy);
        meanY0 = yMesh(xx,yy);
        for aa = 1:nAFactors
            A0 = aFactors(aa)*max(rfDataMesh(:));
            for ss = 1:nStdFactors
                sigmaX0 = (max(xMesh(:))-min(xMesh(:)))/stdFactors(ss);
                sigmaY0 = (max(yMesh(:))-min(yMesh(:)))/stdFactors(ss);
                
                x0 = [meanX0 meanY0 sigmaX0 sigmaY0 A0 B0];
                [x,srcherr] = lsqcurvefit(@ComputeRFGaussian,x0,xData,yData,lb,ub,options);
                if (srcherr < bestErr)
                    bestErr = srcherr;
                    bestX = x;
                end
            end
        end
    end
end

%% Return fit and parameters
results.fit = ComputeRFGaussian(bestX,xData);
results.err = bestErr;
results.meanX = bestX(1);
results.meanY = bestX(2);
results.sigmaX = bestX(3);
results.sigmaY = bestX(4);
results.A = bestX(5);
results.B = bestX(6);

end

