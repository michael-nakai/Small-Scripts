library(tidyverse)
library(qiime2R)
library(RColorBrewer)

##### VERSION 2 (added in x and y flipping)
## MODIFIED TO RUN ON SUBSETS FOR VICTORIA'S DATASET

###################################################################
###################### STUFF TO CHANGE BELOW ######################

### File Paths

# Path to the "subsets" folder (leave the final slash OFF)
dSubsets <- "/home/michael/Projects/Victoria/outputs/217-214/subsets"

# Path to the metadata "subsets" folder (leave the final slash ON)
dMetaSubsets <- "/home/michael/Projects/Victoria/metadata/subsets/"

# File output path
newOutputPath <- "/home/michael/Projects/Victoria/R_outputs/PCoA/outputs/"

# ----

### ggplot settings

# What PC axis number do we want to go until?
final_axis = 2

# Should PC1 be on the x or y axis?
PC1_axis = "x"

# Is the data categorical?
categorical <- TRUE

# What metadata category do we want to divide by (can assign multiple categories)
divide <- c("Donor", "Fermentation", "Condition")

# How large should the PCoA sample points be on the plot?
pointsize = 3

# If your data is categorical, then give the colors to use per category below
#colorvec <- c("#0141Cf", "#FD7F00") #Blue and Orange
#colorvec <- c("#96DEAE", "#F4676C") #Red and Green
colorvec <- c(brewer.pal(8, "Dark2"), brewer.pal(6, "Pastel1")) #If you have a lot of colors

# If your data is continuous, give the colors for the low and high end of the scale
colorLow <- "#F78848" #Blue
colorHigh <- "#3085C7" #Orange

###################### STUFF TO CHANGE ABOVE ######################
###################################################################

subset_fullpaths <- list.dirs(path = dSubsets, recursive = FALSE, full.names = TRUE)
subset_namelist <- list.dirs(path = dSubsets, recursive = FALSE, full.names = FALSE)
metadata_list <- list.files(path = dMetaSubsets, full.names = TRUE)

magicnum <- 1

