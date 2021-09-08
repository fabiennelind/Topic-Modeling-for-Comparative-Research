# Topic-Modeling-for-Comparative-Research

This is the repository for the article: Building the bridge: Topic modeling for comparative research. The article is published in Communication Methods and Measures. http://dx.doi.org/10.1080/19312458.2021.1965973

We here provide instructions that faciliate the implementation of PLTM (Mimno et al., 2009) for projects. Our instructions build mainly on code, example ideas, and guidelines that can be accessed here http://mallet.cs.umass.edu/ and http://mallet.cs.umass.edu/topics-polylingual.php

# Motivation
PLTM can be used for projects that wish to derive topics for a multilingual corpus and different cases. It is useful to identify one topic model for the entire multilingual corpus, which allows the direct quantitative comparisons of topic probabilities across cases.


## Instructions

# Step 1: Create input data

- tuples (aligned data): Prepare one .txt file per language with texts that are topically-comparable across language. See "en.txt", "es.txt", "de.txt" in the folder my_data for an example. 
- unaligned data: Prepare one .txt file per language. See "unaligned.en.txt", "unaligned_es.txt", "unaligned_de.txt" in the folder my_data for an example. 

Pre-processing all texts as comparable as possible is recommended. The example files include the lemmatized versions of the texts.



# Step 2: Run PLTM 

Download and install mallet: see: http://mallet.cs.umass.edu/
Run the 'pltm.sh' file. Place the input data files in the 'my_data' folder. Place customized stopword lists (one .txt file per language, one word per line) in the folder stoplists. The folder structure is set up automatically when downloading mallet. 
The 'pltm.sh' script will perform the following steps:

- prepare sequences for aligned training (tuples)
- prepare sequences for unaligned corpus and use pipe from aligned data
- train pltm with aligned data = create inferencer per language, top words per topic (i.e., keys)
- calculate probabilities for sequences of unaligned data (full corpus) with trained inferencers

# Step 3: Evaluate output

To evalute the top words per topic per model, the metrics NMPI and MTA can be calculated.
We prepared the 'evaluation_steps.R' file to assist with both. Line 10-125 include the code for NMPI calculation. Line 132-280 the code for MTA calculation. At line  74, the instruction published here https://github.com/jhlau/topic_interpretability for the paper Lau et al. (2014) https://aclanthology.org/E14-1056 have to be followed as an intermediate step. On line 191 the python script 'translate_top_terms.py' have to be calculated as an intermediate step.

To evaluate the PLTM results further, we strongly recommend to compare the infered topic probabilities per document against ground truth. 



