function LightnessPopCode
% LightnessPopCode
%
% Configure things for working on the LightnessPopCode project.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUse({'AOMontaging'}) to set up for
% this project.  You then edit your local copy to match your 
%
% The thing that this does is add subfolders of the project to the path as
% well as define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running LightnessPopCode local hook\n');

%% Put project toolbox onto path
%
% Specify project name and location
projectName = 'LightnessPopCode';
projectUrl = 'https://github.com/DavidBrainard/LightnessPopCode.git';
projectBaseDir = '/Users/Shared/Matlab/Experiments/LightnessV4';

% Declare the project git repo and two subfolders that we want on the path
withToolbox = tbToolboxRecord( ...
    'name', 'LightnessPopCode', ...
    'type', 'git', ...
    'url', projectUrl, ...
    'subfolder', 'toolbox');

% Obtain or update the git repo and add subfolders to the Matlab path
config = [withToolbox];
tbDeployToolboxes('config', config, 'toolboxRoot', projectBaseDir, 'runLocalHooks', false);

%% Set preferences for project output
%
outputBaseDir = fullfile(projectBaseDir,'PennOutput');
physiologyInputBaseDir = '/Users1/Users1Shared/Matlab/Experiments/LightnessV4/Pitt';
psychoInputBaseDir = fullfile(projectBaseDir,'PennPsychoData');
stimulusInputBaseDir = '/Users1/Users1Shared/Matlab/Experiments/LightnessV4/stimuli';
stimulusDefInputBaseDir = fullfile(projectBaseDir,'stimuli');

% Set the preferences
setpref('LightnessPopCode','outputBaseDir',outputBaseDir);
setpref('LightnessPopCode','physiologyInputBaseDir',physiologyInputBaseDir);
setpref('LightnessPopCode','psychoInputBaseDir',psychoInputBaseDir);
setpref('LightnessPopCode','stimulusInputBaseDir',stimulusInputBaseDir);
setpref('LightnessPopCode','stimulusDefInputBaseDir',stimulusDefInputBaseDir);