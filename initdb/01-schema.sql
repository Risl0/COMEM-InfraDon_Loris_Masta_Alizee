-- Tables indépendantes (sans FK)

CREATE TABLE type_intervention (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE type_materiel (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE type_mobilier (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE etat (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE statut (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE signalement (
    id SERIAL PRIMARY KEY,
    date DATE,
    signale_par VARCHAR(150),
    objet VARCHAR(255),
    description TEXT,
    urgence VARCHAR(50),
    id_statut INT,
    FOREIGN KEY (id_statut) REFERENCES statut (id)
);

CREATE TABLE fournisseur_contact (
    id SERIAL PRIMARY KEY,
    entreprise VARCHAR(150),
    contact VARCHAR(150),
    telephone VARCHAR(20),
    email VARCHAR(150),
    remarque TEXT,
    id_type_materiel INT,
);

CREATE TABLE intervention (
    id SERIAL PRIMARY KEY,
    date DATE,
    objet VARCHAR(255),
    technicien VARCHAR(150),
    duree INT,
    cout_materiel DECIMAL(10, 2),
    remarque TEXT,
    id_type_intervention INT,
    FOREIGN KEY (id_type_intervention) REFERENCES type_intervention (id)
);

-- Table centrale

CREATE TABLE inventaire_mobilier (
    id SERIAL PRIMARY KEY,
    materiaux_mobilier VARCHAR(150),
    lieu VARCHAR(150),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    date_installation DATE,
    id_etat INT,
    remarque TEXT,
    id_fournisseur_contact INT,
    id_type_mobilier INT,
    FOREIGN KEY (id_etat) REFERENCES etat (id),
    FOREIGN KEY (id_fournisseur_contact) REFERENCES fournisseur_contact (id),
    FOREIGN KEY (id_type_mobilier) REFERENCES type_mobilier (id) FOREIGN KEY (id_type_materiel) REFERENCES type_materiel (id)
);

-- Tables de jointure

CREATE TABLE signalement_inventaire_mobilier (
    id SERIAL PRIMARY KEY,
    id_signalement INT NOT NULL,
    id_inventaire_mobilier INT NOT NULL,
    FOREIGN KEY (id_signalement) REFERENCES signalement (id),
    FOREIGN KEY (id_inventaire_mobilier) REFERENCES inventaire_mobilier (id)
);

CREATE TABLE intervention_inventaire_mobilier (
    id SERIAL PRIMARY KEY,
    id_intervention INT NOT NULL,
    id_inventaire_mobilier INT NOT NULL,
    FOREIGN KEY (id_intervention) REFERENCES intervention (id),
    FOREIGN KEY (id_inventaire_mobilier) REFERENCES inventaire_mobilier (id)
);