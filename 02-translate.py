import numpy
import json
import sys
import pandas
from googletrans import Translator

translator = Translator()

language_df = pandas.read_csv("language.csv")

non_english_df = language_df.loc[language_df['language'] != 'english']

out=[]

for element in range(0, len(non_english_df['text'])):
    t = non_english_df['text'][element]
    translation = translator.translate(t, dest='en', src = "ar") # FIXME
    out.append(translation)
    
df = pandas.DataFrame(out, columns=["translation"])
df.to_csv('translation.csv', index=False)


