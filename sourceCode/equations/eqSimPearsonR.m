function [w, countCoRated]=eqSimPearsonR(actveUsr, neighbor, item, statsRow, loopParams)
ratingsCommon = setdiff(intersect(find(~isnan(actveUsr)), find(~isnan(neighbor))), item);
countCoRated = length(ratingsCommon);

meanAc = loopParams.currentUserStatsDynamicAvg;
meanNg = statsRow(loopParams.currentNeighbor).avg;
w = (...
    (actveUsr(ratingsCommon)-meanAc) * ...
    (neighbor(ratingsCommon)-meanNg)' ...
    ) / ( ...
    sqrt(sum((actveUsr(ratingsCommon)-meanAc) .^2)) *...
    sqrt(sum((neighbor(ratingsCommon)-meanNg) .^2)) ...
    );
end %end of function