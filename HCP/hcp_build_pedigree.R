
rm(list = ls()) #clear all variable
# read pedigree
myTwinData <- read.csv("/media/database1/Download/RESTRICTED_yassinebha_1_6_2015_14_22_6.csv", header=TRUE, na.strings="NaN")
allDup <- function (value) 
{ 
  duplicated(value) | duplicated(value, fromLast = TRUE) # function to detect non duplicated variable
}
summary(myTwinData)
myTwinData  <- myTwinData[allDup(myTwinData$Mother_ID),]  # remove non twins based on the familly id
summary(myTwinData)
# check for duplicated subject IDs
if (any(duplicated(myTwinData$Subject) == TRUE )) { warning( "the duplicated subjects ID are: \n" ,(myTwinData$id_scan[duplicated(myTwinData$id_scan)]),"\n") }
myTwinData <- myTwinData[!duplicated(myTwinData$id_scan),] # remove the dulicated subject
