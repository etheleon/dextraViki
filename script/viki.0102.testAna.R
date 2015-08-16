#!/usr/bin/env Rscript

load("../data/data.Rdata")

library(magrittr)
library(dplyr)
library(ggbiplot)
theme_set(theme_bw())

userdetails_all <- merge(behave, users, by="user_id", all.x=TRUE)

user_video_nocast <- merge(userdetails_all, videos_attributes, by="video_id", all.x=TRUE)

mergedVideo <- merge(videos_casts,
             videos_attributes,
             by.x="contained_id",
             by.y="container_id",
             all=T)
#Bad idea
#video_behave = merge(mergedVideo, behave, by="video_id", all=T)
user_video_nocast$user_id %<>% as.factor
user_score <- user_video_nocast %>% group_by(user_id) %>% dplyr::summarize(totalScore = sum(score))
uu = merge(user_score, users)

gender = gender, user_country = country) %>% arrange(desc(totalScore)) %>% head


genres =
    videos_attributes$genres              %>%
    as.character                          %>%
    sapply(function(x){strsplit(x,", ")}) %>%
    do.call(c,.)                          %>%
    unname                                %>%
    unique

m = matrix(rep(0, nrow(videos_attributes)*length(genres)), nrow = nrow(videos_attributes))

#genres
1:nrow(videos_attributes) %>%
lapply(function(x){
    if(!grepl("Drama|SciFi|Anime|Adventure",videos_attributes$genres[x], ignore.case=T)){
        videos_attributes$genres[x] %>%
        as.character                %>%
        strsplit(", ")              %>%
        .[[1]]                      %>%
        sapply(function(genreName){
                    m[x, which(genres %in% genreName)] <<- m[x, which(genres %in% genreName)] + 1
               })
        }
    })

m %<>% as.data.frame
colnames(m) = genres

m = m[which(apply(m,1, sum) != 0),which(apply(m,2, sum) != 0)]

m.pca <- prcomp(m,
center = TRUE,
scale. = TRUE)

g <- ggbiplot(m.pca, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal',legend.position = 'top')

g2 <- ggbiplot(m.pca, choices = c(1, 3), obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE)
g2 <- g2 + scale_color_discrete(name = '')
g2 <- g2 + theme(legend.direction = 'horizontal',legend.position = 'top')

g3 <- ggbiplot(m.pca, choices = c(2, 3), obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE)
g3 <- g3 + scale_color_discrete(name = '')
g3 <- g3 + theme(legend.direction = 'horizontal',legend.position = 'top')


library(gridExtra)
pdf("../out/pca_removed.pdf", w=20, h=20)
g
g2
g3
dev.off()

library(rgl)
plot3d(m.pca$x[,2:4])


genres %>%
table %>%
as.data.frame %>%
setNames(c("genres", "freq")) %>%
ggplot(aes(reorder(genres, freq), freq)) +
geom_bar(stat="identity") +
theme(axis.text.x=element_text(angle=90))

#scoring system

# theme_set(theme_bw())merge everything into 1 table
#    video att with video casts
#    video id with behavior
#casts wide format

#Wide format
#Might be useful

containerWide = 
videos_casts            %>%
select(-country)        %>%
spread(cast_person_id, casts_gender)



#By user takes too long
videosGenre = user_video_nocast %>% 
select(video_id, genres) %>% 
unique

videosGenre$string = lapply(videosGenre$genres, function(gString){
        gString %>% 
        as.character %>%
        sapply(function(x){
            #browser()
            paste0(as.character((genres %in% strsplit(x,", ")[[1]])*1), collapse="")
            })
        }) %>% do.call(c,.) %>% unname



mUsers = matrix(rep(0, nrow(users)*length(genres)), nrow = nrow(users))

#genres
unique(user_video_nocast$user_id) %>%
lapply(function(x){
genresString = filter(user_video_nocast, user_id == x) %$% genres
allGenres = sapply(genresString, function(entries){entries %>% as.character %>% strsplit(", ") %>% .[[1]] })
if(is.list(allGenres)){
    allGenres = do.call(c,allGenres)
    allGenres %>% sapply(function(genreName){
                    mUsers[x, which(genres %in% genreName)] <<- mUsers[x, which(genres %in% genreName)] + 1
               })
    }
})


dff = read.table("../out/viki.0103.output")
dff2 = dff[,-1]
colnames(dff2) = genres

userPCA = prcomp(dff2, center=T,scale.=T)

woKDrama = dff2[,-10] #removed korean

userPCA_woKDrama = prcomp(woKDrama, center=T,scale.=T)

plot(userPCA_woKDrama, type="l")

g2 <- ggbiplot(userPCA_woKDrama, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE) + geom_point(aes


#g <- g + scale_color_discrete(name = '')
#g <- g + theme(legend.direction = 'horizontal',legend.position = 'top')


