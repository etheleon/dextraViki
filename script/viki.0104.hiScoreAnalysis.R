
#Merged behave and users dataframe
userdetails_all <- merge(behave, users, by="user_id", all.x=TRUE)

#Analysis of Userdetails_all:
  #   behave df has 4,881,883 records with 753,272 unique user_id's belonging to 228 countries
  #   (There is no NONE value for country)

#Merge Userdetails with video details (except the casts)
user_video_nocast <- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)

#group the users by Score country and gender
uu2 <- user_video_nocast %>% group_by(user_id) %>% 
          summarise(totalScore = sum(score),freq = n(), country = unique(country), 
              gender = unique(gender)) %>% arrange(desc(totalScore))

#HiScore users include everyone in the top 20%tile as per Score. They have 60% of total views
#Hi Score Users are Users with Score >= 20

hiScore<- subset(uu2, totalScore >= 20)
   ## hiScore Video Details:
hiScoreVideo <- subset(user_video_nocast, user_id %in% unique(hiScore$user_id))

    ##Segmenting High Score Users by Frequency
hiScoreByFreq <-  hiScoreVideo %>% group_by(user_id) %>% 
       summarise(freq = n(), totalScore = sum(score), 
          country = unique(country), gender = unique(gender))
quantile(hiScoreByFreq$freq, seq(0,1,0.05)) 
 
##making different df by Freq (95%ile & above; 65-95 %ile; < 65%ile)

hiScoreHiFreq <- subset(hiScoreByFreq, freq >= 40)
hiScoreMoFreq <- subset(hiScoreByFreq, freq >= 20 & freq <40)
hiScoreLowFreq <- subset(hiScoreByFreq, freq < 20)

  # with video details
hiScHiFreqVideo <- subset(hiScoreVideo, hiScoreVideo$user_id %in% hiScoreHiFreq$user_id)
hiScMoFreqVideo <- subset(hiScoreVideo, hiScoreVideo$user_id %in% hiScoreMoFreq$user_id)
hiScLowFreqVideo <- subset(hiScoreVideo, hiScoreVideo$user_id %in% hiScoreLowFreq$user_id)

##Ranking 
  #*created a new variable Score_new with levels - 1,2,3, 4 (for mv_ratio <20, >=20 & <50, >=50 & <80, >=80)
dff = hiScoreVideo %>% 
  transmute(mv_ratio = mv_ratio, video_id = video_id, user_id = user_id, 
            Score1 = (mv_ratio < 20)*1, 
            Score2 = (mv_ratio >= 20 & mv_ratio <50)*1, 
            Score3 = (mv_ratio >= 50 & mv_ratio < 80)*1, 
            Score4 = (mv_ratio >= 80)*1) 
##>>>some issue with dff. If we print head we see that for column score1 mv_ratio's are mentioned again 
 
 %>%gather(scoreType, value, -video_id, -user_id, -mv_ratio)

dff$scoreType = factor(dff$scoreType, labels=c("1", "2", "3", "4"))
dff$scoreType %<>% as.character %>% as.integer
##>>>check number of rows in dff and hiScoreVideo should be the same but it isnt! so some issue here!!
    
#merging with df:hiScHiFreqVideo, Movideo, LowVideo
hiScoreVideo_new <- merge(hiScoreVideo, dff, 
                       by= c("user_id","video_id",all=TRUE)

  #**NEW RANKING CODE
  hiScHiFreqRank <- hiScHiFreqVideo %>% group_by(video_id) %>% 
    summarise(totalviews= n(), 
    Score1views= sum(Score_new == "1")/n(), 
    Score2views = sum(Score_new=="2")/n(), 
    Score3views = sum(Score_new=="3")/n(), 
    Ranking = (Score1views*1+Score2views*2+Score3views*3)*(Score2views+Score3views)*totalviews )
  %>% arrange(desc(Ranking)) %>% arrange(desc(Ranking))
 
  
  ##Plot

## copy from Plotscript uploaded in R
  
  
  
  
# *********************************************************************** 
  ##seeing country wise behaviour for the top countries
  
  ## pattern by Country of User
hiScoreHiFreq %>% group_by(country) %>% 
    summarise(CountryFreq = sum(freq), CountryScore = sum(totalScore), 
              f=sum(gender=="f"),m=sum(gender=="m"), o=sum(gender=="o"), N=sum(gender=="None"),
              total = n())%>% arrange(desc(CountryFreq)) %>% head(n=1)

subset(hiScHiFreqVideo, country == "Country001") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender)

##hiScoreHiFreq pattern by gender and score & freq
hiScoreHiFreq %>% group_by(country) %>% summarise(CountryFreq = sum(freq), CountryScore = sum(totalScore), f=sum(gender=="f"),m=sum(gender=="m"), o=sum(gender=="o"), N=sum(gender=="None"), total = n())%>% arrange(desc(CountryFreq)) %>% head(n=15)

#**********************************************************************
#freq Score and User Profiles by Country ***** Results
country CountryFreq CountryScore    f   m  o    N total
1  Country001      184456       353014 1777 335 10 1582  3704
2  Country010       31012        57972  435  42  0  139   616
3  Country002       23698        45259  295  33  2  148   478
4  Country003       18618        34603  195  20  0  151   366
5  Country007       17070        32601  252  24  0   59   335
6  Country014       12975        24884  145  19  0  101   265
7  Country009        9546        17655  150   9  0   38   197
8  Country045        8300        16137  121  13  0   33   167
9  Country018        8046        14675  109   7  0   42   158
10 Country004        7996        14851   94  10  1   51   156
11 Country015        7287        13997  106   3  0   38   147
12 Country011        6866        12911  111   6  0   21   138
13 Country021        6437        11970   80   6  0   42   128
14 Country035        4157         7834   66   6  1   14    87
15 Country022        3578         6418   43   2  1   26    72


##PDF of the graphs (originCountry_Score_by Gender)
pdf("~/Desktop/VideoByCountry.pdf")
subset(hiScHiFreqVideo, country == "Country001") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country001")
> subset(hiScHiFreqVideo, country == "Country010") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country010")
> subset(hiScHiFreqVideo, country == "Country002") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country002")
> subset(hiScHiFreqVideo, country == "Country003") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country003")
> subset(hiScHiFreqVideo, country == "Country007") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country007")
> subset(hiScHiFreqVideo, country == "Country014") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country014")
> subset(hiScHiFreqVideo, country == "Country009") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country009")
> subset(hiScHiFreqVideo, country == "Country045") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country045")
> subset(hiScHiFreqVideo, country == "Country018") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country018")
> subset(hiScHiFreqVideo, country == "Country004") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country004")
> subset(hiScHiFreqVideo, country == "Country015") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country015")
> subset(hiScHiFreqVideo, country == "Country011") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country011")
> subset(hiScHiFreqVideo, country == "Country021") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender) +ggtitle("Country021")
> dev.off()


##Introduce new Score Levels - 1,2,3,4

##**Merge with HiScHiFreqVideo
