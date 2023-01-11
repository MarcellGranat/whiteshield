import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.metrics.pairwise import euclidean_distances
from sentence_transformers import SentenceTransformer

sbert_model = SentenceTransformer('bert-base-nli-mean-tokens')

document_embeddings = sbert_model.encode(r.skills_words)

sentence_embeddings = sbert_model.encode(r.db_sentence['sentence'])

pairwise_similarities=cosine_similarity(sentence_embeddings, document_embeddings)

bert_skills = pd.DataFrame(pairwise_similarities)
