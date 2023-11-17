#!/usr/bin/env python
# coding: utf-8

# In[1]:


from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
import time


# In[12]:


servico = Service(ChromeDriverManager().install())

navegador = webdriver.Chrome(service=servico)


# In[13]:


navegador.get('https://blp.hashtagtreinamentos.com/black-friday/pg-inscricao-black-friday?src=lbf-email-8')


# In[14]:


navegador.find_element('xpath','//*[@id="botao-linkcomu-padrao1"]').click()
navegador.find_element('xpath','//*[@id="firstname"]').send_keys(input("Digite o seu primeiro nome: "))
navegador.find_element('xpath','//*[@id="email"]').send_keys(input("Digite o seu melhor e-mail: "))
navegador.find_element('xpath','//*[@id="field[59]"]').send_keys(input("Insira o DDD: "))
navegador.find_element('xpath','//*[@id="field[60]"]').send_keys(input("Insira o WhatsApp: "))
navegador.find_element('xpath','//*[@id="_form_6988_submit"]').click()


# In[ ]:




