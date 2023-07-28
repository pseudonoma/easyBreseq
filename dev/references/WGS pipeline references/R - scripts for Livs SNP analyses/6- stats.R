### load packages:
library(tidyverse)
library(openxlsx)
library("dplyr")

#change from rif for stp
my_data <- read.xlsx("./metadata/RIF_frequencies_for_stats.xlsx", cols = 1:2, skipEmptyRows = FALSE)

#f test to check variances of both tests are equal
res.ftest <- var.test(Allele.frequency ~ RIF, data = my_data)
res.ftest
#The p-value of F-test is p = 0.3346 which is greater than the significance level 0.05. In conclusion, there is no significant difference between the two variances.

#Shapiro-Wilk test to check that the two groups of samples (A and B), being compared, are normally distributed
shapiro.test(my_data$Allele.frequency)
#From the output, the p-value <0.001239, which is not bigger than 0.05 implying that the distribution of the data are significant#ly different from normal distribution. In other words, we cannot assume the normality.so do mann whitney u test:

wilcox.test(Allele.frequency ~ RIF, data=my_data)
#A significant result suggests that the values for the two groups are different. mine was p-value = 0.1267 so they are the same

# mean of populations
#ab3 rif is 0.927125
#ab13 rif is 0.839
#ab3 stp is 0.686625
#ab13 stp is 0.263875

#calculate SD of populations
#ab3 rif 0.111428719
#ab13 rif 0.16330646
#ab3 stp 0.125475035
#ab13 stp0.266491293


my_data <- read.xlsx("./metadata/STP_frequencies_for_stats.xlsx", cols = 1:2, skipEmptyRows = FALSE)

#f test to check variances of both tests are equal
res.ftest <- var.test(Allele.frequency ~ STP, data = my_data)
res.ftest
#The p-value of F-test is p = 0.06499 which is greater than the significance level 0.05. In conclusion, there is no significant difference between the two variances.

#Shapiro-Wilk test to check that the two groups of samples (A and B), being compared, are normally distributed
shapiro.test(my_data$Allele.frequency)
#From the output, the p-value =0.03115, which is not bigger than 0.05 implying that the distribution of the data are significant#ly different from normal distribution. In other words, we cannot assume the normality.so do mann whitney u test:

wilcox.test(Allele.frequency ~ STP, data=my_data)
#A significant result suggests that the values for the two groups are different. mine was p-value = 0.01352 so they are different. makes sense!



#now to do com- ratios between treatments.
my_data <- read.xlsx("./metadata/com_to_treatment_anova.xlsx", cols = 1:2, skipEmptyRows = FALSE)
library(dplyr)
group_by(my_data, treatment) %>%
  summarise(
    count = n(),
    mean = mean(com_minus, na.rm = TRUE),
    sd = sd(com_minus, na.rm = TRUE)
  )

# Box plots
# ++++++++++++++++++++
# Plot com_minus by treatment and color by treatment
library("ggpubr")
ggboxplot(my_data, x = "treatment", y = "com_minus", 
          color = "treatment", palette = c("#00AFBB", "#E7B800", "#FC4E07", "#AEC6CF"),
          order = c("RIF", "STP", "MIX", "CMB"),
          ylab = "Percentage of com-", xlab = "Treatment")
ggsave("anova.png", anova, dpi = 300, height = 9, width = 20,
       limitsize = FALSE, path = "./plots")

# Compute the analysis of variance
res.aov <- aov(com_minus ~ treatment, data = my_data)
# Summary of the analysis
summary(res.aov)

#output is as follows:
# Df Sum Sq Mean Sq F value   Pr(>F)    
#treatment    3  3.351  1.1171   31.51 4.07e-09 ***
#  Residuals   28  0.993  0.0354                     
#---
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

#this indicates that As the p-value is less than the significance level 0.05, we can conclude that there are significant differences between the groups 
#so next do multiple pariwise comparisons between the com- amount between groups. 
#will perform multiple pairwise-comparison, to determine if the mean difference between specific pairs of group are statistically significant.
#via the Tukey Honest Significant Differences

TukeyHSD(res.aov)
#results show that all are significant, except rif vs mix 

plot(res.aov, 2)
plot(res.aov, 1)
library(car)
leveneTest(com_minus ~ treatment, data = my_data)
#homoegeneity is violated, so mb better to use welch:
oneway.test(com_minus ~ treatment, data = my_data)
 #mb kruskal when anova assumptions ar enot met:
kruskal.test(com_minus ~ treatment, data = my_data)



#check variance between the rif amunts in ab3 and ab13 mixed:
my_data <- read.xlsx("./metadata/MIXED's_RIF_frequencies_for_stats.xlsx", cols = 1:2, skipEmptyRows = FALSE)

#f test to check variances of both tests are equal
res.ftest <- var.test(Allele.frequency ~ RIF, data = my_data)
res.ftest
#The p-value of F-test is p = 0.8915 which is greater than the significance level 0.05. In conclusion, there is no significant difference between the two variances.

#Shapiro-Wilk test to check that the two groups of samples (A and B), being compared, are normally distributed
shapiro.test(my_data$Allele.frequency)
#From the output, the p-value <0.001239, which is not bigger than 0.05 implying that the distribution of the data are significant#ly different from normal distribution. In other words, we can assume the normality.

# Compute t-test
res <- t.test(Allele.frequency ~ RIF, data = my_data, var.equal = TRUE)
res
#The p-value of the test is 0.2828, which is less than the significance level alpha = 0.05. We can conclude that com+ average rif freq is not significantly different from com-’s average rif freq with a p-value = 0.2828.







#check variance between the stp amunts in ab3 and ab13 mixed:
#change from rif for stp
my_data <- read.xlsx("./metadata/MIXED's_STP_frequencies_for_stats.xlsx", cols = 1:2, skipEmptyRows = FALSE)
res.aov2 <- aov(len ~ supp + dose, data = my_data)
summary(res.aov2)


#Shapiro-Wilk test to check that the two groups of samples (A and B), being compared, are normally distributed
shapiro.test(my_data$Allele.frequency)
#From the output, the p-value = 0.002307, which is not bigger than 0.05 implying that the distribution of the data are significant#ly different from normal distribution. In other words, we cannot assume the normality.so many u whitney


wilcox.test(Allele.frequency ~ STP, data=my_data)
#A significant result suggests that the values for the two groups are different. mine was p-value = 0.0005479 so they are significantly different



#ANOVA of whether mdr occured
my_data <- read.xlsx("./metadata/anova_MDR.xlsx", cols = 1:4, skipEmptyRows = FALSE)
#len = wells; x = treatment, colour = ancestry
res.aov2 <- aov(wells ~ ancestry + treatment + shift, data = my_data)
summary(res.aov2)
