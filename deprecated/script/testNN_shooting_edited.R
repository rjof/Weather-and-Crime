library(neuralnet)
library(nnet)

#process arguments passed into the script
args <- commandArgs(trailingOnly = TRUE)

print("===processing input parameters====")

if(length(args) != 6){
  print("[Error] Invalid Input Parameters")
  quit()
}

print("=========crime type=============")
print(args[1])
crimeType = args[1]

print("===directory to input testing data===")
print(args[2])
testingDataDir = args[2]

print("===directory to input model=======")
print(args[3])
modelDir = args[3]

print("===directory to output prediction=======")
print(args[4])
predictionDir = args[4]


print("======number of Bagged Samples=====")
print(args[5])
# This is actually the number of models to iterate over
numOfBaggedSamples = as.integer(args[5])

print("===test file to process===")
print(args[6])
testingFile = args[6]

print("===test iteration to log output===")
#print(args[7])
#testIteration = args[7]

#load testing data
print("loading testing data")

#testingData = readRDS(file = paste(testingDataDir,"/.testingData.rds",sep = ""))
#testingData = read.csv(file = paste(testingDataDir,"WeatherandCrime_Data_Testing_Binned.csv", sep=""))
#testingData = read.csv(file = paste(testingDataDir,"Test.csv", sep=""))
testingData = read.csv(file = paste(testingDataDir,testingFile,sep=""))

print("Done.")

#load original forecast data
#print("loading original forecast data")
#forecastData = readRDS(file = paste(testingDataDir,"/.originalForecastData.rds",sep = ""))
#forecastData = read.csv(paste(testingDataDir, "WeatherandCrime_Data.shooting.",indexOfBaggedSamples,".binned.\
#csv",sep=""))


## Create a thin dataframe of only the crime counts, and we'll append on the forecast # of crimes
myvars <- c("census_tra")
forecastData = testingData[myvars]


#Create a new column to hold all the predictions
forecastData$prediction = 0
forecastData$census_tra <- NULL
#Making prediciton using different Neural net


print("Start predicting....")

# Create an aggregate prediction, that will show the total number of models that predict a crime
for (i in c(1:numOfBaggedSamples)){

  clone_testingData = testingData
  # The model is tied to the columns used in the file to generate it
  # Add / NA-out columns in clone_testingData as needed
  #load in i bagged sample to add columns for predictors used in i NN that are not in testingData (ie month of june)
  baggedData = read.csv(paste(testingDataDir, "WeatherandCrime_Data.shooting.",i,".binned.csv",sep=""), nrows=1)
  baggednames = names(baggedData)
  testingnames = names(clone_testingData)
  newtestingnames = setdiff(baggednames, testingnames)
  clone_testingData[newtestingnames]= 0
  trainedNN = try(readRDS(file = paste(modelDir, "/._NNmodel_", i, ".rds", sep = "")))
  if(inherits(trainedNN, "try-error")){
    next
  }
  print (paste(i,"read rds"))
  extratrainingnames = setdiff(testingnames, baggednames)
  clone_testingData[extratrainingnames] = NA

  predictedResult = predict(trainedNN, clone_testingData,type = "raw")
  forecastData$prediction = forecastData$prediction + predictedResult
  rm(clone_testingData)
  gc()
}

#Average all different predictions
forecastData$prediction = forecastData$prediction/ numOfBaggedSamples
forecastData$predictionBinary = forecastData$prediction
forecastData$predictionBinary[forecastData$prediction>=0.5] = 1
forecastData$predictionBinary[forecastData$prediction<0.5] = 0

print("Done.")

print("Saving prediction file...")

#Save prediction to csv file
write.csv(forecastData, file = paste(predictionDir,"prediction_shooting.csv",sep = ""),row.names = FALSE)
print("Done.") 
