#!/usr/bin/env Rscript
library(magrittr)

load("../data/data.Rdata")
mergedVideo <- merge(videos_casts,
             videos_attributes,
             by.x="contained_id",
             by.y="container_id",
             all=T)
#Bad idea
#video_behave = merge(mergedVideo, behave, by="video_id", all=T)

genres = 
    videos_attributes$genres             %>%
    as.character                         %>%
    sapply(function(x){strsplit(x,", ")}) %>%
    do.call(c,.)                         %>%
    unname                               %>%
    unique

m = matrix(rep(0, nrow(videos_attributes)*length(genres)), nrow = nrow(videos_attributes))

#genres
videos_attributes$genres[videos_attributes$genres %>% 
as.character %>% 
grepl("", .)] %>% as.character %>% 
lapply(function(string) {
strsplit(", ") %>% .[[1]]


1:nrow(videos_attributes) %>% 
lapply(function(x){
    if(!grepl("Drama",videos_attributes$genres[x], ignore.case=T)){
    videos_attributes$genres[x] %>% as.character %>% strsplit(", ") %>% .[[1]] %>%
    sapply(function(genreName){
    #            browser()
                m[x, which(genres %in% genreName)] <<- m[x, which(genres %in% genreName)] + 1
           })
        }
    })

library(devtools)

m %<>% as.data.frame
colnames(m) = genres

m.pca <- prcomp(m,
center = TRUE,
scale. = TRUE)

install_github("ggbiplot", "vqv")

library(ggbiplot)
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
pdf("../out/pca.pdf", w=20, h=20)
grid.arrange(g, g2, g3)
dev.off()

library(rgl)
plot3d(m.pca[,1:3])


genres %>%
table %>%
as.data.frame %>%
setNames(c("genres", "freq")) %>%
ggplot(aes(reorder(genres, freq), freq)) +
geom_bar(stat="identity") +
theme(axis.text.x=element_text(angle=90))
#scoring system

# merge everything into 1 table
#    video att with video casts
#    video id with behavior
#casts wide format

#Wide format
#Might be useful

containerWide = videos_casts %>%
select(-country)      %>% 
spread(cast_person_id, casts_gender)

