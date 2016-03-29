
% these are some notes showing the code I (DAR) used to make figures
% showing weighted RF plots based on decoding weights.

%load the RF map file
load BR130914RFmap0001-sort_reduceddata
%load the channel lists
load BR130914Lightness0002GoodChannels

%for sharing purposes, here are the weights from a condition from that day's lightness decoding:
Weight = [
  -0.00078856
   -0.0013653
   -0.0039574
   -0.0012414
    -0.001859
  -0.00068601
     -0.00206
   0.00077433
   -0.0001815
   -0.0023751
     0.001344
  -0.00022756
   -0.0013349
   0.00010854
   0.00043973
   0.00079548
  -0.00086809
   -0.0038421
    -0.003705
    0.0017867
  -0.00040118
   0.00089647
   0.00035914
    0.0019318
   0.00078172
   -0.0025579
   0.00012847
   0.00056995
    0.0027938
    0.0018294
   -0.0022621
  -0.00011137
   0.00023032
    0.0025693
   -0.0014854
    -7.47e-05
   -0.0015621
   -0.0018444
   0.00033455
   0.00070524
   -0.0015209
   0.00075609
  -0.00070974
  -0.00089477
   0.00050037
   0.00077746
   0.00085634
   -0.0015897
   -0.0023919
    0.0019073
  -0.00071839
   0.00043488
   -0.0012593
   0.00040477
    0.0022998
    0.0017521
   0.00028813
     -3.6e-05
  -0.00011781
   0.00077086
    0.0070341
  -0.00028823
   0.00025699
   0.00045202
   -0.0022013
   -0.0011143
    0.0012167
   -0.0022626
    0.0045808
   -0.0015213
    0.0024142
   0.00031119
    0.0047157
   -0.0025873
    0.0031883
   0.00054174
  -0.00033796
  -0.00071441
  -0.00074091
    0.0020372
  -0.00013185
  -0.00065804
    0.0010158
   0.00052417
   0.00016569
  -0.00074746
   -0.0026897
   0.00084316
     0.001708
   -0.0011553
    0.0037141];


% get the RF map plots for each unit
% i'm calling them 'grids'

xs=unique(StimX);
numx=length(xs);
ys=unique(StimY);
numy=length(ys);

for ic=1:numchannels
    c=channels(ic,1);
    u=channels(ic,2);
    thesecounts=stimcounts(ic,:);
    thisgrid=nans(numy,numx);
    for ix=1:numx;
        thisx=xs(ix);
        for iy=1:numy
            thisy=ys(iy);
            counts=thesecounts(StimX==thisx&StimY==thisy);   
            thisgrid(iy,ix)=nanmean(counts)*framerate/stimlength; % to get firing rate rather than spike count
            AllGrids{ic}.thisgrid=thisgrid;
            AllGrids{ic}.normgrid=thisgrid/(max(thisgrid(:)));
        end
    end

end

% Index AllGrids so that it is just the channels used in the decoding
for i = 1:length(GoodChannelListsThisOne.ChListIDX)
UsedGrids{i} = AllGrids{GoodChannelListsThisOne.ChListIDX(i)};
end

%% Make some different types of average RF plots
% just use one of the following sections at a time

%% non weighted avg RF map
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
        PopRF = PopRF + UsedGrids{i}.thisgrid ;      
end
%% non weighted avg RF map, normalized
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
        PopRF = PopRF + UsedGrids{i}.normgrid ;       
end
PopRF= PopRF/length(UsedGrids);

%% basic approach
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)    
        PopRF = PopRF + (UsedGrids{i}.thisgrid .* Weight(i));       
end

%% normalized maps
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
        PopRF = PopRF + (UsedGrids{i}.normgrid .* Weight(i));        
end

%% normalized  but use just positive weights
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
    if Weight(i) >0
        PopRF = PopRF + (UsedGrids{i}.normgrid .* Weight(i));        
    else
    end
end

