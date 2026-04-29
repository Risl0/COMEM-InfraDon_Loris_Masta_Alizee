-- Active: 1773408975230@@127.0.0.1@5432@service_technique
-- Chargement des données de staging vers le modèle du projet
-- Le script est adapté au schéma défini dans initdb/01-schema.sql.

-- 1. Normalisation des référentiels
INSERT INTO type_mobilier (libelle)
SELECT DISTINCT type_normalise
FROM (
    SELECT
        CASE
            WHEN LOWER(type) LIKE '%lampadaire%' THEN 'lampadaire'
            WHEN LOWER(type) LIKE '%borne recharge%' OR LOWER(type) LIKE '%borne ev%' OR LOWER(type) LIKE '%borne%' THEN 'borne recharge'
            WHEN LOWER(type) LIKE '%fontaine%' THEN 'fontaine'
            WHEN LOWER(type) LIKE '%banc%' THEN 'banc'
            WHEN LOWER(type) LIKE '%panneau%' THEN 'panneau'
            WHEN LOWER(type) LIKE '%poubelle%' OR LOWER(type) LIKE '%corbeille%' THEN 'poubelle'
            ELSE TRIM(type)
        END AS type_normalise
    FROM staging.inventaire
    WHERE type IS NOT NULL
) t
WHERE type_normalise <> ''
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO type_materiel (libelle)
SELECT DISTINCT materiau_normalise
FROM (
    SELECT
        CASE
            WHEN LOWER(materiau) LIKE '%métal%' OR LOWER(materiau) LIKE '%metal%' THEN 'métal'
            WHEN LOWER(materiau) LIKE '%bois%' THEN 'bois'
            WHEN LOWER(materiau) LIKE '%pierre%' THEN 'pierre'
            WHEN LOWER(materiau) LIKE '%béton%' THEN 'béton'
            ELSE TRIM(materiau)
        END AS materiau_normalise
    FROM staging.inventaire
    WHERE materiau IS NOT NULL
) t
WHERE materiau_normalise <> ''
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO etat (libelle)
SELECT DISTINCT etat_normalise
FROM (
    SELECT
        CASE
            WHEN LOWER(etat) LIKE '%remplace%' THEN 'à remplacer'
            WHEN LOWER(etat) LIKE '%bon%' THEN 'bon'
            WHEN LOWER(etat) LIKE '%usé%' OR LOWER(etat) LIKE '%use%' THEN 'usé'
            ELSE TRIM(etat)
        END AS etat_normalise
    FROM staging.inventaire
    WHERE etat IS NOT NULL
) t
WHERE etat_normalise <> ''
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO statut (libelle)
SELECT DISTINCT statut_normalise
FROM (
    SELECT
        CASE
            WHEN LOWER(statut) LIKE '%fait%' THEN 'fait'
            WHEN LOWER(statut) LIKE '%attente%' THEN 'en attente'
            WHEN LOWER(statut) LIKE '%en cours%' OR LOWER(statut) LIKE '%encours%' THEN 'en cours'
            ELSE TRIM(statut)
        END AS statut_normalise
    FROM staging.signalement
    WHERE statut IS NOT NULL
) t
WHERE statut_normalise <> ''
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO type_intervention (libelle)
SELECT DISTINCT type_normalise
FROM (
    SELECT
        CASE
            WHEN LOWER(objet) LIKE '%réparation%' OR LOWER(objet) LIKE '%reparation%' THEN 'réparation'
            WHEN LOWER(objet) LIKE '%remplacement%' THEN 'remplacement'
            WHEN LOWER(objet) LIKE '%nettoyage%' THEN 'nettoyage'
            WHEN LOWER(objet) LIKE '%redressage%' THEN 'redressage'
            WHEN LOWER(objet) LIKE '%remise en service%' THEN 'remise en service'
            WHEN LOWER(objet) LIKE '%hivernage%' THEN 'hivernage'
            WHEN LOWER(objet) LIKE '%peinture%' THEN 'peinture'
            WHEN LOWER(objet) LIKE '%détartrage%' OR LOWER(objet) LIKE '%detartrage%' THEN 'détartrage'
            WHEN LOWER(objet) LIKE '%mise à jour%' OR LOWER(objet) LIKE '%mise a jour%' THEN 'mise à jour logiciel'
            ELSE 'autre'
        END AS type_normalise
    FROM staging.intervention
    WHERE objet IS NOT NULL
) t
WHERE type_normalise <> ''
ON CONFLICT (libelle) DO NOTHING;

-- 2. Chargement des entités
INSERT INTO fournisseur_contact (entreprise, contact, telephone, email, remarque)
SELECT
    NULLIF(TRIM(entreprise), ''),
    NULLIF(TRIM(contact), ''),
    CASE
        WHEN telephone LIKE '0%' THEN TRIM(telephone)
        WHEN telephone LIKE '+41%' THEN regexp_replace(TRIM(telephone), '^\+41', '0')
        ELSE NULL
    END,
    CASE
        WHEN email LIKE '%@%' THEN TRIM(email)
        ELSE NULL
    END,
    NULLIF(TRIM(remarque), '')
