---
author: Wesley & Ritika
title: Users with High Score
---



# Exploratory Analysis

There were a total of 4881883 user behaviour records with 753272 users coming from 
0.


```r
userdetails_all     <- merge(behave, users, by="user_id", all.x=TRUE)
user_video_nocast   <- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)
```

We found the total score for each user and named it `totalScore`.


```r
#group the users by Score country and gender
uu2 <- user_video_nocast               %>%
        group_by(user_id)              %>%
        summarise(
            totalScore = sum(score),
            freq = n(),
            country = unique(country),
            gender = unique(gender))   %>%
        arrange(desc(totalScore))
```

Next we looked at the various quantiles for `totalScore` and found that categorised users into two categories


```r
quantile(uu2$totalScore, c(0,0.25,0.5,0.75,1))
```

```
##   0%  25%  50%  75% 100% 
##    1    3    6   16  224
```

| Category | Description                                                                                  |
| ---      | ---                                                                                          |
| HiScore  | Users >= 80 percentile (based on score). They have 60% of total views (need so suptantiate)  |
| LowScore | Users < 80 percentile (based on score)                                                       |

## High Score Users


```r
hiScore      <- subset(uu2, totalScore >= 20)
hiScoreVideo <- subset(user_video_nocast, user_id %in% unique(hiScore$user_id))
```

We decided to further segment the scores into 4 categories

| newScore | range               |
| ---      | ---                 |
| 1        | mv_ratio < 20       |
| 2        | 20 <= mv_ratio < 50 |
| 3        | 50 <= mv_ratio < 80 |
| 4        | mv_ratio >= 80 |



## Segmenting by Frequency


```r
##Segmenting High Score Users by Frequency
hiScoreByFreq <-    hiScoreVideo_new %>%
    group_by(user_id)                %>%
    summarise(freq          = n(),
              totalScore    = sum(score),
              totalScoreNew = sum(scoreNew),
              country       = unique(country),
              gender        = unique(gender)
              )
quantile(hiScoreByFreq$freq, seq(0,1,0.05)) 
```

```
##   0%   5%  10%  15%  20%  25%  30%  35%  40%  45%  50%  55%  60%  65%  70% 
##    7    9   10   11   12   12   13   14   14   15   16   17   18   20   21 
##  75%  80%  85%  90%  95% 100% 
##   23   25   28   33   40   89
```

We segment the users into the 95, 65-95, < 65 percentiles.


```r
#making different df by Freq (95%ile & above; 65-95 %ile; < 65%ile)
hiScoreHiFreq  <- subset(hiScoreByFreq, freq >= 40)
hiScoreMoFreq  <- subset(hiScoreByFreq, freq >= 20 & freq <40)
hiScoreLowFreq <- subset(hiScoreByFreq, freq < 20)
# with video details
hiScHiFreqVideo  <- subset(hiScoreVideo_new, hiScoreVideo$user_id %in% hiScoreHiFreq$user_id)
hiScMoFreqVideo  <- subset(hiScoreVideo_new, hiScoreVideo$user_id %in% hiScoreMoFreq$user_id)
hiScLowFreqVideo <- subset(hiScoreVideo_new, hiScoreVideo$user_id %in% hiScoreLowFreq$user_id)
```

## Ranking the users


```r
#*** RANKING CODE (based on the new scoring scheme - scoreNew)

hiScHiFreqRankNew <- hiScHiFreqVideo %>% group_by(video_id) %>% 
summarise(
  totalviews     = n(), 
  scoreNew1views = sum(scoreNew == "1")/n(), 
  scoreNew2views = sum(scoreNew=="2")/n(), 
  scoreNew3views = sum(scoreNew=="3")/n(), 
  scoreNew4views = sum(scoreNew=="4")/n(), 
  RankingNew     = ((scoreNew1views*1+scoreNew2views*2+scoreNew3views*3+ scoreNew4views*4)* (scoreNew3views+scoreNew4views)*totalviews)
  ) %>%
arrange(desc(RankingNew))
```

We check to see if the new ranking system has an effect


```r
##Plot both old and new rankings and score views
hiScHiFreqRankNew <- merge(hiScHiFreqRankNew, hiScHiFreqRankOld %>% select(video_id, RankingOld) , by = "video_id", all.x = TRUE)
```

```
## Error in eval(expr, envir, enclos): object 'hiScHiFreqRankOld' not found
```

