## Utilizando R BASE

# Importa o arquivo
df <- read.csv("students_performance.csv", header = TRUE, stringsAsFactors = FALSE)

# Renomeia as colunas
names(df)[6] <- "math_score"
names(df)

# Configura a quantidade de painéis na tela
par(mfrow = c(1,3))

#Gera os gráficos em R BASE
hist(df$math_score,
     col = "#FFEFD5",
     main = 'Concentração das notas de Matemática',
     xlab = 'Nota',
     ylab = 'Quantidade de alunos',
     breaks = 20,
     horiz = TRUE)

boxplot(math_score ~ gender, data = df, 
        xlab = "Gênero", ylab = "Nota", 
        col = c("pink", "blue"), 
        ylim = c(10,100), 
        main = "Apresenta a Média das notas de Matemática por gênero")

boxplot(df$math_score ~ etnicity,  data = df,
        main = "Distribuição das Notas de Matemática por Etnia",
        ylim = c(10,100),
        ylab = "Nota", 
        col = "grey")

savePlot( filename = "exn106_graph1.pdf", type = "pdf" )

dev.print( device = pdf, file = "exn106_graph1.pdf")
dev.off() 


## Utilizando ggplot

# Importa o arquivo
df <- read.csv("students_performance.csv", header = TRUE, stringsAsFactors = FALSE)

install.packages('ggplot2')
library(ggplot2)

install.packages('gridExtra')
library(gridExtra)

names(df)[6] <- "math_score"
names(df)[7] <- "reading_score"
names(df)[8] <- "writing_score"
names(df)

# Gera os gráficos sem configuracoes
plot1 <- ggplot(df, aes(math_score)) + geom_bar()
plot2 <- ggplot(df, aes(reading_score)) + geom_bar()
plot3 <- ggplot(df, aes(writing_score)) + geom_bar()

# Divide em 3 painéis
df_pdf <- grid.arrange(plot1, plot2,plot3,ncol=3)

# Salva em pdf os 3 gráficos
ggsave("exn106_graph2.pdf", device = "pdf")

# Gera os gráficos com configuracoes
plot1 <- ggplot(df, aes(math_score)) +
  geom_bar(col='#E0FFFF') +
  xlab('Math Score') +
  ylab('Count Students') +
  labs(title = "Students for Math Score") +
  labs(subtitle = "Grouped by score") +
  labs(caption = "(based on data from Kaggle)")

plot2 <- ggplot(df, aes(reading_score))+
  geom_bar(col='#FFE4E1') +
  xlab('Reading Score') +
  ylab('Count Students') +
  labs(title = "Students for Reading Score") +
  labs(subtitle = "Grouped by score") +
  labs(caption = "(based on data from Kaggle)")

plot3 <- ggplot(df, aes(writing_score))+
  geom_bar(col='#000000', fill="#D3D3D3") +
  xlab('Writing Score') +
  ylab('Count Students') +
  labs(title = "Students for Writing Score") +
  labs(subtitle = "Grouped by score") +
  labs(caption = "(based on data from Kaggle)") +
  theme(panel.grid.major = element_line(colour = "#D3D3D3"))

# Divide em 3 painéis
df_pdf <- grid.arrange(plot1, plot2,plot3,ncol=3)

# Salva em pdf os 3 gráficos
ggsave("exn106_graph3.pdf", device = "pdf")

