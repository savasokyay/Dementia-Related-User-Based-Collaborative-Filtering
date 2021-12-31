%	@author @savasokyay
%	@date 	2020.12.26
%	@brief 	...
%	@prerq  ...
%	@input  testParams: ...
%	@output creates a results *.mat file at the end of test instance.
%
function mainAuto(testParams)
mtrxData = testParams.filling.mtrxData;
testParams.infoTiming.started = datestr(now, 'yy-mm-dd_HH.MM.SS.fff');
testParams.testSetIDstr = [testParams.testSetIDstr, '_(', testParams.infoTiming.started, ')'];

tic;
for idxSimType=1:length(testParams.simVector) %simdata
    filling = 0;
    for a = 1:size(mtrxData,1)
        for i = testParams.columns.toFill
            if isnan(mtrxData(a,i))
                filling = filling + 1;
                data.dataset = mtrxData;
                loopParams.simIdxs = testParams.simVector(idxSimType).idxs;
                data.dataset(:, setdiff(setdiff(1:size(mtrxData,2), testParams.simVector(idxSimType).idxs),i)) = NaN;
                for row=1:size(mtrxData,1)
                    [data.statsRow(row).cnt, data.statsRow(row).avg, data.statsRow(row).med, data.statsRow(row).std] = ...
                        getMeanMedianStdOfNonNaNValues(data.dataset(row,loopParams.simIdxs));
                end
                
                for eq = 1:testParams.equationUserEntries.equationCount
                    w(eq).wghts = -inf(1, 3); %weight, indexNegihbor, countCorated
                end
                for eq = 1:length(testParams.equationParams)
                    loopParams.currentRow      = a;
                    loopParams.currentColumn   = i;
                    loopParams.currentEquation = eq;
                    
                    %For dynamic purposes, current item should be accepted as not rated
                    vector = data.dataset(loopParams.currentRow,:);
                    %vector(loopParams.currentColumn) = 0;
                    [loopParams.currentUserStatsDynamicCnt, loopParams.currentUserStatsDynamicAvg,  ...
                        loopParams.currentUserStatsDynamicMed, loopParams.currentUserStatsDynamicStd] = ...
                        getMeanMedianStdOfNonNaNValues(vector);
                    
                    neighborWeightsForEquation = getNeighborsAllForEq(w, testParams, loopParams, data);
                    if testParams.equationUserEntries.equationCount>=eq
                        w(eq).wghts = neighborWeightsForEquation;
                    end
                     
                    j=1;
                    %rawActual = testParams.filling.backupActual(loopParams.currentRow, loopParams.currentColumn-3);
                    paiAllNeighborsWghAvg=-inf;
                    for idxBNC = 1:length(testParams.BNCs)
                        bestNeighborCount = testParams.BNCs(idxBNC);
                        if(0==bestNeighborCount)
                            rawWghAvg = eqPreWeightedAverage(...
                                neighborWeightsForEquation, ...
                                data.dataset(:,loopParams.currentColumn));
                            paiAllNeighborsWghAvg = rawWghAvg;                            
                        elseif(bestNeighborCount<size(neighborWeightsForEquation,1))
                            bestNeighbors = neighborWeightsForEquation(1:bestNeighborCount,:);
                            rawWghAvg = eqPreWeightedAverage(...
                                bestNeighbors, ...
                                data.dataset(:,loopParams.currentColumn));                          
                        elseif(bestNeighborCount>=size(neighborWeightsForEquation,1))
                            rawWghAvg = paiAllNeighborsWghAvg;
                        else
                            error('1.1 - this line should have never be executed!'); %TODO: Not critical at this time, maybe detailed later.
                        end
                        
                        testParams.rawResultsAll.simVector(idxSimType).equationParams(eq).results(j).CalculatedRawResults(a, find(i==testParams.columns.toFill)) = rawWghAvg;
                        j=j+1;
                    end %end of for bestNeighborCount
                    printStatsProgress(testParams.path, testParams.testSetIDstr, toc, ...
                        idxSimType, length(testParams.simVector), ...
                        filling, testParams.cntTestItemForEachColumn * length(testParams.columns.toFill), ...
                        eq, length(testParams.equationParams));
                end %end of for simEquations
            end %end of if testCell
        end %end of for i
    end %end of for userCount
end %end of for idxSimType
clc;
disp(['evaluating test set #', num2str(testParams.testSetID), '...']);
testParams.results = getTestResults(testParams);

testParams.infoTiming.ended = datestr(now, 'yy-mm-dd_HH.MM.SS');
elapsedTime = toc;
testParams.infoTiming.elapsedSec = elapsedTime;
text = ['Elapsed time is ', num2str(elapsedTime/60), ' minutes.'];
testParams.infoTiming.elapsedText = text;

save([testParams.path, '\', testParams.testSetIDstr, '.mat'], 'testParams');
disp(text);

end %end of function