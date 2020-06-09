## Created by Erin Becker
## 21 May, 2020

## load libraries
library(ggplot2)
library(dplyr)
library(tidyr)

## Read in goodreads data
all_books <- read.csv("~/Box_Sync/book-tracking/goodreads_library_export.csv", 
                 stringsAsFactors =  FALSE)
# reformat date columns
all_books$Date.Added <- as.Date(all_books$Date.Added)
all_books$Date.Read <- as.Date(all_books$Date.Added)

# ## Some exploratory plotting
# # My most read publishers
# books_read <- filter(all_books, Read.Count >= 1)
# 
# common_publishers <- table(books_read$Publisher) %>% 
#   as.data.frame() %>% 
#   arrange(desc(Freq)) %>%
#   filter(Freq >= 5) %>%
#   select(Var1) %>%
#   pull() %>%
#   as.character()
# 
# ggplot(books_read %>% 
#          filter(Publisher %in% common_publishers)) + 
#   geom_bar(aes(x = Publisher)) + 
#   theme_minimal() +
#   theme(axis.text.x = element_text(angle = 90))

## Extract list of unique authors
authors <- unique(all_books$Author)
authors_df <- data.frame(authors)

separate_names = function(data, name_col) {
  for(i in 1:nrow(data)) {
    name = as.character(data[i, name_col])
    data$personal[i] = strsplit(name, " ")[[1]][1]
    data$family[i] = paste0(strsplit(name, " ")[[1]][-1], collapse = " ")
  }
  data
}

authors_df <- separate_names(authors_df, "authors")
colnames(authors_df) <- c("author", "personal", "family")

# read in author POB data
authors_df_POB <- read.csv("Box_Sync/book-tracking/author_df_POB.csv", 
                          stringsAsFactors = FALSE)
authors_df_POB <- separate_names(authors_df_POB, "author")

authors_df_2 <- merge(authors_df_POB, authors_df, 
                      by = "author", all = TRUE)

# export authors_df as csv for manual data entry
write.csv(authors_df_2, "Box_Sync/book-tracking/authors_df_2.csv", 
          row.names = FALSE)

# read authors_df back in 
authors_df_2_manual <- read.csv("Box_Sync/book-tracking/authors_df_2_manual.csv", 
                          stringsAsFactors = FALSE)

## overall distribution of authors by gender
#ggplot(authors_df_2_manual) + geom_bar(aes(x = gender))

authors_df_2_manual$Author <- authors_df_2_manual$author
authors_df_2_manual <- select(authors_df_2_manual, Author, gender)

# add author data back to book data
all_books <- merge(all_books, authors_df_2_manual)

## books by gender (read only)
books_read <- filter(all_books, Read.Count >= 1)
ggplot(books_read) + geom_bar(aes(x = gender))

## function to plot books by gender for specific time period
extract_time_period <- function(data, start_date, end_date) {
  data <- filter(data, Date.Read >= start_date) %>%
                   filter(Date.Read <= end_date)
}

# # get all unique bookshelves (because Date.Read data is bad)
# # paste together all bookshelves
# all_bookshelves <- as.vector(unique(all_books$Bookshelves)) %>%
#   paste(sep = ",", collapse = " ")
# all_bookshelves <- gsub(" ", ",", all_bookshelves)
# #strsplit
# all_bookshelves <- strsplit(all_bookshelves, ",")
# # get unique
# all_bookshelves <- unique(all_bookshelves[[1]])

# get books shelved for a specific year
all_books[grep("2018", all_books$Bookshelves),] %>% 
  ggplot() + geom_bar(aes(x = gender, fill = gender)) + 
  theme_minimal()

# percent instead of count
all_books[grep("2018", all_books$Bookshelves),] %>% 
  ggplot() + geom_bar(aes(x = gender, y = ..prop.., group = 1, fill = factor(..x..))) + 
  theme_minimal() + 
  theme(legend.position = "none") + 
  ylab("Percent of books") + 
  xlab("Author gender")
