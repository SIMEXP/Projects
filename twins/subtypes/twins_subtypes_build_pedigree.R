
rm(list = ls()) #clear all variable
path_csv = "/media/yassinebha/database11/github_repos/Projects/twins/script/models/twins_pedigre_raw_all.csv"
family_id = "nofamill"
allDup <- function (path_csv,family_id) 
{ 
  # read pedigree
  TwinData <- read.csv(path_csv, header=TRUE, na.strings="NaN")
  TwinData  <- TwinData[duplicated(TwinData[,family_id]) | duplicated(TwinData[,family_id], fromLast = TRUE),]# function to detect non duplicated variable
    summary(TwinData)
}


# check for duplicated subject IDs
if (any(duplicated(TwinData$id) == TRUE )) { warning( "the duplicated subjects ID are: \n" ,(myTwinData$id_scan[duplicated(myTwinData$id_scan)]),"\n") }
myTwinData <- myTwinData[!duplicated(TwinData$id),] # remove the dulicated subject

