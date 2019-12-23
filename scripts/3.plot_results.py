#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 20 12:00:13 2019

@author: nmei
"""

import os
import utils
import pandas as pd
import numpy as np
import seaborn as sns
from matplotlib import pyplot as plt
import pingouin as pg
from scipy import stats
from sklearn import linear_model
from sklearn.model_selection import LeaveOneOut,cross_validate

sns.set_style('white')
sns.set_context('poster')
plt.rcParams["font.weight"] = "bold"
plt.rcParams["axes.labelweight"] = "bold"

def star(x):
    if x < 0.001:
        return "***"
    elif x < 0.01:
        return "**"
    elif x < 0.05:
        return "*"
    else:
        return 'n.s.'
order_x = ['Hummed\ntones',
           'Simple vowel\ntones',
           'CV Pseudo-word\ntones',
           'CV word\ntones']
figures_dir     = '../figures'
dpi = 100
replacement = {"experiment":"experiment",
               "side":"side of ears",
               "condition":"condition",
               "Exp. 1":"experiment 1",
               "Exp. 2":"experiment 2",
               "Interaction":"interaction",
               "condition * side": "interaction"}

# figure 3
df_figure_3 = pd.read_csv('../results/for_figure3.csv')
df_figure_3_RT = pd.read_csv('../results/for_figure3_RT.csv')

# correct rate ~ experiment * side
aov_3 = pg.mixed_anova(data = df_figure_3,
                       dv = 'correct_rate',
                       within = 'side',
                       between = 'experiment',
                       subject = 'sub_name',
                       )
aov_3['sig'] = aov_3['p-unc'].apply(star)
# RT ~ experiment * side
aov_3_RT = pg.mixed_anova(data = df_figure_3_RT,
                       dv = 'RT',
                       within = 'side',
                       between = 'experiment',
                       subject = 'sub_name',
                       )
aov_3_RT['sig'] = aov_3_RT['p-unc'].apply(star)
print('correct rate ~ experiment * side')
print(aov_3)
print()
print("RT ~ experiment * side")
print(aov_3_RT)

empty = "we apply ANOVA on CR\n"
for ii,row in aov_3.iterrows():
    if row['sig'] != 'n.s.':
        empty += f"there was a main effect of {replacement[row['Source']]}, F({row['DF1']},{row['DF2']}) = {row['F']:.3f}, p = {row['p-unc']:.6f}, eta square = {row['np2']}\n\n"
    else:
        empty += f"there was no main effect of {replacement[row['Source']]}, F({row['DF1']},{row['DF2']}) = {row['F']:.3f}, p = {row['p-unc']:.6f}, eta square = {row['np2']}\n\n"

empty += "we apply ANOVA on RT\n"
for ii,row in aov_3_RT.iterrows():
    if row['sig'] != 'n.s.':
        empty += f"there was a main effect of {replacement[row['Source']]}, F({row['DF1']},{row['DF2']}) = {row['F']:.3f}, p = {row['p-unc']:.6f}, eta square = {row['np2']}\n\n"
    else:
        empty += f"there was no main effect of {replacement[row['Source']]}, F({row['DF1']},{row['DF2']}) = {row['F']:.3f}, p = {row['p-unc']:.6f}, eta square = {row['np2']}\n\n"

posthoc3 = pg.pairwise_ttests(dv='correct_rate', within='experiment', between='side',
                   subject='sub_name', data=df_figure_3, padjust='fdr_bh',
                   )
posthoc3['sig'] = posthoc3['p-corr'].apply(star)
print(posthoc3)
empty += "A post-hoc comparison between the left and right ear effect within each experiment showed that there were significant differences between the left ear and right ear in each experiment.\n\n"
for ii,row in posthoc3.iterrows():
    if row['sig'] != 'n.s.':
        print(f"{row['experiment']} t({int(row['dof']/2-1)}) = {row['T']:.3f}, p = {row['p-unc']:.4f}, corrected p = {row['p-corr']:.4f}")
        empty += f"{replacement[row['experiment']]} t({int(row['dof']/2-1)}) = {row['T']:.3f}, p = {row['p-unc']:.4f}, corrected p = {row['p-corr']:.4f}\n\n"

empty += "Multiple comparisons were corrected by BH-FDR\n*:p < 0.05, **: p < 0.01\n\n"
fig3_summary = f'{empty}'

###### pre-define some common arguments that we will repeat over and over again #########
args = dict(x = 'experiment', # x axis
            hue = 'side', # split the bars
            palette = {'left':'blue','right':'red'}, # bar color
            capsize = .1, # errorbar capsize
           )
###### common arguments for annotation ########
annotate_args = dict(xycoords='data',
                     textcoords='data',
                     arrowprops=dict(arrowstyle="-", ec='black',
                                    connectionstyle="bar,fraction=0.2"))
###### common arguments for adding the stars #######
text_args = dict(weight = 'bold',
                 horizontalalignment='center',
                 verticalalignment='center',
                 size = 36,)

fig,axes = plt.subplots(figsize = (16,8),ncols = 2,) # define the figure with 2 columns subplots
# subplot (2,1,1) --> correct rate ~ experiment * side
ax = axes[0]
line_height = .6
text_height = .65
ax = sns.barplot(y = 'correct_rate',
                 data = df_figure_3,
                 ax = ax,
                 **args)
ax.set(ylim =(0,0.65),
       ylabel = 'CR (Proportion)',
       xlabel = '',)
ax.annotate("", xy=(-.2, line_height), 
            xytext=(.2, line_height), 
            **annotate_args)
ax.text(0, text_height, "**",
       **text_args)
ax.annotate("", xy=(1-.2, line_height),
            xytext=(1+.2, line_height), 
            **annotate_args)
ax.text(1, text_height, "**",
       **text_args)
ax.get_legend().remove()
sns.despine()
# RT
ax = axes[1]
ax = sns.barplot(y = 'RT',
                 data = df_figure_3_RT,
                 ax = ax,
                 **args)
ax.set(ylim =(0,2.7),
       ylabel = 'RT (sec)',
       xlabel = '',)
ax.legend(loc = 'upper right')
sns.despine()
fig.tight_layout()
fig.savefig(os.path.join(figures_dir,'figure 3.jpeg'),
            dpi         = dpi,
            bbox_inches = 'tight',)

# figure 4
df_figure_4 = pd.read_csv('../results/for_figure4.csv')
df_figure_4_RT = pd.read_csv('../results/for_figure4_RT.csv')


resRM_4 = pg.rm_anova(data = df_figure_4,
                      dv = 'correct_rate',
                      subject = 'sub_name',
                      within = ['condition','side'],
                      )
resRM_4['sig'] = resRM_4['p-GG-corr'].apply(star)
print(resRM_4)

resRM_4_RT = pg.rm_anova(data = df_figure_4_RT,
                      dv = 'RT',
                      subject = 'sub_name',
                      within = ['condition','side'],
                      )
resRM_4_RT['sig'] = resRM_4_RT['p-GG-corr'].apply(star)
print(resRM_4_RT)

empty = "Apply a repeated measured ANOVA on correct rate as a factor of codition and side of ears in experiment 2\n\n"
for ii,row in resRM_4.iterrows():
    if row['sig'] != 'n.s.':
        empty += f"there was a main effect of {replacement[row['Source']]}, F({row['ddof1']},{row['ddof2']}) = {row['F']:.4f}, p = {row['p-unc']:.4f}, corrected p = {row['p-GG-corr']:.4f}, eta sqaure = {row['np2']:.4f}\n\n"
    else:
        empty += f"there was no main effect of {replacement[row['Source']]}, F({row['ddof1']},{row['ddof2']}) = {row['F']:.4f}, p = {row['p-unc']:.4f}, corrected p = {row['p-GG-corr']:.4f}, eta sqaure = {row['np2']:.4f}\n\n"
empty += "Apply ANOVA on RT\n"
for ii,row in resRM_4_RT.iterrows():
    if row['sig'] != 'n.s.':
        empty += f"there was a main effect of {replacement[row['Source']]}, F({row['ddof1']},{row['ddof2']}) = {row['F']:.4f}, p = {row['p-unc']:.4f}, corrected p = {row['p-GG-corr']:.4f}, eta sqaure = {row['np2']:.4f}\n\n"
    else:
        empty += f"there was no main effect of {replacement[row['Source']]}, F({row['ddof1']},{row['ddof2']}) = {row['F']:.4f}, p = {row['p-unc']:.4f}, corrected p = {row['p-GG-corr']:.4f}, eta sqaure = {row['np2']:.4f}\n\n"
    
post_4 = pg.pairwise_ttests(data = df_figure_4,
                   dv = 'correct_rate',
                   within = ['condition','side'],
                   padjust ='fdr_bh', # multiple comparison correction
                   alpha = 0.05,
                   effsize= 'eta-square',
                   interaction = False,
                   parametric = True,)
post_4['sig'] = post_4['p-unc'].apply(star)
post_4 = post_4.sort_values('p-unc')
print(post_4[[ 'A', 'B', 'T', 'dof','p-unc', 'p-corr','sig']].iloc[1:,:])
empty += "From a post-hoc comparison within each main effect:\n\n"
for ii,row in post_4.iterrows():
    if row['sig'] != 'n.s.':
        empty += f"there was a significant difference between {row['A']} and {row['B']}, t({int(row['dof'])}) = {row['T']:.3f}, p = {row['p-unc']:4f}, corrected p = {row['p-corr']:.4f}\n\n"
        
empty += "we apply a repeated measure ANOVA on LEA as a factor of condition\n"
rmRes_4 = pg.rm_anova(data = pd.read_csv('../results/for_figure5.csv'),
                      dv = 'LEA',
                      within = 'condition',
                      subject = 'sub_name',)
print(rmRes_4)
for ii,row in rmRes_4.iterrows():
    if row['p-unc'] < 0.05:
        empty += f"there was a main effect of {row['Source']}, F({row['ddof1']},{row['ddof2']}) = {row['F']:.3f}, p = {row['p-unc']:.4f}, eta square = {row['np2']:.4f}\n"
post_rm_LEA_4 = pg.pairwise_ttests(data = pd.read_csv('../results/for_figure5.csv'),
                      dv = 'LEA',
                      within = 'condition',
                      padjust ='fdr_bh', # multiple comparison correction
                       alpha = 0.05,
                       effsize= 'eta-square',
                       interaction = False,
                       parametric = True,)
post_rm_LEA_4['sig'] = post_rm_LEA_4['p-unc'].apply(star)
post_rm_LEA_4 = post_rm_LEA_4.sort_values('p-unc')
print(post_rm_LEA_4[['A','B',"T",'dof','p-unc','p-corr','sig']])
empty += 'From a post-hoc test comparison between each pair of conditions\n\n'
for ii, row in post_rm_LEA_4.iterrows():
    if row['sig'] != 'n.s.':
        empty += f"there was a marginally significant difference between {row['A']} and {row['B']}\n\n"
        empty += f"t({int(row['dof'])}) = {row['T']:.3f}, p = {row['p-unc']:.4f}, corrected p = {row['p-corr']:.4f}\n\n"


fig4_summary = f"{empty}"

fig,axes = plt.subplots(figsize = (16,16),nrows = 2)
args = dict(x = 'condition',
            order = order_x,
            capsize = .1,
            palette = {'left':'blue','right':'red'},
            hue = 'side',)
###### common arguments for annotation ########
annotate_args = dict(xycoords='data',
                     textcoords='data',
                     arrowprops=dict(arrowstyle="-", ec='black',
                                    connectionstyle="bar,fraction=0.02"))
# response
ax = axes[0]
ax = sns.barplot(
                 y = 'correct_rate',
                 data = df_figure_4,
                 ax = ax,
                 **args
                 )
ax.set(xlabel = '',
       xticklabels = [],
       ylabel = 'CR (proportion)',
       ylim = (0,0.7),
       )
ax.legend(loc = 'upper right')
sns.despine()

# RT
ax = axes[1]
ax = sns.barplot(
                 y = 'RT',
                 data = df_figure_4_RT,
                 ax = ax,
                 **args
                 )
ax.set(xlabel = '',
       ylabel = "RT (sec)",
       ylim = (0,2.7))
ax.set_xticklabels(ax.xaxis.get_majorticklabels(),
                   rotation = -35, 
                   ha = 'center',
                   weight = 'bold')
ax.get_legend().remove()
sns.despine()
fig.savefig(os.path.join(figures_dir,
                        'figure 4.jpeg'),
           dpi = dpi,
           bbox_inches = 'tight')

# figure 5
df_figure_5 = pd.read_csv('../results/for_figure5.csv')
t,p = stats.ttest_1samp(df_figure_5['adjust_LI'].values,0)
print(f"t = {t:.3f}, p = {p:.4f}")


lm = linear_model.LinearRegression()
cv = LeaveOneOut()
x=df_figure_5['n_condition'].values.reshape(-1,1)
y = df_figure_5['LI'].values
#y = (y - y.mean()) / y.std()
groups = df_figure_5['sub_name']
res = cross_validate(lm,x,y,
                     groups = groups,
                     cv = cv,
                     return_estimator = True,
                     scoring = 'neg_mean_squared_error')
score = res['test_score']
baseline = np.array([(y_true - y.mean())**2 for y_true in y])
weights = np.array([reg.coef_[0] for reg in res['estimator']])
intercepts = np.array([reg.intercept_ for reg in res['estimator']])
t,p = stats.ttest_1samp(weights,0)
print(f"t = {t:.3f}, p = {p:.2e}")
_=plt.hist(weights)

fig5_summary = f"""
We applied a cross-validation procedure to estimate the linear trend of the relation between the conditions and LI. 
For each cross-validation iteration, we selected one of the 20 subjects and removed this data point from fitting the linear regression. 
We used the rest of the 19 subjects' data to fit a linear regression to predict LI as a function of condition. 
Such iteration was repeated until all the subjects were removed from the fitting dataset once, thus, we had 20 linear regression functions. 
We then compare the regression coefficients of the linear regression functions against zero by a one-sample t-test, 
and the average of the coefficients was significantly different from zero, t({19}) = {t:.3f}, p = {p:.2e}. 
On figure 5, we showed the average estimated linear regression function by a dotted line and shaded the standard error of the estimate with upper and lower bounds (in red). ***: p < 0.0001 
"""
print(fig5_summary.replace('\n',''))


fig,ax = plt.subplots(figsize = (16,8),)
ax = sns.pointplot(x = 'condition',
                   order = order_x,
                   y = 'LI',
                   data = df_figure_5,
                   ax = ax,
                   markers = '.',
                   capsize = .1,
                   color = 'black',
                   alpha = 0.4,)
xx = np.linspace(0,3,100)
yy = np.dot(xx.reshape(-1,1),weights.reshape(1,-1)) + intercepts
yy_upper = yy.max(1)
yy_lower = yy.min(1)
ax.plot(xx,yy.mean(1),
        color = 'black',
        linestyle = '--',
        label = 'estimated trend (mean)')
ax.fill_between(xx,
                yy_upper,
                yy_lower,
                color = 'red',
                label = 'estimated trend (SE)',
                )
ax.annotate('***',
            xy = (1.5,0.2),
            size = 36,
            weight = 'bold')
ax.legend(loc = 'upper right')
ax.set(xlabel = '',
       ylabel = 'LI',
       ylim = (-0.1,0.25),)
ax.set_xticklabels(ax.xaxis.get_majorticklabels(),
                   rotation = -35, 
                   ha = 'center',
                   weight = 'bold')
sns.despine()
fig.savefig(os.path.join(figures_dir,
                        'figure 5.jpeg'),
           dpi = dpi,
           bbox_inches = 'tight')
readme_template = """# This repository is in responding to "Lateralization in the dichotic listening of tones is influenced by the content of speech"

# Figure 3
![fig3](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%203.jpeg)

{}

# Figure 4
![fig4](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%204.jpeg)


{}

# Figure 5
![fig5](https://github.com/nmningmei/dichotic-listening-of-tones-is-influenced-by-the-content-of-speech/blob/master/figures/figure%205.jpeg)

{}
""".format(fig3_summary,fig4_summary,fig5_summary)

with open('../README.md','w') as f:
    f.write(readme_template)
    f.close()