for (filename in subset_namelist) {
  
  # Get the core-metrics and metadata paths per subset
  dPath <- paste0(subset_fullpaths[magicnum], "/")
  dMetadataPath <- metadata_list[magicnum]

  # Make a new directory to store all the outputs for this subset into
  final_outputpath <- paste0(newOutputPath, subset_namelist[magicnum])
  dir.create(final_outputpath)

  # Other variable stuff
  dUnweightedPath <- paste(dPath, "core-metrics-results/unweighted_unifrac_pcoa_results.qza", sep="") # Check if there's underscores in your filepath!
  dWeightedPath <- paste(dPath, "core-metrics-results/weighted_unifrac_pcoa_results.qza", sep="") # Check if there's underscores in your filepath!
  
  # Read into data
  dUnweighted <- read_qza(dUnweightedPath)
  dWeighted <- read_qza(dWeightedPath)
  dMetadata <- read_q2metadata(dMetadataPath)
  
  # Make metadata sampleID column into characters (strings), then do it for dUnweighted and dWeighted
  dMetadata %>% mutate(across(where(is.factor), as.character)) -> dMetadata
  dUnweighted$data$Vectors$SampleID <- as.character(dUnweighted$data$Vectors$SampleID)
  dWeighted$data$Vectors$SampleID <- as.character(dWeighted$data$Vectors$SampleID)
  
  if (categorical) {
    for (dividing_category in divide) {
      
      total_int_vec <- c(1:final_axis) # Should be (1, 2, 3, 4, 5)
      
      for (initial_PC_number in c(1:(final_axis-1))) { # Should be (1, 2, 3, 4), since the y axis wont ever have the final axis
        
        x_PC_number_vec <- c((1 + initial_PC_number):final_axis) # Should be 2, 3, 4, 5 for the first time around
        
        for (x_PC_number in x_PC_number_vec) {
          
          # Finding the y and x axis variation explained
          y_PC_axis_str <- paste0("PC", initial_PC_number)
          y_PC_variation_unweighted <- round(dUnweighted[["data"]][["ProportionExplained"]][[y_PC_axis_str]] * 100, 3)
          y_PC_variation_weighted <- round(dWeighted[["data"]][["ProportionExplained"]][[y_PC_axis_str]] * 100, 3)
          
          x_PC_axis_str <- paste0("PC", x_PC_number)
          x_PC_variation_unweighted <- round(dUnweighted[["data"]][["ProportionExplained"]][[x_PC_axis_str]] * 100, 3)
          x_PC_variation_weighted <- round(dWeighted[["data"]][["ProportionExplained"]][[x_PC_axis_str]] * 100, 3)
          
          # Naming each axis (1 for unweighted, 2 for weighted)
          xTitle1 <- paste0(x_PC_axis_str, " (", x_PC_variation_unweighted, "%)")
          yTitle1 <- paste0(y_PC_axis_str, " (", y_PC_variation_unweighted, "%)")
          
          xTitle2 <- paste0(x_PC_axis_str, " (", x_PC_variation_weighted, "%)")
          yTitle2 <- paste0(y_PC_axis_str, " (", y_PC_variation_weighted, "%)")
          
          # Making a vector containing the columns we want to select
          cols_we_need <- c("SampleID", x_PC_axis_str, y_PC_axis_str)
          
          # Determining output file names
          dUnweightedFilename <- paste0(y_PC_axis_str, " vs ", x_PC_axis_str, "_Unweighted.png")
          dWeightedFilename <- paste0(y_PC_axis_str, " vs ", x_PC_axis_str, "_Weighted.png")
          
          if (PC1_axis == "y") {
          
            # Unweighted PCoA Code
            dUnweighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>%
              ggplot(aes_string(x = x_PC_axis_str,
                                y = y_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(xTitle1) + 
              ylab(yTitle1) +
              theme(text = element_text(size=18)) +
              scale_color_manual(values = colorvec) +
              ggsave(filename = dUnweightedFilename,
                     dpi = 600,
                     height = 6,
                     width = 8,
                     device = "png",
                     path = final_outputpath)
            
            # Weighted PCoA Code
            dWeighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>% 
              ggplot(aes_string(x = x_PC_axis_str,
                                y = y_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(xTitle2) +
              ylab(yTitle2) +
              theme(text = element_text(size=18)) +
              scale_color_manual(values = colorvec) +
              ggsave(filename = dWeightedFilename,
                     dpi = 600,
                     device = "png",
                     height = 6,
                     width = 8,
                     path = final_outputpath)
            
          } else if (PC1_axis == "x") {
            # Unweighted PCoA Code
            dUnweighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>%
              ggplot(aes_string(x = y_PC_axis_str,
                                y = x_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(yTitle1) + 
              ylab(xTitle1) +
              theme(text = element_text(size=18)) +
              scale_color_manual(values = colorvec) +
              ggsave(filename = dUnweightedFilename,
                     dpi = 600,
                     height = 6,
                     width = 8,
                     device = "png",
                     path = final_outputpath)
            
            # Weighted PCoA Code
            dWeighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>% 
              ggplot(aes_string(x = y_PC_axis_str,
                                y = x_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(yTitle2) +
              ylab(xTitle2) +
              theme(text = element_text(size=18)) +
              scale_color_manual(values = colorvec) +
              ggsave(filename = dWeightedFilename,
                     dpi = 600,
                     device = "png",
                     height = 6,
                     width = 8,
                     path = final_outputpath)
          }
        }
      }
    }
  } else {
    for (dividing_category in divide) {
      
      total_int_vec <- c(1:final_axis) # Should be (1, 2, 3, 4, 5)
      
      for (initial_PC_number in c(1:(final_axis-1))) { # Should be (1, 2, 3, 4), since the y axis wont ever have the final axis
        
        x_PC_number_vec <- c((1 + initial_PC_number):final_axis) # Should be 2, 3, 4, 5 for the first time around
        
        for (x_PC_number in x_PC_number_vec) {
          
          # Finding the y and x axis variation explained
          y_PC_axis_str <- paste0("PC", initial_PC_number)
          y_PC_variation_unweighted <- round(dUnweighted[["data"]][["ProportionExplained"]][[y_PC_axis_str]] * 100, 3)
          y_PC_variation_weighted <- round(dWeighted[["data"]][["ProportionExplained"]][[y_PC_axis_str]] * 100, 3)
          
          x_PC_axis_str <- paste0("PC", x_PC_number)
          x_PC_variation_unweighted <- round(dUnweighted[["data"]][["ProportionExplained"]][[x_PC_axis_str]] * 100, 3)
          x_PC_variation_weighted <- round(dWeighted[["data"]][["ProportionExplained"]][[x_PC_axis_str]] * 100, 3)
          
          # Naming each axis (1 for unweighted, 2 for weighted)
          xTitle1 <- paste0(x_PC_axis_str, " (", x_PC_variation_unweighted, "%)")
          yTitle1 <- paste0(y_PC_axis_str, " (", y_PC_variation_unweighted, "%)")
          
          xTitle2 <- paste0(x_PC_axis_str, " (", x_PC_variation_weighted, "%)")
          yTitle2 <- paste0(y_PC_axis_str, " (", y_PC_variation_weighted, "%)")
          
          # Making a vector containing the columns we want to select
          cols_we_need <- c("SampleID", x_PC_axis_str, y_PC_axis_str)
          
          # Determining output file names
          dUnweightedFilename <- paste0(y_PC_axis_str, " vs ", x_PC_axis_str, "_Unweighted.png")
          dWeightedFilename <- paste0(y_PC_axis_str, " vs ", x_PC_axis_str, "_Weighted.png")
          
          if (PC1_axis == "y") {
          
            # Unweighted PCoA Code
            dUnweighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>%
              ggplot(aes_string(x = x_PC_axis_str,
                                y = y_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(xTitle1) + 
              ylab(yTitle1) +
              theme(text = element_text(size=18)) +
              scale_color_gradient(low=colorLow,
                                   high=colorHigh) +
              ggsave(filename = dUnweightedFilename,
                     dpi = 600,
                     height = 6,
                     width = 8,
                     device = "png",
                     path = final_outputpath)
            
            # Weighted PCoA Code
            dWeighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>% 
              ggplot(aes_string(x = x_PC_axis_str,
                                y = y_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(xTitle2) +
              ylab(yTitle2) +
              theme(text = element_text(size=18)) +
              scale_color_gradient(low=colorLow,
                                   high=colorHigh) +
              ggsave(filename = dWeightedFilename,
                     dpi = 600,
                     device = "png",
                     height = 6,
                     width = 8,
                     path = final_outputpath)
            
          } else if (PC1_axis == "x") {
            # Unweighted PCoA Code
            dUnweighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>%
              ggplot(aes_string(x = y_PC_axis_str,
                                y = x_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(yTitle1) + 
              ylab(xTitle1) +
              theme(text = element_text(size=18)) +
              scale_color_gradient(low=colorLow,
                                   high=colorHigh) +
              ggsave(filename = dUnweightedFilename,
                     dpi = 600,
                     height = 6,
                     width = 8,
                     device = "png",
                     path = final_outputpath)
            
            # Weighted PCoA Code
            dWeighted$data$Vectors %>%
              select(one_of(cols_we_need)) %>%
              left_join(dMetadata) %>% 
              ggplot(aes_string(x = y_PC_axis_str,
                                y = x_PC_axis_str,
                                color = dividing_category)) +
              geom_point(alpha=0.6, size=pointsize) +
              theme_q2r() +
              theme(panel.grid.major = element_line(0.2),
                    panel.grid.minor = element_line(0.1)) +
              xlab(yTitle2) +
              ylab(xTitle2) +
              theme(text = element_text(size=18)) +
              scale_color_gradient(low=colorLow,
                                   high=colorHigh) +
              ggsave(filename = dWeightedFilename,
                     dpi = 600,
                     device = "png",
                     height = 6,
                     width = 8,
                     path = final_outputpath)
          }
        }
      }
    }
  }
  
  magicnum <- magicnum + 1
  
}