function Pai=eqPreWeightedAverage(bestNeighbors, ratingsItem)
Pai = sum(ratingsItem(bestNeighbors(:,2)) .* bestNeighbors(:,1)) / sum(bestNeighbors(:,1));
end