function err = DecoderErrorFunction(x,decodeInfo,contrasts,responses)
% err = DecoderErrorFunction(x,decodeInfo,contrasts,responses)

switch (decodeInfo.type)
    case 'betacdf'
        decodeInfo.betacdfA = x(1);
        decodeInfo.betacdfB = x(2);
        decodeInfo.betacdfScale = x(3);
        decodeInfo = GetTheDecoderRegressionParams(decodeInfo,contrasts,responses);
        predict = DoThePrediction(decodeInfo,responses);
    case 'betadoublecdf'
        decodeInfo.betacdfA1 = x(1);
        decodeInfo.betacdfB1 = x(2);
        decodeInfo.betacdfA2 = x(3);
        decodeInfo.betacdfB2 = x(4);
        decodeInfo.betacdfScale = x(5);
        decodeInfo = GetTheDecoderRegressionParams(decodeInfo,contrasts,responses);
        predict = DoThePrediction(decodeInfo,responses);
        
    otherwise
        error('Unknown decoder type passed');
end

% Compute error
err = ComputeDecodingError(decodeInfo,contrasts,predict);

end
