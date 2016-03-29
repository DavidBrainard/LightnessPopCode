function plotRFsVer2(data,varargin)
% PLOTRFS plots receptive fields and their fits
%   Please close existing figures before running!
%   plotRFs(data) takes analyzed data from analyzeRFs and creates plots for
%       each unit, saving them in a default path.
%   plotRFs(...,'Parameter',ParameterValue,...) plots data with available
%       parameters listed below.
%
%   Parameters
%       r2LB - R^2 Lower Bound: When set, plots only those units with fits
%           (R^2 values) better than r2LB. 
%               Default: 'r2LB',.5
%       ampLB - Amplitude + Z Offset Lower Bound: When set, plots only
%           those units with Amp+zOff greater than ampLB. 
%               Default: 'ampLB',40
%       savePath - When set, saves figures to the specified path. Make sure
%               to write the '/' at the end.
%               Default: 'savePath',['Plots/' data.fileName '/']
%       save - Set true or false (or 1 or 0). 1: saves figures in
%           savepath. 0: doesn't save figures.
%               Default: 1
%       plotMesh - Set true or false (or 1 or 0). 1: plots the
%           meshgrid for each unit.
%               Default: 1
%       plotUnit - Set true or false (or 1 or 0). 1: plots each
%           unit's summary statistics plot, with original and gaussian.
%               Default: 1
%       plotTogether - Set true or false (or 1 or 0). 1: plots all
%           units on the same plot, with thickness indicating amplitude and
%           color indicating electrode number.
%               Default: 1
%       setRadius - Sets the all units plot circle radii to the specified 
%           standard deviation multiple. For 95% estimate, set this to 1.96
%               Default: 1 standard deviation. 
%       setFRLims - Sets the scale of firing rates on the plots. [lo hi]
%               Default: [0 120].
%    
%   Examples: 
%       plotRFs(data,'r2LB',0.6,'ampLB',40,'plotUnit',0,'plotMesh',0) plots
%           just the final summary figure with all units.
%    
%   See also ANALYZERFS.

%% AUTHOR    : Jeffrey Chiou 
%% $DATE     : 21-Feb-2013 16:51:04 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 7.14.0.739 (R2012a) 
%% FILENAME  : plotRFs.m 

p = inputParser;
p.addRequired('data',@isstruct);
p.addParamValue('r2LB',.5,@(x) isnumeric(x) && isscalar(x));
p.addParamValue('ampLB',40,@(x) isnumeric(x) && isscalar(x));
p.addParamValue('setRadius',1,@(x) isnumeric(x) && isscalar(x));
p.addParamValue('setFRLims',[0 120],@(x) isvector(x) && x(1)>0 && x(2)>x(1) && length(x)==2);
p.addParamValue('plotMesh',1,@(x) islogical(x)||x==0||x==1);
p.addParamValue('plotUnit',1,@(x) islogical(x)||x==0||x==1);
p.addParamValue('plotTogether',1,@(x) islogical(x)||x==0||x==1);
p.addParamValue('savePath',['Plots/' data.fileName '/'],@ischar);
p.addParamValue('save',1,@(x) islogical(x)||x==0||x==1);
p.addParamValue('channels',length(data.stats),@(x) isnumeric(x))
p.addParamValue('drawRectangle',true,@(x) islogical(x))
p.parse(data,varargin{:});

data = p.Results.data;
r2LB = p.Results.r2LB;
ampLB = p.Results.ampLB;
radMultiple = p.Results.setRadius;
frLims = p.Results.setFRLims;
plotMesh = p.Results.plotMesh;
plotUnit = p.Results.plotUnit;
plotTogether = p.Results.plotTogether;
savePath = p.Results.savePath;
saveFigs = p.Results.save;
channelList = p.Results.channels;
drawRectangle = p.Results.drawRectangle;

