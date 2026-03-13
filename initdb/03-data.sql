
-- Table Signalement
SELECT
    CASE
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' 
        THEN TO_CHAR(TO_DATE(date, 'DD.MM.YYYY'), 'YYYY-MM-DD')
        ELSE date
    END AS date_normalisee,
    date AS date_originale,
    signale_par,
    objet,
    description,
    urgence,
    statut
FROM signalement
ORDER BY date_normalisee;