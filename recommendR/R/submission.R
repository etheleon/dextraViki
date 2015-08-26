#' submit to join the predictions
#' 
#' \code{submit} concatenates the predictions for the 
#' two months and generates the submission file as a csv
#' 
#' @param monthOne
#' @param monthTwo
#' @param filePath
#' 
#' @export
submit <- function(monthOne, monthTwo, filePath){
    df <- list(monthOne,
         data.frame(user_id = -1, video_id = "DEXTRA"),
        monthTwo,
        data.frame(user_id = -2, video_id = "DEXTRA")
        ) %>% do.call(rbind,.)
    write.csv(df, file=filePath, quote=F, row.names=F)
}
