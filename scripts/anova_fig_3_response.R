setwd("~/nmei/dl/scripts")
df = read.csv("../results/for_figure3.csv")
df$side = factor(df$side)
df$experient = factor(df$experiment)
summary(aov(correct_rate ~ side*experiment + Error(sub_name/(side*experiment)), data = df))

library(lmerTest)
fit <- lmer(correct_rate ~ side*experiment + (1|sub_name), data=df)
anova(fit)

exp1 <- subset(df,experiment == 'Exp. 1')
exp2 <- subset(df,experiment == 'Exp. 2')
with(exp1,t.test(correct_rate[side == 'left'],correct_rate[side == 'right']),paired = TRUE, alternative = "two.sided")
with(exp2,t.test(correct_rate[side == 'left'],correct_rate[side == 'right']),paired = TRUE, alternative = "two.sided")

