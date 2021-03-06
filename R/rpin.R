#' Generate random (or anonymise existing pins to) non-personal ("fake") pins 
#'
#' \code{rpin} is a generic function to generate non-personal pins for testing and educational purposes.
#' \code{pin_anonymise} is a wrapper to anonymise/de-personalise existing pins.
#' 
#' A pin, where the birth number (digit 9-11 in a 12 number pin) falls in the interval [880, 999], is 
#' a valid personal identification number but is never assigned to an actual person.
#' Numbers of this form can instead be used for testing and educational procedures 
#' without the risk to intefer with personal (and possibly sensitive) data. 
#' 
#' @param x is either an integer (numeric vector of length one) specifing the length of the generated pin vector,
#' or a pin vector itself to be used for generating similair but anonymised pins (see section "Anonymise").
#' @param l_birth,u_birth are dates (or objects that can be coerced to such) constituting a possible time intervall,
#' limiting the period from which birth dates are drawn. 
#' If \code{x} is an integer, these are \code{"1900-01-01"} and \code{Sys.Date()} by default.
#' If \code{x} is a pin vector, these are matched to the birth years in pin.
#' @param unique Should all generated pins be unique, i e should the sampling be done without replacement (\code{TRUE} as default).
#' A possible relation between pins in \code{x} (if x is of class pin) will however be kept if \code{keep_rel = TRUE}.
#' @param male_prob probability that a generated pin refers to a man (\code{female_prob = 1 - male_prob}).
#' If \code{x} is an integer, \code{male_prob} is \code{0.5} by default.
#' If \code{x} is a pin vector, \code{male_prob} is estimated as the observed probability from \code{x}.
#' @param keep_rel Should a possible relationship between pins in \code{x} be kept in the output, i e
#' if the same pin is repeated in \code{x}, should pins at the same positions in the output also be repeated?
#' This is \code{TRUE} by default and works independently of \code{unique}.
#' @param ... additional arguments to be passed to or from methods.
#' 
#' @return
#' \code{rpin} returns a vector of class \code{pin} with length \code{x} if \code{x} is an integer or with length \code{length(x)} 
#' if \code{x} is itself a pin object. The object will also have an extra attribute \code{"non_personal"} set to \code{TRUE} to indicate
#' that the generated pins are non-personal ("fake").
#'
#' @section Simulation:
#' The simulation is done by the following steps:
#' \itemize{
#' \item A birthdate is simulated as described in section \code{Anonymise} or, if \code{x} is an integer,
#' by a uniform distribution from \code{[l_birth, u_birth]}.
#' \item The two first digits of the birth number is given by a discrete random sample from [88, 99]. 
#' Note that these numbers do not speify birthplace in this case (even if year of birth < 1990).
#' \item The last digit of the birth number is sampled from [0, 9] with probabilies according to \code{male_prob} 
#' (that is either specified explicity or as described in section \code{Anonymise}).
#' \item The control number is calculated from digit 1-11 by the Luhn Algorithm 
#' (\code{\link{luhn_algo}}).
#' }
#' 
#' @section Anonymise:
#' Given that \code{x} is an object of class \code{pin}, the output of \code{rpin} 
#' is a pin vector that tries to mimic \code{x} in all aspects 
#' except identifying real persons. 
#' The empirical age (birthday) distribution from \code{x} will be estimated by \code{\link{logspline}}.
#' A random sample of \code{length(x)} is drawn from that distribution. The last four digits are generated
#' as in section \code{Simulation} but with sex distribution estimated from \code{x}. The internal 
#' relationships between elements in \code{x} are maintaind as described for argument
#' \code{keep_rel}.
#' 
#' @export
#' @name rpin 
#' @import sweidnumbr
#' @examples
#' 
#' library(sweidnumbr)
#' set.seed(12345)
#' ## Generate some fake pins
#' p <- rpin(100)
#' 
#' ## Most pin-functions can be applied to p 
#' is.pin(p) # TRUE
#' pin_sex(p) # With mean(pin_sex(p) == "Male") -> male_prob when x -> Inf
#' table(pin_birthplace(p)) # non-informative
#' pin_age(p)
#' pin_to_date(p)
#' 
#' ## If we want to simulate university students in a med course in Sweden,
#' ## we migh try
#' p_ms <- rpin(100, l_birth = "1974-01-01", u_birth = "1994-01-01", male_prob = .25)
#' table(pin_sex(p_ms))
#' summary(pin_age(p_ms))
#' 
#' ## Now, assume for a moment that p_ms is actually real data that we want to anonymise.
#' ## The easy way:
#' p_ms2 <- rpin(p_ms)
#' ## We then have new (fake) numbers but with the same age- and sex distribuiton.
#' table(pin_sex(p_ms2))
#' summary(pin_age(p_ms2))
#' 
#' ## The empirical age distribution from p_ms itself could of course also generate 
#' ## birth dates outside of the empirical birthdate interval from p_ms. The default limit 
#' ## is to not generate pins with birth year before the birth year of the oldest pin in the input
#' ## (and wice versa for the upper limit). But we could also chose to not tolerate any
#' ## pins "older" than the "oldest" pin from the input
#' p_ms3 <- rpin(p_ms, l_birth = min(y <- pin_to_date(p_ms)), u_birth = max(y))
#' min(pin_to_date(p_ms3)) >= min(pin_to_date(p_ms))
#' max(pin_to_date(p_ms3)) <= max(pin_to_date(p_ms))
#' 
#' ## We can modify the sex distribution even though we keep the age-distribution 
#' x <- rpin(p_ms, male_prob = .01) 
#' x <- pin_sex(x) 
#' table(x)

rpin <- function(x, ...){
    UseMethod("rpin")
}
