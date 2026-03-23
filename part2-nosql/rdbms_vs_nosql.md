# RDBMS vs NoSQL 

## Database Recommendation

### Core Patient Management: MySQL (RDBMS)

For the core patient management system, **MySQL is the right choice**, and the reasoning comes directly from the ACID vs BASE distinction.

Patient data — medical history, prescriptions, diagnoses, billing — is among the most legally and ethically sensitive data a system can store. A healthcare application cannot tolerate eventual consistency. If a nurse records an allergy and a prescription is written milliseconds later, the prescribing module must see that allergy immediately, not "eventually." ACID transactions (Atomicity, Consistency, Isolation, Durability) guarantee exactly this: a transaction either commits fully or rolls back completely, and reads always reflect committed state. MongoDB's BASE model (Basically Available, Soft-state, Eventually consistent) — while tunable to stronger consistency — defaults to a posture that is fundamentally misaligned with patient safety requirements.

The CAP theorem adds further weight here. A healthcare system must prioritise **Consistency and Partition Tolerance (CP)** over availability. If a network partition occurs between database nodes, it is safer for the system to return an error ("please retry") than to serve a stale or split-brain view of a patient's medication list. MySQL with synchronous replication (e.g., MySQL Group Replication in single-primary mode) delivers CP behaviour. Regulatory frameworks — HIPAA in the US, IT Act rules in India, and GDPR in Europe — also assume transactional integrity, which relational databases provide natively through foreign keys, constraints, and audit logging.

### Fraud Detection Module: Add MongoDB (or a Graph/Streaming Store)

The answer changes significantly for fraud detection. Fraud detection requires pattern recognition across large, heterogeneous, rapidly changing event streams — logins, insurance claims, prescription frequencies, billing anomalies. This data is **write-heavy, schema-variable, and read in aggregate**, not transactionally. MongoDB's flexible document model handles evolving fraud-signal schemas without costly `ALTER TABLE` migrations. For real-time scoring, a dedicated stream-processing layer (Kafka + Redis or a graph database like Neo4j for detecting provider fraud networks) may be more appropriate still.

**Recommendation summary:** use MySQL for the transactional core; add MongoDB or a purpose-built analytics store for fraud detection. The two systems are complementary, not mutually exclusive.
