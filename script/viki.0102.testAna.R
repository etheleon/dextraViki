#!/usr/bin/env Rscript
library(magrittr)

load("../data/data.Rdata")
mergedVideo <- merge(videos_casts,
             videos_attributes,
             by.x="contained_id",
             by.y="container_id",
             all=T)
#Bad idea
#video_behave = merge(mergedVideo, behave, by="video_id", all=T)


#genres
genres = videos_attributes$genres             %>%
as.character                         %>%
sapply(function(x) strsplit(x,", ")) %>%
do.call(c,.)                         %>%
unname                               

genres %>%
table %>% 
as.data.frame %>%
setNames(c("genres", "freq")) %>%
ggplot(aes(reorder(genres, freq), freq)) +
geom_bar(stat="identity") +
theme(axis.text.x=element_text(angle=90))
#scoring system

# merge everything into 1 table
#    video att with video casts
#    video id with behavior
#casts wide format

#Wide format
#Might be useful

containerWide = videos_casts %>%
select(-country)      %>% 
spread(cast_person_id, casts_gender)

