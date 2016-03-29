function rfData = FitRF(filename)
% ANALYZERFS Finds RFs and fits them to Gaussians; version for Doug's data

%   Multi-line paragraphs of descriptive text go here. Ex: 
%   rfData = analyzeRFs(filename) takes a string of the filename (without
%       the file extension) and returns rfData.
%   rfData contains:
%       params: parameters of the Gaussian fit for each channel
%       stats: calculated statistics related to the fit for each channel
%       frGrid: matrices containing firing rate and position data for each
%           channel
%       fitGrid: matrices containing firing rate predicted by the 2D
%           Gaussian equation
%       scaled: parameters scaled to match x and y pixel positions. Amp,
%           zOff, and angle unaffected
%
%   More detailed help is in the <a href="matlab: help analyzeRFs>extended_help">extended help</a>. 
%    
%   Examples: 
%      rfData = analyzeRFs('Z:\Jeff\Matlab Files\fy121007map0001-sortedGina'); 
%     
%   See also PLUS, SUM, SOMECLASS/SOMEMETHOD. 

%% AUTHOR    : Jeffrey Chiou 
%% $DATE     : 21-Feb-2013 17:18:28 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 7.14.0.739 (R2012a) 
%% FILENAME  : analyzeRFs.m 

thisname=[filename '_reduceddata.mat'];
eval(['load ' thisname])

xs=unique(StimX); %find the unique xcenters 
numx=length(xs); %number of unique xcenters
ys=unique(StimY); %find the unique ycenters
numy=length(ys); %number of unique ycenters

%Initialize data to be stored for further analysis.
rfData.params = zeros(numchannels,7);
rfData.stats = cell(numchannels,1);
rfData.frGrid = cell(numchannels,1);
rfData.fitGrid = cell(numchannels,1);
rfData.scaled = zeros(numchannels,7);
rfData.channels = channels;
rfData.fileName = filename;
rfData.xs = xs;
rfData.ys = ys;






for ic=1:numchannels %for each channel (electrode)    
%----------------------------------------------------------------------
%       Create Firing Rate Grid
%----------------------------------------------------------------------
    thesecounts=stimcounts(ic,:); %get the spike counts for the current channel per stimulus
    frGrid=nans(numy,numx); %make a grid of nans the right size
    CenterOfMass = zeros(numx,2);
    for ix=1:numx; %for each unique xcenter
        thisx=xs(ix); %thisx is the current unique xcenter
        for iy=1:numy %for each unique ycenter
            thisy=ys(iy); %thisy is the current unique y center
            counts=thesecounts(StimX==thisx & StimY==thisy & isfinite(thesecounts)); %&CorrectCount==1);
            %get the spike counts from correct trials where the stimulus location
            %matches the x and y center.
            frGrid(iy,ix)=nanmean(counts)*framerate/stimlength;
            CenterOfMass = [CenterOfMass;frGrid(iy,ix).*[ix,iy]./ sum(counts(isfinite(counts)))];
            %to get firing rate rather than spike count
        end
    end
    ValidIndex =  isfinite(sum(CenterOfMass,2));
    CenterOfMass = mean(CenterOfMass(ValidIndex,:),1);
    
%----------------------------------------------------------------------
%       2D Gaussian Fit and Related Calculations
%----------------------------------------------------------------------
    % 2D Gaussian Fit
    [ySize,xSize] = size(frGrid);
    [XThick,Y] = meshgrid(1:xSize,1:ySize);
    xdata(:,:,1) = XThick; % not really the data - this is just the axes matrices. Rename when convenient.
    xdata(:,:,2) = Y;

    %find image moment for x0 and y0, use size of grid for sigmax and sigmay,
    %use mean(max(img)+mean(img)) for amplitude.
    amp = (max(frGrid(:))+mean(frGrid(:)))/2;
    zOff = (min(frGrid(:))+mean(frGrid(:)))/2;
    %calculate centroid using moments
    xGuess = sum(frGrid(:).*XThick(:))/sum(frGrid(:));
    yGuess = sum(frGrid(:).*Y(:))/sum(frGrid(:));
    % parameters are: [Amplitude, x0, sigmax, y0, sigmay, angle(in rad), zoffset]
    % x0 = [amp,xGuess,xSize,yGuess,ySize*2,0,zOff]; %Inital guess parameters
    x0 = [amp,CenterOfMass(1),CenterOfMass(2),0,0];
    %---------------------Fit---------------------
    %Set upper amp limit to around 300 (highest firing rates in visual areas)
    %lb = [0,0,0,0,0,-pi/4,0];
    %ub = [300-min(frGrid(:)),xSize,xSize^2,ySize,ySize^2,pi/4,inf];
    lb = [0,-2,-2,0,0];
    ub = [Inf,xSize+2,ySize+2,5,500];
    %[x,resnorm,residual,exitFlag] = lsqcurvefit(@gauss2DFunctionRot,x0,xdata,frGrid,lb,ub);
    [x,resnorm,residual,exitFlag] = lsqcurvefit(@FitCircularGaussianRF,x0,xdata,frGrid);
    
    % Calculate relevant statistics here.
    rfData.stats{ic}.residuals = residual;
    rfData.stats{ic}.r2 = 1 - sum(residual(:).^2) / sum((frGrid(:)-mean(frGrid(:))).^2); %Find r^2
    rfData.stats{ic}.exitFlag = exitFlag;
    rfData.stats{ic}.resNorm = resnorm;
    
    % Reconstruction of the 2D Gaussian function into a grid
    %rfData.fitGrid{ic} = gauss2DFunctionRot(x,xdata);
    rfData.fitGrid{ic} = FitCircularGaussianRF(x,xdata);
    % Scaling
    [xcScaled xUnit] = changeScale(x(2),1,length(xs),xs(1),xs(end));
    [ycScaled yUnit] = changeScale(x(3),1,length(ys),ys(end),ys(1));
    % Y fLo and Y fHi are reversed because computers measure pixels from
    % the top left corner.
    xwScaled = x(3)*xUnit;
    ywScaled = x(5)*yUnit;
    %rfData.scaled(ic,:) = [x(1), xcScaled, xwScaled, ycScaled, ywScaled, x(6), x(7)];    
    %rfData.scaled(ic,:) = [xcScaled ycScaled];    
    %rfData.params(ic,:) = x;
    rfData.frGrid{ic} = frGrid;
    %DAR add output that tells me RF center (which was made above using
    %changeScale function
    rfData.FitCenter(ic,:) = [xcScaled, ycScaled]; %in pixels
end
end 

function [GaussianRF] = FitCircularGaussianRF(X0,Coords)

Amplitude = X0(1);
X = X0(2);
Y = X0(3);
Radius = X0(3);
Baseline = X0(4);

GaussianRF = Baseline + Amplitude .* exp(-((Coords(:,:,1)-X).^2 + (Coords(:,:,2)-Y).^2)./(2*Radius));


end


function extended_help 
%EXTENDED_HELP Some additional technical details and examples 
%    
%   Here is where you would put additional examples, technical discussions, 
%   documentation on obscure features and options, and so on. 
    
   error('This is a placeholder function just for helptext'); 
end 
