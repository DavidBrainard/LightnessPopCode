function results = FitGaussianToRF(xMesh,yMesh,rfDataMesh)
    

%% Initial parameters
meanX0 = mean(xMesh(:));
meanY0 = mean(yMesh(:));
sigmaX0 = (max(xMesh(:))-min(xMesh(:)))/4;
sigmaY0 = (max(yMesh(:))-min(yMesh(:)))/4;
A0 = max(rfDataMesh(:));
B0 = min(rfDataMesh(:));

x0 = [meanX0 meanY0 sigmaX0 sigmaY0 A0 B0];
lb = [min(xMesh(:)) min(yMesh(:)) 0 0 0 0];
ub = [max(xMesh(:)) max(yMesh(:)) 16*sigmaX0 16*sigmaY0 2*A0 A0];

xData(:,:,1) = xMesh;
xData(:,:,2) = yMesh;
yData = rfDataMesh;

x0 = [meanX0 meanY0 sigmaX0 sigmaY0 A0 B0];
x = lsqcurvefit(@ComputeRFGaussian,x0,xData,yData,lb,ub);

results.fit = ComputeRFGaussian(x,xData);
results.meanX = x(1);
results.meanY = x(2);
results.sigmaX = x(3);
results.sigmaY = x(4);
results.A =x(5);
results.B = x(6);

end

function yData = ComputeRFGaussian(x,xData)

xMesh = xData(:,:,1);
yMesh = xData(:,:,2);

meanX = x(1);
meanY = x(2);
sigmaX = x(3);
sigmaY = x(4);
A =x(5);
B = x(6);

xArg = ((xMesh-meanX)/sigmaX).^2;
yArg = ((yMesh-meanY)/sigmaY).^2;


yData = B + A*(1/sqrt(sigmaX*sigmaY))*exp(-0.5*(xArg + yArg))/(2*pi);
end