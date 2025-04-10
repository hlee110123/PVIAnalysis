# PVIOutcomeAnalysis
PVIAnalysis is an R package for comparing outcomes between early and non-early Peripheral Vascular Intervention (PVI) using OMOP Common Data Model (CDM). This package enables reproducible research by encapsulating cohort definitions, data extraction, and statistical analysis.

# Overview
This package implements a reproducible cohort study that:

1. Generates two cohorts: Early PVI and Non-Early PVI
2. Extracts and analyzes three key outcomes: CLTI, repeated PVI, and major amputation
3. Provides statistical comparison between the two intervention strategies

# Installation
You can install the development version from GitHub:

```r
# Install devtools if not already installed
install.packages("devtools")

# Install PVIAnalysis
devtools::install_github("username/PVIAnalysis")
```

# Dependencies
This package requires:

* R (≥ 4.0.0)
* dplyr
* stats
* knitr
* broom
* SqlRender
* DatabaseConnector
* ParallelLogger
* CohortGenerator
* ROhdsiWebApi

These dependencies will be automatically installed when installing the package.

# How to run

## 1. Load the Package:
```r
library(PVIAnalysis)
```

## 2. Set up Connection Details:
```r
# Connect to the database
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "sql server",
  server = Sys.getenv("server"),
  user = Sys.getenv("user"),
  password = Sys.getenv("password"),
  pathToDriver = "D:/pathToDriver")
```

## 3. Define Database Schemas and Table Names:

```r
cdmDatabaseSchema <- "your_cdm_schema"  # Replace with your CDM schema
cohortDatabaseSchema <- "your_cohort_schema"  # Replace with your cohort schema
cohortTable <- "your_cohort_table"  # Replace with your cohort table name
outputFolder <- "D:/PVIAnalysisOutput"  # Replace with desired output folder
```

## 4. Generate Cohorts:

```r
generateCohorts(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable
)
```

## 5. Generate Analysis Data:

```r
analysisData <- generateAnalysisData(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable
)

```
## 6. Analyze Outcomes and Output to CSV:

```r
analyzeOutcomes(analysisData, outputFileName = file.path(outputFolder, "outcome_comparison.csv"))
```


