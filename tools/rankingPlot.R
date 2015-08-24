#!/usr/bin/env Rscript
load("../out/hischiFreqRank.rda")

hiScHiFreqRank %<>% arrange(desc(Ranking))
hiScHiFreqRank$video_id = factor(hiScHiFreqRank$video_id, levels = as.character(hiScHiFreqRank$video_id))

library(tidyr)

hiScHiFreqRank_long = hiScHiFreqRank %>%
gather(scoreType, value, -video_id, -totalviews, -Ranking)

rankDF = hiScHiFreqRank_long %>% select(video_id, Ranking) %>% unique

pdf("../out/scoreTypeRanking.pdf", w=20)
hiScHiFreqRank_long %>% mutate(newValue = value* totalviews) %>% 
ggplot(aes(x=video_id, y=newValue))                                 +
geom_line(aes(group=scoreType, color=scoreType))                    +
geom_line(data=rankDF, inherit.aes=FALSE, aes(video_id, Ranking/2, group=1), color="black", size=1.5) +
ylab("Totalviews")
dev.off()
