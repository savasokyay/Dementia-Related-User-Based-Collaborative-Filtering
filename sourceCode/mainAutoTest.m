function mainAutoTest
%	@func	mainAutoTest
%	@author @savasokyay	 
%	@date 	2021.01.14: v2 Tests with new dataset
%	@brief 	This script can automate the test procedure for cascaded multiple times.
%           If you edit or use this code, please read and cite the following article. TODO
%	@prerq  ...
%	@input  -
%	@output testResults file on output path
%

addpath('equations','scripts', '_version');
clear;
clc;

%---------
%for executable tests, to organize how many instances are running simultaneously, give an id for each instance
%executable file names on current directory are searched on process tree. 
cntInstance = 0;
files = dir('*.exe');
for i=1:length(files)
    [status,list] = system(['tasklist /FI "imagename eq ', [files(i).name],'" /fo table /nh']);
    cntInstance = cntInstance + count(list,newline) - 1;
end
testInstanceName = num2str(cntInstance); 
%---------
disp('The tests are started...');

%This processed dataset size is actually 816x605 (double).
%However, you can only view the code, but not debug it properly.
%The raw or preprocessed dataset cannot be shared due to copyright. 
%You can access the raw brain scans at ADNI Access Data (http://adni.loni.usc.edu/data-samples/access-data/) webpage.
%If you want to understand how the code works, you can create a matrix having the name "mtrxData" with the corresponding size.
dataset = 'Normalized_ADNI1Screening_DemogAndMorphMeas_AvgLR_FSanamoliesDiscarded_Numeric.mat'; 

ver=checkVersion();
testName = ['CFforImputingADNI3x250MissingData_v', ver.Maj,'.', ver.Min,'.', ver.Rev];

path = 'testResultsCF\';
mkdir(path, testName);
path = [path, testName];

countTest = 100;
for testSetID = 1:countTest
    testParams = createTestCase(dataset, path, testSetID, testInstanceName);
    mainAuto(testParams);
    text = [num2str(testSetID), ' test set has been finished.'];
    disp(text);
end

end %end of function