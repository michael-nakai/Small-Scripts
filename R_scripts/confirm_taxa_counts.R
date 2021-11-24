library(tidyverse)
library(qiime2R)
library(phyloseq)

pathToOutputs <- "/home/michael/hamdi_test/outputs_silva/270-202/"

taxpath <- paste0(pathToOutputs, "taxonomy.qza")
treepath <- paste0(pathToOutputs, "rooted-tree.qza")
metadatapath <- "/home/michael/hamdi_test/metadata/all_samples.txt"
tablepath <- paste0(pathToOutputs, "table.qza")

phyD <- qza_to_phyloseq(features = tablepath,
                        tree = treepath,
                        taxonomy = taxpath,
                        metadata = metadatapath)

tax_table(phyD) %>%
  as("matrix") %>%
  as_tibble(rownames = "OTU") %>%
  gather("Rank", "Name", rank_names(phyD)) %>%
  na.omit() %>% # remove rows with NA value
  group_by(Rank) %>%
  summarize(ntaxa = length(unique(Name))) %>% # compute number of unique taxa
  mutate(Rank = factor(Rank, rank_names(phyD))) %>%
  arrange(Rank)