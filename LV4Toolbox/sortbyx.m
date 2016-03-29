function [means,stes,ns,ys,inds,xs,stds]=sortbyx(xdata,ydata)
% [means,stes,ns,ys,inds,xs,stds]=sortbyx(xdata,ydata)
% 
% Take trial-by-trial data and get mean of y for each x.
%
% xdata    - input indpendent variable data, vector, entry per trial
% ydata    - input dependent variable data, vector, entry per trial
%
% means    - row vector, mean of ydata for each unique value of xdata
% sdes     - row vector, standard error of each mean in means
% ns       - row vector, number of trials that went into each mean in means
% ys       - cell array, values of ydata that were averaged to produce each mean
% inds     - cell array, index into ydata to obtain corresponding cell of ys.
% xs       - row vector, unique values of xdata arranged to correspond to vector means, etc.
% stds     - row vector, standard deviation of each mean in means
% 
% X/XX/XX       Provided by Doug and Marlene
% 5/13/14  dhb  Added comments
% 1/09/15  dhb  Add return of stds too.  Sometimes we want to know the
%               standard deviation.

xs=unique(xdata);
numx=length(xs);
means=nans(1,numx);
stes=nans(1,numx);
ns=nans(1,numx);
ys=cell(1,numx);
inds=cell(1,numx);

for ix=1:numx
    x=xs(ix);
    ind=find(xdata==x);
    inds{ix}=ind;
    y=ydata(ind);
    ys{ix}=y;
    means(ix)=mean(y(~isnan(y)));
    stes(ix)=ste(y');
    ns(ix)=length(y);
    stds(ix) = std(y');
end
