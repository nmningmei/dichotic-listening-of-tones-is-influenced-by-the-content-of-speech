#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec  9 13:59:51 2019

@author: nmei
"""
import os
import utils
from glob import glob
from tqdm import tqdm
import pandas as pd
import numpy as np
import seaborn as sns
from matplotlib import pyplot as plt
from scipy import stats

import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import MultiComparison
from statsmodels.stats.anova import AnovaRM

import PIL

sns.set_style('white')
sns.set_context('poster')

working_dir = '../data/results_all'
working_data = glob(os.path.join(working_dir,'*.csv'))
results_dir = '../results/'
if not os.path.exists(results_dir):
    os.mkdir(results_dir)
figures_dir = '../figures'
if not os.path.exists(figures_dir):
    os.mkdir(figures_dir)

results = dict(experiment = [],
               condition = [],
               sub_name = [],
               LRT = [],
               RRT = [],
               )
for f in working_data:
    f = f.replace('\\','/')
    temp = pd.read_csv(f)
    left_RT = temp[temp['response'] == temp['left']]['RT'].median()
    right_RT = temp[temp['response'] == temp['right']]['RT'].median()
    experiment,condition,sub_name = f.split('/')[-1].split('.')[0].split('_')
    results['experiment'].append(experiment)
    results['condition'].append(condition)
    results['sub_name'].append(sub_name)
    results['LRT'].append(left_RT)
    results['RRT'].append(right_RT)
results = pd.DataFrame(results)


df_plot = pd.melt(results,
                  id_vars = ['experiment', 'condition', 'sub_name'],
                  value_vars = ['LRT', 'RRT'],
                  )
df_plot.columns = ['experiment', 'condition', 'sub_name', 'side', 'RT']
df_plot['side'] = df_plot['side'].map({'LRT':'left','RRT':'right'})

results['LI'] = (results['LRT'] - results['RRT']) / (results['LRT'] + results['RRT'])


# plot figure 3 RT
figure3_csv_name = os.path.join(results_dir,'for_figure3_RT.csv')
df_figure_3 = df_plot[df_plot['condition'] == 'hum']
df_figure_3.loc[:,'experiment'] = df_figure_3['experiment'].map({'experiment1':'Exp. 1',
                                                                 'experiment2':'Exp. 2',})
df_figure_3.to_csv(figure3_csv_name,index = False)

#fig,ax = plt.subplots(figsize = (10,8))
#ax = sns.barplot(x = 'experiment',
#                 y = 'RT',
#                 hue= 'side',
#                 palette = {'left':'blue','right':'red'},
#                 data = df_figure_3,
#                 ax = ax,
#                 capsize = .1,)
#ax.set(ylim =(0,2.7),)
#ax.legend(loc = 'upper right')
#sns.despine()
#fig.savefig(os.path.join(figures_dir,'figure 3 RT.jpeg'),
#            dpi = 300,
#            bbox_inches = 'tight',)


# plot figure 4 RT
figure4_csv_name = os.path.join(results_dir,'for_figure4_RT.csv')
df_figure_4 = df_plot[df_plot['experiment'] == 'experiment2']
df_figure_4 = pd.concat([df_figure_4[df_figure_4['condition'] == condition] for condition in ['hum','tone','gi','di']])
df_figure_4.loc[:,'condition'] = df_figure_4['condition'].map({'hum':'Hummed\ntones',
                                                               'tone':'Simple vowel\ntones',
                                                               'gi':'CV Pseudo-word\ntones',
                                                               'di':'CV word\ntones'})
df_figure_4.to_csv(figure4_csv_name,index = False)
#df_figure_4['val'] = (df_figure_4['RT'] - df_figure_4['RT'].mean()) / df_figure_4['RT'].std()
#model = ols('val ~ C(condition)*C(side)', df_figure_4).fit()
#res = sm.stats.anova_lm(model, typ= 2)
#
#fig,ax = plt.subplots(figsize = (10,8))
#ax = sns.barplot(x = 'condition',
#                 y = 'RT',
#                 hue= 'side',
#                 palette = {'left':'blue','right':'red'},
#                 data = df_figure_4,
#                 ax = ax,
#                 capsize = .1,)
#ax.set(ylim =(0,2.7),)
#ax.legend(loc = 'upper right')
#ax.set_xticklabels(ax.xaxis.get_majorticklabels(),
#                   rotation = -35, 
#                   ha = 'center')
#sns.despine()
#fig.savefig(os.path.join(figures_dir,'figure 4 RT.jpeg'),
#            dpi = 300,
#            bbox_inches = 'tight',)

# plot figure 5 RT
figure5_csv_name = os.path.join(results_dir,'for_figure5_RT.csv')
df_figure_5 = results[results['experiment'] == 'experiment2'].reset_index()
df_figure_5['n_condition'] = df_figure_5['condition'].map({'hum':0,
                                                           'tone':1,
                                                           'gi':2,
                                                           'di':3})
df_figure_5['adjust'] = df_figure_5['condition'].map({'hum':-2,
                                                       'tone':-1,
                                                       'gi':1,
                                                       'di':2})
df_figure_5['adjust_LI'] = df_figure_5['LI'] * df_figure_5['adjust']
df_figure_5.loc[:,'condition'] = df_figure_5['condition'].map({'hum':'Hummed\ntones',
                                                               'tone':'Simple vowel\ntones',
                                                               'gi':'CV Pseudo-word\ntones',
                                                               'di':'CV word\ntones'})
df_figure_5.to_csv(figure5_csv_name,index = False)























