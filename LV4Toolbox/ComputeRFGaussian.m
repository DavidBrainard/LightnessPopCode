function zData = ComputeRFGaussian(x,xyData)
% zData = ComputeRFGaussian(x,xyData)
%
% Input x is a vector of Guassian parameters.
%   [meanX, meanY, sigmaX, sigmaY, A, B]
% where A is a multiplicative scalar on the Gaussian and B is the additive
% offset.
% Computes a 2D Gaussian surface with an additive offset. Used to fit RF data.
% The Gaussian is normalized to max of one before application of leading
% constant, not as a PDF.  That keeps things simpler.
%
% There is a separate x and y standard deviation, but no rotation, in the
% current implementation.
%
% Input xyData has two matrices generated with meshgrid, indexed by the
% third dimension.
%
% This is meant to be used in conjunction with FitGaussianToRF.
%
% 8/9/15  dhb  Wrote it.
% 8/14/15 dhb  Fix normalization to be as intended.

% Get the x andy meshes
xMesh = xyData(:,:,1);
yMesh = xyData(:,:,2);

% Parameters from x
meanX = x(1);
meanY = x(2);
sigmaX = x(3);
sigmaY = x(4);
A =x(5);
B = x(6);

% Form the args to the exponent of the Gaussian
xArg = ((xMesh-meanX)/sigmaX).^2;
yArg = ((yMesh-meanY)/sigmaY).^2;

% Compute
zData = B + A*exp(-0.5*(xArg + yArg));

end