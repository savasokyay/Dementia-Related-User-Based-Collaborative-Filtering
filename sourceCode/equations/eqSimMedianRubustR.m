function [w, countCoRated]=eqSimMedianRubustR(actveUsr, neighbor, item, statsRow, loopParams)
ratingsCommon = setdiff(intersect(find(~isnan(actveUsr)), find(~isnan(neighbor))), item);
countCoRated = length(ratingsCommon);

medAc = loopParams.currentUserStatsDynamicMed;
medNg = statsRow(loopParams.currentNeighbor).med;
w = (...
    (actveUsr(ratingsCommon)-medAc) * ...
    (neighbor(ratingsCommon)-medNg)' ...
    ) / ( ...
    sqrt(sum((actveUsr(ratingsCommon)-medAc) .^2)) *...
    sqrt(sum((neighbor(ratingsCommon)-medNg) .^2)) ...
    );
end %end of function