library(tidyverse)
library(jsonlite)

localAuthorityValueData <- fromJSON("../data/health.json")
subDomains <- fromJSON("../data/indlu.json")
subDomainToDomainLookup <- fromJSON("../data/domlu.json")

valuesDataFrame <- as.data.frame(names(localAuthorityValueData))

colnames(valuesDataFrame) <- c("la")

for (year in 2019:2019) {
  
  for (subdomain in names(subDomains)) {
    
    laData <- lapply(localAuthorityValueData, function(x) {
      
      subdomainData <- x[["data"]][[subDomainToDomainLookup[[subdomain]]]][["subdomains"]][[subdomain]][["total"]][[as.character(year)]][["value"]]
    })
    
    #valuesDataFrame[[paste0(subdomain,'_',year)]] <- laData
    valuesDataFrame[[paste0(subdomain)]] <- laData
  }
}

binnedValuesDataFrame <- as.data.frame(seq(from=50.5, to=150.5, by=1))
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

rm(laData, year, subdomain, minValue, maxValue, breaks, field, binnedData, valuesDataFrame)

binnedValuesDataFrame[is.na(binnedValuesDataFrame)] <- 0

write.csv(binnedValuesDataFrame, "../data/binnedDistributions2019.csv")

write(toJSON(binnedValuesDataFrame, auto_unbox = TRUE), "../data/binnedDistributions2019.json")
