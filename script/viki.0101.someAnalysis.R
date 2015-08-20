load("../data/data.Rdata")

#Merged video attributes and vide casts
video_all <- merge(videos_attributes, videos_casts, 
                   by.x = "container_id",
                   by.y = "contained_id",
                   all=TRUE)

#Merged behave and users dataframe
userdetails_all <- merge(behave, users, by="user_id", all.x=TRUE)

#Analysis of Userdetails_all:
#   behave df has 4,881,883 records with 753,272 unique user_id's belonging to 228 countries(There is no NONE value for country)

#Merge Userdetails with video details (except the casts)
user_video_nocast <- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)

#group the users by Score country and gender
user_score <- user_video_nocast %>% group_by(user_id) %>% summarise(totalScore = sum(score)) %>% arrange(desc(totalScore))
uu = merge(user_score, users)

#****
#make a plot and save it in the pdf
pdf("~/Desktop/somePlot.pdf", width=20)
ggplot(uu, aes(gender, totalScore)) + geom_boxplot() + geom_jitter(aes(color=country))
dev.off()
||||||| merged common ancestors
# Things we want to do now: 1) See how the user and video clusters
=======
>>>>>>> cad02c09bb65307178178a1db1fcdf96a7efd21f
#***

#finding score by country
ScorebyCountry <- uu %>% group_by((country) %>% summarise(ScoreCountrywise = sum(totalScore)) %>% arrange(desc(ScoreCountrywise))

#no of users vs #views
abc <- behave %>% group_by(user_id) %>% summarise(freq = n(), totalScore = sum(score)) %>% arrange(desc(freq))
uu2 <- merge(uu, abc, by = c("user_id", "totalScore")) %>% arrange(desc(freq)) #add totalscore to users

#understanding the quantiles. We decided to segment the users by scores
quantile(uu2$freq, probs = c(0, .25, .50, .75, .90, 0.95,0.96, 0.98, 0.99, 1.00), na.rm=TRUE)
quantile(uu2$totalScore, probs = c(0, .25, .50, .75, .90, 0.95,0.96, 0.98, 0.99, 1.00), na.rm=TRUE)

#make a subset of the highscore users as in uu3 (have all user info for high score users - top 20% (with 60% of views)
hiScore<- subset(uu2, totalScore >= 20)

#finding the segmentation of hih, moderate and low fre Users under highScore users
quantile(hiScore$totalScore, c(0.5,0.7,0.75,0.8,0.9,0.95,0.98,1)) 
## find the totalfreqby Quantiles and the number of users to calculate the avgfreq/user 
#(these values are cumulative, rest calculation is done in excel)
quantile(hiScore$totalScore, seq(0,1,0.05)) %>% sapply(function(value) { filter(hiScore, totalScore < value) %>% summarise(val = value, totalfreq = sum(freq), us = length(unique(user_id))) }, simplify=F) %>% do.call(rbind,.) %>% mutate(totalfreq/us)



 ##nolonger valid analysis - kept for syntax
hiFreqUsers %>% group_by(country) %>% summarise(freq = n(), usersByCountry= length(unique(user_id))) %>% arrange(desc(freq))
hiFreqUsers %>% group_by(country) %>% summarise(freq=n(), totalscore = sum(score)) %>% filter(freq > 0) %>% ggplot(aes(as.factor(freq), totalscore))+geom_bar(stat = "identity") 
hiFreqUser_bycountry <- hiFreqUsers %>% group_by(country) %>% summarise(freq = n(), usersByCountry= length(unique(user_id)), avgview = freq/usersByCountry) %>% arrange(desc(freq))


