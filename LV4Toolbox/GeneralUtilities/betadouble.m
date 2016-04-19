function out = betadouble(in,a,b)
% out = betadouble(in,a,b)
%
% Beta double function.  Used as wrapper for static nonlinearity
% in beta double method.
%
% 10/31/13  dhb  Pulled this out.

out = (b*in).^a;

end