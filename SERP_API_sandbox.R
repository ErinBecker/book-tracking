# Use SERP API (Serpstack) to scrap nationality data for
# a list of authors and add to goodreads data

# https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
# https://serpstack.com/documentation

library(httr)
library(ggmap)
library(dplyr)

# I should update my access key and then make it private and not keep it in the script
# but right now it's not attached to billing info so I don't care
access_key <- "bc88a016231ab5b6f44fffe8fef4360a"

get_auth_info <- function(access_key, auth_name) {
  # convert spaces in name to plus signs so that url works
  my_query <- gsub(" ", "+", auth_name)
  # build query url
  q_result <- GET(paste0("http://api.serpstack.com/search?access_key=", access_key, 
                         "&query=", my_query, "+place+of+birth"))
  
  if (q_result$status_code == 200) {
    
    # check if answer box text is NULL
    if (is.null(content(q_result, "parsed")$answer_box$answers[[1]]$answer)) {
      print("unknown") }
    
    # extract answer box text
    else print(content(q_result, "parsed")$answer_box$answers[[1]]$answer)
  }
  
}

# read in goodreads data
books <- read.csv("~/Box_Sync/book-tracking/goodreads_library_export.csv", stringsAsFactors = FALSE)

# get list of unique authors to minimize number of queries
unique_authors <- unique(books$Author)
# create df to store author info
author_df <- data.frame("author" = unique_authors) 
# keep author names as character
author_df$author <- as.character(author_df$author)

for (i in 1:nrow(author_df)) {
  author <- author_df$author[i]
  print(author)
  auth_pob <- get_auth_info(access_key, author)
  author_df$auth_POB[i] <- auth_pob 
}
# comma within POB messed up columns, in next run, change to quote = TRUE
write.csv(author_df, "author_df.csv", row.names = FALSE, quote = FALSE)

# read in author dataframe
author_df <- read.csv("author_df.csv", stringsAsFactors = FALSE)
author_df <- transform(author_df, newcol = paste(auth_POB1, auth_POB2, sep=","))
# string line terminal commas
author_df$newcol <- gsub("(*),$", "\\1", author_df$newcol)
# cleanup
author_df$auth_POB1 <- NULL
author_df$auth_POB2 <- NULL
colnames(author_df) <- c("author", "POB")

# take only authors with known POB
author_df <- filter(author_df, POB != "unknown")


# mapping
# first register your google API key with
# register_google(key = "YOUR KEY HERE", write = TRUE)
# how to get a key instructions here: https://developers.google.com/maps/documentation/javascript/get-api-key

locations_df <- mutate_geocode(author_df, POB)
