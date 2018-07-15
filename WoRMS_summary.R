data <- read.csv("taxa.csv")

## number of species
#total
nrow(data)
#Order Aplousobranchia
nrow(data[grepl("Aplousobranchia",data[,2]),])
#Order Phlebobranchia
nrow(data[grepl("Phlebobranchia",data[,2]),])
#Order Stolidobranchia
nrow(data[grepl("Stolidobranchia",data[,2]),])

## number of genera
length(unique(data$Genus))

## export csv of genera
a <- unique(data$Genus)
a <- as.data.frame(a)
names(a) <- c("Genera")
write.csv(a, file = "genera.csv", row.names = FALSE)