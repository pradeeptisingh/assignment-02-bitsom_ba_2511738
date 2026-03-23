# Vector Database Reflection

## Vector DB Use Case

### Legal Contract Search — Why Keyword Search Falls Short

A traditional keyword-based search engine (SQL `LIKE`, Elasticsearch BM25, or full-text index) operates on exact lexical overlap: it finds documents that contain the words you typed. For a lawyer asking *"What are the termination clauses?"*, a keyword engine would look for the literal string "termination clause" across the contract. This immediately fails in several real-world scenarios. The contract might use synonymous language — "exit provisions," "contract dissolution," "notice of cancellation," or "rights to rescind" — none of which share a word with the query. Long 500-page contracts also bury relevant clauses inside dense boilerplate, making precision low (too many false positives) and recall inconsistent (relevant clauses under different headings are missed entirely).

A vector database solves this by replacing lexical matching with **semantic matching**. The contract is first chunked into overlapping passages (e.g., 300-token windows with 50-token overlap). Each chunk is converted into a dense embedding vector using a model like `all-MiniLM-L6-v2` or a legal-domain fine-tuned variant (e.g., `legal-bert`). These vectors are stored in a vector index (Pinecone, Weaviate, or pgvector). At query time, the lawyer's natural-language question is also embedded into the same vector space, and an approximate nearest-neighbour search retrieves the top-k most semantically similar contract chunks — regardless of exact wording.

This is the retrieval layer of a **RAG (Retrieval-Augmented Generation)** pipeline: the retrieved chunks are passed as context to a large language model (e.g., GPT-4 or Claude), which then synthesises a precise, cited answer. The vector database does not answer the question — it ensures the LLM receives the right context from potentially thousands of pages, enabling accurate, grounded responses to any plain-English legal query.
