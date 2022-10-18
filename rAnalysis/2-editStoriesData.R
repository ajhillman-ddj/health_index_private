library(tidyverse)
library(jsonlite)

sourceData <- fromJSON("../data/health.json")
subDomains <- fromJSON("../data/indlu.json")
subDomainToDomainLookup <- fromJSON("../data/domlu.json")

updatedSourceData <- lapply(sourceData, function(la) {
  
  values2019 <- c()
        
  for (subdomain in names(subDomains)) {
    
     values2019 <- append(values2019, la[["data"]][[subDomainToDomainLookup[[subdomain]]]][["subdomains"]][[subdomain]][["total"]][["2019"]][["value"]])
    
  }
  
  values2019 <- data.frame(names(subDomains), values2019)
  colnames(values2019) <- c("metric", "value2019")
  
  storiesDFCopy <- la[["stories"]]
  
  la[["stories"]] <- merge(x = storiesDFCopy, y = values2019, by = "metric", all.x = TRUE)
  
  return(la)
})

write(toJSON(updatedSourceData, auto_unbox = TRUE), "../data/healthWith2019Values.json")
