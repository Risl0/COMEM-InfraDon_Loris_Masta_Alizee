-- Citoyen : lecture seule sur les données publiques
CREATE ROLE citoyen;

-- Technicien : lecture + écriture sur les tables opérationnelles
CREATE ROLE technicien;

-- Administrateur : tous les privilèges sur la base
CREATE ROLE administrateur;

-- ============================================================
GRANT SELECT ON inventaire_mobilier TO citoyen;

GRANT SELECT ON type_mobilier TO citoyen;

GRANT SELECT ON type_materiel TO citoyen;

GRANT SELECT ON etat TO citoyen;

GRANT SELECT ON signalement TO citoyen;

GRANT SELECT ON statut TO citoyen;

GRANT SELECT ON signalement_inventaire_mobilier TO citoyen;

-- ============================================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO technicien;

GRANT INSERT, UPDATE ON signalement TO technicien;

GRANT INSERT, UPDATE ON intervention TO technicien;

GRANT INSERT, UPDATE ON inventaire_mobilier TO technicien;

GRANT INSERT,
UPDATE ON signalement_inventaire_mobilier TO technicien;

GRANT INSERT,
UPDATE ON intervention_inventaire_mobilier TO technicien;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO technicien;

-- ============================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrateur;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrateur;

GRANT CREATE ON SCHEMA public TO administrateur;