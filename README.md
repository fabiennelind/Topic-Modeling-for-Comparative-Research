# Topic-Modeling-for-Comparative-Research

This is the repository for the article: Building the bridge: Topic modeling for comparative research. The article is accepted at Communication Methods and Measures. http://dx.doi.org/10.1080/19312458.2021.1965973



# Create input data

- tuples (aligned data)
- unaligned data

# Run PLTM 

- prepare sequences for aligned training (tuples)
- prepare sequences for unaligned corpus and use pipe from aligned data
- train pltm = create inferencer per language, keys, model
- calculate probabilities for sequences of unaligned data (full corpus) with trained inferencers

# Evaluate output

- keys (coherence = wie gut innerhalb sprache (nmpi), consistency = wie gut across sprachen (mta))
- topic probabilities per document (compare against ground truth / manual inspection)



