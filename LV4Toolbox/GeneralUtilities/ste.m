function[result]=ste(x)
result=std(x(~isnan(x)))./sqrt(sum(~isnan(x)));
