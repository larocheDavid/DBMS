CREATE VIEW individus
AS SELECT *
FROM patients
UNION
SELECT prenom, nom, no_avs, canton
FROM medecins

CREATE VIEW achat_totaux
AS SELECT intitule_med, SUM(quantite) AS total FROM achats
GROUP BY (intitule_med)

CREATE VIEW factures_client
AS SELECT patients.prenom, patients.nom, patients.no_avs, assurances.nom AS nom_assurance, achats.id_distributeur AS id_distributeur, achats.intitule_med, achats.quantite, contient.prix, achats.quantite*contient.prix AS total
FROM patients
INNER JOIN achats, assurances, contient
WHERE achats.no_patient = patients.no_avs AND patients.no_assurance = assurances.no AND achats.id_distributeur = contient.id_distributeur AND contient.no_CAS = achats.no_CAS AND contient.intitule_med = achats.intitule_med

CREATE VIEW ordonnances_achat
SELECT inclut.id_ordonnance as id_ordonnance, patients.prenom, patients.nom, medicaments.intitule, achats.date as date_achat
FROM ordonnances
INNER JOIN inclut ON ordonnances.id_ordonnance = inclut.id_ordonnance
INNER JOIN medicaments ON medicaments.no_CAS = inclut.no_CAS and medicaments.intitule = inclut.intitule_med
INNER JOIN achats ON  medicaments.no_CAS = achats.no_CAS and medicaments.intitule = achats.intitule_med
INNER JOIN patients ON achats.no_patient = patients.no_avs and patients.no_avs = ordonnances.no_patient
WHERE ordonnances.date < achats.date
