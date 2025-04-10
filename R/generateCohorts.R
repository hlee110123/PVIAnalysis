#' Generate Cohorts
#'
#' @param connectionDetails Connection details for the database
#' @param cdmDatabaseSchema CDM database schema
#' @param cohortDatabaseSchema Cohort database schema
#' @param cohortTable Cohort table name
#'
#' @export
generateCohorts <- function(connectionDetails, cdmDatabaseSchema, cohortDatabaseSchema, cohortTable) {
  cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(system.file("cohorts", package = "PVIAnalysis"))

  CohortGenerator::generateCohortSet(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTable,
    cohortDefinitionSet = cohortDefinitionSet
  )
}
