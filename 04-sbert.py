import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.metrics.pairwise import euclidean_distances
from sentence_transformers import SentenceTransformer

sbert_model = SentenceTransformer('bert-base-nli-mean-tokens')

document_embeddings = sbert_model.encode(r.db['text'])

job_tasks = sbert_model.encode(r.ilo_stat_df['ISCO3Tasks'])
job_descriptions = sbert_model.encode(r.ilo_stat_df['ISCO3Description'])
job_merged = sbert_model.encode(r.ilo_stat_df['ISCO3_merged'])

pairwise_similarities_task=cosine_similarity(job_tasks, document_embeddings)
pairwise_similarities_desc=cosine_similarity(job_descriptions, document_embeddings)
pairwise_similarities_merged=cosine_similarity(job_merged, document_embeddings)

bert_task = pd.DataFrame(pairwise_similarities_task)
bert_desc = pd.DataFrame(pairwise_similarities_desc)
bert_merged = pd.DataFrame(pairwise_similarities_merged)
