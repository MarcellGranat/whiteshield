import numpy
import json
import sys
import pandas
from googletrans import Translator
import os
from tqdm import tqdm
import time

translator = Translator()
non_english_df = pandas.read_csv("foreign_language.csv")

if os.path.isdir('translation') == False:
  os.mkdir('translation')

if os.path.isdir('translation'):
  n_translated_sentences = len(os.listdir('translation')) * 1000
  non_english_df = non_english_df.iloc[n_translated_sentences:]

out=[]
file_name = 1

for element in tqdm(range(0, len(non_english_df['text']))):
  if element % 20 == 0:
      time.sleep(1)
  t = non_english_df.iloc[element,1]
  translation = '___still nothing___'
  n_error = 0
  while translation == '___still nothing___':
    try:
        translation = translator.translate(t, dest='en', src = "ar").text
    except:
        n_error += 1
        print("Error! Wait " + str(60*n_error) + "sec...")
        time.sleep(60*n_error)
        if n_error > 3:
          translation = "___fatal_error___"
          print("Fatal error :/")
  out.append(translation)
  if (element + 1) % 1000 == 0:
    df = pandas.DataFrame(out, columns=["translation"])
    df.to_csv('translation/translation' + str(file_name) + '.csv', index=False)
    file_name += 1
    out = []

