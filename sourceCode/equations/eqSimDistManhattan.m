function [w, countCoRated]=eqSimDistManhattan(actveUsr, neighbor, item, statsRow, loopParams)
countCoRated = length(setdiff(intersect(find(~isnan(actveUsr)), find(~isnan(neighbor))), item));
actveUsr = actveUsr(loopParams.simIdxs);
actveUsr(find(isnan(actveUsr))) = 0;
neighbor = neighbor(loopParams.simIdxs);
neighbor(find(isnan(neighbor))) = 0;

w = 1/norm(actveUsr-neighbor, 1);
end %end of function