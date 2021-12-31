function testParams = createTestCase(dataset, path, testSetID, testInstanceName)
%	@func	createTestCase(dataset, path, testSetID, testInstanceName)
%	@author @savasokyay
%	@date 	2021.01.02
%	@brief 	Test parameters are defined and modified in this function
%	@prerq  see mainAuto.m and mainAutoTest.m
%	@input  dataset   : which predefined dataset
%           path      : file path
%           testSetID : numerical task id
%           testI.Name: this parameter is used to identify which run on parallel runs
%	@output testParams: whole test parameters to run automatized
%

testParams.nameDataSet = dataset;
testParams.path = path;
testParams.testSetID = testSetID;
testParams.testSetIDstr = [getenv('COMPUTERNAME'), '-', testInstanceName, '-', num2str(testSetID, '%03i')];
testParams.infoTiming.started = -1;
testParams.infoTiming.ended = -1;
testParams.infoTiming.elapsedSec = -1;
testParams.infoTiming.elapsedText = '';

testParams.BNCs = 0:1:100;
testParams.cntKFold = -1;

%hardcodded dataset details
testParams.columns.toFill = 4:6;
testParams.columns.infDem = 1:9; %excluding weight feature hardcoddedly
testParams.columns.infMrf = 11:604;
testParams.columns.clsLbl = 605;

%----------------------Enter Test Equations Manually----------------------%
equationSimFunctions = {'PCC','MRC','COS','EUC','MAN'};

testParams.simVector(1).simType = 'infMrf';
testParams.simVector(1).idxs = testParams.columns.infMrf;
testParams.simVector(2).simType = 'infDem';
testParams.simVector(2).idxs = testParams.columns.infDem;
testParams.simVector(3).simType = 'infAll';
testParams.simVector(3).idxs = [testParams.columns.infMrf testParams.columns.infDem];

testParams.cntTestItemForEachColumn = 250;
%-------------------------------------------------------------------------%
eqCount = length(unique(equationSimFunctions)); %this is the original eq count to handle not significant operations

load(testParams.nameDataSet);

testParams.filling.input = mtrxData;
testParams.filling.backupActual = mtrxData(:,testParams.columns.toFill);
testParams.filling.testMask = zeros(size(mtrxData,1), length(testParams.columns.toFill));
reset(RandStream.getGlobalStream,sum(100*clock));%make the randperm generates different numbers for each exe
for i=1:length(testParams.columns.toFill)
    testParams.filling.testMask(randperm(size(mtrxData,1),testParams.cntTestItemForEachColumn),i) = 1;
end
tmp = testParams.filling.backupActual;
tmp(find(testParams.filling.testMask)) = NaN;
mtrxData(:,testParams.columns.toFill) = tmp;
testParams.filling.mtrxData = mtrxData;
testParams.filling.Actual = testParams.filling.backupActual;
testParams.filling.Actual(find(testParams.filling.testMask==0)) = NaN;
testParams.filling.ResultTemplate = testParams.filling.Actual;
testParams.filling.ResultTemplate(find(testParams.filling.testMask)) = -1;

testParams.rawResultsAll.name  = 'WghAvg';

if 1<testParams.cntKFold
    testParams.KFoldIndices = crossvalind('Kfold',size(data.dataset,1),testParams.cntKFold);
end

load _definitionSimilarityEquations;
testParams.equationUserEntries.equationCount        = eqCount;
testParams.equationUserEntries.equationSimFunctions = equationSimFunctions;
for i=1:length(equationSimFunctions)
    defeq = find(strcmp(equationSimFunctions{i},{definitionSimilarityEquations.abbreviation}));
    if isempty(defeq)
        textErr = ['Abbr(', num2str(i), ')=',equationSimFunctions{i},' is not a compatible abbreviation.'];
        textErr = [textErr, newline, 'Check your test parameters.'];
        textErr = [textErr, newline, 'See equations\_definitionSimilarityEquations for details.'];
        error(textErr);
    end
    testParams.equationParams(i).equationName         = definitionSimilarityEquations(defeq).equationName;
    testParams.equationParams(i).abbreviation         = definitionSimilarityEquations(defeq).abbreviation;
    testParams.equationParams(i).functionName         = definitionSimilarityEquations(defeq).functionName;
    testParams.equationParams(i).functionType         = definitionSimilarityEquations(defeq).functionType;
    testParams.equationParams(i).overrideEquation     = definitionSimilarityEquations(defeq).overrideEquation;
    testParams.equationParams(i).functionExplanation  = definitionSimilarityEquations(defeq).functionExplanation;    
    for idxSimType = 1:length(testParams.simVector)
        j=1;
        for idxBNC = 1:length(testParams.BNCs)
            testParams.rawResultsAll.simVector(idxSimType).equationParams(i).results(j).bestNeighborCount = testParams.BNCs(idxBNC);
            testParams.rawResultsAll.simVector(idxSimType).equationParams(i).results(j).CalculatedRawResults = testParams.filling.ResultTemplate;
            j=j+1;
        end
    end
end %end of for

testParams.countEqNotOverrided = length(find(0==[testParams.equationParams.functionType]));
testParams.errors = 0;
end %end of function