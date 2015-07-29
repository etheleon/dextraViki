

## Disclaimer: 
Records only includes cases where User began watching from Episode1

## Summary

* mv_ratio 
* score 

>NOTE:: Country is masked

geoblock (only some of the countries are available)


```r
behave      = data.table::fread("../data/Behavior_training.csv")
dateTime    = behave$date_hour %>% 
                str_split(pattern="T") %>% 
                do.call(rbind,.) %>% 
                as.data.frame %>% setNames(c("date", "time"))

dateTime    %<>% mutate(date = lubridate::ymd(date))
behave      %<>% cbind(dateTime)
str(behave)
```

```
## Classes 'data.table' and 'data.frame':	4881883 obs. of  7 variables:
##  $ date_hour: chr  "2014-10-06T09" "2014-10-19T09" "2014-10-11T09" "2014-10-12T06" ...
##  $ user_id  : int  759744 759744 759744 759744 759744 759744 759744 759744 759744 759744 ...
##  $ video_id : chr  "TV003" "TV015" "TV040" "TV045" ...
##  $ mv_ratio : int  6 75 96 78 1 86 24 20 3 1 ...
##  $ score    : int  1 2 3 2 1 3 2 2 1 1 ...
##  $ date     : POSIXct, format: "2014-10-06" "2014-10-19" ...
##  $ time     : Factor w/ 24 levels "00","01","02",..: 10 10 10 7 1 7 4 20 6 23 ...
##  - attr(*, ".internal.selfref")=<externalptr>
```



```r
users  = read.csv("../data/User_attributes.csv")
str(users)
```

```
## 'data.frame':	887416 obs. of  3 variables:
##  $ user_id: int  1 2 3 4 5 6 7 8 9 10 ...
##  $ country: Factor w/ 228 levels "Country001","Country002",..: 1 2 1 3 1 4 5 1 1 6 ...
##  $ gender : Factor w/ 4 levels "f","m","None",..: 3 3 3 3 3 3 3 3 3 3 ...
```


```r
videos_attributes = read.csv("../data/Video_attributes.csv", h = T)
str(videos_attributes)
```

```
## 'data.frame':	623 obs. of  11 variables:
##  $ video_id        : Factor w/ 623 levels "TV001","TV002",..: 1 2 3 4 5 6 7 8 9 10 ...
##  $ container_id    : Factor w/ 623 levels "Container001",..: 1 2 3 4 5 6 7 8 9 10 ...
##  $ origin_country  : Factor w/ 16 levels "ca","cn","co",..: 15 15 14 15 14 9 15 2 16 14 ...
##  $ origin_language : Factor w/ 11 levels "en","es","hi",..: 1 1 11 1 11 6 1 10 2 11 ...
##  $ adult           : Factor w/ 2 levels "False","True": 1 1 1 1 1 1 1 1 1 1 ...
##  $ broadcast_from  : Factor w/ 186 levels "1927-09","1930-08",..: 186 164 153 164 164 164 13 138 155 164 ...
##  $ broadcast_to    : Factor w/ 169 levels "1933-07","1935-06",..: 169 146 137 146 149 146 11 119 169 149 ...
##  $ season_number   : Factor w/ 9 levels "0","1","11","2",..: 9 5 9 5 9 9 9 9 9 9 ...
##  $ content_owner_id: Factor w/ 77 levels "ContentOwner01",..: 1 2 3 2 4 5 6 7 8 4 ...
##  $ genres          : Factor w/ 240 levels "Action & Adventure (1g)",..: 237 1 98 52 116 165 237 80 212 116 ...
##  $ episode_count   : int  5 10 77 10 21 17 17 122 29 22 ...
```

```r
videos_casts      = read.csv("../data/Video_casts.csv", h = T)
str(videos_casts)
```

```
## 'data.frame':	5333 obs. of  4 variables:
##  $ container_id: Factor w/ 432 levels "Container003",..: 219 136 183 112 113 112 188 274 308 235 ...
##  $ person_id   : Factor w/ 1954 levels "Cast0001","Cast0002",..: 1 2 3 4 5 6 7 8 9 10 ...
##  $ country     : Factor w/ 11 levels "cn","gb","hk",..: 8 10 5 5 5 5 5 5 10 10 ...
##  $ gender      : Factor w/ 2 levels "f","m": 1 1 2 2 1 1 2 1 1 1 ...
```


```r
save(behave, users, videos_attributes, videos_casts, file="../data/data.Rdata")
```

