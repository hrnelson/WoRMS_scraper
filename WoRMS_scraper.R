## load relevant libraries
library(rvest)
library(stringr)

prefix <- "http://www.marinespecies.org/aphia.php?p=taxdetails&id="

#returns data frame with species contained within taxa (associated with WoRMS AphiaID #) provided
get_taxa <- function(AphiaID) {
  name <- get_name(AphiaID)
  rank <- get_rank(AphiaID)
  parents <- as.data.frame(cbind(name, AphiaID))
  names(parents)[1] <- rank
  names(parents)[2] <- "id"
  parents[] <- lapply(parents, as.character)
  
  while (rank != "Species") {
    for (i in 1:nrow(parents)) {
      id <- as.character(parents$id[i])
      children <- get_children(id)
      if (is.data.frame(children)) {
        rank <- as.character(children[1,1])
        children <- children[,-1]
        names(children)[1] <- rank
        add <- cbind(parents[i,],children, row.names = NULL)
        add <- add[,-(ncol(add)-2)]
        if (exists("new_parents")) {
          new_parents <- rbind(new_parents,add)
        } else {
          new_parents <- add
        }
      }
    }
    parents <- new_parents
    rank <- names(new_parents)[ncol(add)-1]
    rm(new_parents)
  }
  return(parents)
}

#returns scientific name associated with WorMS AphiaID #
get_name <- function(AphiaID) {
  url <- paste(prefix,AphiaID,sep="")
  webpage <- read_html(url)
  name <- webpage %>%
    html_nodes("b") %>%
    html_text()
  name <- name[1]
  return(name)
}

#returns rank associated with WorMS AphiaID #
get_rank <- function(AphiaID){
  url <- paste(prefix,AphiaID,sep="")
  webpage <- read_html(url)
  rank <- webpage %>%
    html_nodes("#Rank") %>%
    html_text()
  rank <- gsub("\\s", "", rank)
}

#returns direct children associated with WorMS AphiaID #
get_children <- function(AphiaID) {
  
  #get children
  url <- paste(prefix,AphiaID,sep="")
  webpage <- read_html(url)
  children <- webpage %>%
    html_nodes(".aphia_core_pb-3") %>%
    html_text()
  
  #clean up children
  children <- as.data.frame(str_split(children, " ", n = 2))
  children <- as.data.frame(t(children)) #transpose data frame
  rownames(children) <- c()
  children <- children[!grepl("no longer in use",children[,2]),] #delete no longer in use
  children <- children[!grepl("nomen dubium",children[,2]),] #delete nomen dubium
  children <- children[!grepl("nomen nudum",children[,2]),] #delete nomen nudum
  children <- children[!grepl("unaccepted",children[,2]),] #delete unaccepted
  children <- children[!grepl("accepted as",children[,2]),] #delete anything accepted as something else
  
  if (nrow(children) == 0) {
    children <- "NA"
  }
  else {#add AphiaID of children
    names(children) <- c("rank", "name")
    children <- cbind(children, id = 0) #add row for AphiaID, initialize as 0
    if (children[1,1] != "Species") { #only get AphiaID if not species 
      #paste here
      s <- html_session(url)
      for (i in 1:nrow(children)) {
        #get AphiaID
        child_page <- s %>% follow_link(as.character(children[i,2])) %>% read_html()
        id <- child_page %>%
          html_nodes(".aphia_core_break-words") %>%
          html_text()
        
        #clean up AphiaID
        id <- gsub("\\D", "", as.data.frame(str_split(id, "u", n = 2))[1,1])
        
        #store AphiaID
        children[i,3] <- id
        
        #convert dataframe to characters
        children[] <- lapply(children, as.character)
      }
    }
  }
  return (children) 
}

taxa <- get_taxa(1839) #replace 1839 with relevant AphiaID

## clean up file
taxa <- taxa[,-ncol(taxa)] #remove id column
for (i in 1:ncol(taxa)) {
  replace <- taxa[,i]
  replace <- paste0(replace," ")
  if (i == ncol(taxa)) { #species column
    replace <- as.data.frame(str_split(replace, " ", n = 3))
    replace <- t(replace) 
    rownames(replace) <- c()
    replace <- paste(replace[,1],replace[,2])
  } else { #not species column
    replace <- as.data.frame(str_split(replace, " ", n = 2))
    replace <- t(replace) 
    rownames(replace) <- c()
    replace <- replace[,1]
  }
  taxa[,i] <- replace
}

## export datagrame to csv file
write.csv(taxa, file = "taxa.csv", row.names = FALSE)
