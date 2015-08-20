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

#Merge Userall details with video details (except the casts)
user_video_nocast <- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)

# Things we want to do now: 1) See how the user and video clusters

<<<<<<< HEAD
#trying things 16th August
#group the users by Score country and gender
user_score <- user_video_nocast %>% group_by(user_id) %>% summarise(totalScore = sum(score)) %>% arrange(desc(totalScore))
uu = merge(user_score, users)

#make a plot and save it in the pdf
pdf("~/Desktop/somePlot.pdf", width=20)
ggplot(uu, aes(gender, totalScore)) + geom_boxplot() + geom_jitter(aes(color=country))
dev.off()
||||||| merged common ancestors
# Things we want to do now: 1) See how the user and video clusters
=======
>>>>>>> cad02c09bb65307178178a1db1fcdf96a7efd21f

#finding score by country
ScorebyCountry <- uu %>% group_by((country) %>% summarise(ScoreCountrywise = sum(totalScore)) %>% arrange(desc(ScoreCountrywise))

#keeping only imp variables
userVideoNocast <- subset(x = user_video_nocast, select = c(video_id, user_id, score, date, time, country, gender, container_id, origin_country, origin_language, adult, broadcast_from, broadcast_to, genres))

#no of users vs #views
abc <- behave %>% group_by(user_id) %>% summarise(freq = n(), totalScore = sum(score)) %>% arrange(desc(freq)))
uu2 <- merge(uu, abc, by = c("user_id", "totalScore")) %>% arrange(desc(freq))
uu3<- filter(uu2, uu2$freq > 16, uu2$totalScore > 32)
