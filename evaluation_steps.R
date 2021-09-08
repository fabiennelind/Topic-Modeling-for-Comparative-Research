library(data.table)
library(stringr)
library(stringi)
library(plyr)
library(dplyr)


########
#######
# Coherence: NPMI: check whether the language-specific versions of a specific topic k are related to the same concept (each language-specific version by itself)
########
#######


# create input for npmi calcuation

k_list <- c('5', '10', '15', '20', '25', '30', '35', '40', '45', '50')
topic_keys <- data.frame()
# loop over k number of topics
for (k_t in k_list) {
  # load output data from pltm
  filename <- paste0('~/mallet-2.0.8/output/', k_t, 't_output.csv')
  topics <- read.csv(filename, sep = '\t', header = F)
  # rename columns
  colnames(topics)[1] <- ('language')
  colnames(topics)[2] <- ('num_words')
  colnames(topics)[3] <- ('beta')
  colnames(topics)[4] <- ('top_words')
  
  # split up data
  num <- nrow(topics) 
  K <- num/4 
  topics$topic <- rep(1:K, each=4)
  
  check <- topics %>% dplyr::filter(row_number() %% 4 == 1) 
  
  check$alpha <- check$num_words
  check <- subset(check, select =c(alpha, topic))
  
  topics <- topics %>% dplyr::filter(row_number() %% 4 != 1)
  topics <- left_join(topics, check, by = 'topic')
  
  # extract top10 words
  topics$top_word <- str_extract(topics$top_words, '^\\w+\\s\\w+\\s\\w+\\s\\w+\\s\\w+\\s\\w+\\s\\w+\\s\\w+\\s\\w+\\s\\w+\\s')
  
  # split per language
  de <- subset(topics, language == 0)
  de <- subset(de, select = top_word)
  
  en <- subset(topics, language == 1)
  en <- subset(en, select = top_word)
  
  es <- subset(topics, language == 2)
  es <- subset(es, select = top_word)
  
  #save txt file in the format needed for npmi calculation
  fname = paste0(k_t, '_topics.txt')
  
  setwd('~/mallet-2.0.8/coherence/data/en')
  write.table(en, file=fname, sep='\t', quote=FALSE, col.names = F, row.names = F, na = '')
  
  setwd('~/mallet-2.0.8/coherence/data/es')
  write.table(es, file=fname, sep='\t', quote=FALSE, col.names = F, row.names = F, na = '')
  
  setwd('~/mallet-2.0.8/coherence/data/de')
  write.table(de, file=fname, sep='\t', quote=FALSE, col.names = F, row.names = F, na = '')
  topics$k <- k_t
  topic_keys <- rbind(topic_keys, topics)
}

#####
#######
# Before you continue, please calculate npmi: To do so, please follow the instructions published here: https://github.com/jhlau/topic_interpretability
#and cite the respective paper https://aclanthology.org/E14-1056
######
#####


# read the result files (created by python scripts) and add it to topic_key 
npmi_all <- data.frame()
for (k in c('5', '10', '20', '30', '40', '50')) {
  temp_df_npmi = data.frame()
  for (lang in c('de', 'en', 'es')) {
    # read file
    file_path <- paste0('~/mallet-2.0.8/coherence/results/', lang, '/', k, '_topics-oc.txt')
    coherence <- read.delim(file_path, header = F)
    
    # clean: get only the NMPI values and the average
    coherence <- coherence$V1
    coherence_cl <- as.character(coherence)
    test <- paste(unlist(coherence), collapse =' ')
    
    # extract the individual npmi values
    npmi_list <- str_extract_all(test, '\\[.?\\d...') # extract npmi values (just one per topic)
    npmi <- unlist(npmi_list)
    npmi_df <- data.frame(npmi)
    npmi_df$npmi <- gsub('\\[', '', npmi_df$npmi)
    npmi_df$npmi<- as.numeric(npmi_df$npmi)
    
    # extract the average and the median and add to the result df
    average <- str_extract(test, 'Average Topic Coherence = \\d....')
    average <- str_extract(average, '\\d....')
    median <- str_extract(test, 'Median Topic Coherence = \\d....')
    median <- str_extract(median, '\\d....')
    
    npmi_df$npmi_mean <- average
    npmi_df$npmi_median <- median
    
    # add two columns to match back later with the topic keys
    npmi_df$language <- lang
    n <- nrow(npmi_df)
    npmi_df$topic <- seq(1:n)
    npmi_df$k <- k
    temp_df_npmi <- rbind(temp_df_npmi, npmi_df)
  }
  npmi_all <- rbind(npmi_all, temp_df_npmi)
}

topic_keys$language[topics$language == 0] <- 'de'
topic_keys$language[topics$language == 1] <- 'en'
topic_keys$language[topics$language == 2] <- 'es'

topic_keys_coherence <- merge(topic_keys, npmi_all, by=c('language', 'topic', 'k'))
# save output
setwd('~/mallet-2.0.8/coherence/topic_keys_npmi')
write.csv('topic_keys.csv', x=topic_keys_coherence, row.names = F)




########
#######
# Consistency: MTA: assess whether the language-specific versions of a specific topic k are all related to the same concept (across languages)
########
#######

# prepare data for translation
rm(list=setdiff(ls(), 'topic_keys_coherence'))

setwd('~/mallet-2.0.8/output/')

