# Dallas Mavericks Points Prediction: 2023-2024 Season Analysis

This repository contains a project investigating the factors influencing the number of points scored by the Dallas Mavericks in games during the 2023-2024 NBA season. The primary objective is to explore the linear relationships between points scored and the following key variables:

- **Turnovers**: High turnover rates can lead to more possessions for the opposing team, impacting scoring opportunities.
- **Field Goal Percentage**: This metric reflects the efficiency of the team’s shooting; a higher percentage indicates a better chance of scoring.
- **Total Rebounds**: More rebounds increase the chances of maintaining possession and scoring.
- **Luka Doncic's Minutes Played**: As a star player, Doncic's playing time is expected to correlate positively with the Mavericks' scoring.

### Data Collection
The data for this analysis was collected from [ESPN](https://www.espn.com/nba/team/_/name/dal/dallas-mavericks), consisting of 30 randomly selected games from the 2023-2024 season. Each observation reflects the team's cumulative statistics from individual games, focusing solely on the Mavericks without accounting for the opponent's stats.

### Components
- **Apache Spark (Scala)**: Implements data processing and regression analysis to identify relationships among the variables.
- **SAS**: Conducts additional regression analysis and visualizations, providing a comparative perspective on the findings.

### Usage
- Run the Spark Scala script for data processing and analysis.
- Execute the SAS script for further exploration and visualization of the regression results.