```r
## Plot for New Ranking (with a line for Old Ranking as well)

#Set Factor levels
hiScHiFreqRankNew %<>% arrange(desc(RankingNew))
hiScHiFreqRankNew$video_id %<>% factor(levels = as.character(hiScHiFreqRankNew$video_id))

hiScHiFreqRankNew_long <- hiScHiFreqRankNew %>%
    gather(scoreType, value, -video_id, -totalviews, -RankingNew, -RankingOld)
```

```
## Error in eval(expr, envir, enclos): object 'RankingOld' not found
```

```r
rankDFNew <- hiScHiFreqRankNew_long %>% select(video_id, RankingNew, RankingOld) %>% unique
```

```
## Error in eval(expr, envir, enclos): object 'hiScHiFreqRankNew_long' not found
```

```r
rankDFNew %<>% gather(rankType, value, -video_id)
```

```
## Error in eval(expr, envir, enclos): object 'rankDFNew' not found
```


```r
#  pdf("../out/.pdf", w=20)
hiScHiFreqRankNew_long %>% 
    mutate(newValue = value * totalviews) %>% 
    ggplot(aes(x=video_id, y=newValue))                                                                                                 +
        geom_line(aes(group=scoreType, color=scoreType))                                                                                +
        geom_line(data=rankDFNew, inherit.aes=FALSE, aes(video_id, value/2, group=rankType, linetype=rankType), color="black",size=0.5) +
        ylab("Totalviews")                                                                                                              +
        ggtitle("New ranking")
```

```
## Error in eval(expr, envir, enclos): object 'hiScHiFreqRankNew_long' not found
```

```r
#  dev.off() 
```


```r
## Plot for Old Ranking** No Need to run til you want to look at the details
  
hiScHiFreqRankOld <- hiScHiFreqVideo %>%
group_by(video_id) %>%
    summarise(
      totalviews   =  n(),
      score1views  =  sum(score == "1")/n(),
      score2views  =  sum(score=="2")/n(),
      score3views  =  sum(score=="3")/n(),
      RankingOld   =  ((score1views*1+score2views*2+score3views*3)*(score2views+score3views)*totalviews)
)%>% 
arrange(desc(RankingOld))
  
hiScHiFreqRankOld %<>% arrange(desc(RankingOld))
hiScHiFreqRankOld$video_id = factor(hiScHiFreqRankOld$video_id, levels = as.character(hiScHiFreqRankOld$video_id))
  
hiScHiFreqRankOld_long = hiScHiFreqRankOld %>%
gather(scoreType, value, -video_id, -totalviews, -RankingOld)
  
rankDFOld = hiScHiFreqRankOld_long %>% select(video_id, RankingOld) %>% unique
```


```r
#  pdf("../out/.pdf", w=20) 
hiScHiFreqRankOld_long                %>%
mutate(newValue = value * totalviews) %>%
ggplot(aes(x=video_id, y=newValue))                                 +
    geom_line(aes(group=scoreType, color=scoreType))                +
    geom_line(data=rankDFOld,
        aes(video_id, RankingOld/2, group=1),
        inherit.aes=FALSE, color="black", size=1.5)                 +
    ylab("Totalviews")                                              +
    ggtitle("Old ranking")
```

![plot of chunk scoreTypeRankingOLD](figure/scoreTypeRankingOLD-1.png) 

```r
#  dev.off()
```



## High-Score High-Freq 

Segmented by gender, score, Frequency



## Session Infomation


```
## R version 3.1.1 (2014-07-10)
## Platform: x86_64-apple-darwin13.1.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] recommendR_0.0.0.9000 devtools_1.9.0        ggplot2_1.0.1        
## [4] tidyr_0.2.0           dplyr_0.4.1           magrittr_1.5         
## [7] knitr_1.10.5          setwidth_1.0-4        colorout_1.0-3       
## 
## loaded via a namespace (and not attached):
##  [1] assertthat_0.1    codetools_0.2-9   colorspace_1.2-6 
##  [4] DBI_0.3.1         digest_0.6.8      evaluate_0.7     
##  [7] formatR_1.2       grid_3.1.1        gtable_0.1.2     
## [10] labeling_0.3      lazyeval_0.1.10   markdown_0.7.7   
## [13] MASS_7.3-35       memoise_0.2.1     munsell_0.4.2    
## [16] parallel_3.1.1    plyr_1.8.3        proto_0.3-10     
## [19] Rcpp_0.12.0       reshape2_1.4.1    scales_0.2.5.9000
## [22] stringi_0.5-5     stringr_1.0.0     tools_3.1.1
```
