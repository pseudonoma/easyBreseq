# this is where I'll plot the output of the previous scripts 

library(tidyverse)
library(cowplot)
library(RColorBrewer)
library(VennDiagram)
library(circlize)
library(ggplot2)

# loading files:
ancestralSNPs <- read_csv("./results/ancestralSNPs.csv")
sampleInfo <- read_csv("./metadata/sampleInfo.csv") %>%
  select("#Sample ID", "name") %>%
  rename(sampleNo = `#Sample ID`, info = name)

# making sure all populations are there (even if no ancestral SNPs detected):
ancestralSNPs <- ancestralSNPs %>%
  select(sampleNo, refName:ancestral) %>%
  full_join(sampleInfo, by = "sampleNo") %>%
  separate(info, c("strain", "treatment", "replicate", "shift", "day"), sep = "_") %>%
  arrange(sampleNo) %>%
  select(sampleNo, strain, treatment, replicate, shift, gene, CDSPos, change, minVariantFreq, coverage) #change5/11

#might need to make frequency numeric, not factored?

# get rid of starting population empty rows:
#ancestralSNPs <- ancestralSNPs[-1:4, ]
#ancestralSNPs <- slice(ancestralSNPs, 5:n())
ancestralSNPs <- ancestralSNPs[which(as.integer(substr(ancestralSNPs$sampleNo, 3, 99)) > 4210),]

ancestralSNPs <- ancestralSNPs %>%
  separate(change, into = c("changeFrom", "changeTo")) %>%
  mutate(mutName = ifelse(is.na(CDSPos), NA, paste0(gene, "_", changeFrom, CDSPos, changeTo)))

# merge replicate and shift as well as strain & treatment, and simplify:
ancestralSNPs <- ancestralSNPs %>%
  mutate(shiftRep = paste0(shift, replicate)) %>%
  mutate(strainTreat = paste0(strain, treatment)) %>%
  select(strainTreat, shiftRep, mutName, minVariantFreq, coverage) %>%
  rename(varFreq = minVariantFreq)

ancestralSNPs <- ancestralSNPs %>%
  complete(nesting(strainTreat, shiftRep), mutName, fill = list(varFreq = 0)) %>%
  filter(!is.na(mutName) & mutName=="rpoB_C1556T" | mutName=="rpsL_A128C") 

#save to help w the com stats tomorrow
library(tidyverse)
library(cowplot)
library(RColorBrewer)
library(VennDiagram)
library(circlize)

write_csv(ancestralSNPs, "./results/ancestralSNPsforcom+/-stats.csv")

#test the plot before do faceting

#4/11 conf intervals

#function to calculate binomaial confidence intervals:
confInt <- function(freq, coverage) {
  binom.test(round(coverage * freq), coverage)$conf.int[1:2]
}

ancestralSNPs$ConfIntMin <- NA
ancestralSNPs$ConfIntMax <- NA
for(i in 1:nrow(ancestralSNPs)) {
  if((ancestralSNPs$varFreq[i] > 0) & (ancestralSNPs$coverage[i] > 0)){
    ci <- confInt(ancestralSNPs$varFreq[i], ancestralSNPs$coverage[i])
    ancestralSNPs$ConfIntMin[i] <- ci[1]
    ancestralSNPs$ConfIntMax[i] <- ci[2]
  } else {
    ancestralSNPs$ConfIntMin[i] <- NA # "0" will get plotted as an error bar, NA removes it
    ancestralSNPs$ConfIntMax[i] <- NA
  }
}

# define colours:
cols <- c("rpoB_C1556T" = hsv(0, 1, 0.9), "rpsL_A128C" = hsv(0.66, 1, 0.9), "rpoB_T443G" = hsv(0.5, 1, 0.9))

plot_test <- ggplot(ancestralSNPs) +
  geom_bar(aes(mutName,varFreq, fill = mutName), stat = "identity") +
  geom_errorbar(aes(x = mutName, y = varFreq, ymin = ConfIntMin, ymax = ConfIntMax), width = .1, size = 0.3, 
                position = position_dodge(width = 0.75)) + #5/11
  facet_grid(cols = vars(shiftRep), rows = vars(strainTreat)) +
  scale_fill_manual(values = cols) +
  theme_bw()+
  labs(x = "Mutation Name", y = "Variant Frequency", fill = "") +
  theme(axis.text.x = element_text(angle = 90))

