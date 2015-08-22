#!/usr/bin/env Rscript
load("../out/hischiFreqRank.rda")

hiScHiFreqRank %<>% arrange(desc(Ranking))
hiScHiFreqRank$video_id = factor(hiScHiFreqRank$video_id, levels = as.character(hiScHiFreqRank$video_id))

library(tidyr)

hiScHiFreqRank_long = hiScHiFreqRank %>%
gather(scoreType, value, -video_id, -totalviews, -Ranking)

pdf("../out/scoreTypeRanking.pdf", w=20)
hiScHiFreqRank_long %>% mutate(newValue = value* totalviews) %>% 
ggplot(aes(x=video_id, y=newValue)) +
geom_line(aes(group=scoreType, color=scoreType)) + 
ylab("Percentage of totalviews")
dev.off()
