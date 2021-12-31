function results = getTestResults(testParams)
%	@func   getTestResults(testParams)
%	@author @savasokyay
%	@date 	2021.01.14: new error and correlation metrics after TIK#4
%	@brief 	Performance evaluation metrics during runtime.
%	@prerq  ...
%	@input  testParams: struct containing specially raw prediction results
%	@output results:    struct containing error & performance metrics
%

actuRaw = testParams.filling.Actual;

for idxSimType=1:length(testParams.rawResultsAll(1).simVector)
    results.simVector(idxSimType).simType = testParams.simVector(idxSimType).simType;
    results.simVector(idxSimType).simidxs = testParams.simVector(idxSimType).idxs;
    for idxSimEq = 1:length(testParams.equationParams)
        results.simVector(idxSimType).resultsSimEq(idxSimEq).equationName      = testParams.equationParams(idxSimEq).equationName;
        results.simVector(idxSimType).resultsSimEq(idxSimEq).abbreviation      = testParams.equationParams(idxSimEq).abbreviation;

        for index = 1 : length(testParams.rawResultsAll.simVector(idxSimType).equationParams(idxSimEq).results)
            calcRaw = testParams.rawResultsAll.simVector(idxSimType).equationParams(idxSimEq).results(index).CalculatedRawResults;
            if ~isequal(find(~isnan(actuRaw)),find(~isnan(calcRaw)))
                error('sth went wrong!');
            end
            resultsEq(index).BNC  = testParams.rawResultsAll.simVector(idxSimType).equationParams(idxSimEq).results(index).bestNeighborCount;
            resultsEq(index).MAE  = mae(actuRaw(find(~isnan(actuRaw))), calcRaw(find(~isnan(calcRaw))));
            resultsEq(index).MSE  = mse(actuRaw(find(~isnan(actuRaw))), calcRaw(find(~isnan(calcRaw))));
            resultsEq(index).RMSE = sqrt(resultsEq(index).MSE);
            resultsEq(index).Rsq  = rsquare(actuRaw(find(~isnan(actuRaw))), calcRaw(find(~isnan(calcRaw))));               
         end %end of for bestNeighborCount

        results.simVector(idxSimType).resultsSimEq(idxSimEq).statistics = resultsEq;
        resultsEq = [];
    end %end of for simEquations
end %end of for simType
end %end of function