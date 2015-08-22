#!/usr/bin/env Rscript

load("../data/data.Rdata")

library(parallel)
library(magrittr)
library(dplyr)
theme_set(theme_bw())

userdetails_all <- merge(behave, users, by="user_id", all.x=TRUE)
user_video_nocast <- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)
mergedVideo <- merge(videos_casts,
             videos_attributes,
             by.x="contained_id",
             by.y="container_id",
             all=T)
user_video_nocast$user_id %<>% as.factor
user_score <- user_video_nocast %>% group_by(user_id) %>% summarise(totalScore = sum(score)) %>% arrange(desc(totalScore))
uu = merge(user_score, users)
#Step2
abc <- behave %>% group_by(user_id) %>% summarise(freq = n(), totalScore = sum(score)) %>% arrange(desc(freq))
uu2 <- merge(uu, abc, by = c("user_id", "totalScore")) %>% arrange(desc(freq)) #add totalscore to users
hiScore<- subset(uu2, totalScore >= 20)
hiScoreVideo <- subset(user_video_nocast, user_id %in% unique(hiScore$user_id))
hiScoreByFreq <-  hiScoreVideo    %>%
                group_by(user_id) %>%
                summarise(freq = n(), 
                          totalScore = sum(score),
                          country = unique(country),
                          gender = unique(gender))
hiScore_COI = hiScoreVideo %>% #filter(user_id %in% c(37, 91)) %>%
            select(video_id, user_id, mv_ratio, genres)
hiScoreHiFreq <- hiScoreByFreq %>% filter(freq >= 40) %>% #nrow
            inner_join(hiScore_COI)

write.table(hiScoreHiFreq %>% select(user_id, genres, mv_ratio), file="../out/hiScoreHiFreq_genreInfo.txt", quote=F, col.names=F, 
            row.name=F, sep="\t")
dff = read.table("../out/viki.0103.output_hiFreq_hi.txt", skip=2)
dff2 = dff[,-1]
colnames(dff2) = c(genres, "country", "gender")

hiFreqPCA = prcomp(dff2[, 1:33], center = T, scale.=T)
library(ggbiplot)
pdf("../out/viki.0102.hiFreq.pdf", w=20, h=20)
plot(hiFreqPCA, type="l")
   ggbiplot(hiFreqPCA, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE, alpha=0.01)
   ggbiplot(hiFreqPCA, obs.scale = 1, choices = c(1,3), var.scale = 1, ellipse = TRUE,circle = TRUE, alpha=0.01)
   ggbiplot(hiFreqPCA, obs.scale = 1, choices = c(2,3), var.scale = 1, ellipse = TRUE,circle = TRUE, alpha=0.01)
dev.off()


hiScoreMoFreq <- subset(hiScoreByFreq, freq >= 20 & freq <40)

hiScoreLowFreq <- subset(hiScoreByFreq, freq < 20)


