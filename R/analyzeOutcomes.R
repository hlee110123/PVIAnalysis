#' Analyze Outcomes
#'
#' @param data Analysis data generated from generateAnalysisData
#'
#' @importFrom stats chisq.test median quantile sd t.test
#' @importFrom utils write.csv
#'
#' @export
analyzeOutcomes <- function(data) {
  # Function to calculate mean (SD) and median (IQR) for a numeric vector
  get_stats <- function(x) {
    mean_sd <- paste0(round(mean(x, na.rm = TRUE), 1), " (", round(sd(x, na.rm = TRUE), 1), ")")
    q25 <- quantile(x, 0.25, na.rm = TRUE)
    q75 <- quantile(x, 0.75, na.rm = TRUE)
    median_iqr <- paste0(round(median(x, na.rm = TRUE), 1), " (", round(q25, 1), "-", round(q75, 1), ")")

    return(list(mean_sd = mean_sd, median_iqr = median_iqr))
  }

  # Function to conduct t-test between two groups
  conduct_ttest <- function(data, var, group_var) {
    # Handle the case where there might not be enough data
    tryCatch({
      t_result <- t.test(data[[var]] ~ data[[group_var]])
      return(round(t_result$p.value, 3))
    }, error = function(e) {
      return("N/A")
    })
  }

  # Function to conduct chi-square test
  conduct_chisq <- function(data, var, group_var) {
    # Create contingency table
    cont_table <- table(data[[group_var]], data[[var]])

    # Handle the case where there might not be enough data
    tryCatch({
      chi_result <- chisq.test(cont_table)
      return(round(chi_result$p.value, 3))
    }, error = function(e) {
      return("N/A")
    })
  }

  # Assign the data to all_patients_df
  all_patients_df <- data

  # Define the groups
  early_pvi <- all_patients_df[all_patients_df$cohort_group == "Early PVI", ]
  non_early_pvi <- all_patients_df[all_patients_df$cohort_group == "Non-Early PVI", ]

  # Create results dataframe
  results <- data.frame(
    Metric = character(),
    Early_PVI = character(),
    Non_Early_PVI = character(),
    P_Value = character(),
    stringsAsFactors = FALSE
  )

  # Overall patient counts
  early_count <- nrow(early_pvi)
  non_early_count <- nrow(non_early_pvi)
  total_count <- early_count + non_early_count

  results <- rbind(results, data.frame(
    Metric = "Total Patients",
    Early_PVI = as.character(early_count),
    Non_Early_PVI = as.character(non_early_count),
    P_Value = "N/A"
  ))

  # Overall follow-up time
  early_followup_stats <- get_stats(early_pvi$follow_up_days)
  non_early_followup_stats <- get_stats(non_early_pvi$follow_up_days)

  results <- rbind(results, data.frame(
    Metric = "Follow-up time, Mean (SD), days",
    Early_PVI = early_followup_stats$mean_sd,
    Non_Early_PVI = non_early_followup_stats$mean_sd,
    P_Value = as.character(conduct_ttest(all_patients_df, "follow_up_days", "cohort_group"))
  ))

  results <- rbind(results, data.frame(
    Metric = "Follow-up time, Median (IQR), days",
    Early_PVI = early_followup_stats$median_iqr,
    Non_Early_PVI = non_early_followup_stats$median_iqr,
    P_Value = "N/A"  # No standard test for comparing IQRs
  ))

  # CLTI Outcome
  early_clti_count <- sum(early_pvi$had_clti)
  non_early_clti_count <- sum(non_early_pvi$had_clti)
  early_clti_pct <- round(early_clti_count / early_count * 100, 1)
  non_early_clti_pct <- round(non_early_clti_count / non_early_count * 100, 1)

  results <- rbind(results, data.frame(
    Metric = paste("CLTI, n (%)"),
    Early_PVI = paste0(early_clti_count, " (", early_clti_pct, "%)"),
    Non_Early_PVI = paste0(non_early_clti_count, " (", non_early_clti_pct, "%)"),
    P_Value = as.character(conduct_chisq(all_patients_df, "had_clti", "cohort_group"))
  ))

  # Time to CLTI
  if(early_clti_count > 0 && non_early_clti_count > 0) {
    early_clti_time_stats <- get_stats(early_pvi$days_to_clti[early_pvi$had_clti == 1])
    non_early_clti_time_stats <- get_stats(non_early_pvi$days_to_clti[non_early_pvi$had_clti == 1])

    results <- rbind(results, data.frame(
      Metric = "Time to CLTI, Mean (SD), days",
      Early_PVI = early_clti_time_stats$mean_sd,
      Non_Early_PVI = non_early_clti_time_stats$mean_sd,
      P_Value = as.character(conduct_ttest(all_patients_df[all_patients_df$had_clti == 1, ], "days_to_clti", "cohort_group"))
    ))

    results <- rbind(results, data.frame(
      Metric = "Time to CLTI, Median (IQR), days",
      Early_PVI = early_clti_time_stats$median_iqr,
      Non_Early_PVI = non_early_clti_time_stats$median_iqr,
      P_Value = "N/A"
    ))
  }

  # PVI Outcome (Repeat PVI)
  early_pvi_count <- sum(early_pvi$had_pvi)
  non_early_pvi_count <- sum(non_early_pvi$had_pvi)
  early_pvi_pct <- round(early_pvi_count / early_count * 100, 1)
  non_early_pvi_pct <- round(non_early_pvi_count / non_early_count * 100, 1)

  results <- rbind(results, data.frame(
    Metric = paste("Repeat PVI, n (%)"),
    Early_PVI = paste0(early_pvi_count, " (", early_pvi_pct, "%)"),
    Non_Early_PVI = paste0(non_early_pvi_count, " (", non_early_pvi_pct, "%)"),
    P_Value = as.character(conduct_chisq(all_patients_df, "had_pvi", "cohort_group"))
  ))

  # Time to PVI
  if(early_pvi_count > 0 && non_early_pvi_count > 0) {
    early_pvi_time_stats <- get_stats(early_pvi$days_to_pvi[early_pvi$had_pvi == 1])
    non_early_pvi_time_stats <- get_stats(non_early_pvi$days_to_pvi[non_early_pvi$had_pvi == 1])

    results <- rbind(results, data.frame(
      Metric = "Time to Repeat PVI, Mean (SD), days",
      Early_PVI = early_pvi_time_stats$mean_sd,
      Non_Early_PVI = non_early_pvi_time_stats$mean_sd,
      P_Value = as.character(conduct_ttest(all_patients_df[all_patients_df$had_pvi == 1, ], "days_to_pvi", "cohort_group"))
    ))

    results <- rbind(results, data.frame(
      Metric = "Time to Repeat PVI, Median (IQR), days",
      Early_PVI = early_pvi_time_stats$median_iqr,
      Non_Early_PVI = non_early_pvi_time_stats$median_iqr,
      P_Value = "N/A"
    ))
  }

  # Amputation Outcome
  early_amp_count <- sum(early_pvi$had_amputation, na.rm = TRUE)
  non_early_amp_count <- sum(non_early_pvi$had_amputation, na.rm = TRUE)
  early_amp_pct <- round(early_amp_count / early_count * 100, 1)
  non_early_amp_pct <- round(non_early_amp_count / non_early_count * 100, 1)

  # Chi-square test for amputation counts
  amp_chisq_pvalue <- conduct_chisq(all_patients_df, "had_amputation", "cohort_group")

  results <- rbind(results, data.frame(
    Metric = paste("Major Amputation, n (%)"),
    Early_PVI = paste0(early_amp_count, " (", early_amp_pct, "%)"),
    Non_Early_PVI = paste0(non_early_amp_count, " (", non_early_amp_pct, "%)"),
    P_Value = as.character(amp_chisq_pvalue)
  ))

  # Extracting amputation-specific data
  early_amp_data <- early_pvi$days_to_amputation[early_pvi$had_amputation == 1]
  non_early_amp_data <- non_early_pvi$days_to_amputation[non_early_pvi$had_amputation == 1]

  # Time to Amputation - Make sure we calculate this regardless of counts
  if(length(early_amp_data) > 0 || length(non_early_amp_data) > 0) {
    # For Early PVI group
    if(length(early_amp_data) > 0) {
      early_amp_mean <- mean(early_amp_data, na.rm = TRUE)
      early_amp_sd <- sd(early_amp_data, na.rm = TRUE)
      early_amp_median <- median(early_amp_data, na.rm = TRUE)
      early_amp_q1 <- quantile(early_amp_data, 0.25, na.rm = TRUE)
      early_amp_q3 <- quantile(early_amp_data, 0.75, na.rm = TRUE)
      early_amp_mean_sd <- paste0(round(early_amp_mean, 1), " (", round(early_amp_sd, 1), ")")
      early_amp_median_iqr <- paste0(round(early_amp_median, 1), " (", round(early_amp_q1, 1), "-", round(early_amp_q3, 1), ")")
    } else {
      early_amp_mean_sd <- "N/A"
      early_amp_median_iqr <- "N/A"
    }

    # For Non-Early PVI group
    if(length(non_early_amp_data) > 0) {
      non_early_amp_mean <- mean(non_early_amp_data, na.rm = TRUE)
      non_early_amp_sd <- sd(non_early_amp_data, na.rm = TRUE)
      non_early_amp_median <- median(non_early_amp_data, na.rm = TRUE)
      non_early_amp_q1 <- quantile(non_early_amp_data, 0.25, na.rm = TRUE)
      non_early_amp_q3 <- quantile(non_early_amp_data, 0.75, na.rm = TRUE)
      non_early_amp_mean_sd <- paste0(round(non_early_amp_mean, 1), " (", round(non_early_amp_sd, 1), ")")
      non_early_amp_median_iqr <- paste0(round(non_early_amp_median, 1), " (", round(non_early_amp_q1, 1), "-", round(non_early_amp_q3, 1), ")")
    } else {
      non_early_amp_mean_sd <- "N/A"
      non_early_amp_median_iqr <- "N/A"
    }

    # T-test for amputation days
    if(length(early_amp_data) > 0 && length(non_early_amp_data) > 0) {
      amp_ttest_pvalue <- tryCatch({
        amp_ttest <- t.test(early_amp_data, non_early_amp_data)
        round(amp_ttest$p.value, 3)
      }, error = function(e) {
        return("N/A")
      })
    } else {
      amp_ttest_pvalue <- "N/A"
    }

    # Add to results table
    results <- rbind(results, data.frame(
      Metric = "Time to Amputation, Mean (SD), days",
      Early_PVI = early_amp_mean_sd,
      Non_Early_PVI = non_early_amp_mean_sd,
      P_Value = as.character(amp_ttest_pvalue)
    ))

    results <- rbind(results, data.frame(
      Metric = "Time to Amputation, Median (IQR), days",
      Early_PVI = early_amp_median_iqr,
      Non_Early_PVI = non_early_amp_median_iqr,
      P_Value = "N/A"
    ))
  }

  # Display the results table
  #knitr::kable(results, caption = "Comparison of Outcomes Between Early PVI and Non-Early PVI Groups")

  # Optionally write to a CSV file
  write.csv(results, "outcome_comparison_table.csv", row.names = FALSE)
}
