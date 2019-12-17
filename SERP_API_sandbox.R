# Use SERP API (Serpstack) to scrap nationality data for
# a list of authors and add to goodreads data

# https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
# https://serpstack.com/documentation

library(httr)

# I should update my access key and then make it private and not keep it in the script
# but right now it's not attached to billing info so I don't care
access_key <- "bc88a016231ab5b6f44fffe8fef4360a"

# my_query <- "eduardo+bonilla-silva+nationality"

get_nationality <- function(access_key, my_query) {
  # add a line to transform query to this format "name+name+blah" (no space)
  q_result <- GET(paste0("http://api.serpstack.com/search?access_key=", access_key, 
                         "&query=", my_query))
  content(q_result, "parsed")$answer_box$answers[[1]]$answer
}


# 
# http_status(test)
# content(test, "parsed")$answer_box$answers[[1]]$answer
