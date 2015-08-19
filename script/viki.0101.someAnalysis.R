#Merged video attributes and vide casts
video_all<- merge(videos_attributes, videos_casts, by.x = "container_id", by.y = "contained_id", all.x=TRUE, all.y = TRUE)

#Merged behave and users dataframe
userdetails_all<-merge(behave, users, by="user_id", all.x=TRUE)
#Analysis of Userdetails_all:
  ## behave df has 4,881,883 records with 753,272 unique user_id's belonging to 228 countries(There is no NONE value for country)

#Merge Userall details with video details (except the casts)
user_video_nocast<- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)

#trying things 16th August
#group the users by Score country and gender
user_score <- user_video_nocast %>% group_by(user_id) %>% summarise(totalScore = sum(score)) %>% arrange(desc(totalScore))
uu = merge(user_score, users)

#make a plot and save it in the pdf
pdf("~/Desktop/somePlot.pdf", width=20)
ggplot(uu, aes(gender, totalScore)) + geom_boxplot() + geom_jitter(aes(color=country))
dev.off()
