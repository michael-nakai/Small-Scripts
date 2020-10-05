library(phyloseq)
library(tidyverse)
library(microbiome)



i = 2

# Creates the alpha diversity .tsv files for each sub-dataset in VicGut data
if (i == 1){
    load('~/git_repos/small-scripts/R_scripts/initializedVars.RData')
    titles <- c('Baker', 'Shepparton', 'MasketHTN', 'noMasketHTN', 'WCH', 'noWCH')
    index <- c(1,2,3,4,5,6)
    for (i in index) {
        tab <- microbiome::alpha(dPhyObj[[i]])
        savelocation <- paste('~/alphas/', titles[i], '.tsv', sep = '')
        write.table(tab, 
                    file = savelocation,
                    quote=FALSE,
                    na = "",
                    sep='\t', 
                    col.names = TRUE,
                    row.names = TRUE)
    }
}

# Creates an alpha diversity .tsv file for the whole dataset for Vicgut data
if (i == 2){
    dPhyObj <- readRDS('~/git_repos/small-scripts/R_scripts/phy.rds')
    savelocation <- paste('~/alphas/', 'all_VicGut.tsv', sep="")
    tab <- microbiome::alpha(dPhyObj)
    write.table(tab, 
                file = savelocation,
                quote=FALSE,
                na = "",
                sep='\t', 
                col.names = TRUE,
                row.names = TRUE)
}