
#Merged behave and users dataframe
userdetails_all <- merge(behave, users, by="user_id", all.x=TRUE)

#Analysis of Userdetails_all:
#   behave df has 4,881,883 records with 753,272 unique user_id's belonging to 228 countries(There is no NONE value for country)

#Merge Userdetails with video details (except the casts)
user_video_nocast <- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)

#group the users by Score country and gender
uu2 <- user_video_nocast %>% group_by(user_id) %>% summarise(totalScore = sum(score),freq = n(), country = unique(country), gender = unique(gender)) %>% arrange(desc(totalScore))


#make a subset of the highscore users as in uu3 (have all user info for high score users - top 20% (with 60% of views)
hiScore<- subset(uu2, totalScore >= 20)

#analysis for HiScoreUsers
  ## hiScore Video Details:
hiScoreVideo <- subset(user_video_nocast, user_id %in% unique(hiScore$user_id))

    ##calculating Freq
hiScoreByFreq <-  hiScoreVideo %>% group_by(user_id) %>% summarise(freq = n(), totalScore = sum(score), country = unique(country), gender = unique(gender))
quantile(hiScoreByFreq$freq, seq(0,1,0.05)) 
 
##making different df by Freq (95%ile & above; 65-95 %ile; < 65%ile)

hiScoreHiFreq <- subset(hiScoreByFreq, freq >= 40)
hiScoreMoFreq <- subset(hiScoreByFreq, freq >= 20 & freq <40)
hiScoreLowFreq <- subset(hiScoreByFreq, freq < 20)

##highFreq User video Details
hiScoreHiFreq %>% group_by(country) %>% summarise(CountryFreq = sum(freq), CountryScore = sum(totalScore), f=sum(gender=="f"),m=sum(gender=="m"), o=sum(gender=="o"), N=sum(gender=="None"), total = n())%>% arrange(desc(CountryFreq)) %>% head(n=15)

##seeing country wise behaviour for the top countries
subset(hiScHiFreqVideo, country == "Country001") %>% group_by(origin_country, gender) %>% summarise(totalScore = sum(score)) %>% ggplot(aes(reorder(origin_country, totalScore), totalScore))+geom_boxplot()+ aes(color = gender)

##hiScoreHiFreq pattern by gender and score & freq
hiScoreHiFreq %>% group_by(country) %>% summarise(CountryFreq = sum(freq), CountryScore = sum(totalScore), f=sum(gender=="f"),m=sum(gender=="m"), o=sum(gender=="o"), N=sum(gender=="None"), total = n())%>% arrange(desc(CountryFreq)) %>% head(n=15)

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


