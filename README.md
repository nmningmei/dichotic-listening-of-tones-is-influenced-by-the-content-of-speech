# This repository is in responding to "Lateralization in the dichotic listening of tones is influenced by the content of speech"

# Figure 3
![fig3](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%203.jpeg)

we apply ANOVA on CR
there was no main effect of experiment, F(1,41) = 0.000, p = 1.000000, eta square = 0.0

there was a main effect of side of ears, F(1,41) = 9.897, p = 0.003079, eta square = 0.194

there was no main effect of interaction, F(1,41) = 0.189, p = 0.666131, eta square = 0.005

we apply ANOVA on RT
there was no main effect of experiment, F(1,41) = 0.060, p = 0.807731, eta square = 0.001

there was no main effect of side of ears, F(1,41) = 0.382, p = 0.540013, eta square = 0.009

there was no main effect of interaction, F(1,41) = 1.517, p = 0.225125, eta square = 0.036

A post-hoc comparison between the left and right ear effect within each experiment showed that there were significant differences between the left ear and right ear in each experiment.

experiment 1 t(21) = 2.368, p = 0.0223, corrected p = 0.0223

experiment 2 t(18) = 2.851, p = 0.0070, corrected p = 0.0140

Multiple comparisons were corrected by BH-FDR
*:p < 0.05, **: p < 0.01



# Figure 4
![fig4](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%204.jpeg)


Apply a repeated measured ANOVA on correct rate as a factor of codition and side of ears in experiment 2

there was a main effect of condition, F(3,57) = 9.8560, p = 0.0000, corrected p = 0.0001, eta sqaure = 0.3420

there was a main effect of side of ears, F(1,19) = 4.6410, p = 0.0443, corrected p = 0.0443, eta sqaure = 0.1960

there was no main effect of interaction, F(3,57) = 1.1930, p = 0.3204, corrected p = 0.3177, eta sqaure = 0.0590

Apply ANOVA on RT
there was no main effect of condition, F(3,57) = 1.3920, p = 0.2546, corrected p = 0.2604, eta sqaure = 0.0680

there was no main effect of side of ears, F(1,19) = 0.1490, p = 0.7033, corrected p = 0.7033, eta sqaure = 0.0080

there was no main effect of interaction, F(3,57) = 0.8790, p = 0.4575, corrected p = 0.4413, eta sqaure = 0.0440

From a post-hoc comparison within each main effect:

there was a significant difference between left and right, t(79) = 2.494, p = 0.014711, corrected p = nan

there was a significant difference between Hummed
tones and Simple vowel
tones, t(39) = -2.214, p = 0.032729, corrected p = 0.1035

there was a significant difference between CV word
tones and Simple vowel
tones, t(39) = -2.191, p = 0.034498, corrected p = 0.1035

we apply a repeated measure ANOVA on LEA as a factor of condition
there was a main effect of condition, F(3,57) = 3.547, p = 0.0200, eta square = 0.1570
From a post-hoc test comparison between each pair of conditions

there was a marginally significant difference between CV word
tones and Simple vowel
tones

t(19) = -2.661, p = 0.0154, corrected p = 0.0925



# Figure 5
![fig5](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%205.jpeg)


We applied a cross-validation procedure to estimate the linear trend of the relation between the conditions and LI. 
For each cross-validation iteration, we selected one of the 20 subjects and removed this data point from fitting the linear regression. 
We used the rest of the 19 subjects' data to fit a linear regression to predict LI as a function of condition. 
Such iteration was repeated until all the subjects were removed from the fitting dataset once, thus, we had 20 linear regression functions. 
We then compare the regression coefficients of the linear regression functions against zero by a one-sample t-test, 
and the average of the coefficients was significantly different from zero, t(19) = -150.782, p = 5.75e-99. 
On figure 5, we showed the average estimated linear regression function by a dotted line and shaded the standard error of the estimate with upper and lower bounds (in red). ***: p < 0.0001 

