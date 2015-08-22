#!/usr/bin/env Rscript

load("../data/data.Rdata")

library(parallel)
library(magrittr)
library(dplyr)
#library(ggbiplot)
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

user_score <- user_video_nocast %>% group_by(user_id) %>% summarise(totalScore = sum(score)) %>% arrange(desc(totalScore))

totalScore = sum(score)
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

videosGenre$string = lapply(videosGenre$genres, function(gString){
        gString %>% 
        as.character %>%
        sapply(function(x){
            #browser()
            paste0(as.character((genres %in% strsplit(x,", ")[[1]])*1), collapse="")
            })
        }) %>% do.call(c,.) %>% unname

mUsers = matrix(rep(0, nrow(users)*length(genres)), nrow = nrow(users))

#genres to
genresList = genres


genresString =
   hiFreqUsers$genres %>%
   as.character       %>%
sapply(function(gen){
     paste0((genresList %in% (gen %>% strsplit(", ") %>% .[[1]])) * 1,collapse="")
})

weightedMatrix = hiFreqUsers %>% apply(1, function(row){
        aString = paste0(
            (genresList %in% (row["genres"] %>% strsplit(", ") %>% .[[1]])) * as.integer(row["mv_ratio"]),
        collapse="|")
        data.frame(user = as.integer(row["user_id"]), String = aString, stringsAsFactors=FALSE)
}) %>% do.call(rbind,.)

df = data.frame(user = hiFreqUsers$user_id,string = genresString)

write.table(df, file="../data/Videos_user_string.txt2", quote=F, sep="\t", row.names=F)

dff = read.table("../out/viki.0103.output")
dff2 = dff[,-1]

colnames(dff2) = c(genres, "country", "gender")

dfMales = dff2 %>% filter(gender == "m") 
malesPCA = prcomp(dfMales[, 1:33], center = T, scale.=T)
pdf("../out/viki.0102.pcaGender_justMales.pdf", w=20, h=20)
plot(malesPCA, type="l")
   ggbiplot(malesPCA, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE)
   ggbiplot(malesPCA, obs.scale = 1, choices = c(1,3), var.scale = 1, ellipse = TRUE,circle = TRUE)
   ggbiplot(malesPCA, obs.scale = 1, choices = c(2,3), var.scale = 1, ellipse = TRUE,circle = TRUE)
dev.off()

dffemales = dff2 %>% filter(gender == "f") 
femalesPCA = prcomp(dffemales[, 1:33], center = T, scale.=T)
pdf("../out/viki.0102.pcaGender_justfemales.pdf", w=20, h=20)
plot(femalesPCA, type="l")
   ggbiplot(femalesPCA, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE)
   ggbiplot(femalesPCA, obs.scale = 1, choices = c(1,3), var.scale = 1, ellipse = TRUE,circle = TRUE)
   ggbiplot(femalesPCA, obs.scale = 1, choices = c(2,3), var.scale = 1, ellipse = TRUE,circle = TRUE)
dev.off()

countryGender = dff2[,34:35]
userPCA = prcomp(dff2[, 1:33], center=T,scale.=T)

#woKDrama = dff2[,-10] #removed korean

#userPCA_woKDrama = prcomp(woKDrama, center=T,scale.=T)


png("../out/viki.0102.pcaGender.png")
plot(userPCA, type="l")
ggbiplot(userPCA, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE, group=countryGender[,2])
ggbiplot(userPCA, obs.scale = 1, choices = c(1,3), var.scale = 1, ellipse = TRUE,circle = TRUE, group=countryGender[,2])
ggbiplot(userPCA, obs.scale = 1, choices = c(2,3), var.scale = 1, ellipse = TRUE,circle = TRUE, group=countryGender[,2])
dev.off()


library(rgl); 
rgl.open(); 
offset <- 50; 
par3d(windowRect=c(offset, offset, 640+offset, 640+offset)); 
rm(offset); 
rgl.clear(); 
rgl.viewpoint(theta=45, phi=30, fov=60, zoom=1); 
spheres3d(userPCA$x[,1], userPCA$x[,2], userPCA$x[,3], radius=0.3, color=as.character(tt), alpha=1, shininess=20); 
#aspect3d(1, 1, 1); axes3d(col='black'); title3d("", "", "PC1", "PC2", "PC3", col='black'); bg3d("

library(dplyr)
abc <- behave %>% group_by(user_id) %>% summarise(freq = n(), totalScore = sum(score)) %>% arrange(desc(freq))
uu2 <- merge(uu, abc, by = c("user_id", "totalScore")) %>% arrange(desc(freq))
uu3<- filter(uu2, uu2$freq >= 16, uu2$totalScore >= 32)

##################################################
df_hiFreq = read.table("../out/viki.0103.output_hiFreq")
df_hiFreq = df_hiFreq[,-1]
colnames(df_hiFreq) = c(genres, "country", "gender")
countryGender = df_hiFreq[,34:35]

malesPCA = prcomp(df_hiFreq[, 1:33], center = T, scale.=T)
library(ggbiplot)

pdf("../out/viki.0102.pcaGender_hiFreq.pdf", w=20, h=20)
plot(malesPCA, type="l")
   ggbiplot(malesPCA, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE, groups = countryGender[,1])
   ggbiplot(malesPCA, obs.scale = 1, choices = c(1,3), var.scale = 1, ellipse = TRUE,circle = TRUE, groups = countryGender[,1])
   ggbiplot(malesPCA, obs.scale = 1, choices = c(2,3), var.scale = 1, ellipse = TRUE,circle = TRUE, groups= countryGender[,1])
dev.off()

df_hiFreq_country1 = filter(df_hiFreq, country == 'Country001')

country1PCA = prcomp(df_hiFreq_country1[,-34], center = T, scale.=T)
ggbiplot(country1PCA, obs.scale = 1, var.scale = 1, ellipse = TRUE,circle = TRUE)
