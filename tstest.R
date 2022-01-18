library(ggplot2)
df <- read.csv('data.csv')
head(df)
ggplot(df,aes('Time','Temperature'))+geom_smooth()