FROM staging.fournisseur_contact;

INSERT INTO inventaire_mobilier (
    materiaux_mobilier,
    lieu,
    latitude,
    longitude,
    date_installation,
    id_etat,
    remarque,
    id_type_mobilier
)
SELECT
    NULLIF(TRIM(materiau), ''),
    NULLIF(TRIM(lieu), ''),
    NULLIF(NULLIF(TRIM(latitude), ''), '')::DECIMAL(10, 7),
    NULLIF(NULLIF(TRIM(longitude), ''), '')::DECIMAL(10, 7),
    CASE
        WHEN date_installation ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(TRIM(date_installation), 'DD.MM.YYYY')
        WHEN date_installation ~ '^\d{4}-\d{2}-\d{2}$' THEN TRIM(date_installation)::DATE
        ELSE NULL
    END,
    e.id,
    NULLIF(TRIM(remarques), ''),
    tm.id
FROM staging.inventaire i
LEFT JOIN etat e ON (
    CASE
        WHEN LOWER(i.etat) LIKE '%remplace%' THEN 'à remplacer'
        WHEN LOWER(i.etat) LIKE '%bon%' THEN 'bon'
        WHEN LOWER(i.etat) LIKE '%usé%' OR LOWER(i.etat) LIKE '%use%' THEN 'usé'
        ELSE TRIM(i.etat)
    END
) = e.libelle
LEFT JOIN type_mobilier tm ON (
    CASE
        WHEN LOWER(i.type) LIKE '%lampadaire%' THEN 'lampadaire'
        WHEN LOWER(i.type) LIKE '%borne recharge%' OR LOWER(i.type) LIKE '%borne ev%' OR LOWER(i.type) LIKE '%borne%' THEN 'borne recharge'
        WHEN LOWER(i.type) LIKE '%fontaine%' THEN 'fontaine'
        WHEN LOWER(i.type) LIKE '%banc%' THEN 'banc'
        WHEN LOWER(i.type) LIKE '%panneau%' THEN 'panneau'
        WHEN LOWER(i.type) LIKE '%poubelle%' OR LOWER(i.type) LIKE '%corbeille%' THEN 'poubelle'
        ELSE TRIM(i.type)
    END
) = tm.libelle;

INSERT INTO intervention (
    date,
    objet,
    technicien,
    duree,
    cout_materiel,
    remarque,
    id_type_intervention
)
SELECT
    CASE
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(TRIM(date), 'DD.MM.YYYY')
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TRIM(date)::DATE
        ELSE NULL
    END,
    NULLIF(TRIM(objet), ''),
    CASE
        WHEN TRIM(technicien) IN ('JM', 'Jean-Marc') THEN 'Jean-Marc Bonvin'
        ELSE NULLIF(TRIM(technicien), '')
    END,
    CASE
        WHEN LOWER(TRIM(duree)) = 'une matinée' THEN 4
        WHEN LOWER(TRIM(duree)) = 'une journée' THEN 8
        WHEN TRIM(duree) ~ '^\d+h\d{2}$' THEN (SPLIT_PART(TRIM(duree), 'h', 1)::INT * 60 + SPLIT_PART(TRIM(duree), 'h', 2)::INT) / 60
        WHEN TRIM(duree) ~ '^\d+h$' THEN SPLIT_PART(TRIM(duree), 'h', 1)::INT
        WHEN TRIM(duree) ~ '^\d+\s*min$' THEN SPLIT_PART(TRIM(duree), ' ', 1)::INT / 60
        ELSE NULL
    END,
    CASE
        WHEN LOWER(TRIM(cout_materiel)) LIKE '%gratuit%' THEN 0.00
        WHEN regexp_replace(TRIM(cout_materiel), '[^0-9\.,]', '', 'g') ~ '^\d+[\.,]?\d*$' THEN regexp_replace(TRIM(cout_materiel), '[^0-9\.,]', '', 'g')::NUMERIC(10,2)
        ELSE NULL
    END,
    NULLIF(TRIM(remarque), ''),
    COALESCE(ti.id, (SELECT id FROM type_intervention WHERE libelle = 'autre'))
