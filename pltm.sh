#!/bin/bash

# set path to folder containing mallet
cd /path/to/mallet/folder/mallet-2.0.8

# 1: prepare sequences for aligned and unaligned data in different languages
for lang in de en es
do
    gv_input="my_data/gv_tuples/${lang}.txt"
    seq_out="sequences/${lang}_sequences"
    stopwords="stoplists/reminder_stopwords_${lang}.txt"
    unaligned_input="my_data/unaligned/unaligned_${lang}.txt"
    unaligned_seq_output="sequences/${lang}_UNALIGNED_sequences"
    # prepare sequences for aligned data
    bin/mallet import-file --input ${gv_input} --output ${seq_out} --keep-sequence --token-regex '\p{L}+' --print-output --extra-stopwords ${stopwords} --remove-stopwords
    # prepare sequences for unaligned data using the sequence from the aligned data
    bin/mallet import-file --input ${unaligned_input} --output ${unaligned_seq_output} --keep-sequence --token-regex '\p{L}+' --print-output --extra-stopwords ${stopwords} --remove-stopwords --use-pipe-from ${seq_out}   
done

# train polylingual topic models for different k number of topics
for k in 5 10 15 20 25 30 35 40 45 50
do
    output_csv="output/${k}t_output.csv"
    output_model="output/${k}t_model.txt"
    output_inferencer="output/${k}t_inferencer"
    # train model for k topics: use aligned sequences (for all languages), create topic-keys, model and inferencer output
    bin/mallet run cc.mallet.topics.PolylingualTopicModel --language-inputs sequences/de_sequences sequences/en_sequences sequences/es_sequences  --num-topics ${k}   --num-top-words 25 --random-seed 124 --optimize-interval 10 --optimize-burn-in 20 --num-iterations 2000 --output-topic-keys ${output_csv} --output-model ${output_model} --inferencer-filename ${output_inferencer}
done

# 3: predict probabilites per document in unaligned data for different k number of topics per language
for k in 5 10 15 20 25 30 35 40 45 50
do
    csv_out_0="output/csv_data/${k}_de_probabilities.csv"
    csv_out_1="output/csv_data/${k}_en_probabilities.csv"
    csv_out_2="output/csv_data/${k}_es_probabilities.csv"

    inf_0="output/${k}t_inferencer.0"
    inf_1="output/${k}t_inferencer.1"
    inf_2="output/${k}t_inferencer.2"

    # predict probabilites: use sequence for unaligned data, inferencer per language, create document-topic output
    bin/mallet infer-topics --input sequences/de_UNALIGNED_sequences --inferencer ${inf_0} --output-doc-topics ${csv_out_0} 
    bin/mallet infer-topics --input sequences/en_UNALIGNED_sequences --inferencer ${inf_1} --output-doc-topics ${csv_out_1} 
    bin/mallet infer-topics --input sequences/es_UNALIGNED_sequences --inferencer ${inf_2} --output-doc-topics ${csv_out_2} 
done