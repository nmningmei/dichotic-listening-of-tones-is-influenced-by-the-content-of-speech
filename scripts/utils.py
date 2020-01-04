#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec  8 17:07:19 2019

@author: nmei
"""
import numpy as np
import pandas as pd
from scipy import stats

def resample_ttest(x,baseline = 0.5,n_ps = 100,n_permutation = 10000,one_tail = False,
                   n_jobs = 12, verbose = 0):
    """
    http://www.stat.ucla.edu/~rgould/110as02/bshypothesis.pdf
    https://www.tau.ac.il/~saharon/StatisticsSeminar_files/Hypothesis.pdf
    Inputs:
    ----------
    x: numpy array vector, the data that is to be compared
    baseline: the single point that we compare the data with
    n_ps: number of p values we want to estimate
    one_tail: whether to perform one-tailed comparison
    """
    import numpy as np
    # t statistics with the original data distribution
    t_experiment = (np.mean(x) - baseline) / (np.std(x) / np.sqrt(x.shape[0]))
    null            = x - np.mean(x) + baseline # shift the mean to the baseline but keep the distribution
    from joblib import Parallel,delayed
    import gc
    gc.collect()
    def t_statistics(null,size,):
        """
        null: shifted data distribution
        size: tuple of 2 integers (n_for_averaging,n_permutation)
        """
        null_dist = np.random.choice(null,size = size,replace = True)
        t_null = (np.mean(null_dist,0) - baseline) / (np.std(null_dist,0) / np.sqrt(null_dist.shape[0]))
        if one_tail:
            return ((np.sum(t_null >= t_experiment)) + 1) / (size[1] + 1)
        else:
            return ((np.sum(np.abs(t_null) >= np.abs(t_experiment))) + 1) / (size[1] + 1) /2
    ps = Parallel(n_jobs = n_jobs,verbose = verbose)(delayed(t_statistics)(**{
                    'null':null,
                    'size':(null.shape[0],int(n_permutation)),}) for i in range(n_ps))
    
    return np.array(ps)
def resample_ttest_2sample(a,b,n_ps=100,n_permutation = 10000,
                           one_tail=False,
                           match_sample_size = True,
                           n_jobs = 6,
                           verbose = 0):
    # when the samples are dependent just simply test the pairwise difference against 0
    # which is a one sample comparison problem
    if match_sample_size:
        difference  = a - b
        ps          = resample_ttest(difference,baseline=0,
                                     n_ps=n_ps,n_permutation=n_permutation,
                                     one_tail=one_tail,
                                     n_jobs=n_jobs,
                                     verbose=verbose,)
        return ps
    else: # when the samples are independent
        t_experiment,_ = stats.ttest_ind(a,b,equal_var = False)
        def t_statistics(a,b):
            group = np.random.choice(np.concatenate([a,b]),size = int(len(a) + len(b)),replace = True)
            new_a = group[:a.shape[0]]
            new_b = group[a.shape[0]:]
            t_null,_ = stats.ttest_ind(new_a,new_b,equal_var = False)
            return t_null
        from joblib import Parallel,delayed
        import gc
        gc.collect()
        ps = np.zeros(n_ps)
        for ii in range(n_ps):
            t_null_null = Parallel(n_jobs = n_jobs,verbose = verbose)(delayed(t_statistics)(**{
                            'a':a,
                            'b':b}) for i in range(n_permutation))
            if one_tail:
                ps[ii] = ((np.sum(t_null_null >= t_experiment)) + 1) / (n_permutation + 1)
            else:
                ps[ii] = ((np.sum(np.abs(t_null_null) >= np.abs(t_experiment))) + 1) / (n_permutation + 1) / 2
        return ps

class MCPConverter(object):
    import statsmodels as sms
    """
    https://gist.github.com/naturale0/3915e2def589553e91dce99e69d138cc
    https://en.wikipedia.org/wiki/Holm%E2%80%93Bonferroni_method
    input: array of p-values.
    * convert p-value into adjusted p-value (or q-value)
    """
    def __init__(self, pvals, zscores = None):
        self.pvals                    = pvals
        self.zscores                  = zscores
        self.len                      = len(pvals)
        if zscores is not None:
            srted                     = np.array(sorted(zip(pvals.copy(), zscores.copy())))
            self.sorted_pvals         = srted[:, 0]
            self.sorted_zscores       = srted[:, 1]
        else:
            self.sorted_pvals         = np.array(sorted(pvals.copy()))
        self.order                    = sorted(range(len(pvals)), key=lambda x: pvals[x])
    
    def adjust(self, method           = "holm"):
        import statsmodels as sms
        """
        methods = ["bonferroni", "holm", "bh", "lfdr"]
         (local FDR method needs 'statsmodels' package)
        """
        if method is "bonferroni":
            return [np.min([1, i]) for i in self.sorted_pvals * self.len]
        elif method is "holm":
            return [np.min([1, i]) for i in (self.sorted_pvals * (self.len - np.arange(1, self.len+1) + 1))]
        elif method is "bh":
            p_times_m_i = self.sorted_pvals * self.len / np.arange(1, self.len+1)
            return [np.min([p, p_times_m_i[i+1]]) if i < self.len-1 else p for i, p in enumerate(p_times_m_i)]
        elif method is "lfdr":
            if self.zscores is None:
                raise ValueError("Z-scores were not provided.")
            return sms.stats.multitest.local_fdr(abs(self.sorted_zscores))
        else:
            raise ValueError("invalid method entered: '{}'".format(method))
            
    def adjust_many(self, methods = ["bonferroni", "holm", "bh", "lfdr"]):
        if self.zscores is not None:
            df = pd.DataFrame(np.c_[self.sorted_pvals, self.sorted_zscores], columns=["p_values", "z_scores"])
            for method in methods:
                df[method] = self.adjust(method)
        else:
            df = pd.DataFrame(self.sorted_pvals, columns=["p_values"])
            for method in methods:
                if method is not "lfdr":
                    df[method] = self.adjust(method)
        return df

def change_width(ax,new_value):
    for patch in ax.patches:
        current_width = patch.get_width()
        diff = current_width - new_value
        # we change the bat width
        patch.set_width(new_value)
        # we recenter the bar
        patch.set_x(patch.get_x() + diff * .5)