FROM staging.intervention s
LEFT JOIN type_intervention ti ON (
    CASE
        WHEN LOWER(s.objet) LIKE '%réparation%' OR LOWER(s.objet) LIKE '%reparation%' THEN 'réparation'
        WHEN LOWER(s.objet) LIKE '%remplacement%' THEN 'remplacement'
        WHEN LOWER(s.objet) LIKE '%nettoyage%' THEN 'nettoyage'
        WHEN LOWER(s.objet) LIKE '%redressage%' THEN 'redressage'
        WHEN LOWER(s.objet) LIKE '%remise en service%' THEN 'remise en service'
        WHEN LOWER(s.objet) LIKE '%hivernage%' THEN 'hivernage'
        WHEN LOWER(s.objet) LIKE '%peinture%' THEN 'peinture'
        WHEN LOWER(s.objet) LIKE '%détartrage%' OR LOWER(s.objet) LIKE '%detartrage%' THEN 'détartrage'
        WHEN LOWER(s.objet) LIKE '%mise à jour%' OR LOWER(s.objet) LIKE '%mise a jour%' THEN 'mise à jour logiciel'
        ELSE 'autre'
    END
) = ti.libelle;

INSERT INTO signalement (
    date,
    signale_par,
    objet,
    description,
    urgence,
    id_statut
)
SELECT
    CASE
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(TRIM(date), 'DD.MM.YYYY')
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TRIM(date)::DATE
        ELSE NULL
    END,
    NULLIF(TRIM(signale_par), ''),
    NULLIF(TRIM(objet), ''),
    NULLIF(TRIM(description), ''),
    CASE
        WHEN LOWER(TRIM(urgence)) LIKE '%urgent%' THEN 'urgent'
        WHEN LOWER(TRIM(urgence)) LIKE '%normal%' THEN 'normal'
        ELSE NULL
    END,
    st.id
FROM staging.signalement s
LEFT JOIN statut st ON lower(trim(s.statut)) = lower(st.libelle);

-- 3. Création des associations par mobilités et signalements
-- Les jointures suivantes sont des heuristiques textuelles basées sur le type et l'objet.
INSERT INTO intervention_inventaire_mobilier (id_intervention, id_inventaire_mobilier)
SELECT DISTINCT i.id, im.id
FROM intervention i
JOIN inventaire_mobilier im ON (
    i.objet ILIKE '%' || COALESCE(im.lieu, '') || '%'
    OR i.objet ILIKE '%' || COALESCE((SELECT libelle FROM type_mobilier WHERE id = im.id_type_mobilier), '') || '%'
);

INSERT INTO signalement_inventaire_mobilier (id_signalement, id_inventaire_mobilier)
SELECT DISTINCT s.id, im.id
FROM signalement s
JOIN inventaire_mobilier im ON (
    s.objet ILIKE '%' || COALESCE(im.lieu, '') || '%'
    OR s.objet ILIKE '%' || COALESCE((SELECT libelle FROM type_mobilier WHERE id = im.id_type_mobilier), '') || '%'
);

-- 4. Vues finales pour le rapport budgétaire
CREATE OR REPLACE VIEW view_budget_entretien_par_type_mobilier AS
SELECT
    tm.libelle AS type_mobilier,
    COUNT(i.id) AS nb_interventions,
    SUM(i.duree) AS duree_heure_totale,
    SUM(i.cout_materiel) AS cout_materiel_total
FROM intervention i
JOIN intervention_inventaire_mobilier iim ON i.id = iim.id_intervention
JOIN inventaire_mobilier im ON iim.id_inventaire_mobilier = im.id
LEFT JOIN type_mobilier tm ON im.id_type_mobilier = tm.id
GROUP BY tm.libelle
ORDER BY cout_materiel_total DESC NULLS LAST;

CREATE OR REPLACE VIEW view_signalements_par_type_etat AS
SELECT
    COALESCE(tm.libelle, 'inconnu') AS type_mobilier,
    COALESCE(e.libelle, 'inconnu') AS etat,
    COUNT(s.id) AS nb_signalements,
    SUM(CASE WHEN LOWER(s.urgence) = 'urgent' THEN 1 ELSE 0 END) AS nb_signalements_urgents,
    SUM(CASE WHEN LOWER(s.urgence) = 'normal' THEN 1 ELSE 0 END) AS nb_signalements_normaux
FROM signalement s
JOIN signalement_inventaire_mobilier sim ON s.id = sim.id_signalement
JOIN inventaire_mobilier im ON sim.id_inventaire_mobilier = im.id
LEFT JOIN type_mobilier tm ON im.id_type_mobilier = tm.id
LEFT JOIN etat e ON im.id_etat = e.id
GROUP BY tm.libelle, e.libelle
ORDER BY nb_signalements DESC;

CREATE OR REPLACE VIEW view_cout_entretien_par_type_intervention AS
SELECT
    COALESCE(ti.libelle, 'autre') AS type_intervention,
    COUNT(i.id) AS nb_interventions,
    SUM(i.cout_materiel) AS cout_materiel_total,
    SUM(i.duree) AS duree_heure_totale
FROM intervention i
LEFT JOIN type_intervention ti ON i.id_type_intervention = ti.id
GROUP BY ti.libelle
ORDER BY cout_materiel_total DESC NULLS LAST;
