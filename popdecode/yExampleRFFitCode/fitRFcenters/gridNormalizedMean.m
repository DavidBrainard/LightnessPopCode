function data = gridNormalizedMean(filename)
% GRIDNORMALIZEDMEAN gets/plots normalized mean of firing rates

thisname=[filename '_reduceddata.mat'];
eval(['load ' thisname])
xcenters = StimX;
ycenters = StimY;
xs=unique(xcenters); %find the unique xcenters 
numx=length(xs); %number of unique xcenters
ys=unique(ycenters); %find the unique ycenters
numy=length(ys); %number of unique ycenters

%Initialize data to be stored for further analysis.
%data.frGrid = cell(numchannels,1);
%data.normGrid = cell(numchannels,1);
data.channels = channels;
data.fileName = filename;
data.xs = xs;
data.ys = ys;


for ic=1:numchannels %for each channel (electrode)
    c=channels(ic,1);
    u=channels(ic,2);
%----------------------------------------------------------------------
%       Create Firing Rate Grid
%----------------------------------------------------------------------
    if(c<=96)
        thesecounts=stimcounts(ic,:); %get the spike counts for the current channel per stimulus
        frGrid=nans(numy,numx); %make a grid of nans the right size
        for ix=1:numx; %for each unique xcenter
            thisx=xs(ix); %thisx is the current unique xcenter
            for iy=1:numy %for each unique ycenter
                thisy=ys(iy); %thisy is the current unique y center
                counts=thesecounts(xcenters==thisx&ycenters==thisy);%&correct==1
                %get the spike counts from correct trials where the stimulus location
                %matches the x and y center.
                frGrid(iy,ix)=nanmean(counts)*framerate/stimlength;
                %to get firing rate rather than spike count
            end
        end
        data.frGrid{ic} = frGrid;
        frMean = nanmean(frGrid(:));
        frStd = nanstd(frGrid(:));
        normGrid = (frGrid(:)-frMean)./frStd;
        normGrid = reshape(normGrid,numx,numy);
        data.normGrid{ic} = normGrid;
    
% %----------------------------------------------------------------------
% %       Plot
% %----------------------------------------------------------------------
%     figure(1);
%     imagesc(xs,fliplr(ys),frGrid)
%     set(gca,'Ydir','normal')  % to fix the weird y-axis direction in Matlab
%     colormap jet
%     colorbar
%     title(['Electrode #' num2str(c) ', unit #' num2str(u)])
%     thisname=['elec' num2str(c) 'unit' num2str(u) '.png'];
%     exportfig(gcf,thisname,'Format','png','FontMode','fixed','FontSize',12,'Color','cmyk')
%     figure(2); 
%     imagesc(xs,fliplr(ys),normGrid);
%     set(gca,'Ydir','normal')  % to fix the weird y-axis direction in Matlab
%     colormap jet
%     colorbar
%     title(['Normed; Electrode #' num2str(c) ', unit #' num2str(u)])
%     thisname=['elec' num2str(c) 'unit' num2str(u) '_normed.png'];
%     exportfig(gcf,thisname,'Format','png','FontMode','fixed','FontSize',12,'Color','cmyk')
    end
end 
%----------------------------------------------------------------------
%       Combine Normalized Grids
%----------------------------------------------------------------------
for i = 1:length(data.normGrid{1}(:))
    for j = 1:length(data.normGrid)
        tempFR(j) = data.normGrid{j}(i);
    end
    finalGrid(i) = nanmean(tempFR);
end
finalGrid = reshape(finalGrid,numx,numy);
figure(3); 
imagesc(xs,fliplr(ys),finalGrid);
set(gca,'Ydir','normal')  % to fix the weird y-axis direction in Matlab
colormap jet
colorbar
title(['Final Grid - ' filename])
thisname=['FinalGrid_' filename '.png'];
exportfig(gcf,thisname,'Format','png','FontMode','fixed','FontSize',12,'Color','cmyk')