% ListAllConditions
%
% Just list up all the recording sessions
%
% 1/7/15  dhb  Pulled this out.

switch (decodeInfoIn.DATASTYLE)
    case 'new'
        insertFilenameStr = 'lightness';
    case 'old'
        insertFilenameStr = 'Lightness';
    otherwise
        error('Unkown data style');
end

%% Uncomment this block to get a quick test for SY data.
% theFiles{outIndex} = ['SY150423' insertFilenameStr '0001'];
% theRFFiles{outIndex} = ['SY150423RFmap0002_reduceddata'];
% decodeInfoInRun{outIndex} = decodeInfoIn;
% decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
% decodeInfoInRun{outIndex}.subjectStr = 'SY';
% decodeInfoInRun{outIndex}.rfInfoLocation = [];
% decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
% decodeInfoInRun{outIndex}.normIndexLocation = [];
% decodeInfoInRun{outIndex}.sameDayRF = true;
% outIndex = outIndex + 1;
% return

%% Uncomment this block to get a quick test for JD data.
% theFiles{outIndex} = ['JD130827' insertFilenameStr '0001'];
% theRFFiles{outIndex} = [''];
% decodeInfoInRun{outIndex} = decodeInfoIn;
% decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
% decodeInfoInRun{outIndex}.subjectStr = 'JD';
% decodeInfoInRun{outIndex}.rfInfoLocation = [];
% decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
% decodeInfoInRun{outIndex}.normIndexLocation = [];
% decodeInfoInRun{outIndex}.sameDayRF = true;
% outIndex = outIndex + 1;
% return

%% Uncomment this block to get a quicker test case.
% % This crashes at the end because there isn't enough
% % summary data, but is fine for testing the core session
% % analyses.
% 
% % SY data
% theFiles{outIndex} = ['SY150423' insertFilenameStr '0001'];
% theRFFiles{outIndex} = ['SY150423RFmap0002_reduceddata'];
% decodeInfoInRun{outIndex} = decodeInfoIn;
% decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
% decodeInfoInRun{outIndex}.subjectStr = 'SY';
% decodeInfoInRun{outIndex}.rfInfoLocation = [];
% decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
% decodeInfoInRun{outIndex}.normIndexLocation = [];
% decodeInfoInRun{outIndex}.sameDayRF = true;
% outIndex = outIndex + 1;
%  
% theFiles{outIndex} = ['JD130904' insertFilenameStr '0001'];
% theRFFiles{outIndex} = ['JD130904RFmap0001_reduceddata'];
% decodeInfoInRun{outIndex} = decodeInfoIn;
% decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
% decodeInfoInRun{outIndex}.subjectStr = 'JD';
% decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
% decodeInfoInRun{outIndex}.rfInfoLocation = [];
% decodeInfoInRun{outIndex}.normIndexLocation = [];
% decodeInfoInRun{outIndex}.sameDayRF = true;
% outIndex = outIndex + 1;
% 
% return;