%%
% normalized  but use just negative weights
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
    if Weight(i) <0
        PopRF = PopRF + (UsedGrids{i}.normgrid .* Weight(i));       
    else
    end
end


%% basic approach  but use just positive weights
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
    if Weight(i) >0
        PopRF = PopRF + (UsedGrids{i}.thisgrid .* Weight(i));       
    else
    end
end


%% basic approach  but use just BIG positive weights
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
    if Weight(i) >0.005
        PopRF = PopRF + (UsedGrids{i}.thisgrid .* Weight(i));      
    else
    end
end


%% basic approach  but use just negative weights
PopRF=zeros(5,5);
for i = 1:length(UsedGrids)   
    if Weight(i) <0
        PopRF = PopRF + (UsedGrids{i}.thisgrid .* Weight(i));       
    else
    end
end




%% make plot
figure;
    imagesc(xs,ys,PopRF)   % imagesc(xs,fliplr(ys),thisgrid)
    set(gca,'Ydir','normal')  % to fix the weird y-axis direction in Matlab
    colormap jet
    colorbar
    title(['Population weighted RF'])
    
    
%%
%%
%%  Now make weight based, average luminance plots
%v1
filename='BR130914Lightness0002'

ReducedData = [filename '_ReducedData_Share'];
eval(['load ' ReducedData]);

numunits=length(GoodChannelListsThisOne.ChListIDX);
Conts=unique(suffix);
numConts=numel(Conts);
Sizes=unique(sizeX);
numSizes=numel(Sizes);
StimXs=unique(centerX);
numStimXs=numel(StimXs);
idx = outcome==150;
xvals = Conts(1:21)-1000;

for i=1:numunits
    for s = 1:numStimXs %go through all sizes
        for c=1:numConts; %go through each condition
            thisCond = SpikeCount(i,centerX==StimXs(s)&suffix==Conts(c)&idx);
            %for each channel,
            %find spike counts of a paticular location and contrast
            Rates(c,s,i) = nanmean(thisCond);
            Rates_error(c,s,i) = nanstd(thisCond)/sqrt(numel(~isnan(thisCond)));
        end
    end
end

%then, collapse across all units.
for s = 1:numStimXs
    for q = 1:42
        AvgRates(q,s) = nanmean(Rates(q,s,1:numunits));
        AvgSTE(q,s) = nanstd(Rates(q,s,1:numunits))/sqrt(numunits);
    end
end

for j = 1:numStimXs
    subplot(numStimXs,1,j)
    errorbar(xvals,AvgRates(1:21,j),AvgSTE(1:21,j))
    hold on;
    errorbar(xvals,AvgRates(22:end,j),AvgSTE(22:end,j),'k')
    title(['Population Average ' num2str(StimXs(j)) ' x pos'])
    xlim([-5 110]);
    %ylim([0 max(AvgRates(:))+10]);
end

%%   use weights to pick units
LIST = (Weight>.001);  %determine which units to include based on their weights
for s = 1:numStimXs
    for q = 1:42
        AvgRates(q,s) = nanmean(Rates(q,s,LIST));
        AvgSTE(q,s) = nanstd(Rates(q,s,LIST))/sqrt(sum(LIST));
    end
end

figure; errorbar(xvals,AvgRates(22:end,2),AvgSTE(22:end,2),'k')
title(['Population Average ' num2str(StimXs(j)) ' x pos'])
xlim([15 80]);
ylim([25 35])

%     figure;
%     for j = 1:numStimXs
%         subplot(numStimXs,1,j)
%         errorbar(xvals,AvgRates(1:21,j),AvgSTE(1:21,j))
%         hold on;
%         errorbar(xvals,AvgRates(22:end,j),AvgSTE(22:end,j),'k')
%         title(['Population Average ' num2str(StimXs(j)) ' x pos'])
%         xlim([15 80]);
%         %ylim([0 max(AvgRates(:))+10]);
%     end
%     
    
    



    
    