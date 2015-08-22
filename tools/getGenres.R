#!/usr/bin/env Rscript
args <- commandArgs(TRUE)

#give this script the path to the data.Rdata file in the data folder
load(args[1])

library(parallel)
library(magrittr)
library(dplyr)

genres =
    videos_attributes$genres              %>%
    as.character                          %>%
    sapply(function(x){strsplit(x,", ")}) %>%
    do.call(c,.)                          %>%
    unname                                %>%
    unique
write.table(genres, file="../data/genresList", quote=F, row.names=F, col.names=F)
