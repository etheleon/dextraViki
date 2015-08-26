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
uu2 <- user_video_nocast                %>%
        group_by(user_id)                  %>%
        summarise(
            totalScore = sum(score),
            freq = n(),
            country = unique(country),
            gender = unique(gender))       %>%
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
| HiScore  | Users >= 80 percentile (based on score). They have 60% of total views (need so suptantiate) |
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



##Introduce new Score Levels - 1,2,3,4

##**Merge with HiScHiFreqVideo

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
## [10] lazyeval_0.1.10   markdown_0.7.7    MASS_7.3-35      
## [13] memoise_0.2.1     munsell_0.4.2     parallel_3.1.1   
## [16] plyr_1.8.3        proto_0.3-10      Rcpp_0.12.0      
## [19] reshape2_1.4.1    scales_0.2.5.9000 stringi_0.5-5    
## [22] stringr_1.0.0     tools_3.1.1
```
