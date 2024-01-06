// Clean the database
MATCH(n) DETACH DELETE(n);

// Create the miRNA-mRNA interaction network
LOAD CSV WITH HEADERS
FROM 'https://raw.githubusercontent.com/MylenaRoberta/PFG/main/data/processed/mirna-mrna_mirwalk_mirtarbase_data.csv' AS row
MERGE (mirna:MicroRNA {id: row.mirnaid})
MERGE (mrna:MessengerRNA {id: row.genesymbol})
MERGE (mirna)-[:INTERACTS_WITH]->(mrna);

// Partial visualization of the microRNA-mRNA interaction network
MATCH (mirna:MicroRNA)-[r:INTERACTS_WITH]->(mrna:MessengerRNA)
RETURN mirna, r, mrna
LIMIT 150;

// Projection of miRNA nodes
MATCH (mirnaA:MicroRNA)-[:INTERACTS_WITH]->(mrnaA:MessengerRNA)
MATCH (mirnaB:MicroRNA)-[:INTERACTS_WITH]->(mrnaB:MessengerRNA)
WHERE mirnaA.id <> mirnaB.id AND mrnaA.id = mrnaB.id
MERGE (mirnaA)-[:IS_RELATED_TO]-(mirnaB);

// Visualization of the projection of miRNAs
MATCH (mirnaA:MicroRNA)-[r:IS_RELATED_TO]-(mirnaB:MicroRNA)
RETURN mirnaA, r, mirnaB;

// Degrees of miRNA nodes in the projection
MATCH (mirna:MicroRNA)
WHERE mirna.id IN ['hsa-miR-221-3p', 'hsa-miR-146b-5p', 'hsa-miR-222-3p',
 'hsa-miR-181b-5p', 'hsa-miR-155-5p', 'hsa-miR-34a-5p', 'hsa-miR-26a-5p',
 'hsa-miR-224-5p', 'hsa-miR-138-5p', 'hsa-miR-187-3p', 'hsa-miR-31-5p',
 'hsa-miR-125b-5p', 'hsa-let-7c-5p', 'hsa-miR-30a-5p', 'hsa-miR-30d-5p']
MATCH (mirna)-[r:IS_RELATED_TO]->()
RETURN mirna.id AS mirna, count(r) AS degree
ORDER BY degree;

// Projection of mRNA nodes
// *** Neo.TransientError.General.MemoryPoolOutOfMemoryError
MATCH (mirnaA:MicroRNA)-[:INTERACTS_WITH]->(mrnaA:MessengerRNA)
MATCH (mirnaB:MicroRNA)-[:INTERACTS_WITH]->(mrnaB:MessengerRNA)
WHERE mirnaA.id = mirnaB.id AND mrnaA.id <> mrnaB.id
MERGE (mrnaA)-[:IS_RELATED_TO]-(mrnaB);

// Visualization of the projection of mRNAs
// *** Neo.TransientError.General.MemoryPoolOutOfMemoryError
MATCH (mrnaA:MessengerRNA)-[r:IS_RELATED_TO]-(mrnaB:MessengerRNA)
RETURN mrnaA, r, mrnaB;