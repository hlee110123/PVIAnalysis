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
# Database Connection Setup
First, set up your database connection. Using environment variables is recommended for security:

```r
# Create an .Renviron file to store credentials
usethis::edit_r_environ()

# Add these lines to your .Renviron file:
# DB_SERVER=your_server
# DB_USER=your_username
# DB_PASSWORD=your_password
# JDBC_DRIVER_PATH=path/to/jdbc/drivers
```
# DatabaseConnector:
```r
library(PVIAnalysis)

# Connect to the database
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "sql server",
  server = Sys.getenv("DB_SERVER"),
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD"),
  pathToDriver = Sys.getenv("JDBC_DRIVER_PATH")
)
```

# Running the Complete Analysis

```r
# Define schemas and output location
cdmDatabaseSchema <- "your_cdm_schema"
cohortDatabaseSchema <- "your_results_schema"
cohortTable <- "your_cohortTable"
outputFolder <- "~/PVIResults"

# Run the complete analysis pipeline
results <- executePVIStudy(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outputFolder = outputFolder,
  createCohorts = TRUE  # Set to FALSE if cohorts already exist
)

# View results
print(results$analysisResults)
```

# Step-by-Step Analysis
For more control, you can run each component separately:

## 1. Generate Cohorts
```r
rcohortCounts <- generateCohorts(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outputFolder = file.path(outputFolder, "cohorts")
)

```

## 2. Extract Outcome Data
```r
routcomeData <- getOutcomeData(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outputFolder = file.path(outputFolder, "data")
)

```

## 3. Analyze Outcomes
```r
ranalysisResults <- analyzeOutcomes(
  outcomeData = outcomeData,
  outputFolder = file.path(outputFolder, "analysis")
)

# View results
print(analysisResults)
```
# Output Files
The analysis generates the following outputs:

* Results table (CSV): [outputFolder]/analysis/outcome_comparison_table.csv

