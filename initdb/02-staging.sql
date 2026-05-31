--gt Créer un schéma dédié pour la staging
CREATE SCHEMA IF NOT EXISTS staging;
-- Table de staging : miroir exact du CSV
-- Tout en TEXT, aucune contrainte
CREATE TABLE staging.inventaire (
    id TEXT,
    type TEXT,
    materiau TEXT,
    lieu TEXT,
    latitude TEXT,
    longitude TEXT,
    date_installation TEXT,
    etat TEXT,
    remarques TEXT
);

COPY staging.inventaire
FROM '/data/inventaire_mobilier.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

-- Créer un schéma dédié pour la staging
CREATE SCHEMA IF NOT EXISTS staging;
-- Table de staging : miroir exact du CSV
-- Tout en TEXT, aucune contrainte
CREATE TABLE staging.intervention (
    id TEXT,
    date TEXT,
    objet TEXT,
    technicien TEXT,
    duree TEXT,
    cout_materiel TEXT,
    remarque TEXT
);

COPY staging.intervention
FROM '/data/interventions.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

CREATE SCHEMA IF NOT EXISTS staging;
-- Table de staging : miroir exact du CSV
-- Tout en TEXT, aucune contrainte
CREATE TABLE staging.fournisseur_contact (
    id TEXT,
    entreprise TEXT,
    contact TEXT,
    telephone TEXT,
    email TEXT,
    remarque TEXT
);

COPY staging.fournisseur_contact
FROM '/data/fournisseurs_contacts.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

CREATE SCHEMA IF NOT EXISTS staging;
-- Table de staging : miroir exact du CSV
-- Tout en TEXT, aucune contrainte
CREATE TABLE staging.signalement (
    date TEXT,
    signale_par TEXT,
    objet TEXT,
    description TEXT,
    urgence TEXT,
    statut TEXT
);

COPY staging.signalement
FROM '/data/signalements.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );