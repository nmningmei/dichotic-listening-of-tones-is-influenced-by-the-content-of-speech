# This repository is in responding to "Lateralization in the dichotic listening of tones is influenced by the content of speech"

# Figure 3
![fig3](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%203.jpeg)

we apply ANOVA on CR
there was no main effect of experiment, F(1,41) = 0.000, p = 1.000000, eta square = 0.0

there was a main effect of side of ears, F(1,41) = 11.129, p = 0.001813, eta square = 0.213

there was no main effect of interaction, F(1,41) = 0.219, p = 0.641934, eta square = 0.005

we apply ANOVA on RT
there was no main effect of experiment, F(1,41) = 0.060, p = 0.807731, eta square = 0.001

there was no main effect of side of ears, F(1,41) = 0.382, p = 0.540013, eta square = 0.009

there was no main effect of interaction, F(1,41) = 1.517, p = 0.225125, eta square = 0.036

A post-hoc comparison between the left and right ear effect within each experiment showed that there were significant differences between the left ear and right ear in each experiment.

experiment 1 t(21) = 3.143, p = 0.0030, corrected p = 0.0030

experiment 2 t(18) = 3.532, p = 0.0011, corrected p = 0.0022

Multiple comparisons were corrected by BH-FDR
*:p < 0.05, **: p < 0.01



# Figure 4
![fig4](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%204.jpeg)


Apply a repeated measured ANOVA on correct rate as a factor of codition and side of ears in experiment 2

there was no main effect of condition, F(3,57) = -0.0000, p = 1.0000, corrected p = 1.0000, eta sqaure = -0.0000

there was a main effect of side of ears, F(1,19) = 5.4480, p = 0.0307, corrected p = 0.0307, eta sqaure = 0.2230

there was no main effect of interaction, F(3,57) = 1.2250, p = 0.3089, corrected p = 0.3080, eta sqaure = 0.0610

Apply ANOVA on RT
there was no main effect of condition, F(3,57) = 1.3920, p = 0.2546, corrected p = 0.2604, eta sqaure = 0.0680

there was no main effect of side of ears, F(1,19) = 0.1490, p = 0.7033, corrected p = 0.7033, eta sqaure = 0.0080

there was no main effect of interaction, F(3,57) = 0.8790, p = 0.4575, corrected p = 0.4413, eta sqaure = 0.0440

From a post-hoc comparison within each main effect:

there was a significant difference between left and right, t(79) = 2.691, p = 0.008698, corrected p = nan

we apply a repeated measure ANOVA on LEA as a factor of condition
From a post-hoc test comparison between each pair of conditions



# Figure 5
![fig5](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%205.jpeg)


We applied a cross-validation procedure to estimate the linear trend of the relation between the conditions and LI. 
For each cross-validation iteration, we selected one of the 20 subjects and removed this data point from fitting the linear regression. 
We used the rest of the 19 subjects' data to fit a linear regression to predict LI as a function of condition. 
Such iteration was repeated until all the subjects were removed from the fitting dataset once, thus, we had 20 linear regression functions. 
We then compare the regression coefficients of the linear regression functions against zero by a one-sample t-test, 
and the average of the coefficients was significantly different from zero, t(19) = -150.782, p = 5.75e-99. 
On figure 5, we showed the average estimated linear regression function by a dotted line and shaded the standard error of the estimate with upper and lower bounds (in red). ***: p < 0.0001 

