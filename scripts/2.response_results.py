#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec  8 14:59:26 2019

@author: nmei
"""

import os
import utils
from glob import glob
import pandas as pd
import numpy as np
import seaborn as sns
from matplotlib import pyplot as plt
from scipy import stats
import pingouin as pg

sns.set_style('white')
sns.set_context('poster')
plt.rcParams["font.weight"] = "bold"
plt.rcParams["axes.labelweight"] = "bold"

dpi             = 500
working_dir     = '../data/results_all'
working_data    = glob(os.path.join(working_dir,'*.csv'))
results_dir     = '../results/'
figures_dir     = '../figures'
if not os.path.exists(results_dir):
    os.mkdir(results_dir)

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
           'Simple voxel\ntones',
           'CV Pseudo-word\ntones',
           'CV word\ntones']

results = dict(experiment   = [],
               condition    = [],
               sub_name     = [],
               LEA          = [],
               REA          = [],
               )
for f in working_data:
    f                               = f.replace('\\','/')
    temp                            = pd.read_csv(f)
    temp['left_correct']            = np.array(temp['response'] == temp['left'],dtype = int)
    temp['right_correct']           = np.array(temp['response'] == temp['right'],dtype = int)
    experiment,condition,sub_name   = f.split('/')[-1].split('.')[0].split('_')
    results['experiment'].append(experiment)
    results['condition' ].append(condition)
    results['sub_name'  ].append(sub_name)
    results['LEA'       ].append(temp['left_correct'].sum() / temp.shape[0])
    results['REA'       ].append(temp['right_correct'].sum() / temp.shape[0])


results         = pd.DataFrame(results)
results['LI']   = (results['LEA'] - results['REA']) / (results['LEA'] + results['REA'])

df_plot         = pd.melt(results,
                          id_vars       = ['experiment', 'condition', 'sub_name'],
                          value_vars    = ['LEA', 'REA'],
                          )
df_plot.columns = ['experiment', 'condition', 'sub_name', 'side', 'correct_rate']
df_plot['side'] = df_plot['side'].map({'LEA':'left','REA':'right'})

# plot figure 3
figure3_csv_name                = os.path.join(results_dir,'for_figure3.csv')
df_figure_3                     = df_plot[df_plot['condition'] == 'hum']
df_figure_3.loc[:,'experiment'] = df_figure_3['experiment'].map({'experiment1':'Exp. 1',
                                                                 'experiment2':'Exp. 2',})
df_figure_3_RT                  = pd.read_csv(os.path.join(results_dir,'for_figure3_RT.csv'))
df_figure_3.to_csv(figure3_csv_name,index = False)

# correct rate ~ experiment * side
aov_3           = pg.mixed_anova(data     = df_figure_3,
                                 dv       = 'correct_rate',
                                 within   = 'side',
                                 between  = 'experiment',
                                 subject  = 'sub_name',
                                 )
aov_3['sig']    = aov_3['p-unc'].apply(star)
# RT ~ experiment * side
aov_3_RT        = pg.mixed_anova(data       = df_figure_3_RT,
                                 dv         = 'RT',
                                 within     = 'side',
                                 between    = 'experiment',
                                 subject    = 'sub_name',
                                 )
aov_3_RT['sig'] = aov_3_RT['p-unc'].apply(star)
print('correct rate ~ experiment * side')
print(aov_3)
print()
print("RT ~ experiment * side")
print(aov_3_RT)

res_3 = dict(t      = [],
             p      = [],
             exp    = [],
             dof    = [],)
for exp,df_sub in df_figure_3.groupby(['experiment']):
    df_sub  = df_sub.sort_values(['sub_name','side'])
    left    = df_sub[df_sub['side']=='left']['correct_rate'].values
    right   = df_sub[df_sub['side']=='right']['correct_rate'].values
    t,p     = stats.ttest_rel(left,right,)
    res_3['t'  ].append(t)
    res_3['p'  ].append(p)
    res_3['exp'].append(exp)
    res_3['dof'].append(df_sub.shape[0] / 2 - 1)
res_3                   = pd.DataFrame(res_3)
res_3                   = res_3.sort_values(['p'])
coverter                = utils.MCPConverter(pvals = res_3['p'].values)
d                       = coverter.adjust_many()
res_3['p_corrected']    = d['bh'].values
res_3                   = res_3.sort_values('exp')
for exp,df_sub in res_3.groupby('exp'):
    print(f"{exp} t({int(df_sub['dof'].values[0])}) = {df_sub['t'].values[0]:.3f}, p = {df_sub['p'].values[0]:.4f}, corrected p = {df_sub['p_corrected'].values[0]:.4f}")

# plot
###### pre-define some common arguments that we will repeat over and over again #########
args = dict(x           = 'experiment', # x axis
            hue         = 'side', # split the bars
            palette     = {'left':'blue','right':'red'}, # bar color
            capsize     = .1, # errorbar capsize
           )
###### common arguments for annotation ########
annotate_args = dict(xycoords   = 'data',
                     textcoords = 'data',
                     arrowprops = dict(arrowstyle       = "-", 
                                       ec               = 'black',
                                       connectionstyle  = "bar,fraction=0.2"))
###### common arguments for adding the stars #######
text_args = dict(weight                 = 'bold',
                 horizontalalignment    = 'center',
                 verticalalignment      = 'center')

fig,axes = plt.subplots(figsize = (16,8),ncols = 2,) # define the figure with 2 columns subplots
# subplot (2,1,1) --> correct rate ~ experiment * side
ax          = axes[0]
line_height = .55
text_height = .6
ax          = sns.barplot(y     = 'correct_rate',
                          data  = df_figure_3,
                          ax    = ax,
                          **args)
ax.set(ylim     = (0,0.65),
       ylabel   = 'CR',
       xlabel   = '',)
ax.annotate("",
            xy      = (-.2, line_height), 
            xytext  = (.2,  line_height), 
            **annotate_args)
ax.text(0,
        .6,
        "*",
        **text_args)
ax.annotate("",
            xy      = (1-.2, line_height),
            xytext  = (1+.2, line_height), 
            **annotate_args)
ax.text(1,
        text_height, "*",
        **text_args)
ax.get_legend().remove()
sns.despine()
# RT
ax = axes[1]
ax = sns.barplot(y      = 'RT',
                 data   = df_figure_3_RT,
                 ax     = ax,
                 **args)
ax.set(ylim     = (0,2.7),
       ylabel   = 'RT (sec)',
       xlabel   = '',)
ax.legend(loc   = 'upper right')
sns.despine()
fig.tight_layout()
fig.savefig(os.path.join(figures_dir,'figure 3.jpeg'),
            dpi         = dpi,
            bbox_inches = 'tight',)


# plot figure 4
figure4_csv_name                = os.path.join(results_dir,'for_figure4.csv')
df_figure_4                     = df_plot[df_plot['experiment'] == 'experiment2']
df_figure_4.loc[:,'condition']  = df_figure_4['condition'].map({'hum' :'Hummed\ntones',
                                                                'tone':'Simple voxel\ntones',
                                                                'gi'  :'CV Pseudo-word\ntones',
                                                                'di'  :'CV word\ntones'})
df_figure_4.to_csv(figure4_csv_name,index = False)
resRM_4         = pg.rm_anova(data      = df_figure_4,
                              dv        = 'correct_rate',
                              subject   = 'sub_name',
                              within    = ['condition','side'],
                              )
resRM_4['sig']  = resRM_4['p-GG-corr'].apply(star)
print(resRM_4)

# condition main effect
post_4          = pg.pairwise_ttests(data           = df_figure_4,
                                     dv             = 'correct_rate',
                                     within         = ['condition','side'],
                                     padjust        ='fdr_bh',
                                     alpha          = 0.05,
                                     effsize        = 'eta-square',
                                     interaction    = False,
                                     parametric     = True,
                                     )
post_4['sig']   = post_4['p-unc'].apply(star)
post_4          = post_4.sort_values('p-unc')
print(post_4[[ 'A', 'B', 'T', 'dof','p-unc', 'p-corr','sig']].iloc[1:,:])

pose_side_4     = dict(condition    = [],
                       t            = [],
                       p            = [],)
# left and right in hum and tone
for condition in order_x[:2]:
    df_sub  = df_figure_4[df_figure_4['condition'] == condition]
    df_sub  = df_sub.sort_values(['sub_name','side'])
    left    = df_sub[df_sub['side'] == 'left']['correct_rate'].values
    right   = df_sub[df_sub['side'] == 'right']['correct_rate'].values
    t,p     = stats.ttest_rel(left,right)
    pose_side_4['condition'].append(condition)
    pose_side_4['t'        ].append(t)
    pose_side_4['p'        ].append(p)
pose_side_4                 = pd.DataFrame(pose_side_4)
pose_side_4                 = pose_side_4.sort_values('p')
converter                   = utils.MCPConverter(pvals = pose_side_4['p'].values)
d                           = converter.adjust_many()
pose_side_4['correct_p']    = d['bh']
for condition, df_sub in pose_side_4.groupby('condition'):
    condition               = condition.replace('\n',' ')
    print(f"{condition:.12s}, t = {df_sub['t'].values[0]:.3f}, p = {df_sub['p'].values[0]:.4f}, correct p = {df_sub['correct_p'].values[0]:.4f}")

df_figure_4_RT              = pd.read_csv('../results/for_figure4_RT.csv')

# rmANOVA on LEA
rmRes_4         = pg.rm_anova(data      = results[results['experiment'] == 'experiment2'],
                              dv        = 'LEA',
                              within    = 'condition',
                              subject   = 'sub_name',)
post_rm_LEA_4   = pg.pairwise_ttests(data           = results[results['experiment'] == 'experiment2'],
                                     dv             = 'LEA',
                                     within         = 'condition',
                                     padjust        ='fdr_bh',
                                     alpha          = 0.05,
                                     effsize        = 'eta-square',
                                     interaction    = False,
                                     parametric     = True,)

fig,axes = plt.subplots(figsize = (16,16),nrows = 2)
args = dict(x       = 'condition',
            order   = order_x,
            capsize = .1,
            palette = {'left':'blue','right':'red'},
            hue     = 'side',)
# response
ax = axes[0]
ax = sns.barplot(
                 y      = 'correct_rate',
                 data   = df_figure_4,
                 ax     = ax,
                 **args
                 )
ax.set(xlabel       = '',
       xticklabels  = [],
       ylabel       = 'CR',
       ylim         = (0,0.67),
       )
ax.legend(loc = 'upper right')
sns.despine()
line_height = .55
text_height = .6

ax.annotate("", 
            xy      = (-.2, line_height),
            xytext  = (.2,  line_height),
            **annotate_args)
ax.text(0, 
        text_height, "~*",
        **text_args)

ax.annotate("",
            xy      = (1-.2, line_height),
            xytext  = (1+.2, line_height), 
            **annotate_args)
ax.text(1,
        text_height,
        "n.s.",
        **text_args)
# RT
ax = axes[1]
ax = sns.barplot(
                 y      = 'RT',
                 data   = df_figure_4_RT,
                 ax     = ax,
                 **args
                 )
ax.set(xlabel = '',
       ylabel = "RT")
ax.set_xticklabels(ax.xaxis.get_majorticklabels(),
                   rotation = -35, 
                   ha       = 'center',
                   weight   = 'bold')
ax.get_legend().remove()
sns.despine()
fig.savefig('../figures/figure4.jpeg',
            dpi         = dpi,
            bbox_inches = 'tight',)

# plot figure 5
figure5_csv_name                = os.path.join(results_dir,'for_figure5.csv')
df_figure_5                     = results[results['experiment'] == 'experiment2'].reset_index()
df_figure_5['n_condition']      = df_figure_5['condition'].map({'hum' :0,
                                                                'tone':1,
                                                                'gi'  :2,
                                                                'di'  :3})
df_figure_5['adjust']           = df_figure_5['condition'].map({'hum' :2,
                                                                'tone':1,
                                                                'gi'  :-1,
                                                                'di'  :-2})
df_figure_5['adjust_LI']        = df_figure_5['LI'] * df_figure_5['adjust']

df_figure_5.loc[:,'condition']  = df_figure_5['condition'].map({'hum' :'Hummed\ntones',
                                                                'tone':'Simple voxel\ntones',
                                                                'gi'  :'CV Pseudo-word\ntones',
                                                                'di'  :'CV word\ntones'})
df_figure_5.to_csv(figure5_csv_name,index = False)
df_figure_5_RT  = pd.read_csv('../results/for_figure5_RT.csv')

ps              = utils.resample_ttest(df_figure_5['adjust_LI'].values,
                          baseline = 0,)
t,p             = stats.ttest_1samp(df_figure_5['adjust_LI'].values,0)
print(f"t = {t:.3f}, p = {p:.4f}")


from sklearn import linear_model
from sklearn.model_selection import LeaveOneOut,cross_validate
lm      = linear_model.LinearRegression()
cv      = LeaveOneOut()
x       = df_figure_5['n_condition'].values.reshape(-1,1)
y       = df_figure_5['LI'].values
#y   = (y - y.mean()) / y.std()
groups  = df_figure_5['sub_name']
res     = cross_validate(lm,
                         x,
                         y,
                         groups             = groups,
                         cv                 = cv,
                         return_estimator   = True,
                         scoring            = 'neg_mean_squared_error')
score       = res['test_score']
baseline    = np.array([(y_true - y.mean())**2 for y_true in y])
weights     = np.array([reg.coef_[0] for reg in res['estimator']])
intercepts  = np.array([reg.intercept_ for reg in res['estimator']])
t,p         = stats.ttest_1samp(weights,0)


fig,ax  = plt.subplots(figsize = (16,8),)
ax      = sns.pointplot(x       = 'condition',
                        order   = order_x,
                        y       = 'LI',
                        data    = df_figure_5,
                        ax      = ax,
                        markers = '.',
                        capsize = .1,
                        color   = 'black',
                        alpha   = 0.4,)
xx          = np.linspace(0,3,100)
yy          = np.dot(xx.reshape(-1,1),weights.reshape(1,-1)) + intercepts
yy_upper    = yy.max(1)
yy_lower    = yy.min(1)
ax.plot(xx,
        yy.mean(1),
        color       = 'black',
        linestyle   = '--',
        label       = 'estimated trend (mean)')
ax.fill_between(xx,
                yy_upper,
                yy_lower,
                color = 'red',
                label = 'estimated trend (SE)',
                )
ax.annotate('***',
            xy      = (1.5,0.2),
            size    = 36,
            weight  = 'bold')
ax.legend(loc       = 'upper right')
ax.set(xlabel       = '',
       ylabel       = 'LI',
       ylim         = (-0.1,0.25),)
ax.set_xticklabels(ax.xaxis.get_majorticklabels(),
                   rotation = -35, 
                   ha       = 'center',
                   weight   = 'bold')
sns.despine()
fig.savefig('../figures/figure5.jpeg',
            dpi         = dpi,
            bbox_inches = 'tight')