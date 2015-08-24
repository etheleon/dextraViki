oad("../data/data.Rdata")
library (magrittr)
library (dplyr)
library (tidyr)
library (ggplot2)

#Merged behave and users dataframe

userdetails_all <- merge(behave, users, by="user_id", all.x=TRUE)

#Merge Userdetails with video details (except the casts)
user_video_nocast <- merge(userdetails_all, videos_attributes, 
                           by="video_id", all.x=TRUE)

#group the users by Score country and gender
uu2 <- user_video_nocast %>% group_by(user_id) %>% 
  summarise( totalScore = sum(score),freq = n(), country = unique(country), 
             gender = unique(gender)) %>% arrange(desc(totalScore))
quantile(uu2$totalScore, c(0.0,0.25,0.5,0.75,1))

#HiScore users include everyone in the top 20%tile as per Score. They have 60% of total views
#Hi Score Users are Users with Score >= 20

hiScore<- subset(uu2, totalScore >= 20)
hiScoreVideo <- subset(user_video_nocast, user_id %in% unique(hiScore$user_id))

#*created a new variable scoreType with levels - 1,2,3, 4 (for mv_ratio <20, >=20 & <50, >=50 & <80, >=80)
dff = hiScoreVideo %>% 
  transmute(mv_ratio = mv_ratio, video_id = video_id, user_id = user_id, 
            Score1 = (mv_ratio < 20 )*1,
            Score2 = (mv_ratio >= 20 & mv_ratio <50)*1,
            Score3 = (mv_ratio >= 50 & mv_ratio < 80)*1, 
            Score4 = (mv_ratio >= 80)*1) %>% gather(scoreType, value, -video_id, -user_id, -mv_ratio)
dff %<>% filter(value > 0 )
dff$scoreType = factor(dff$scoreType, labels=c("1", "2", "3", "4"))
dff$scoreType %<>% as.character %>% as.integer
dff %<>% select(-value) #remove a column
colnames(dff)[4] = "scoreNew" #rename a col

#merging with dff to get new score variables 
hiScoreVideo_new <- merge(hiScoreVideo, dff, 
                          by= c("user_id","video_id", "mv_ratio"),all=TRUE)

##****************ranking Videos of Hi Score Users******************************************

hiScoreRankNew <- hiScoreVideo_new %>% group_by(video_id) %>% 
  summarise(
    totalviews= n(), 
    scoreNew1views = sum(scoreNew == "1")/n(), 
    scoreNew2views = sum(scoreNew=="2")/n(), 
    scoreNew3views = sum(scoreNew=="3")/n(), 
    scoreNew4views = sum(scoreNew=="4")/n(), 
    RankingNewOverall = ((scoreNew1views*1+scoreNew2views*2+scoreNew3views*3+ scoreNew4views*4)*
                    (scoreNew3views+scoreNew4views)*totalviews)) %>% arrange(desc(RankingNewOverall))


##***************Videos with Ranks  (Videos of HiScoreUsers only)**************************
videoranksHiScore <- subset(hiScoreRankNew, select = c("video_id", "RankingNewOverall")) %>% arrange(desc(RankingNewOverall))

write.table(videoranksHiScore, "/Users/ritikakapoor/Desktop/dextraViki/out/HiScoreVideoRanks.txt", sep = "\t")

## ********Plot for Ranking - Overall Rank(HighScore Users: video 585) with Rank (HiScHIFreq Users; video: 560)*****
#*********Need to run previous Code - .1014hiScoreAnalysis.R****************

hiscoreRankCompare <- merge(hiScoreRankNew, hiScHiFreqRankNew %>% select(video_id, RankingNew) , by = "video_id", all.x=TRUE )


hiscoreRankCompare %<>% arrange(desc(RankingNewOverall))
hiscoreRankCompare$video_id = factor(hiscoreRankCompare$video_id, levels = as.character(hiscoreRankCompare$video_id))

hiscoreRankCompare_long = hiscoreRankCompare %>%
  gather(scoreType, value, -video_id, -totalviews, -RankingNew, -RankingNewOverall)

rankDFNewOverall = hiscoreRankCompare_long %>% select(video_id, RankingNew, RankingNewOverall) %>% unique
rankDFNewOverall %<>% gather(rankType, value, -video_id)
pdf("../out/scoreTypeRankingHiScoreOverall.pdf", w=20)
hiscoreRankCompare_long %>% mutate(newValue = value* totalviews) %>% 
  ggplot(aes(x=video_id, y=newValue))                                 +
  geom_line(aes(group=scoreType, color=scoreType))                    +
  geom_line(data=rankDFNewOverall, inherit.aes=FALSE, aes(video_id, value/2, group=rankType, linetype=rankType), color="black",size=0.5) +
  ylab("Totalviews")+ggtitle("New ranking")
dev.off() 




