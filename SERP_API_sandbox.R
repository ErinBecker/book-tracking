# Use SERP API (Serpstack) to scrap nationality data for
# a list of authors and add to goodreads data

# https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
# https://serpstack.com/documentation

library(httr)

# I should update my access key and then make it private and not keep it in the script
# but right now it's not attached to billing info so I don't care
access_key <- "bc88a016231ab5b6f44fffe8fef4360a"

get_auth_info <- function(access_key, auth_name) {
  # convert spaces in name to plus signs so that url works
  my_query <- gsub(" ", "+", auth_name)
  # build query url
  q_result <- GET(paste0("http://api.serpstack.com/search?access_key=", access_key, 
                         "&query=", my_query, "+place+of+birth"))
  # extract answer box text
  content(q_result, "parsed")$answer_box$answers[[1]]$answer
}

# note - can also try "birthplace" to get something more mapable, but might have sparser results
# also some people will have more than one nationality result (e.g. Abraham Joshua Heschel)
# currently returns NULL if more than one nationality - want to do a check for dimensionality of
# the answer box first
# also add check for status of query and stop if bad

# read in goodreads data
books <- read.csv("~/Box_Sync/book-tracking/goodreads_library_export.csv", stringsAsFactors = FALSE)
