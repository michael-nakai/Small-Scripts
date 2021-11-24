library("tidyverse")

# Created by Michael Nakai, 2021-01-21

# DESCRIPTION
# This script generates a stacked bar plot for phyla-level taxa counts across n groups.
# It requires a CSV with the columns: x, Phylum, Average Read Count (replace x with your grouping variable)
# Best to generate this CSV from a level-2.csv from taxa-bar-plots.qzv

#--------------------------------------------------
###                  CONFIGS
#--------------------------------------------------

PathToCSV <- "/home/michael/Projects/Liang/GPR65_Characterization/level-2-avg.csv"

column_name <- "Genotype"

#Use colorspace::qualitative_hcl(n, palette = "Dark 3") to find colors (replace n with number of needed colors)
colorlist <- c("#ED90A4","#E19B79","#C6A856","#A0B454","#6ABD74","#03C19E","#00BFC4","#53B6E1","#9DA7EC","#CE96E4","#E88ECA")

outputFolder <- "/home/michael/Projects/Liang/GPR65_Characterization/images/"


#--------------------------------------------------
###                 CODE BELOW
#--------------------------------------------------

csvimport <- read.csv(PathToCSV)

newplot <- ggplot(csvimport, aes_string(fill="Phylum", y="Average Read Count", x=column_name)) + 
  geom_bar(position="stack", stat="identity") +
  scale_fill_manual(values = colorlist) +
  ggsave("genotype-sex.png",
         device = "png",
         dpi = 600,
         path = outputFolder)