# SERP APIs I've found have limited free access
# try doing things natively within R using XML scraping
# https://gist.github.com/jtleek/c5158965d77c21ade424

# Scrape data for a list of authors and add to goodreads data

## Load libraries
library(XML)
library(dplyr)
library(RCurl)
library(httr)

## Get the results for a specific author
get_auth_info <- function(auth_name) {
  # convert spaces in name to plus signs so that url works
  my_query <- gsub(" ", "+", auth_name)
  # build query url
  base_url <- "http://www.google.com/search?"
  search_string <- paste0("q=", my_query)
  q_result <- GET(paste0(base_url, my_query, "+place+of+birth"))
  doc <- htmlParse(q_result, encoding="UTF-8")
}
  