# loop over k number of topics
for (k in c('5', '10', '20', '30', '40', '50')) {
  # read file
  file_name = paste0(k, 't_output.csv')
  topic_keys <- read.csv(file_name, sep = '\t', header = F)
  topic_keys$model_ID <- file_name
  
  # some cleaning & restructuring (insight from: http://mallet.cs.umass.edu/topics-polylingual.php)
  colnames (topic_keys) [1] <- ('language')
  colnames (topic_keys) [2] <- ('num_words')
  colnames (topic_keys) [3] <- ('beta')
  colnames (topic_keys) [4] <- ('top_words')
  
  # topic number
  num <- nrow(topic_keys) 
  K <- num/4
  topic_keys$topic <- rep(1:K, each=4)
  
  # extract alpha info
  check <- topic_keys %>% dplyr::filter(row_number() %% 4 == 1) # select the alpha values (every 4th line) 
  check$alpha <- check$num_words
  check <- subset(check, select = c(alpha, topic))
  
  topic_keys <- topic_keys %>% dplyr::filter(row_number() %% 4 != 1) # delete alpha info 
  topic_keys <- left_join(topic_keys, check, by = 'topic')
  
  #### MTA of top words

  # extract the all top words and store them individually in a column 
  extr_top_words <- as.data.frame(str_split_fixed(topic_keys$top_words, ' ', 11))
  topic_keys$top_word_01 <- trimws(extr_top_words$V1)
  topic_keys$top_word_02 <- trimws(extr_top_words$V2)
  topic_keys$top_word_03 <- trimws(extr_top_words$V3)
  topic_keys$top_word_04 <- trimws(extr_top_words$V4)
  topic_keys$top_word_05 <- trimws(extr_top_words$V5)
  topic_keys$top_word_06 <- trimws(extr_top_words$V6)
  topic_keys$top_word_07 <- trimws(extr_top_words$V7)
  topic_keys$top_word_08 <- trimws(extr_top_words$V8)
  topic_keys$top_word_09 <- trimws(extr_top_words$V9)
  topic_keys$top_word_10 <- trimws(extr_top_words$V10)
  
  filename_new <- paste0(k, 'topics_for_translation.csv')
  setwd('~/mallet-2.0.8/translate_terms/input')
  write.csv(topic_keys, filename_new, row.names = F)
}
rm(list=ls())

########
########
# translation: start python script "translate_top_terms.py"
########
########

# mta calculation

# read in the translated keywords
setwd('~/mallet-2.0.8/translate_terms/output')
topic_keys <- fread('results.csv')

#clean results
#all to lower case (has to be upper case for translation)
for (lang in c('de', 'en', 'es')) {
  for (k in c('01', '02', '03', '04', '05', '06', '07', '08', '09', '10')) {
    var <- paste0('top_word_mt_', lang, '_', k)
    topic_keys[[var]] <- tolower(topic_keys[[var]])
  }
}

# identify NAs
topic_keys <- na_if(topic_keys, 'term not detected') 
# model ID
topic_keys$model_ID_topic <- paste0(topic_keys$model_ID, topic_keys$topic)

all_mta  <- NULL
model_ID_topic <- unique(topic_keys$model_ID_topic)

mta_df <- data.frame()
# calculate mta per model
for (i in 1:length(model_ID_topic)) { 
  topic_num <- str_sub(model_ID_topic[i], start= -1)
  topic <- topic_keys[topic_keys$model_ID_topic==model_ID_topic[i],]
  model_ID <- topic[1,]$model_ID_topic
  
  #filter out line with original language topic terms
  topic_en <- subset(topic, language==1)
  topic_es <- subset(topic, language==2)
  topic_de <- subset(topic, language==0)
  
  # loop over languages
  tmta <- 0
  for (lang in c('en', 'es', 'de')) {
    if (lang == 'en') {
      lnr <- 1
      ol1 <- 'es'
      ol_n1 <- 2
      ol2 <- 'de'
      ol_n2 <- 0
    }
    if (lang == 'es') {
      lnr <- 2
      ol1 <- 'en'
      ol_n1 <- 1
      ol2 <- 'de'
      ol_n2 <- 0
    }
    if (lang == 'de') {
      lnr <- 0
      ol1 <- 'en'
      ol_n1 <- 1
      ol2 <- 'es'
      ol_n2 <- 2
    }
    
    temp_topic <- subset(topic, language==lnr)
    temp_topic_ol1 <- subset(topic, language==ol_n1)
    temp_topic_ol2 <- subset(topic, language==ol_n2)
    orig <- data.frame()
    mt1 <- data.frame()
    mt2 <- data.frame()
    
    for (i in c('01', '02', '03', '04', '05', '06', '07', '08', '09', '10')) {
      orig <- rbind(orig, temp_topic[[paste0('top_word_', i)]])
      mt1 <- rbind(mt1, tolower(temp_topic_ol1[[paste0('top_word_mt_', lang, '_', i)]]))
      mt2 <- rbind(mt2, tolower(temp_topic_ol2[[paste0('top_word_mt_', lang, '_', i)]]))
    }
    
    temp_t <- cbind(orig, mt1, mt2)
    colnames(temp_t) <- c('orig', 'mt1', 'mt2')
    
    orig_n <- 0
    for (i in 1:nrow(temp_t)) {
      orig_n <- orig_n + length(intersect(temp_t[i,]$orig,temp_t$mt1)) + length(intersect(temp_t[i,]$orig,temp_t$mt2))
    }
    
    tmta <- tmta + orig_n
  }
  mta_df <- rbind(mta_df, data.frame(model_ID=model_ID, mta=tmta))
}

write.csv('~/mallet-2.0.8/translate_terms/mta_output.csv', x=mta_df, row.names = F)



