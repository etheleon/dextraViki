#!/usr/bin/env Rscript

load("../data/data.Rdata")
library (magrittr)
library (dplyr)
library (tidyr)
library (ggplot2)

# Merged user behave and video attributes datasets

```{r init,echo=FALSE}
userdetails_all <- merge(behave, users, by="user_id", all.x=TRUE)
user_video_nocast <- merge(userdetails_all, videos_attributes, 
                               by="video_id", all.x=TRUE)
```
# We decided to further segment the scores into 4 categories and updated the dataset of hiScore and low Score Users
| newScore | range               |
  | ---      | ---                 |
  | 1        | mv_ratio < 20       |
  | 2        | 20 <= mv_ratio < 50 |
  | 3        | 50 <= mv_ratio < 80 |
  | 4        | mv_ratio >= 80 |
  
  ```{r eval=FALSE, echo=FALSE}
dff = user_video_nocast %>% 
  transmute(mv_ratio = mv_ratio, video_id = video_id, user_id = user_id, 
            Score1 = (mv_ratio < 20 )*1,
            Score2 = (mv_ratio >= 20 & mv_ratio <50)*1,
            Score3 = (mv_ratio >= 50 & mv_ratio < 80)*1, 
            Score4 = (mv_ratio >= 80)*1) %>% gather(scoreType, value, -video_id, -user_id, -mv_ratio)
dff %<>% filter(value > 0 )

# change scoreType to integers
dff$scoreType = factor(dff$scoreType, labels=c("1", "2", "3", "4"))
dff$scoreType %<>% as.character %>% as.integer
dff %<>% select(-value) 
colnames(dff)[4] = "scoreNew" 

user_video_nocast_new <- merge(user_video_nocast, dff, 
                          by= c("user_id","video_id", "mv_ratio"),all=TRUE)
```

# Identify the highly engaged UserBase based on initial scoring scheme.
##  We segmented users into high score users (top 20 percentile) and low score users (rest 80 percentile). 

```{r}
uu2 <- user_video_nocast %>% group_by(user_id) %>% 
  summarise( totalScore = sum(score),freq = n(), country = unique(country), 
             gender = unique(gender)) %>% arrange(desc(totalScore))
hiScore<- subset(uu2, totalScore >= quantile(uu2$totalScore,0.8))
lowScore<- subset(uu2, totalScore < quantile(uu2$totalScore,0.8))

hiScoreVideo <- subset(user_video_nocast_new, user_id %in% unique(hiScore$user_id))
lowScoreVideo <- subset(user_video_nocast_new, user_id %in% unique(lowScore$user_id))
```
# we ranked the videos (watched by high Score Users) based on their frequency giving higher weights to views with mv_ratio > 50.

```{r}
hiScoreRankNew <- hiScoreVideo_new %>% group_by(video_id) %>% 
  summarise(
    totalviews= n(), 
    scoreNew1views = sum(scoreNew == "1")/n(), 
    scoreNew2views = sum(scoreNew=="2")/n(), 
    scoreNew3views = sum(scoreNew=="3")/n(), 
    scoreNew4views = sum(scoreNew=="4")/n(), 
    RankingNewOverall = ((scoreNew1views*1+scoreNew2views*2+scoreNew3views*3+ scoreNew4views*4)*
                    (scoreNew3views+scoreNew4views)*totalviews)) %>% arrange(desc(RankingNewOverall))

videoranksHiScore <- subset(hiScoreRankNew, select = c("video_id", "RankingNewOverall")) %>% 
                              arrange(desc(RankingNewOverall))

# Created a dataframe of videos with their genres ranked in descending order

videoRankGenre <- merge(videoranksHiScore, videos_attributes%>% select(video_id,genres), by= "video_id", all.x=TRUE)

```
## Session Infomation

```{r echo=FALSE}
sessionInfo()
```



