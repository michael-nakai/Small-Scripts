library(tidyverse)
library(data.table)

# All variables to change below
# ------------------------------------------------

# Set this path to the file called "level-7.csv", which is downloaded from Qiime2 View on the file "taxa-bar-plots.qzv"
level7path <- "level-7.csv"

# Set this path to the folder where the output will be saved. 
# IMPORTANT: INCLUDE THE FINAL SLASH! This means "/home/michael/" is good, but "/home/michael" isn't
folder_to_save_to <- "/home/michael/Projects/Francine_Marques/vicgut-qiime2/really_final/outputs/243-224/"

# This variable should be set to "gg" if greengenes, or "silva" if the silva classifier was used
# STILL IN CONSTRUCTION (TODO)
classifier_used <- "silva"

# ------------------------------------------------
# All code below
# ------------------------------------------------

if (classifier_used == "gg") {
  

  # For some reason, read.csv has trouble with semicolons.
  # read.table still turns them into periods, but doesn't break anything else
  raw <- read.table(level7path, sep = ",", header = TRUE)
  
  # Find the col number where the first col of metadata is
  i <- 1
  for (name in colnames(raw)) {
    if (name == "index") {
      i <- i + 1
      
    } else if (grepl("Unassigned", name, fixed = TRUE)) {
      # if taxa is Unassigned
      i <- i + 1
    
    } else if (grepl("k__", name, fixed = TRUE)) {
      i <- i + 1
      
    } else {
      break
    }
  }
  
  # KILL THE METADATA COLUMNS
  b <- ncol(raw)
  raw.nometa <- dplyr::select(raw, -c(all_of(i):all_of(b)))
  
  # Let's map everything to Otu1, Otu2, etc... R needs python dicts, but we'll use a named vector
  # Also, let's just quickly convert all the periods back into semicolons
  otunums <- character(length(colnames(raw.nometa)) - 1)
  for (i in 1:length(colnames(raw.nometa)) - 1) {
    otunums[i] <- paste0("Otu", i)
  }
  
  noindex <- colnames(raw.nometa)[-1]
  replacementvec <- c("; p__", "; c__", "; o__", "; f__", "; g__", "; s__", "; __")
  i <- 1
  for (thing in c(".p__", ".c__", ".o__", ".f__", ".g__", ".s__", ".__")) {
    noindex <- gsub(thing, replacementvec[i], noindex, fixed = TRUE)
    i <- i + 1
  }
  
  mapping <- setNames(noindex, otunums)
  
  # OK, great. Now let's clean up the actual specie names. First: find stray __ and label them accordingly.
  # This is gonna be a circus in R, I shoulda done this in python.
  underscorevec <- c("k__", "p__", "c__", "o__", "f__", "g__", "s__")
  i <- 1
  for (name in mapping) {
  
    newname <- name
    
    # Iterate between 1 and the underscore num, and replace blank underscores with underscorevec[number]
    for (classification in underscorevec) {
      if (!(grepl(classification, newname, fixed = TRUE))) {
        newname <- sub("[^c-s]__", paste0(" ", classification), newname)
      }
    }
    
    # Remove any periods left with an underscore, replace mapping[i] with newname, then iterate i
    newname <- gsub(".", "", newname, fixed = TRUE)
    mapping[i] <- newname
    i <- i + 1
  }
  
  # Now mapping has the right names in it. WHEW, FINALLY.
  # And now we can make Calypso_Qiime2_Taxonomy.tsv
  taxonomyTSV <- data.frame(matrix(ncol = 2, nrow = length(mapping)))
  names(taxonomyTSV) <- c("#OTU ID", "Taxonomy")
  
  i <- 1
  for (col1cell in taxonomyTSV[,1]) {
    taxonomyTSV[i,1] <- names(mapping)[i]
    i <- i + 1
  }
  
  i <- 1
  for (col2cell in taxonomyTSV[,2]) {
    taxonomyTSV[i,2] <- mapping[i]
    i <- i + 1
  }
  
  write.table(taxonomyTSV, file=paste0(folder_to_save_to, 'Calypso_Qiime2_Taxonomy.tsv'), quote=FALSE, sep='\t', row.names = FALSE)
  
  # And now the harder part: making Calypso_L7.csv
  raw.transposed <- t(raw.nometa)
  
  # Move the rownames to the first column, and rename it "Header"
  raw.transposed <- setDT(as.data.frame(raw.transposed), keep.rownames = TRUE)[]
  raw.transposed[1,1] <- "Header"
  
  # Move the first row to colnames
  raw.transposed2 <- raw.transposed
  colnames(raw.transposed2) <- as.character(raw.transposed[1,])
  raw.transposed2 <- raw.transposed2[-1,]
  
  # Make a 2-column df to add as cols 1 and 2
  dfToAdd <- data.frame(matrix(ncol = 2, nrow = length(mapping)))
  colnames(dfToAdd) <- c("OTU", "Header")
  
  i <- 1
  for (col1cell in dfToAdd[,1]) {
    dfToAdd[i,1] <- "OTU"
    i <- i + 1
  }
  
  i <- 1
  for (col2cell in dfToAdd[,2]) {
    dfToAdd[i,2] <- names(mapping)[i]
    i <- i + 1
  }
  
  # Remove the first column from raw.transposed2, then combine the DFs. Export as a csv
  raw.transposed2 <- raw.transposed2[,-1]
  final <- cbind(dfToAdd, raw.transposed2)
  write_csv(final, file = paste0(folder_to_save_to, "Calypso_L7.csv"))

} else if (classifier_used == "silva"){
  # For some reason, read.csv has trouble with semicolons.
  # read.table still turns them into periods, but doesn't break anything else
  raw <- read.table(level7path, sep = ",", header = TRUE)
  
  # Find the col number where the first col of metadata is
  i <- 1
  for (name in colnames(raw)) {
    if (name == "index") {
      i <- i + 1
      
    } else if (grepl("Unassigned", name, fixed = TRUE)) {
      # if taxa is Unassigned
      i <- i + 1
      
    } else if (grepl("D_0__", name, fixed = TRUE)) {
      i <- i + 1
      
    } else {
      break
    }
  }
  
  # KILL THE METADATA COLUMNS
  b <- ncol(raw)
  raw.nometa <- dplyr::select(raw, -c(all_of(i):all_of(b)))
  
  # Let's map everything to Otu1, Otu2, etc... R needs python dicts, but we'll use a named vector
  # Also, let's just quickly convert all the periods back into semicolons
  otunums <- character(length(colnames(raw.nometa)) - 1)
  for (i in 1:length(colnames(raw.nometa)) - 1) {
    otunums[i] <- paste0("Otu", i)
  }
  
  noindex <- colnames(raw.nometa)[-1]
  replacementvec <- c("k__", "; p__", "; c__", "; o__", "; f__", "; g__", "; s__", "; __")
  i <- 1
  for (thing in c("D_0__", ".D_1__", ".D_2__", ".D_3__", ".D_4__", ".D_5__", ".D_6__", ".D_7__")) {
    noindex <- gsub(thing, replacementvec[i], noindex, fixed = TRUE)
    i <- i + 1
  }
  
  mapping <- setNames(noindex, otunums)
  
  # OK, great. Now let's clean up the actual specie names. First: find stray __ and label them accordingly.
  # This is gonna be a circus in R, I shoulda done this in python.
  underscorevec <- c("k__", "p__", "c__", "o__", "f__", "g__", "s__")
  i <- 1
  for (name in mapping) {
    
    newname <- name
    
    # Iterate between 1 and the underscore num, and replace blank underscores with underscorevec[number]
    for (classification in underscorevec) {
      if (!(grepl(classification, newname, fixed = TRUE))) {
        newname <- sub("[^c-s]__", paste0(" ", classification), newname)
      }
    }
    
    # Remove any periods left with an underscore, replace mapping[i] with newname, then iterate i
    newname <- gsub(".", "", newname, fixed = TRUE)
    mapping[i] <- newname
    i <- i + 1
  }
  
  # Now mapping has the right names in it. WHEW, FINALLY.
  # And now we can make Calypso_Qiime2_Taxonomy.tsv
  taxonomyTSV <- data.frame(matrix(ncol = 2, nrow = length(mapping)))
  names(taxonomyTSV) <- c("#OTU ID", "Taxonomy")
  
  i <- 1
  for (col1cell in taxonomyTSV[,1]) {
    taxonomyTSV[i,1] <- names(mapping)[i]
    i <- i + 1
  }
  
  i <- 1
  for (col2cell in taxonomyTSV[,2]) {
    taxonomyTSV[i,2] <- mapping[i]
    i <- i + 1
  }
  
  write.table(taxonomyTSV, file=paste0(folder_to_save_to, 'Calypso_Qiime2_Taxonomy.tsv'), quote=FALSE, sep='\t', row.names = FALSE)
  
  # And now the harder part: making Calypso_L7.csv
  raw.transposed <- t(raw.nometa)
  
  # Move the rownames to the first column, and rename it "Header"
  raw.transposed <- setDT(as.data.frame(raw.transposed), keep.rownames = TRUE)[]
  raw.transposed[1,1] <- "Header"
  
  # Move the first row to colnames
  raw.transposed2 <- raw.transposed
  colnames(raw.transposed2) <- as.character(raw.transposed[1,])
  raw.transposed2 <- raw.transposed2[-1,]
  
  # Make a 2-column df to add as cols 1 and 2
  dfToAdd <- data.frame(matrix(ncol = 2, nrow = length(mapping)))
  colnames(dfToAdd) <- c("OTU", "Header")
  
  i <- 1
  for (col1cell in dfToAdd[,1]) {
    dfToAdd[i,1] <- "OTU"
    i <- i + 1
  }
  
  i <- 1
  for (col2cell in dfToAdd[,2]) {
    dfToAdd[i,2] <- names(mapping)[i]
    i <- i + 1
  }
  
  # Remove the first column from raw.transposed2, then combine the DFs. Export as a csv
  raw.transposed2 <- raw.transposed2[,-1]
  final <- cbind(dfToAdd, raw.transposed2)
  write_csv(final, file = paste0(folder_to_save_to, "Calypso_L7.csv"))
}