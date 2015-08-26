#' runPCA runs principal component analysis using the prcomp function

#' \code{runPCA} takes the first N PCs (latent variables) and 
#' maps users onto the new N dimensional space

#'@param df data.frame for genre table generated by genre2matrix in the tools folder

#'@export
runPCA <- function(df){
    PCAdf <- df %>% 
            select(-user, -gender, -country) %>% 
            prcomp(center=T, scale.=T)
    message("Running Principal Component Analysis")
    numPC       <- choosePC(PCAdf)
    PCAdf$x[,1:numPC]
}

#' closest finds videos to recommend based on the PCA matrix

#' Closest finds the closest users (Ux) for each user (U0)
#' selects videos which they (Uxs) have watched and recommends to U0 
#' videos watched by Uxs but not U0

#'@param latentVars could be as many N as possible
#'@param distance the type of distance formula to use, defaults to euclidian distance
#'@param integer representing the top N closest users; defaults to 5
#'@param users A list of userIDs in the same order as was used in the matrix to generate the PCA

#' @export
closest <- function(latentVars, distance="euclidian", top = 5, users, behaviour, cores = 1){
    aDist <- latentVars %>% dist %>% as.matrix
    message("#calculatedDistance")
    outCSV = 1:nrow(latentVars) %>% #nrow(aDist) %>% 
        mclapply(function(rowID){
            closestUsers = users[head(order(aDist[-1,rowID]),top)+1] #we take the top 5 most similar 100 users

            closestVids  =  behaviour %>% subset(user_id %in% closestUsers) %$% video_id %>% unique

            #videos which user himself has seen
            hisVids = behaviour %>% subset(user_id == users[rowID]) %$% video_id
            candidates = closestVids[which(!closestVids %in% hisVids)]
            topcandidate = whichVideos(candidates, behaviour)
            data.frame(user_id = users[rowID], video_id = topcandidate)
    }, mc.cores = cores)
}

#' whichVideos choses which videos watched by the user's neighbours to recommend

#' the description

#' @param candidate

whichVideos <- function(candidates, behaviour){
    vidRecommend = 
        behaviour                                      %>%
        subset(video_id %in% candidates)               %>%
        group_by(video_id)                             %>%
        summarise(count = n(), aveMV = mean(mv_ratio)) %>%
        arrange(desc(count), desc(aveMV))              %>%
        head(6)                                        %$%
    video_id #can be optimised to search for time
    if(length(vidRecommend)<3){
        NA
    }else{
        vidRecommend
    }
}

#' choosePC determines the N of PCs to consider to account for ~50% fo the variability

#' the function finds cumulative variance of Principal Components and find the number of PCs 
#' required to account for 50% of the variance

#' @param pcaObj the PCA object
#' @param variance the threshold amt of variance that is required

choosePC <- function(pcaObj, varThreshold = .5){
    cumVariance <- pcaObj %>%
        summary              %$%
        importance[2,]       %>%
        cumsum
    #pdf("cumVariance.pdf")
    #qplot(x=as.factor(1:length(cumVariance)), y=cumVariance) + ylim(0,1)
    #dev.off()
    v = max(which(cumVariance < varThreshold))
    message(sprintf("Selected PCs account for %s of total variance", cumVariance[v]))
    v
}

