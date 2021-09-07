# Topic-Modeling-for-Comparative-Research

This is the repository for the article: Building the bridge: Topic modeling for comparative research. The article is accepted at Communication Methods and Measures. http://dx.doi.org/10.1080/19312458.2021.1965973

We here provide instructions that faciliate the implementation of PLTM (Mimno et al., 2009) for projects. Our instructions build mainly on code and guidelines that can be accessed here http://mallet.cs.umass.edu/ and http://mallet.cs.umass.edu/topics-polylingual.php

# Motivation
PLTM can be used for projects that wish to derive topics for a multilingual corpus and different cases. It is useful to identify one topic model for the entire multilingual corpus, which allows the direct quantitative comparisons of topic probabilities across cases.


## Instructions

# Step 1: Create input data

- tuples (aligned data)
- unaligned data

# Step 2: Run PLTM 

- prepare sequences for aligned training (tuples)
- prepare sequences for unaligned corpus and use pipe from aligned data
- train pltm = create inferencer per language, keys, model
- calculate probabilities for sequences of unaligned data (full corpus) with trained inferencers

# Step 3: Evaluate output

- keys (coherence = wie gut innerhalb sprache (nmpi), consistency = wie gut across sprachen (mta))
- topic probabilities per document (compare against ground truth / manual inspection)



