#' Transform a "survival" data frame Surv(enter, exit, event) to tabular form
#' with 'event' and 'exposure' and aggregating
#' 
#' @param dat The survival data frame.
#' @param cuts Vector defining the age periods of constant hazard.
#' 
#' @export toTpch
toTpch <- function(dat, cuts){
    ## 'dat' is typically 'vb1' or 'vb2'.
    n <- length(cuts) - 1
    out <- age.window(dat, cuts[1:2])
    out$age <- 1
    for (i in 2:n){
        tmp <- age.window(dat, cuts[i:(i+1)])
        tmp$age <- i
        out <- rbind(out, tmp)
    }
    
    out$exposure <- out$exit - out$enter
    out$enter <- out$exit <- NULL
    covars <- out[, -(which(names(out) %in% c("event", "exposure")))]
    outTab <- aggregate(out[, c("event", "exposure")], by = covars, FUN = sum)
    ageNames <- character(n)
    for (i in 1:n){
        ageNames[i] <- paste(cuts[i], cuts[i+1], sep = "-")
    }
    outTab$age <- factor(outTab$age, labels = ageNames)
    outTab
}