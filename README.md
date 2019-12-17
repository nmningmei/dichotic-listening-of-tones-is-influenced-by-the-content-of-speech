# This repository is in responding to "Lateralization in the dichotic listening of tones is influenced by the content of speech"

# Figure 3
![fig3](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%203.jpeg)

there was a main effect of side of ears, F(1,41) = 9.897, p = 0.003079, eta square = 0.194
A post-hoc comparison between the left and right ear effect within each experiment showed that there were significant differences between the left ear and right ear in each experiment.
experiment 1 t(21) = 2.368, p = 0.0223, corrected p = 0.0223
experiment 2 t(18) = 2.851, p = 0.0070, corrected p = 0.0140
Multiple comparisons were corrected by BH-FDR
*:p < 0.05, **: p < 0.01

# Figure 4
![fig4](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%204.jpeg)


there was a main effect of condition, F(3,57) = 9.8560, p = 0.0000, corrected p = 0.0001, eta sqaure = 0.3420
there was a main effect of side of ears, F(1,19) = 4.6410, p = 0.0443, corrected p = 0.0443, eta sqaure = 0.1960
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

