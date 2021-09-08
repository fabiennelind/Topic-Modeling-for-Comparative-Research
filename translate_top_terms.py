# coding: utf-8
from word2word import Word2word
import pandas as pd
import os
import glob

# define functions to translate words
def en2es_ex(text):
    try:
        b = en2es(text, n_best=1)
        return b[0]
    except:
        return "Term Not Detected"
    
def en2de_ex(text):
    try:
        b = en2de(text, n_best=1)
        return b[0]
    except:
        return "Term Not Detected"

def es2en_ex(text):
    try:
        b = es2en(text, n_best=1)
        return b[0]
    except:
        return "Term Not Detected"   

def es2de_ex(text):
    try:
        b = es2de(text, n_best=1)
        return b[0]
    except:
        return "Term Not Detected"   
        
def de2en_ex(text):
    try:
        text = text.title() #capitalize the first letter of a word (this is the way it is stored in the bilingual dict)
        b = de2en(text, n_best=1)
        return b[0]
    except:
        return "Term Not Detected"

def de2es_ex(text):
    try:
        text = text.title()
        b = de2es(text, n_best=1)
        return b[0]
    except:
        return "Term Not Detected"   

# initialize dictionaries
en2es = Word2word("en", "es")
en2de = Word2word("en", "de")
es2en = Word2word("es", "en")
es2de = Word2word("es", "de")
de2en = Word2word("de", "en")
de2es = Word2word("de", "es")

# set paths
path = f'~/mallet-2.0.8/translate_terms/input'
all_files = glob.glob(os.path.join(path, '*.csv'))

# load data
df_from_each_file = (pd.read_csv(f) for f in all_files)
df = pd.concat(df_from_each_file, ignore_index=True)

# subset per language
de = df.loc[df['language'] == 0]
en = df.loc[df['language'] == 1]
es = df.loc[df['language'] == 2]

# loop over top words
for tw in ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10']:
    top_word = f'top_word_{tw}'

    # translate
    en[f'top_word_mt_de_{tw}'] = en[top_word].apply(en2de_ex)
    en[f'top_word_mt_es_{tw}'] = en[top_word].apply(en2es_ex)

    es[f'top_word_mt_en_{tw}'] = es[top_word].apply(es2en_ex)
    es[f'top_word_mt_de_{tw}'] = es[top_word].apply(es2de_ex)

    de[f'top_word_mt_en_{tw}'] = de[top_word].apply(de2en_ex)
    de[f'top_word_mt_es_{tw}'] = de[top_word].apply(de2es_ex)

# combine data
df_new = pd.concat([en,es,de])
# save data
df_new.to_csv('/mallet-2.0.8/translate_terms/output/results.csv', index=False, header=True)

