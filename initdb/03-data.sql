-- Table Signalement
SELECT
    CASE
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_CHAR(
            TO_DATE(date, 'DD.MM.YYYY'),
            'YYYY-MM-DD'
        )
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

insert into public.type_intervention (libelle)

SELECT DISTINCT objet FROM staging.intervention;

SELECT
    objet,
    CASE
        WHEN LOWER(objet) LIKE '%réparation%'
        OR LOWER(objet) LIKE '%reparation%' THEN 'réparation'
        WHEN LOWER(objet) LIKE '%remplacement%' THEN 'remplacement'
        WHEN LOWER(objet) LIKE '%nettoyage%' THEN 'nettoyage'
        WHEN LOWER(objet) LIKE '%redressage%' THEN 'redressage mât'
        WHEN LOWER(objet) LIKE '%remise en service%' THEN 'remise en service'
        WHEN LOWER(objet) LIKE '%hivernage%' THEN 'hivernage'
        WHEN LOWER(objet) LIKE '%peinture%' THEN 'peinture'
        WHEN LOWER(objet) LIKE '%détartrage%'
        OR LOWER(objet) LIKE '%detartrage%' THEN 'détartrage'
        WHEN LOWER(objet) LIKE '%mise à jour%'
        OR LOWER(objet) LIKE '%mise a jour%' THEN 'mise à jour logiciel'
        ELSE objet
    END AS type_intervention_normalise
FROM staging.intervention

insert into public.type_materiel (libelle)

SELECT DISTINCT
    materiau
FROM staging.inventaire
WHERE
    materiau IS NOT NULL;

INSERT INTO public.type_materiel (materiau)
SELECT DISTINCT
    CASE
        WHEN LOWER(materiau) LIKE '%métal%'
        OR LOWER(materiau) LIKE '%metal%' THEN 'métal'
        WHEN LOWER(materiau) LIKE '%Pierre%'
        OR LOWER(materiau) LIKE '%pierre%' THEN 'pierre'
        ELSE materiau
    END AS type_materiel_normalise
FROM staging.inventaire

insert into public.type_mobilier (libelle)

SELECT DISTINCT
    type
FROM staging.inventaire
WHERE
    type IS NOT NULL;

INSERT INTO public.type_mobilier (libelle)
SELECT DISTINCT
    CASE
    -- Lampadaires
        WHEN LOWER(type) LIKE '%lampadaire%' THEN 'lampadaire'
        -- Bornes de recharge EV
        WHEN LOWER(type) LIKE '%borne recharge%'
        OR LOWER(type) LIKE '%borne ev%'
        OR LOWER(type) LIKE '%borne recharge ev%' THEN 'borne recharge'
        -- Fontaines
        WHEN LOWER(type) LIKE '%fontaine%' THEN 'fontaine'
        -- Bancs
        WHEN LOWER(type) LIKE '%banc%' THEN 'banc'
        -- Panneaux
        WHEN LOWER(type) LIKE '%panneau%' THEN 'panneau'
        -- Poubelles / corbeilles
        WHEN LOWER(type) LIKE '%poubelle%'
        OR LOWER(type) LIKE '%corbeille%' THEN 'poubelle'
        ELSE type
    END AS type_mobilier_normalise
FROM staging.inventaire;
 

insert into public.etat (libelle)
SELECT DISTINCT
    etat
FROM staging.inventaire
WHERE
    etat IS NOT NULL;

insert into public.statut (libelle)
SELECT DISTINCT
    statut
FROM staging.signalement
WHERE
    statut IS NOT NULL;

insert into public.signalement (urgence)
SELECT DISTINCT
    urgence
FROM staging.signalement
WHERE
    urgence IS NOT NULL;