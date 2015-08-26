library(magrittr)
library(dplyr)
library(recommendR)

load("~/Dropbox/dextra/data/data.Rdata")

df  = read.table("../../out/genreMatrix", sep="\t", h=T)
x   = runPCA(df)
xx  = closest(x)

write.table(xx, file="../../out/submissionForHiScoreHiFreq")
