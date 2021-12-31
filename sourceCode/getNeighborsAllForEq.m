function sortedWeights=getNeighborsAllForEq(w, testParams, loopParams, data)

if 1<testParams.cntKFold
    neighborsTrain = intersect(find(data.dataset(:,loopParams.currentColumn)), ...
        find(testParams.KFoldIndices(loopParams.currentRow) ~= testParams.KFoldIndices));
else
    neighborsTrain = find(~isnan(data.dataset(:,loopParams.currentColumn)));
end
weights = zeros(length(neighborsTrain), 3); %weight, indexNegihbor, countCorated

for index = 1:length(neighborsTrain)
    u = neighborsTrain(index);
    loopParams.currentNeighbor = u;
    eval(['[weight, countCoRated] = ', ...
        testParams.equationParams(loopParams.currentEquation).functionName, '(', ...
        'data.dataset(loopParams.currentRow,:),', ...
        'data.dataset(loopParams.currentNeighbor,:),', ...
        'loopParams.currentColumn,', ...
        'data.statsRow,', ...
        'loopParams);']);

    weights(index,1) = weight;
    weights(index,2) = u;
    weights(index,3) = countCoRated;
end
weights(find(isnan(weights(:,1))),:)=[]; %Eliminate row
sortedWeights(:,:) = flipud(sortrows(weights(1:max(find(weights(:,2)~=0)),:)));

%Must hardcodded line
%Some patients have more than one imaging study. Demographics are the same, but morphometrics has differences.
%When sim idxs are only (parital) demographics info, the distance between neighbors becomes 1 and weight becomes Inf, as expected. 
%In this case, the weight of the second neighbor is given to the first one as well.
%It should not be ignored, as all vectors are not the same in other similarity tests!
if(Inf==sortedWeights(1,1))
    sortedWeights(1,1) = sortedWeights(2,1);
end
            
end %end of function