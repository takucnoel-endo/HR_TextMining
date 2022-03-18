# R Tutorial
# Text mining is used to converted unstructured data into structured data for 
# different data analysis purposes, such as word frequency analysis, topic identification and so on.

# load packages
library(tidytext)
library(ggraph)
library(dplyr)
library(tidyr)
library(ggplot2)

#Loading in the data


user_reviews <- readr::read_tsv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-05/user_reviews.tsv')

# Clearning Steps

# 1 Tokenization: unnest_tokens function
#A token is a meaningful unit of text, most often a word, 
#that we are interested in using for further analysis, 
#and tokenization is the process of splitting text into tokens.
#


user_reviews%>%
  unnest_tokens(output=word,input=text) %>%
  count(word, sort=T)


# 2 Apply stoplis#stop words are words that are not useful for 
#an analysis, typically extremely common words such as 
#"the", "of", "to", and so forth in English. 

stop_words

tidy_reviews<-user_reviews%>%
  unnest_tokens(output=word,input=text) %>%
anti_join(stop_words)%>%
  count(word, sort=T)

#Update stop word list
stop_words<-stop_words%>%add_row(word="1",lexicon="SMART")



tidy_reviews %>%
 filter(n >500) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col() +
  labs(y = NULL)



# N-gram analysis
#we can also use the function to tokenize into consecutive sequences of words, 
#called n-grams.

tidy_reviewgrams<-
  user_reviews%>%
  unnest_tokens(bigram,input=text,token = "ngrams",n=2)%>%
  count (bigram,sort=T)

#As one might expect, a lot of the most common bigrams are pairs of common (uninteresting)
#words, such as of the and to be: what we call "stop-words" (see Chapter 1). 
#This is a useful time to use tidyr's separate(), 
#which splits a column into multiple based on a delimiter. 
#This lets us separate it into two columns, "word1" and "word2", 
#at which point we can remove cases where either is a stop-word.

bigrams_separated <- tidy_reviewgrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)

#combine bigram
bigrams_united <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")

# new bigram counts:
bigram_counts <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

library(Rccp)

bigrams_united


bigrams_united %>%
  filter(n >100) %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(n, bigram)) +
  geom_col() +
  labs(y = NULL)

# what about trigram: three consecutive words?
