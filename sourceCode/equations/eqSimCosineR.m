function [w, countCoRated]=eqSimCosineR(activeUser, neighbor, item, statsRow, loopParams)
countCoRated = length(setdiff(intersect(find(~isnan(activeUser)), find(~isnan(neighbor))), item));
activeUser = activeUser(loopParams.simIdxs);
activeUser(find(isnan(activeUser))) = 0;
neighbor   =   neighbor(loopParams.simIdxs);
neighbor(find(isnan(neighbor))) = 0;
w = dot(activeUser,neighbor)/(norm(activeUser)*norm(neighbor));
end%end of function