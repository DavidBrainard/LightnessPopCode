function [paintResponsesPCA,shadowResponsesPCA,pcaBasis,meanResponse] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
% function [paintResponsesPCA,shadowResponsesPCA,pcaBasis,meanResponse] = PaintShadowPCA(decodeInfo,paintResponses,shadowResponses)
%
% PCA on responses.  
%   decodeInfo.pcaType - type of PCA
%     'no' - don't do PCA.
%     'ml' - use Matlab's pca or pca2 based on a flag in the source.  They
%            give the same result to high precision.
%
%  PCA by default centers the data around its mean before finding
%  the principle components.  That's fine.  We don't do any subtraction on
%  the returned responses, however.  You can subtract the returned
%  meanResponse in the calling routine if you'd like to do that.
%
%  If you pass shadowResponses as empty, the PCA will be done on the paint
%  responses and the shadowResponsePCA will come back empty.
%
% 4/22/14 dhb  Wrote it.
% 4/17/16 dhb  Switch to Matlab version.
% 3/31/17 dhb  Return the PCA basis and mean response in pcaBasis coordinates

%% Set flags
DOMATLAB = false;
DOPCA2 = true;

%% Do PCA on responses
%
% We specify this by overloading the trial suffle type
switch (decodeInfo.pcaType)
    case {'no'}
        paintResponsesPCA = paintResponses;
        shadowResponsesPCA = shadowResponses;
    case {'ml'}
        dataForPCA = [paintResponses ; shadowResponses];
        if (~isempty(dataForPCA) & ~any(isnan(dataForPCA)))
            
            % Get mean response, so people can mean center the coordinates
            % if they like
            meanResponse = mean(dataForPCA,1);
            
            if (DOMATLAB)
                pcaBasis1 = pca(dataForPCA);
                paintResponsesPCA1 = (pcaBasis1\paintResponses')';
            end
            
            % Let's see if we can get same PCA with Marlene's routine.
            %
            % Looks good up to sign, by manual plot
            if (DOPCA2)
                pcaBasis2 = pca2(dataForPCA',min(size(dataForPCA'))-1);
                paintResponsesPCA2 = (pcaBasis2\paintResponses')';
            end
            
            % Check for equality of PCA responses up to sign
            if (DOMATLAB & DOPCA2)
                for i = 1:min([size(paintResponsesPCA1,2) size(paintResponsesPCA2,2)])
                    check1 = any(abs(paintResponsesPCA1(:,i)-paintResponsesPCA2(:,i)) > 1e-9);
                    check2 = any(abs(paintResponsesPCA1(:,i)+paintResponsesPCA2(:,i))> 1e-9);
                    if (check1 & check2)
                        error('PCA mismatch for component %d\n',i);
                    end
                end
            end
            
            % Decide which to use
            if (DOPCA2)
                pcaBasis = pcaBasis2;
                paintResponsesPCA = paintResponsesPCA2;
            elseif (DOMATLAB)
                pcaBasis = pcaBasis1;
                paintResponsesPCA = paintResponsesPCA1;
            else
                error('Must set at least one PCA method to true');
            end

            % Shadow responses if needed.
            if (~isempty(shadowResponses))
                shadowResponsesPCA = (pcaBasis\shadowResponses')';
            else
                shadowResponsesPCA = [];
            end
            
        end

    otherwise
        error('Unknown PCA type specified');
        
end