% ST data
theFiles{outIndex} = ['ST140422' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['ST140422RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'ST';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['ST140424' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['ST140422RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'ST';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['ST140504' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['ST140504RFmap0009_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'ST';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['ST140609' insertFilenameStr '0001'];
theRFFiles{outIndex} = 'None';
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'ST';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['ST140621' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['ST140621RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'ST';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['ST140623' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['ST140623RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'ST';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

% Only have these ST files in the new format.
if (strcmp(decodeInfoIn.DATASTYLE,'new'))
    theFiles{outIndex} = ['ST140703' insertFilenameStr '0001'];
    theRFFiles{outIndex} = ['ST140703RFmap0001_reduceddata'];
    decodeInfoInRun{outIndex} = decodeInfoIn;
    decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
    decodeInfoInRun{outIndex}.subjectStr = 'ST';
    decodeInfoInRun{outIndex}.rfInfoLocation = [];
    decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
    decodeInfoInRun{outIndex}.normIndexLocation = [];
    decodeInfoInRun{outIndex}.sameDayRF = true;
    outIndex = outIndex + 1;
    
    theFiles{outIndex} = ['ST140704' insertFilenameStr '0001'];
    theRFFiles{outIndex} = ['ST140703RFmap0001_reduceddata'];
    decodeInfoInRun{outIndex} = decodeInfoIn;
    decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
    decodeInfoInRun{outIndex}.subjectStr = 'ST';
    decodeInfoInRun{outIndex}.rfInfoLocation = [];
    decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
    decodeInfoInRun{outIndex}.normIndexLocation = [];
    decodeInfoInRun{outIndex}.sameDayRF = false;
    outIndex = outIndex + 1;
    
    theFiles{outIndex} = ['ST140705' insertFilenameStr '0001'];
    theRFFiles{outIndex} = ['ST140703RFmap0001_reduceddata'];
    decodeInfoInRun{outIndex} = decodeInfoIn;
    decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
    decodeInfoInRun{outIndex}.subjectStr = 'ST';
    decodeInfoInRun{outIndex}.rfInfoLocation = [];
    decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
    decodeInfoInRun{outIndex}.normIndexLocation = [];
    decodeInfoInRun{outIndex}.sameDayRF = false;
    outIndex = outIndex + 1;
    
    theFiles{outIndex} = ['ST140706' insertFilenameStr '0001'];
    theRFFiles{outIndex} = ['ST140703RFmap0001_reduceddata'];
    decodeInfoInRun{outIndex} = decodeInfoIn;
    decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
    decodeInfoInRun{outIndex}.subjectStr = 'ST';
    decodeInfoInRun{outIndex}.rfInfoLocation = [];
    decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
    decodeInfoInRun{outIndex}.normIndexLocation = [];
    decodeInfoInRun{outIndex}.sameDayRF = false;
    outIndex = outIndex + 1;
end

% BR data
theFiles{outIndex} = ['BR130902' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['BR130902RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'BR';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

% This file has two center X locs and 1 center y loc.
% Does that make sense?
theFiles{outIndex} = ['BR130914' insertFilenameStr '0002'];
theRFFiles{outIndex} = ['BR130914RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'BR';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['BR130921' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['BR130921RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'BR';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['BR130922' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['BR130921RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V1';
decodeInfoInRun{outIndex}.subjectStr = 'BR';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

% JD data
theFiles{outIndex} = ['JD130827' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130827RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

% There is RF data on this day, but not all lightness electrodes match up
% with an RF electrode.
theFiles{outIndex} = ['JD130828' insertFilenameStr '0002'];
theRFFiles{outIndex} = ['JD130827RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130829' insertFilenameStr '0002'];
theRFFiles{outIndex} = ['JD130829RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130830' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130829RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

% No good data for any of the sizes
% theFiles{outIndex} = ['JD130831' insertFilenameStr '0001'];
% theRFFiles{outIndex} = 'None';
% decodeInfoInRun{outIndex} = decodeInfoIn;
% decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
% decodeInfoInRun{outIndex}.rfInfoLocation = [];
% decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
% decodeInfoInRun{outIndex}.normIndexLocation = [];
% decodeInfoInRun{outIndex}.sameDayRF = false;
% outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130831' insertFilenameStr '0002'];
theRFFiles{outIndex} = ['JD130904RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130901' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130904RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130902' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130904RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130904' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130904RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130910' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130912RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130911' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130912RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130912' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130912RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130913' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130912RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

% There is RF data on this day, but not all lightness electrodes match up
% with an RF electrode.
theFiles{outIndex} = ['JD130914' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130916RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130915' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130916RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = false;
outIndex = outIndex + 1;

theFiles{outIndex} = ['JD130916' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['JD130916RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'JD';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

% SY data
theFiles{outIndex} = ['SY150423' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150423RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150424' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150424RFmap0002_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150430' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150430RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150501' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150501RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150502' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150502RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150503' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150503RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150505' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150505RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150506' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150506RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150508' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150508RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

% Some of the response matrices in this file are rank deficient, by 1.
% This is caused by one unit having very few spikes and in particular no
% spikes for one of the paint conditions.
theFiles{outIndex} = ['SY150512' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150512RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150514' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150514RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150515' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150515RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150518' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150518RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150519' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150519RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150520' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150520RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150521' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150521RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

% Some of the response matrices in this file are rank deficient, by 1.
theFiles{outIndex} = ['SY150522' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150522RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150526' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150526RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150528' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150528RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150529' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150529RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150601' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150601RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150603' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150603RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150608' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150608RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150609' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150609RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150610' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150610RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150611' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150611RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150615' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150615RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150616' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150616RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150618' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150618RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150619' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150619RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150622' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150622RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150623' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150623RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150626' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150626RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150629' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150629RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150706' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150706RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150707' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150707RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;

theFiles{outIndex} = ['SY150708' insertFilenameStr '0001'];
theRFFiles{outIndex} = ['SY150708RFmap0001_reduceddata'];
decodeInfoInRun{outIndex} = decodeInfoIn;
decodeInfoInRun{outIndex}.titleInfoStr = 'V4';
decodeInfoInRun{outIndex}.subjectStr = 'SY';
decodeInfoInRun{outIndex}.rfInfoLocation = [];
decodeInfoInRun{outIndex}.doIndElectrodeRFPlots = decodeInfoIn.doIndElectrodeRFPlots;
decodeInfoInRun{outIndex}.normIndexLocation = [];
decodeInfoInRun{outIndex}.sameDayRF = true;
outIndex = outIndex + 1;
