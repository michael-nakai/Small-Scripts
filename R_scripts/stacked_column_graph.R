library("tidyverse")
library("reshape2")
library("qiime2R")

### NOTES
# - original csv MUST have columns called: "Group", "Phylum", and "Abundance" and nothing else

### VARS TO CHANGE

PathToCSV <- "/home/michael/jo_stuff/top10.csv"

colorlist <- c("darkblue", 
               "darkgoldenrod1", 
               "darkseagreen", 
               "darkorchid", 
               "darkolivegreen1", 
               "lightskyblue", 
               "darkgreen", 
               "deeppink", 
               "khaki2", 
               "firebrick")

outputFolder <- "/home/michael/jo_stuff/"

### CODE BELOW

orig_table <- read.csv(PathToCSV)

stackedplot <- ggplot(data = orig_table, aes_string(x = "Group", y = "Abundance", fill = "Phylum"))

stackedplot + 
  geom_bar(aes(), stat="identity", position="stack") +
  theme(legend.position="right") +
  scale_fill_manual(values = colorlist) +
  ggsave("test.png",
         device = "png",
         dpi = 600,
         path = outputFolder)
