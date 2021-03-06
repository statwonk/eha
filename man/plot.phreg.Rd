% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.phreg.R
\name{plot.phreg}
\alias{plot.phreg}
\title{Plots output from a phreg regression}
\usage{
\method{plot}{phreg}(x, fn = c("haz", "cum", "den", "sur"),
  main = NULL, xlim = NULL, ylim = NULL, xlab = "Duration",
  ylab = "", col, lty, printLegend = TRUE, new.data = NULL, ...)
}
\arguments{
\item{x}{A \code{phreg} object}

\item{fn}{Which functions shoud be plotted! Default is all. They will scroll
by, so you have to take care explicitely what you want to be produced. See,
eg, \code{par(mfrow = ...)}}

\item{main}{Header for the plot}

\item{xlim}{x limits}

\item{ylim}{y limits}

\item{xlab}{x label}

\item{ylab}{y label}

\item{col}{Color(s) for the curves. Defaults to black.}

\item{lty}{Line type for the curve(s). Defaults to 1:(No. of strata).}

\item{printLegend}{Logical, or character ("topleft", "bottomleft",
"topright" or "bottomright"); if \code{TRUE} or character, a legend is added
to the plot if the number of strata is two or more.}

\item{new.data}{Now deprecated; reference hazard is given by the fit; either
zero or the means all covariates, and (always) the reference category for
factors.}

\item{\dots}{Extra parameters passed to 'plot' and 'lines'.}
}
\value{
No return value.
}
\description{
Plot(s) of the hazard, density, cumulative hazards, and/or the survivor
function(s) for each stratum.
}
\examples{

y <- rllogis(40, shape = 1, scale = 1)
x <- rep(c(1,1,2,2), 10)
fit <- phreg(Surv(y, rep(1, 40)) ~ x, dist = "loglogistic")
plot(fit)

}
\seealso{
\code{\link{phreg}}
}
\author{
Göran Broström
}
\keyword{dplot}
\keyword{survival}
