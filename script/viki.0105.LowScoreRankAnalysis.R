load("../data/data.Rdata")
library (magrittr)
library (dplyr)
library (tidyr)
library (ggplot2)

# Merged behave and users dataframe

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
#Hi Score Users are Users with Score >= 20 and Hence Low Score Users are those with totalScore <20 

lowScore<- subset(uu2, totalScore < 20)
lowScoreVideo <- subset(user_video_nocast, user_id %in% unique(lowScore$user_id))


#Understanding the watching behaviour
LoScBehave <- lowScoreVideo %>% group_by(user_id) %>% 
    summarise(nogenres = length(unique(genres)), freq=n(), totalScore = sum(score), nofseries = length(unique(video_id)))
#this tell us - user_id, #series_watches, #uniquegenreswatched, totalScore

lowScore %>% group_by(freq) %>% summarise( totalUsers = n(), avgScoreperUser = sum(totalScore)/ n())

#***********Output******************/
#Frequency  no_Users	  Avg_TotalScore/User  	AvgScore/(view*User)
#1	            212438	1.878713	      1.878713
#2	            110603	3.808938	      1.904469
#3	            72617	  5.779267	      1.926422333
#4	            52640	  7.789039	      1.94725975
#5	            40897	  9.810108	      1.9620216
#6	            32972	  11.816147	      1.969357833
#7	            26827	  13.54885	      1.93555
#8	            19813	  14.751527	      1.843940875
#9	            13410	  15.725578	      1.747286444
#10	          8504	  16.298683	      1.6298683
#11	          4750	  16.784632	      1.525875636
#12	          2645	  17.153875	      1.429489583
#13	          1284	  17.479751	      1.344596231
#14	          626	    17.662939	      1.2616385
#15          	266	    18	            1.2
#16          	113	    18.132743	      1.133296438
#17          	43	    18.465116	      1.086183294
#18          	14	    18.5	          1.027777778
#19	          7	      19	            1


##**Understangind the behaviour towards Genres
table(lowScoreVideo$genres) %>% as.data.frame() -> freqbygenre_LowScore
write.table(reqbygenre_LowScore, "/Users/ritikakapoor/Desktop/dextraViki/out/reqbygenre_LowScore.txt", sep = "\t")



