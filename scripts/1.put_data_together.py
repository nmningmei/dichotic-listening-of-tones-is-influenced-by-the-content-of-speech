#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec  8 13:59:34 2019

@author: nmei
"""

import os
import re
from glob import glob
from scipy.io import loadmat
import pandas as pd
import numpy as np

working_dir = '../data'
data_dir = '../data/results_all'
working_data = glob(os.path.join(working_dir,'*','Dichotic*.mat'))

df_file = dict(experiment = [],
               condition = [],
               sub_name = [],
               file_to_read = [],)
for ii,f in enumerate(working_data):
    temp = f.split('/')
    experiment = 1 if temp[2] == 'result' else 2
    df_file['experiment'].append(experiment)
    df_file['condition'].append(temp[-1].split('Classic')[0][8:])
    df_file['sub_name'].append(100 * experiment + int(re.findall('\d+',temp[-1])[0]))
    df_file['file_to_read'].append(f)
df_file = pd.DataFrame(df_file)


for ii,row in df_file.iterrows():
    results = dict(experiment = [],
                   condition = [],
                   sub_name = [],
                   left = [],
                   right = [],
                   response = [],
                   RT = [],
                   )
    temp = loadmat(row['file_to_read'])['Output'][0,0]
    permutations = np.array([item[0] for item in temp[0][0]])
    responses = np.array(list(map(int,temp[1][0])))
    RT = temp[2][0]
    left = temp[3][0]
    right = temp[4][0]
    order = temp[-1][0]
    for left_,right_,responses_,RT_ in zip(left,right,responses,RT):
        results['experiment'].append(row['experiment'])
        results['condition'].append(row['condition'])
        results['sub_name'].append(row['sub_name'])
        results['left'].append(left_)
        results['right'].append(right_)
        results['response'].append(responses_)
        results['RT'].append(RT_)
    results_to_save = pd.DataFrame(results)
    results_to_save.to_csv(os.path.join(data_dir,
                                        f'experiment{row["experiment"]}_{row["condition"]}_{row["sub_name"]}.csv'),
        index = False)








