mkdir(savePath);
%----------------------------------------------------------------------
%       Individual Figure Creation and Data Storage
%----------------------------------------------------------------------
for channelIDX = channelList
    i = find(data.channelID == channelIDX);
    ampPlusZOff = data.scaled(i,1)+data.scaled(i,7);
    thisname=['elec' num2str(data.channels(i,1)) 'unit' num2str(data.channels(i,2))];
    if(data.stats{i}.r2>r2LB && (ampPlusZOff)>ampLB)
        %set color legend limits for future figures
        clims = frLims;
        if (plotUnit==1)
            h1 = figure(1);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
            set(gcf,'paperpositionmode','auto'); %so saved PNGS are larger.
            suptitle(['Electrode #' num2str(data.channels(i,1)) ', unit #' num2str(data.channels(i,2))])

            subplot(2,2,1);
            imagesc(data.xs,fliplr(data.ys),data.frGrid{i},clims)
            set(gca,'Ydir','normal')  % to fix the weird y-axis direction in Matlab
            colormap jet
            colorbar
            title(['Amp: ' num2str(data.scaled(i,1)) ', zOff: ' num2str(data.scaled(i,7))...
                ', Angle: ' num2str(data.scaled(i,6))])
            %Same scale
            subplot(2,2,2);
            imagesc(data.xs,fliplr(data.ys),data.fitGrid{i},clims);
            set(gca,'Ydir','normal')
            colormap jet
            colorbar
            title(['Center: (' num2str(data.scaled(i,2)) ', ' num2str(data.scaled(i,4))...
                '), R^2: ' num2str(data.stats{i}.r2) ', xWidth: ' num2str(data.scaled(i,3))...
                ', yWidth: ' num2str(data.scaled(i,5))])

            subplot(2,2,3);
            imagesc(data.frGrid{i});
            title(['Amp: ' num2str(data.params(i,1)) ', zOff: ' num2str(data.params(i,7))...
                ', Angle: ' num2str(data.params(i,6))])

            subplot(2,2,4);
            imagesc(data.fitGrid{i});
            title(['Center: (' num2str(data.params(i,2)) ', ' num2str(data.params(i,4))...
                '), R^2: ' num2str(data.stats{i}.r2) ', xWidth: ' num2str(data.params(i,3))...
                ', yWidth: ' num2str(data.params(i,5))])
            
            if (saveFigs==1)
                saveas(h1,[savePath thisname '.png']);
                saveas(h1,[savePath thisname '.fig']);
            end        
        end
        if (plotMesh==1)
            Z = data.frGrid{i};
            [ySize,xSize] = size(Z);
            [X,Y] = meshgrid(1:xSize,1:ySize);
            xdata(:,:,1) = X; % not really the data - this is just the axes matrices. Rename when convenient.
            xdata(:,:,2) = Y;
            [Xhr,Yhr] = meshgrid(linspace(-xSize,xSize*2,6*xSize),linspace(-ySize,ySize*2,6*ySize)); % generate high res grid for plot
            xdatahr(:,:,1) = Xhr;
            xdatahr(:,:,2) = Yhr;
            
            h2 = figure(2);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
            set(gcf,'paperpositionmode','auto'); %so saved PNGS are larger.
            C = del2(Z); %discrete Laplacian
            mesh(X,Y,Z,C) %plot data
            hold on
            surface(Xhr,Yhr,gauss2DFunctionRot(data.params(i,:),xdatahr),'EdgeColor','none') %plot fit
            alpha(0.5)
            rotate3d
            hold off
            if (saveFigs==1)
                saveas(h2,[savePath thisname 'mesh.fig']);
                saveas(h2,[savePath thisname 'mesh.png']);
            end
        end
    end
end
if (plotTogether==1)
    % Simulate left and right array electrode arrangements
    r = randperm(99);
    leftArray = r(1:48); rightArray = r(49:96);
    leftArray = reshape(leftArray,8,6); 
    rightArray = reshape(rightArray,8,6);

    % Color code based on array arrangement
    leftSize = length(leftArray(:)); rightSize = length(rightArray(:));
    colors = jet(leftSize+rightSize);
    bothArrays = [leftArray(:); rightArray(:)];
    
    h3 = figure(3);     
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    set(gcf,'paperpositionmode','auto'); %so saved PNGS are larger.
    hold on;
    %colors = jet(length(data.stats));
    %Loop through and plot
    for channelIDX = channelList
        i = find(data.channelID == channelIDX);
        ampPlusZOff = data.scaled(i,1)+data.scaled(i,7);
        if(data.stats{i}.r2>r2LB && (ampPlusZOff)>ampLB)
            t = linspace(0,2*pi,1000);
            theta0 = data.scaled(i,6);
            a=data.scaled(i,3)*radMultiple;
            b=data.scaled(i,5)*radMultiple;
            x = a*sin(t+theta0)+data.scaled(i,2);
            y = b*cos(t)+data.scaled(i,4);

            %scale line thickness with zoff+amplitude
            %normalize to [10 130] initial range, [1 10] final range.
            [ampThick unitThick] = changeScale(ampPlusZOff,10,130,1,5);

            try
                j = bothArrays==data.channels(i,1);
                color = colors(j,:);
            catch err
                disp('Electrode # and array do not match. Assigning black color')
                disp(err)
                color = 'k';
            end
            % Sometimes, with the random array generation, the electrode
            % doesn't have a corresponding location in the array. In this
            % case, we assign black as the color.
            if isempty(color)
                color = 'k';
            end
            
            plot(x,y,'Color',color,'LineWidth',ampThick);
        end
    end
    
    if drawRectangle
    rectangle('Position',[data.xs(1),data.ys(1),...
        data.xs(end)-data.xs(1),data.ys(end)-data.ys(1)],...
        'LineStyle','--');
    end
    
    axis equal;
    hold off;
    
    if (saveFigs==1)
        saveas(h3,[savePath 'All.fig']);
        saveas(h3,[savePath 'All.png']);
    end
end
