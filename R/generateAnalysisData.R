#' Generate Analysis Data
#'
#' @param connectionDetails Connection details for the database
#' @param cdmDatabaseSchema CDM database schema
#' @param cohortDatabaseSchema Cohort database schema
#' @param cohortTable Cohort table name
#'
#' @export
generateAnalysisData <- function(connectionDetails, cdmDatabaseSchema, cohortDatabaseSchema, cohortTable) {
  sql <- readr::read_file(system.file("sql", "analysis_data.sql", package = "PVIAnalysis"))

  conn <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(conn))

  data <- DatabaseConnector::querySql(conn, sql, snakeCaseToCamelCase = TRUE)

  return(data)
}
