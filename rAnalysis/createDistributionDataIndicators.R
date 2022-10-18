library(tidyverse)
library(jsonlite)

localAuthorityValueData <- fromJSON("../data/indis.json")

indicatorToSubDomainLookup <- c()

for (key in names(localAuthorityValueData[["E06000001"]])) {
  
  for (subKey in names(localAuthorityValueData[["E06000001"]][[key]])) {
    
    indicatorToSubDomainLookup[[subKey]] <- key
    
  }
}

valuesDataFrame <- as.data.frame(names(localAuthorityValueData))

colnames(valuesDataFrame) <- c("la")

for (year in 2020:2020) {
  
  for (indicator in names(indicatorToSubDomainLookup)) {
    
    laData <- lapply(localAuthorityValueData, function(x) {
      
      indicatorData <- x[[indicatorToSubDomainLookup[[indicator]]]][[indicator]][[as.character(year)]]
    })
    
    #valuesDataFrame[[paste0(indicator,'_',year)]] <- laData
    valuesDataFrame[[paste0(indicator)]] <- laData
  }
}


binnedValuesDataFrame <- as.data.frame(seq(from=50.5, to=150.5, by=2))
names(binnedValuesDataFrame) <- c('midpoint')

for (field in names(valuesDataFrame)) {
  
  if (field != "la") {
  
    minValue <- Reduce(min, valuesDataFrame[[field]]) - (Reduce(min, valuesDataFrame[[field]]) %% 1)
    maxValue <- Reduce(max, valuesDataFrame[[field]]) - (Reduce(max, valuesDataFrame[[field]]) %% 1) + 1
    breaks <- seq(from = minValue, to = maxValue, by = 1)
    
    binnedData <- cut(x = as.numeric(valuesDataFrame[[field]]), breaks = breaks)
    
    binnedData <- as.data.frame(as.vector(binnedData))
    
    binnedData <- binnedData |>
      group_by(`as.vector(binnedData)`) |>
      summarise(count = n()) |>
      mutate(midpoint = as.numeric(substr(`as.vector(binnedData)`,2,regexpr(",",`as.vector(binnedData)`)-1))+0.5)
    
    colnames(binnedData) <- c('range', field, 'midpoint')
    
    binnedValuesDataFrame <- merge(x = binnedValuesDataFrame, y = binnedData[c(field, 'midpoint')], by='midpoint', all.x = TRUE)
  }
}

rm(laData, year, minValue, maxValue, breaks, field, binnedData, valuesDataFrame)

binnedValuesDataFrame[is.na(binnedValuesDataFrame)] <- 0

write.csv(binnedValuesDataFrame, "../data/binnedIndicatorDistributions2020.csv")

write(toJSON(binnedValuesDataFrame, auto_unbox = TRUE), "../data/binnedIndicatorDistributions2020.json")
