#' Prints coxreg objects
#' 
#' More "pretty-printing" than \code{print.coxph}, which is a fall-back for
#' 'difficult' objects.
#' 
#' Doesn't work with three-way and higher interactions, in which case
#' \code{print.coxph} is used. Prints also output from \code{\link{mlreg}}.
#' 
#' @param x A \code{coxreg} object, typically the result of running
#' \code{coxreg}
#' @param digits Output format.
#' @param \dots Other arguments.
#' @return No value is returned.
#' @author Göran Broström
#' @seealso \code{\link{coxreg}}, \code{\link[survival]{print.coxph}}
#' @keywords survival
#' @export
print.coxreg <-
 function(x, digits=max(options()$digits - 4, 3), ...)
    {
    if (!is.null(cl<- x$call)) {
	cat("Call:\n")
	dput(cl)
	cat("\n")
	}

    if (!is.null(x$fail)) {
        if (x$fail != 0){
            cat(" coxreg failed with: ")
            stop(x$fail)
        }
    }

    if (x$nullModel){
        ##cat("Null log likelihood = ", x$loglik[2], "\n")
        cat("Null model\n")
        return()
    }

    savedig <- options(digits = digits)
    on.exit(options(savedig))

    coef <- x$coef

    se <- sqrt(diag(x$var))

    wald.p <- formatC(1 - pchisq((coef/ se)^2, 1),
                      digits = 3,
                      width = 9, format = "f")
    if(is.null(coef) | is.null(se))
        stop("Input is not valid")
#####################################
    cat("Covariate           Mean       Coef     Rel.Risk   S.E.    Wald p\n")
    e.coef <- formatC(exp(coef), width = 9, digits = 3, format = "f")
    coef <- formatC(coef, width = 9, digits = 3, format = "f")
    se <- formatC(se, width = 9, digits = 3, format = "f")
    
    ett <-  formatC(1, width = 9, digits = 0, format = "f")
    noll <-  formatC(0, width = 5, digits = 0, format = "f")

    factors <- attr(x$terms, "factors")
    resp <- attr(x$terms, "response")
    row.strata <- attr(x$terms, "specials")$strata
    if (!is.null(row.strata))
      col.strata <- which(factors[row.strata, ] == 1)
    else col.strata <- NULL
    if (!is.null(col.strata)){
        factors <-
            attr(x$terms, "factors")[-c(resp, row.strata), -col.strata,
                                 drop = FALSE]
    }else{
        factors <-
            attr(x$terms, "factors")[-c(resp, row.strata), ,
                                     drop = FALSE]
    }

    covar.names <- x$covars
    term.names <- colnames(factors)

    isF <- x$isF

    ord <- attr(x$terms, "order")
    if (!is.null(col.strata)) ord <- ord[-col.strata]

    index <- 0

    for (term.no in 1:length(term.names)){

        if (ord[term.no] == 1){
            covar.no <- which(factors[, term.no] == 1)

            if (isF[covar.no]){ ## Factors:
                cat(covar.names[covar.no], "\n")
                ##p <- match(covar.names[covar.no], names(data))
                no.lev <- length(x$levels[[covar.no]])
                x$levels[[covar.no]] <-
                    substring(x$levels[[covar.no]], 1, 16)
                cat(formatC(x$levels[[covar.no]][1], width = 16, flag = "+"),
                    formatC(x$w.means[[covar.no]][1],
                            width = 8, digits = 3, format = "f"),
                    noll,
                    ett,
                    "(reference)\n")
                for (lev in 2:no.lev){
            ##cat("lev = ", lev, "\n")
                    index <- index + 1
                    cat(formatC(x$levels[[covar.no]][lev], width = 16,
                                flag = "+"),
                        formatC(x$w.means[[covar.no]][lev],
                                width = 8, digits = 3, format = "f"),
                        coef[index],
                        e.coef[index],
                         se[index],
                        ##formatC(" ", width = 9),
                        formatC(wald.p[index],
                                digits = 3,
                                width = digits + 2,
                                format = "f"),
                        ##signif(1 - pchisq((coef/ se)^2, 1), digits - 1),
                        "\n")
                }
            }else{ ## Covariates:
                index <- index + 1
                cat(formatC(substr(covar.names[covar.no], 1, 16),
                            width = 16, flag = "-"),
                    formatC(x$w.means[[covar.no]],
                            width = 8, digits = 3, format = "f"),
                    coef[index],
                    e.coef[index],
                                        #exp(coef[index]),
                    se[index],
                    ##formatC(" ", width = 9),
                    formatC(wald.p[index],
                            digits = 3,
                            width = digits + 2,
                            format = "f"),
                    ##signif(1 - pchisq((coef/ se)^2, 1), digits - 1),
                    "\n")
            }
        }else if (ord[term.no] > 1){ ## Interactions:
            cat(formatC(term.names[term.no], width = 16, flag = "-"), "\n")
            niv <- numeric(ord[term.no])
            covar.no <- which(factors[, term.no] == 1)

            for (i in 1:ord[term.no]){
                if (isF[covar.no[i]]){
                    niv[i] <- length(x$levels[[covar.no[i]]]) - 1
                }else{
                    niv[i] <- 1
                }
            }
            stt <- index + 1
            for (index in stt:(stt + prod(niv) - 1)){
                vn <- sub(covar.names[covar.no[1]], "", names(coef)[index])
                for (i in 1:ord[term.no]){
                    vn <- sub(covar.names[covar.no[i]], "", vn)
                }
                ##          cat(format(names(coef)[index], 15, "+"),
                cat(formatC(" ", width = 2),
                    formatC(substring(vn, 1, 22), width = 22, flag = "-"),
                    ##format(" ", 8),
                    coef[index],
                    e.coef[index],
                    se[index],
                    ##formatC(" ", width = 9),
                    formatC(wald.p[index],
                            digits = 3,
                            width = digits + 2,
                            format = "f"),
                    ##signif(1 - pchisq((coef[index]/ se[index])^2, 1), digits - 1),
                    "\n")
            }
        }
        
    }
      
#####################################
    if(FALSE){
        tmp <- cbind(coef, exp(coef), se,
                     signif(1 - pchisq((coef/ se)^2, 1), digits - 1))
        dimnames(tmp) <- list(names(coef), c("coef", "rel. risk",
                                             "se(coef)", "p"))
        
        cat("\n")
        prmatrix(tmp)
    }

    if (!is.null(x$frailty)){
        cat("\nFrailty standard deviation = ", x$sigma, "\n")
        cat("                      S.E. = ", x$sigma.sd, "\n\n")
    }
    
    logtest <- -2 * (x$loglik[1] - x$loglik[2])
    if (is.null(x$df)) df <- sum(!is.na(coef))
    else  df <- round(sum(x$df),2)
    cat("\n")
    cat(formatC("Events", width = 25, flag = "-"), x$events, "\n")
    cat(formatC("Total time at risk", width = 25, flag = "-"),
        formatC(x$ttr, digits = 5, format = "fg"), "\n")
    cat(formatC("Max. log. likelihood", width = 25, flag = "-"),
        formatC(x$loglik[2], digits = 5, format = "fg"), "\n")
    cat(formatC("LR test statistic", width = 25, flag = "-"),
        format(round(logtest, 2), nsmall = 2), "\n")
    cat(formatC("Degrees of freedom", width = 25, flag = "-"),
        formatC(df, digits = 0, format = "f"), "\n")
    cat(formatC("Overall p-value", width = 25, flag = "-"),
        format.pval(1 - pchisq(logtest, df), digits = 6, "\n"))
    cat("\n")
    if (length(x$icc))
	cat("   number of clusters=", x$icc[1],
	    "    ICC=", format(x$icc[2:3]), "\n")
    invisible(x)
}
