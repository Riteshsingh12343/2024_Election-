This repository contains SQL scripts for analyzing the 2024 Indian Election Results. The queries focus on extracting insights from the eci_data_2024 database, including vote counts, constituency-wise winners, party performance, and voting trends.

Key Features:
Database Setup: Creates the election_2024 database and tables (eci_data_2024, ge_data, phase_data).

Winning Candidates: Identifies winners in each constituency using EVM_Votes.

Vote Analysis: Calculates total votes per state, postal votes, and NOTA (None of the Above) statistics.

Party Performance: Computes vote share percentages and ranks parties by total votes.

Margins of Victory: Highlights constituencies with the largest winning margins.

Advanced Queries: Uses CTEs, temporary tables, and window functions for complex analysis.

Example Insights:
Which party has the highest vote share?

Which candidate won by the largest margin in their constituency?

How many postal votes were cast in Bihar?

What is the total NOTA count per state?

Setup Instructions:
Import the SQL file into MySQL or compatible databases.

Ensure the eci_data_2024 dataset is populated (schema provided in the script).

Run queries to replicate the analysis.

Contribution:
Report issues or suggest improvements via GitHub Issues.

Fork the repository to propose changes via Pull Requests.

Tools Used:
MySQL (compatible with MariaDB, PostgreSQL with minor adjustments).
