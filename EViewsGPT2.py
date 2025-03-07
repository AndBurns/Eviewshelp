# -*- coding: utf-8 -*-
"""
Author: Andrew Burns
Created Date: March 2, 2025
Updated Date: March 7, 2025
"""
from pathlib import Path
from lxml import html
from lxml.html.clean import clean_html
import time
import re

dataset = []
executed_files = []  # List to store executed file names
skipped_files = []   # List to store skipped file names
first_match = True

# Directory containing the HTML files
directory = Path(r'C:\git\eviewshelp\PRG')

# Loop through all .html files in the directory
for html_file in directory.glob('*.PRG'):    
    # Skip files with 'snapshot' in their names
    if 'snapshot' in html_file.name.lower():
        skipped_files.append(html_file.name)  # Add to skipped list
        print(f"Skipped file: {html_file.name} (Contains 'snapshot')")
        continue  # Skip to the next iteration
    # Check if the filename ends with 5 digits and 'SOLVE.PRG'
    if re.match(r'.*\d{5}Solve.prg$', html_file.name):
        if first_match:
            with open(html_file, 'r', encoding='ISO-8859-1') as file:
                content = file.read()
            print(f"Read file: {html_file.name}")
            print(f'Loaded {len(content)} entries')
            dataset += " " + content
            executed_files.append(html_file.name)  # Add to executed list
            first_match = False  # After the first match, set to False
        else:
            skipped_files.append(html_file.name)  # Add to skipped list
            print(f"Skipped file: {html_file.name}")
    else:
        with open(html_file, 'r', encoding='ISO-8859-1') as file:
            content = file.read()
        print(f"Read file: {html_file.name}")
        print(f'Loaded {len(content)} entries')
        dataset += " " + content
        executed_files.append(html_file.name)  # Add to executed list


#for html_file in directory.glob('*.PRG'):    
#    with open(html_file, 'r',  encoding='ISO-8859-1') as file:
#        content = file.read()   
#    print(f"Read file: {html_file.name}")  
#    print(f'Loaded {len(content)} entries')
#    dataset+=" "+content

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
start_time = time.time()
for i, chunk in enumerate(dataset):
  add_chunk_to_database(chunk)
  if i % 100 == 0:  # Check if i is divisible by 100
      elapsed_time = time.time() - start_time
      # Format elapsed time in seconds
      elapsed_minutes = elapsed_time // 60
      elapsed_seconds = elapsed_time % 60
      print(f'Added chunk {i}/{len(dataset)} to the database, {100*i/len(dataset):.2f} complete, Elapsed time: {int(elapsed_minutes)}m {int(elapsed_seconds)}s')


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

#load_vector_db("EviewsPRG.pkl")    

# Example call to save
save_vector_db("Eviewsprg.pkl")
  
  
 #%% Do the magic
  
input_query = input('Ask me a question: ')
retrieved_knowledge = retrieve(input_query)

print('Retrieved knowledge:')
for chunk, similarity in retrieved_knowledge:
  print(f' - (similarity: {similarity:.2f}) {chunk}')

instruction_prompt = f'''You are a helpful chatbot.
Use only the following pieces of context to answer the question. Dont give answers based on programming languages other than EViews. Don't make up any new information:
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