#' Calculate Correlation in Local Ancestry (K = 3)
#'
#' Create single data frame with average correlation of local ancestry
#' for pairs of SNPs varying distances apart. Combines data for each chromosome
#' generated by get_corr_chr(). Code is currently applicable
#' only to admixed populations with three ancestral populations.
#'
#' @param cor.list list of data tables, one per chromosome, generated by get_corr_chr().
#'
#' @return A data table with the average correlation in local ancestry, to be used for estimating the number of generations since admixture using \code{\link[STEAM]{get_g}}.
#'
#' @import data.table
#'
#' @importFrom stats reshape
#'
#' @seealso \code{\link[STEAM]{get_g}} and \code{\link[STEAM]{get_corr_chr}}
#'
#' @export
combine_corr_chr <- function(cor.list){
  # combine into single data table
  snps.df <- rbindlist(cor.list)

  # get average within each bin
  avgs <- snps.df[,.(mean(corr_11),mean(corr_12),mean(corr_13),mean(corr_21),mean(corr_22),mean(corr_23),mean(corr_31),mean(corr_32),mean(corr_33)), by = .(bin)]
  avgs[,('theta') := L_to_theta(bin)] # add recomb fraction back on

  # add col names
  names(avgs) <- c('cM',
                   'corr_11','corr_12','corr_13',
                   'corr_21','corr_22','corr_23',
                   'corr_31','corr_32','corr_33',
                   'theta')

  # convert from wide to long
  avgs.long <- reshape(avgs, direction = 'long', varying = list(2:10),
                       v.names = 'corr', idvar = 'bin', timevar = 'anc',
                       times = c('1_1','1_2','1_3','2_1','2_2','2_3','3_1','3_2','3_3'))

  avgs.long$anc2 <- avgs.long$anc
  avgs.long$anc2[avgs.long$anc2=='2_1'] <- '1_2'
  avgs.long$anc2[avgs.long$anc2=='3_1'] <- '1_3'
  avgs.long$anc2[avgs.long$anc2=='3_2'] <- '2_3'

  # save final results as data frame
  lacorr.df <- as.data.frame(avgs.long)
  lacorr.df <- lacorr.df[,c('theta','corr','anc2')]
  names(lacorr.df) <- c('theta','corr','anc')
  return(lacorr.df)
}