plot_test


ggsave("plot_jic30oct.png", plot_test, dpi = 300, height = 9, width = 20,
    limitsize = FALSE, path = "./plots")
#coord_equal()
            #need to change labels so that CDSPos pertains to the ancestral mutation names, and subdivide the x axis (mb coordflip) into strain names. leave gaps for non-present strains?
     

#attempt to use format of tutorial to be able to expand on it
ggplot(data = ancestralSNPs) +
  geom_point(mapping = aes(x = CDSPos, y = variantFreq))
#worked yay
#try to "left join" the table with all sample names so can have blank spaces where samples don't have ancestrals
names_for_merging <- read_csv("./data/sample_names_for_merging.csv") %>%
  separate(sampleName, c("strain", "treatment", "replicate", "shift", "day"), sep = "_")
  

#names_for_merging <- left_join(ancestralSNPs, sampleInfo, by = "sampleNo")





# check SNPs in No Drug treatment, and if all frequencies are zero then exclude
#...

#SNPsPlotting <- filter(ancestralSNPs, treatment != "NOD")

# pool the two shifts, i.e. create new column "population" with entries Pop1, ..., Pop8
# (write function that takes shift and rep and returns pop)
...

# pool drug and recombination treatment, i.e. create new column "drugrec"
# (merge strings, e.g. STP and AB13 --> "STP com-")
...


#first want to run a test_plot of the first 3 files run from scripts 1-3
#x axis is the 8 ancestral variants
#y axis is the frequency of the variant
# error bars should be binomial confidence intervals based on frequency and coverage
#not averaged over 4, but individually plot and pool over 2 shifts 

#of the general format: plot_test_of_three_replicates <-ggplot(ancestralSNPs)

#plotting_data <- allData %>%
  #select(variant_frequency, sample_name, ancestry, treatment) %>%      ----make sure get correct variable names. ancestry=ab3/13

  

plot_test <- ggplot(SNPsPlotting) +
  geom_bar(mapping = aes(x = ancestral, y=variant_frequency, fill = ancestral)) +
#  coord_flip() #this stops the x axis being cluttered with sample names
  facet_grid(vars(population), vars(drugrec), nrow = 2)  # ----- make sure that 18 graphs are made, 9 treatments and 2 for AB3and AB13 wth shifts pooled. 
#run the scip twice once for ab3 and once for ab13 to get 2 diffplots

    #here stat_count transforms the data before plotting
    #will also colour the sections according to treatment type




#the test is a test but the main one can be used a couple times to test. 

  #have 2 big figures, "AB3" and "AB13" with the 9 treatment types each.having 3/13 in different plots makes more sense 
    #because normalised to dfferent backgrounds (all ab3 and all ab13, not one background for 2)

#final_for_factering<alData%>%
  #select(strai &ancestry & treatment &varint frequency) #check variable names
#ggplot(final_for_faceting)+
  #geom_line(mapping=aes(ancestral, variant frequency), group=interaction(sample))
    #facet_grid(vars(treatment), vars(ancestry 3/13))

#mb use       
#facetplot <- ggplot(data=ancestralSNPs, aes()) +
# geom_tile(colour="black",size=0.20) +
#coord_equal() +
#scale_x_continuous(name = "Well", breaks = seq(1, 6, 1), position = "top") +
#scale_y_reverse(name = "Population", breaks = seq(1, 4, 1)) + 
#scale_fill_continuous(high = "dodgerblue4", low = "white", limits = c(0.0, 2.0), breaks = seq(0.0, 2.0, 0.5)) +
#scale_fill_distiller(direction = 1) +
#theme(legend.position = "bottom", panel.spacing = unit(0.1, "lines")) +
#guides(colour = guide_colourbar(title.vjust = 0.9)) +
#facet_grid(Treatment_f~transfer, switch = "x")
#facetplot
#ggsave("OD_facet_bAB3.png", plot = facetplot, dpi = 300, height = 9, width = 20,
#    limitsize = FALSE, path = "./plots")

#final for fact



#then add more elements like a figure legend, colour theme, key etc
#mb install ggthemes

