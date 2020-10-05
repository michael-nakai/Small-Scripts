library(tidyverse)
library(xml2)

# Created by Michael, 2020-10-05
# ------------------
# WHAT IT DOES:
# This script queries the Metacyc pathway database using their REST API and downloads an xml file containing pathway info.
# It then reads the long-form name from the xml file and adds it to the output file, alongside the short pathway code.
# ------------------
# REQUIRED LIBRARIES:
# -tidyverse
# -xml2
# If these are not installed yet, run the following code in your R console: install.packages(c("tidyverse", "xml2"))
# ------------------
# HOW TO USE:
#  1. Format your picrust output file so that the first column is titled "pathways" (no quote marks), and contains all the pathway codes.
#  2. Change pathToCSVFile to the filepath to your picrust csv file.
#  3. Change xmlStorageFolder to an empty folder. If this folder doesn't exist yet, this script will make it (so don't worry).
#  4. Change outputFile to the place/name of the file that this script will create (this shouldn't exist yet).
#  5. Run this script! Select all the text in this file, then hit "Run" on the top left of your RStudio screen.
# ------------------
# NOTES:
# -Once this script is done running, you can delete the entire xmlStorageFolder folder, since the script will redownload xml files if reran.
# -Depending on how many pathways you have, this script may take anywhere from 5-20 minutes. As a benchmark, it processed 400 pathways in 5 minutes.
# -The files downloaded are small (~5-30KB each), but VERY bad internet speeds may slow this script down.
# -If the script can't find a pathway on Metacyc, the row containing the pathway will not exist in the final output.
# ------------------


#############################################
#                 FILEPATHS                 #
#############################################
pathToCSVFile <- "/home/michael/xmlTest/BakerShepAlfred_picrust.csv"
xmlStorageFolder <- "/home/michael/xmlTest/xml_files"
outputFile <- "/home/michael/xmlTest/long_picrust_name.csv"


#############################################
#                   CODE                    #
#############################################

# Import csv file as dataframe
picrustcsv <- read.csv(pathToCSVFile)

# Create xmlStorageFolder if it doesn't exist already
dir.create(xmlStorageFolder, showWarnings = FALSE)

# Initialize temp dataframe to store for loop outputs, and i for for-loop shenanigans
tempData <- data.frame(Shortform=character(), Longform=character())
i <- 1

# Function for later, to clean out HTML tags using regex
cleanFun <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}

# Start the loop for each shortform name
for (pathwayname in picrustcsv[,1]) {
  
  tryCatch({
    url1 <- paste0("https://websvc.biocyc.org/getxml?meta:", pathwayname)
    savename <- paste0(xmlStorageFolder, "/", pathwayname, ".xml")
    
    # Download and read the xml file
    download.file(url1, destfile = savename, method = "wget")
    xmlfile <- read_xml(savename)
    
    # Retrieve the longform name (common-name under pathway)
    xmlLong <- xml_find_all(xmlfile, "Pathway/common-name")
    pathLong <- xml_text(xmlLong)
    pathLongClean <- cleanFun(pathLong)
    
    # Add to tempData
    tempData[i,1] <- pathwayname
    tempData[i,2] <- pathLongClean
    
    i <- i + 1
  },
  
  error=function(cond) {
    message(paste("URL does not seem to exist:", url1))
    message("Here's the original error message:")
    message(cond)
    
    tempData[i,1] <- pathwayname
    tempData[i,2] <- "Does not currently exist on the biocyc or metacyc website, may have been deleted"
    
    i <- i + 1
  })
  
}

# Merge, reorder, and save
finalDF <- merge(picrustcsv, tempData, by.x = "pathways", by.y = "Shortform")
reallyFinalDF <- finalDF %>% select("Longform", everything())
write.csv(reallyFinalDF, file = outputFile, row.names = FALSE)
