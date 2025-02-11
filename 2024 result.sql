-- Create a database for 2024 election results
create database election_2024;

-- Explore raw data from relevant tables
SELECT * FROM election_2024.eci_data_2024;
SELECT * FROM election_2024.ge_data;
SELECT * FROM election_2024.phase_data;

-- Retrieve EVM votes specifically for the state of Bihar
select EVM_Votes
from eci_data_2024
where state = "Bihar";

-- Calculate total postal votes (for remote/absentee voters) per state
SELECT state, SUM(Postal_Votes) AS total_votes_polled 
FROM eci_data_2024
GROUP BY state;

-- Identify the winning candidate in each constituency based on MAX votes
SELECT 
    el.constituency, 
    el.state, 
    el.candidate, 
    el.party, 
    el.Total_Votes
FROM eci_data_2024 el
INNER JOIN (
    -- Subquery to find max votes per constituency-state pair
    SELECT 
        constituency, 
        state, 
        MAX(total_votes) AS max_votes
    FROM eci_data_2024
    GROUP BY constituency, state
) AS max_votes_per_constituency
ON el.constituency = max_votes_per_constituency.constituency 
    AND el.state = max_votes_per_constituency.state 
    AND el.Total_Votes = max_votes_per_constituency.max_votes;

-- Analyze NOTA ("None of the Above") performance across constituencies
SELECT 
    candidate, 
    party,
    state,
    Postal_Votes,
    COUNT(*) AS constituencies_won
FROM eci_data_2024
WHERE Candidate = "nota"  -- Filter for NOTA entries
GROUP BY candidate, party, Postal_Votes, state
ORDER BY constituencies_won DESC;

-- List candidates and their EVM votes in Bihar
SELECT 
    candidate, 
    party, 
    constituency, 
    Evm_votes
FROM eci_data_2024
WHERE state = 'Bihar';

-- Calculate total votes polled per state
SELECT 
    state, 
    SUM(Total_Votes) AS total_votes_polled
FROM eci_data_2024
GROUP BY state;

-- Alternative method to find winners using CTE (Common Table Expression)
WITH WinningCandidates AS (
    SELECT 
        constituency, 
        state, 
        MAX(Evm_votes) AS max_votes
    FROM eci_data_2024
    GROUP BY constituency, state
)
SELECT 
    e.constituency, 
    e.state, 
    e.candidate, 
    e.party, 
    e.Evm_votes
FROM eci_data_2024 e
JOIN WinningCandidates w
    ON e.constituency = w.constituency
    AND e.state = w.state
    AND e.Evm_votes = w.max_votes;

-- Calculate overall party-wise vote share percentage
SELECT 
    party, 
    SUM(EVM_Votes) AS total_votes, 
    (SUM(EVM_Votes) * 100.0 / (SELECT SUM(EVM_Votes) FROM eci_data_2024)) AS vote_share_percentage
FROM eci_data_2024
GROUP BY party
ORDER BY total_votes DESC;

-- Identify top 10 constituencies by party vote share
WITH VoteShareByParty AS (
    SELECT 
        party, 
        SUM(EVM_Votes) AS total_votes, 
        (SUM(EVM_Votes) * 100.0 / (SELECT SUM(EVM_Votes) FROM eci_data_2024)) AS vote_share_percentage
    FROM eci_data_2024
    GROUP BY party
)
SELECT 
    e.constituency, 
    e.state, 
    e.candidate, 
    e.party, 
    v.total_votes, 
    v.vote_share_percentage
FROM eci_data_2024 e
JOIN VoteShareByParty v ON e.party = v.party
ORDER BY v.total_votes DESC
LIMIT 10;

-- Calculate victory margins between top two candidates per constituency
WITH CandidateRanks AS (
    SELECT 
        constituency, 
        state, 
        candidate, 
        party, 
        Evm_votes,
        RANK() OVER (PARTITION BY constituency, state ORDER BY EVM_Votes DESC) AS rank_
    FROM eci_data_2024
)
SELECT 
    c1.constituency, 
    c1.state, 
    c1.candidate AS winner_name, 
    c1.party AS winner_party, 
    c1.Evm_votes AS winner_votes,
    c2.candidate AS runnerup_name, 
    c2.party AS runnerup_party, 
    c2.Evm_votes AS runnerup_votes,
    (c1.Evm_votes - c2.Evm_votes) AS margin
FROM CandidateRanks c1
JOIN CandidateRanks c2
    ON c1.constituency = c2.constituency 
    AND c1.state = c2.state 
    AND c1.rank_ = 1 
    AND c2.rank_ = 2
ORDER BY margin DESC;

-- Create temporary table to store ranked results for reuse
CREATE TEMPORARY TABLE TempRankedResults AS
SELECT 
    constituency, 
    state, 
    candidate, 
    party, 
    Evm_votes,
    ROW_NUMBER() OVER (PARTITION BY constituency, state ORDER BY Evm_votes DESC) AS rank_
FROM eci_data_2024;

-- Retrieve all winners using the temporary ranked table
SELECT 
    constituency, 
    state, 
    candidate, 
    party, 
    Evm_votes
FROM TempRankedResults
WHERE rank_ = 1;

-- Alternative method to find winners using max votes per constituency
CREATE TEMPORARY TABLE TempMaxVotes AS
SELECT 
    constituency, 
    state, 
    MAX(EVM_Votes) AS max_votes
FROM eci_data_2024
GROUP BY constituency, state;

SELECT 
    er.constituency, 
    er.state, 
    er.candidate, 
    er.party, 
    er.Evm_votes
FROM eci_data_2024 er
INNER JOIN TempMaxVotes mv 
    ON er.constituency = mv.constituency 
    AND er.state = mv.state 
    AND er.EVM_Votes = mv.max_votes;

-- Retrieve candidates ranked 5th in their constituencies (for specific analysis)
SELECT 
    constituency, 
    state, 
    candidate, 
    party, 
    Evm_votes
FROM TempRankedResults
WHERE rank_ = 5;