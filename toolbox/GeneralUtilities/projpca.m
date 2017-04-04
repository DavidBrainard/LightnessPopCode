function[newvec]=projpca(newdata,y,oldmean)

s=size(newdata);
oldmean=repmat(oldmean,1,s(2));
newvec=((newdata-oldmean)'*y)';