# -*- coding: utf-8 -*-
"""
Author: Andrew Burns
Created Date: March 2, 2025
Updated Date: March 7, 2025
"""
from pathlib import Path
from lxml import html
from lxml.html.clean import clean_html

dataset = []

# Directory containing the HTML files
directory = Path(r'C:\git\eviewshelp\chm\test')

# Loop through all .html files in the directory
for html_file in directory.glob('*program*.html'):
    with open(html_file, 'r', encoding='utf-8') as file:
        content = file.read()   
    print(f"Read file: {html_file.name}")  # Optional: Display file name
    parsed_html = html.fromstring(content)
# Clean the HTML
    cleaned_html = clean_html(parsed_html)
# Extract text content
    content= cleaned_html.text_content().strip()
#dataset = clean_html(dataset).text_content().strip()
    print(f'Loaded {len(content)} entries')
    dataset+=" "+content

#%%Begin program
import ollama

EMBEDDING_MODEL = 'hf.co/CompendiumLabs/bge-base-en-v1.5-gguf'
LANGUAGE_MODEL = 'hf.co/bartowski/Llama-3.2-1B-Instruct-GGUF'

# Each element in the VECTOR_DB will be a tuple (chunk, embedding)
# The embedding is a list of floats, for example: [0.1, 0.04, -0.34, 0.21, ...]
VECTOR_DB = []
#%% routines
def add_chunk_to_database(chunk):
  embedding = ollama.embed(model=EMBEDDING_MODEL, input=chunk)['embeddings'][0]
  VECTOR_DB.append((chunk, embedding))
  
def cosine_similarity(a, b):
  dot_product = sum([x * y for x, y in zip(a, b)])
  norm_a = sum([x ** 2 for x in a]) ** 0.5
  norm_b = sum([x ** 2 for x in b]) ** 0.5
  return dot_product / (norm_a * norm_b)

def retrieve(query, top_n=3):
  query_embedding = ollama.embed(model=EMBEDDING_MODEL, input=query)['embeddings'][0]
  # temporary list to store (chunk, similarity) pairs
  similarities = []
  for chunk, embedding in VECTOR_DB:
    similarity = cosine_similarity(query_embedding, embedding)
    similarities.append((chunk, similarity))
  # sort by similarity in descending order, because higher similarity means more relevant chunks
  similarities.sort(key=lambda x: x[1], reverse=True)
  # finally, return the top N most relevant chunks
  return similarities[:top_n]
#%% process data
for i, chunk in enumerate(dataset):
  add_chunk_to_database(chunk)
  print(f'Added chunk {i+1}/{len(dataset)} to the database')

#%% save the   enumerated database
import pickle
  
def save_vector_db(filename='vector_db.pkl'):
    with open(filename, 'wb') as file:
        pickle.dump(VECTOR_DB, file)
    print(f"VECTOR_DB saved to {filename}")
    
def load_vector_db(filename='vector_db.pkl'):
    global VECTOR_DB
    with open(filename, 'rb') as file:
        VECTOR_DB = pickle.load(file)
    print(f"VECTOR_DB loaded from {filename}")

# Example call to load

#load_vector_db("EviewsInfo.pkl")    

# Example call to save
save_vector_db("EviewsInfo.pkl")
  
  
 #%% Do the magic
  
input_query = input('Ask me a question: ')
retrieved_knowledge = retrieve(input_query)

print('Retrieved knowledge:')
for chunk, similarity in retrieved_knowledge:
  print(f' - (similarity: {similarity:.2f}) {chunk}')

instruction_prompt = f'''You are a helpful chatbot.
Use only the following pieces of context to answer the question. Don't make up any new information:
{'\n'.join([f' - {chunk}' for chunk, similarity in retrieved_knowledge])}
'''

stream = ollama.chat(
  model=LANGUAGE_MODEL,
  messages=[
    {'role': 'system', 'content': instruction_prompt},
    {'role': 'user', 'content': input_query},
  ],
  stream=True,
)

# print the response from the chatbot in real-time
print('Chatbot response:')
for chunk in stream:
  print(chunk['message']['content'], end='', flush=True)     