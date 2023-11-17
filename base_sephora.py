#!/usr/bin/env python
# coding: utf-8

# In[63]:


import pandas as pd
import matplotlib.pyplot as plt


# In[64]:


# Importa cadastro de produtos
df_products = pd.read_csv("product_info.csv")


# In[65]:


df_products.head(1)


# In[66]:


# Remove colunas desnecessárias
df_products = df_products[['product_id','brand_name','loves_count','online_only', 'out_of_stock', 'primary_category','secondary_category']]


# In[67]:


# Importa os 5 arquivos de reviews
df_review_1 = pd.read_csv("reviews_0-250.csv",low_memory=False)
df_review_2 = pd.read_csv("reviews_250-500.csv", low_memory=False)
df_review_3 = pd.read_csv("reviews_500-750.csv",low_memory=False)
df_review_4 = pd.read_csv("reviews_750-1250.csv", low_memory=False)
df_review_5 = pd.read_csv("reviews_1250-end.csv",low_memory=False)


# In[68]:


# Concatena os 5 dataframes com as reviews em apenas um df
df_review = df_review_1._append(df_review_2)
df_review = df_review._append(df_review_3)
df_review = df_review._append(df_review_4)
df_review = df_review._append(df_review_5)


# In[69]:


# Remove colunas desnecessárias
df_review = df_review[['rating','skin_tone','eye_color','skin_type','product_id','price_usd']]


# In[70]:


# Merge das reviews com o cadastro de produtos
df_review = df_review.merge(df_products, left_on='product_id', right_on='product_id')


# In[71]:


# Exporta o DataFrame em csv para análises em ferramentas de Bi
df_review.to_csv('reviews.csv', sep=';', index=False)


# In[72]:


df_review.head(1)


# In[73]:


loves_count = df_review[['product_id','brand_name', 'loves_count', 'primary_category','secondary_category', 'out_of_stock']]


# In[74]:


loves_count.drop_duplicates()


# In[106]:


loved_category = loves_count[['loves_count', 'secondary_category']]
loved_category = loved_category.groupby("secondary_category")['loves_count'].sum().reset_index()
least_loved_category = loved_category.sort_values(by='loves_count', ascending=[True])
loved_category = loved_category.sort_values(by='loves_count', ascending=[False])
loved_category = loved_category[:5]
least_loved_category = least_loved_category[:5]


# In[110]:


print(f"As categorias MAIS favoritadas no site são: \n{loved_category[['secondary_category']]}")


# In[113]:


print(f"As categorias MENOS favoritadas no site são: \n{least_loved_category[['secondary_category']]}")

