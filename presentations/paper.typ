#import "@preview/tracl:0.6.1": *
#import "@preview/diagraph:0.3.3": raw-render

#show: doc => acl(doc,
  anonymous: false,
  title: "Legal entity recognition in the graph of french Law",
  authors: (
    (
      name: "Antonin PERONNET",
      email: "antonin.peronnet@telecom-paris.fr",
      affiliation: [Télécom Paris]
    ),
    (
      name: "Nils Holzenberger",
      email: "nils.holzenberger@telecom-paris.fr",
      affiliation: [Télécom Paris]
    ),
  ),
)


#set text(size: 10pt)
#show math.equation.where(block: false): box

#let w = word => {
 box(fill: luma(90%), inset: 5pt, word)
}


= Introduction


As of may 2024, the French law is made up of approximately 800k articles identified as "currently applicable law".
Among them, 160k (20%) are part of one of the 77 French codes. Given this massive amount of articles and the rate at which new articles are written, information retrieval methods are increasingly important. Indeed, research in natural language processing (NLP) for law has seen a fast increase in the 5 last years. This research focuses on classification, information extraction and information retrieval @nlplegal. State of the art approaches to legal question answering use Large Language models with document retrieval (Retrieval Augmented Generation) @legal_question_rag. An embedding key is calculated for each article, and then articles are retrieved based on this key. This can greatly reduce hallucinations in LLMs, but embeddings have other problems: They are sensitive to writing style, and are not easily interpretable. But more importantly, the text embedding approach does not question the underlying text medium. Other options include programming languages @catala, smart contracts @smart-contracts and knowledge graphs @knoledge_graphs_simplify_text. Such approaches can add syntactic and semantic constraints to law, which helps to deal with the increasing complexity of the law @simplification_qualite_droit  @growth_law.

Graph-based knowledge representations (ontologies) emerge as a good candidate to represent legal knowledge. They are a tradeoff between the flexibility of text and the strictness of rule-based approaches. Ontologies can represent diverse knowledge, link information, be audited and edited, and evolve with time. Ontologies have been used more extensively for medical and web texts, but they could be relevant for legal knowledge. Ontologies can be used to detect duplicate information and simplify text @knoledge_graphs_simplify_text, to navigate easily by entity or attribute (like wikidata), and impose a structure for future legal knowledge. For example, the EU published a data model that the law makers are encouraged to follow @eu_cdm. Diverse type of ontologies for law have already been discussed, for different subdomains @taking_stock. Graph-based approaches for legal tasks show promising results @graf. Unfortunately, creating ontologies manually is very costly and time-consuming. A solution is to learn ontologies directly from text, using *ontology induction*. Ontology induction is often broken down in multiple steps: Named Entity Recognition (NER), Concept analysis, and relation extraction (RE). Algorithms for ontology induction can be very specific to a domain and rely heavily on annotated data, or be domain agnostic and be a lot less supervised.


Named Entity Recognition in the law has specificities that are not addressed by existing methods. Named entity recognition either rely on annotated training data, or uses an external dictionary. For the French law, such labeled data is not easily available, and completely unsupervised methods are rare. Another challenge is the existence of nested entities (@figure-nested-entities). Finally, methods to evaluate the quality of extracted entities either lack justification or are applicable to legal subdomains only.


Our contributions are as follows:
+ Giving a definition of legal entities and discussing their properties. In particular, we develop a metric based on information theory to measure the importance of an entity in a corpus.
+ Creating a method for legal entity extraction based on grammatical trees. This method is based on a *global* optimization over all the corpus, which is very efficient.
+ Creating a ABX testing benchmark for legal entity extraction in the case of french Law, and testing our algorithm on it.


= Related work


There is a wide variety of schemes proposed for legal ontologies, depending on the legal subdomain @taking_stock. Most of these ontologies have been created manually, or use manually created extraction rules.

The task of ontology induction when the entities are not known beforehand is often refereed to as "open-ended information extraction" #citet(<openie>). Usual approaches for open-ended information extraction are driven by relations instead of entities. The usual approach is to extract every occurrence of the entities, and then to merge them. This is known as "ontology alignment". This procedure can wrongly merge distinct entities together, and does not solve the issue of nested entities.

#citet(<owner>) use BIO sequence labeling for named entity recognition (they call it mention detection). In order to deal with nested entities, they use spans that can overlap on the same sentence. Since they use transfer-learning from annotated data, the method only works for data similar to the original distribution. It was not tested on legal data, and only works for english text.

#citet(<cycle-ner>) uses a different strategy for unsupervised NER. It uses an encoder-decoder architecture for a sequence to sequence task. 2 models are trained jointly, one for creating a sequence of entities from text, and the other for creating a text from a sequence of entities.


#citet(<aske>) is the most complete attempt at entity recognition in a general-purpose law corpus. The method makes a heavy use of embeddings, both for entities and texts, and use a form of aggregative clustering in order to produce concepts. While it selects relevant entities from the text, the method is not able to identify new entities. Indeed, it uses wordnet as an external term definition dictionary, and exploit it to get embeddings for n-grams appearing in the text. Since most terms in the french law are not defined in any dictionary (except in the law itself), it would miss a lot of relevant entities in the French law.




#[
#set text(size:13pt)
#figure(
  placement: auto,
  scope: "parent",
$
underbracket("Agence" "nationale" "de" underbracket("sécurité" "du" "médicaments" "et" "des" overbracket("produits" "de" "santé", "entity 1"), "entity 2"), "entity 3")
$,
caption:"A nested entity in the french law: what is the 'correct' entity ?",
) <figure-nested-entities>
]

= Legal Entity Recognition

As stated previously, the law has 2 important specificities.
First, it is both *descriptive* and *normative*. This means that some entities are supposed to exist in the real world, and some of them are defined *within* the law.

Second, entities in the form of noun phrases are often nested (see @figure-nested-entities). In such cases, it is nontrivial to know which entity should be considered, between the entire noun phrase and some part of it.

Classical approaches in NER would either select the entire group, select all all subgroups as independent entities, or chose the groups based on some heuristic. The right answer cannot be decided *locally*: it depends on context, and on how common the different subgroups are. As for the example, `Agence nationale de sécurité du médicaments et produits de santé` is extremely common in "Code de la santé publique", with more than 1000 occurrences, but standard NER approaches have the tendency to break it down into smaller pieces. Since this kind of nested noun phrases are extremely common in the french law, it is the problem we will focus on in this work.

In this context, we define a Legal Entity as a concept having the following properties.
+ it can be expressed unambiguously as a noun phrase. We will refer to it as a "canonical form" of the entity.
+ each time the entity appears in the text, it can be easily replaced by another entity that make the sentence still semantically coherent.
+ it can be used intuitively by a lawyer to find relevant articles.

Since the last two point of the definition are very informal and subjective, we define a measure of the information content of an entity.

The score is based on the following intuition: an important entity should appear often, but be hard to predict from the context. Said differently, the words that refer to the entity can be replaced to refer to another entity, and the result still has a high probability.

#box(inset: (y:5pt))[

This can be formalized using *masking*. Let $t$ be a text and $e$ an entity. We denote by $t \\ e$ the text where all words referring to $e$ are masked (or hidden) and $P(t \\ e)$ the probability of all possible sentences that could produce $t \\ e$ #footnote["Masking" classically refers to replacing words with a special `<mask>` token, but here we consider it as any transformation that can remove information from the text locally. ]. We extend this definition to $P(t \\ cal(E))$ where $cal(E)$ is a set of entities. For the special case of model based on a token sequence $w_0, ..., w_n$, we can define define $I$ the indices of all words referring to any entity $e in cal(E)$, and then we have:


$
  P (t \\ cal(E)) = P (\{t' | forall i in.not I, t_i = t'_i\})
$


If $P(t \\ cal(E))$ is large for a lot of texts $t$, that means that entities in $cal(E)$ are very informative.


]


Given a corpus $D$ and a probabilistic model $P$, the we define the information content $H_m$ of a collection of entities $cal(E) = {e_1, ..., e_m}$ as

$
  H_m (cal(E)) = sum_(t in D) log_2((P (t \\ cal(E))) / (P (t)))
$


This corresponds to the total number of bits needed to reconstruct the corpus when all entities in $cal(E)$ are masked. #footnote[Of course, the measure depends on $P$. Ideally, we would like $P$ to be as close as possible to the probability in the lawyer head.]


We can finally define the task of Legal Entity Recognition (LER).

Given a corpus $D$ and an integer $n$, label each token position in the texts of $D$ such that:
- all tokens with the same label relate indeed to the same entity
- the information content score is maximal


= Preliminary results

To analyze the properties of $H_m$, we can use the most simplistic probability model: the unigram model.


Let's suppose that we are only allowed to select words as entities and that $P$ is a unigram model: $P(s) = P(w_1, w_2, ...) = product_i P(w_i)$. Let $I = \{e_1, ..., e_n\}$ be the candidate set of entities.

$
  P(t \\ cal(E)) / P(t) &= (product_i P (w_i in.not I))/( product_(w_i) P(w_i) )
  = product_(w_i in I) 1/P(w_i)
$

Thus, if we denote by $\#(e)$ the number of occurrences of $e$ in the corpus, our score is simply:
$
  H_m (e_1, ..., e_n) &= sum_(t in D) sum_(w_i in I) log_2 P(w_i) \
  &= sum_j \# (e_j) log_2 (1/P(e_j))
$

This can be interpreted as the cross-entropy between the probability distribution given by the model and the reality.

But as soon as we choose a slightly more complicated probability model (even bigram), there is no such closed form anymore.

For example, someone might try to mask a candidate in a sentence and use a LLM to compute the probability. But candidates are not independent: if we have 2 potential candidates $e_1$ and $e_2$ such that $e_2$ appears whenever $e_1$ appear, then $H_m (e_1, e_2) approx H_m (e_1)$.
// j'ai ajouté la phrase ci-dessous
How to solve $H_m$ for n-grams is left to future work.

= Entity extraction algorithm

#box[
Our algorithm consists of 3 steps:
+ selecting occurrences
+ clustering the occurrences into candidate entities
+ optimizing $H_m$ over all choices of candidates
]

== Extracting candidates

The first challenge consists in finding potential entities.

Following criteria (1) and (2) of our definition, we want to identify self-contained noun and verb phrases.

For this, we will use a standard NLP pipeline with part of speech (POS) tagging and dependency parsing.
Given a sentence $w_0, ..., w_n$ with $m+1$ tokens acting as nodes, the dependency parsing of $s$ is a rooted tree $T$ with root at position $r$.

A candidate occurrence is any token in the text marked with a POS of `NOUN`, along with its entire subtree.
In addition, to respect criteria (2), we filter out occurrences that have too many non-syntactic words (nouns, adjectives, verbs) in their subtrees. We chose a threshold of 7 words, because it is often considered the maximum number of items someone can hold in working memory @magic7. As a reference point, @figure-nested-entities has 6 words.



== Clustering occurences

To detect that 2 occurrences refer to the same entity candidate, we use a simple merging strategy.
For each occurrence, we consider the set of nouns, verbs and adjectives in its subtree, lemmatize all words in the set, and use the result as a key. Two occurrences are considered to refer to the same entity if their keys are the same. #footnote[Using sets is particularly relevant for legal entities: take for example ...]

Contrary to NER for other domains, we do not expect synonyms to be a major problem. Indeed, the legal vocabulary must very precise and repetitive in order to avoid ambiguity. See @discussion for discussion of this point.


In the following, we denote by $Omega$ the set of occurrences (subtrees), $cal(S)$ the set of keys (or entity candidates), and $l_i in cal(S)$ the key associated to occurrence $i$

== Subtree probability

Ideally, we would like to approximate $P$ in the lawyer's head. But to be able to approach the optimization problem, we chose a simpler model instead.


We make the assumption that most of the meaning of an entity can be deduced from its syntactic structure, as captured in the dependency parse tree.

We will also make the following simplifying assumptions:
- The arity of each node in the tree is IID according to some given distribution $P_"arity" (dot)$, independent from the words
- The probability of the word of a given node only depends on its parent according to $P_"word" ( dot | dot)$

Thus, for a tree $T$ with node arities $a_i$ and arcs $\{i arrow j\}$ (parent to child), we have:

$
  P(T) = P_"word" (w_r) product_(i arrow j) P_"arity" (a_i) P_"word" (w_i | w_j)
$

We estimate $P_"arity"$ and $P_"word"$ using frequency in a sample of all French law articles.

== Optimization algorithm


Once all occurrences and entities are defined, we must select the best set of  $cal(E) = \{e_1, ..., e_n\} subset cal(S)$ that maximizes $H_m$.

We introduce the relation $i prec.eq j$ when $j$ is contained in the subtree of $i$.
We also introduce boolean variables $(x_k)_(k in cal(S)) in \{0, 1\}^cal(S)$ such that $x_k = 0 <=> k in cal(E)$


In a similar way as the unigram model, we can use the fact that grammatical trees in the corpus are independent to derive an expression for $H_m (cal(E))$  (see @derivation-hm).

$
  H_m (cal(E)) = \ -sum_("t" in D) sum_((i arrow j) in "t") log_2(P_"word" (w_j | w_i)P_"arity" (a_i)) [1 - product_(i' prec.eq j) x_l_i']
$

The key observation is that $H_m$ is polynomial in $(x_l)$, and that we can compute each one of the coefficients of the polynomial.

This is an instance of a higher-order binary optimization (HOBO) problem, which we can solve using standard combinatorial methods such as simulated annealing @hobo.

Finally, we would like to introduce the constraint that $|cal(E)| <= m$. Since it cannot be added easily to HOBO, we instead add a penality term $+gamma$ to each monome $x_i$ #footnote[We cannot directly chose the number of selected entities, but we can it as a function of $gamma$: the higher $gamma$, the smaller the number of entities]


We will illustrate the selected entities using a *graph representation*. The graph associated to the optimization problem is the graph whose vertices are $cal(S)$ and whose edges are
$
w_(a b) = sum_(i arrow j \ l_i = a "and" l_j = b) -log_2[P_"word" (w_j | w_i) P_"arity" (a_j)]
$

== Additional step

We noticed that a small set of nouns accounts for  most of the weight in $H_m$. This set does not depend on the law corpus.

#box[
These particular top nouns are:

#w[article], #w[R.], #w[L.], #w[D.], #w[chapitre], #w[alinéa]
]

Because these entities are known to be purely syntactic (they help to cite other parts of the law), they are not informative at all about the content. As an additional step, we remove all occurrences whose subtree includes one of these words.

Other similar words are identified as entities by our approach, but we cannot remove them because of ambiguity (example: "présent titre" vs "titre d'assistant"): context in this case is crucial.

One advantage of our approach is that these special entities are automatically grouped together and easy to identify. This can allow users of the system to very rapidly filter them and treat them differently if needed. See @figure-syntax-article


#figure(
  placement: auto,
  scope: "parent",
  raw-render(
```
digraph {
	graph [rankdir=LR]
	node [shape=box style=filled fontsize=20]
	edge [fontsize=15]
	9117 [label="..." fillcolor=none]
	3188 [label="validation des acquis de l' expérience" fillcolor=lightblue]
	76326 [label="..." fillcolor=none]
	10096 [label="compétence et de leur expérience" fillcolor=none]
	1026 [label="expérience" fillcolor=lightblue]
	26804 [label="..." fillcolor=none]
	4974 [label="..." fillcolor=none]
	3189 [label="acquis de l' expérience" fillcolor=none]
  7224 [label="activité et l' expérience" fillcolor=none]
 7224 -> 1026 [label="184.91 (3)"]
	9117 -> 3188 [label="349.53 (4)"]
	76326 -> 3188 [label="349.53 (4)"]
	10096 -> 1026 [label="513.63 (5)"]
	26804 -> 3188 [label="786.43 (6)"]
	4974 -> 3188 [label="1070.42 (7)"]
	3188 -> 3189 [label="52465.31 (49)"]
	3189 -> 1026 [label="76449.13 (61)"]
}
```,
width:100%),
  caption: [Example of extracted candidates, and selected entities in blue. \ Code du travail, $gamma=500$.
"acquis de l'experience" is not selected because it appears often within other selected entities.]
)



== Grouping

After all entities are selected, we organize them using graph clustering.
We use the Louvain algorithm @louvain on the article-level co-occurrence graph with a high resolution parameter. The resulting groups must be seen as topic and not categories of entities. Yet, this is useful to compare them.

= Evaluation

== Perplexity drop

To assess whether our simplifying assumptions for our probabilistic tree model were justified, we also evaluated the probability of the selected entities using a larger model.

For different numbers of selected entities, we mask the corresponding token positions in the source text and predict the masked tokens with a bidirectional language model trained for masked token prediction. We use the total loss of the model over all sentences as an approximation of $H_m$ (@figure-perplexity)

#box(inset: (y: 5pt))[

As a baseline, we use a very simple per-word model. We select the $k$ most frequent nouns (using our POS pipeline) in the corpus and use them as entities.

We also evaluate a simplified version of our algorithm: we first compute the information content of each entity, and select the top-n entities with the best scores. This comes back to considering that all entities are independent, and may return all nested sub-entities.
]


We used the camembert-v2 language model @camembert, with its default tokenizer.
The results are visible in @figure-perplexity

#figure(
  placement: auto,
  scope: "parent",
grid(
  columns: 2,
  inset: 10pt,
  align: center,
  stroke: (x, y) => if x==0 {
    (right: (
      paint: luma(50%),
      thickness: 2pt,
      dash: "dotted"
    ))},
[57 total entities],[303 total entities],
  table(
  columns: (80pt, 1fr, 1fr),
  inset: 5pt,
  stroke: none,
  table.hline(),
  [*model*], [$bold(rho)$],[*surprisal* \(bits)],
  table.hline(),
  [Subtrees (ours)], [5.3%], [13.34],
  [Subtrees (naive)], [5.2%], [13.08],
  [Baseline], [13.36%], [19.64],
  table.hline(),
),
  table(
  columns: (80pt, 1fr, 1fr),
  inset: 5pt,
  stroke:none,
  table.hline(),
  [*model*], [$bold(rho)$],[*surprisal*\ (bits)],
  table.hline(),
  [Subtrees (ours)], [10.3%], [35.75],
  [Subtrees (naive)], [10.5%], [30.24],
  [Baseline], [21.9%], [56],
  table.hline(),
)),
caption: [negative log likelihood of the masked tokens, according to the camemBERT model. $rho$ is the proportion of masked tokens]
) <figure-perplexity>

#v(15pt)

The first interesting element is that the baseline yields the most surprisal, despite masking words that are very frequent in the corpus. This can be explained by the fact that legal text is different from the typical distribution of text in the camemBERT training data: a lot of frequent nouns in the law are not frequent in common language. Additionally, nouns are harder to predict than syntactic elements or verbs, because they can be substituted easily (ex: "travail / emploi"). We can also note that the baseline masks a lot more tokens than the subtree approach (3 times more for the table on the left). Thus, the baseline has a lower surprisal *per token*. We did not try to mask more entities: a higher proportion of masked tokens might yield un-relevant results, because masked language modeling is typically done with a rate of 15%.


== ABX task


To evaluate our method, we looked for a data source that gives us information about what entities are important for lawyers.

For this, we used the website `dictionnaire-juridique.com`. It features definitions of juridical terms with references to French law articles.

Because concepts are formulated differently in different articles, we cannot model it as a sequence to sequence task. Instead, we model it as a ABX task: given a reference article X and 2 articles A and B, guess which among A and B has an entity in common with X. We generated triplets from the terms defined in the website (see @benchmark-creation), and manually filtered out the ones where there were more entities in common between X and B than between X and A.

The results are in @figure-abx


#figure(
  placement: auto,
  scope: "parent",
grid(
columns: (1fr, 1fr),
image("results/abx.svg"),
image("results/abx_relative.svg")
),
caption: [Accuracy on the ABX task in function of total number of entities (left) and average number of entities per document (right). $gamma$ varying from $10000$ to $500$]
) <figure-abx>

#v(5pt)

When looking at the curve on the left, it can seem that the baseline does better on the ABX task. This is because the baseline is not restricted to valid entities: it can select arbitrary entities, part of entities or attributes. In comparison, our approach can only select entire subtrees. But when looking at the same data in function of the number of entities per document, our algorithm has a better accuracy. This is relevant for document retrieval, because a lawyer may want to find a document using only a few key entities.


== Qualitative results


#let o = word => text(fill:orange)[#word]

=== Example

#quote[
Lorsque le #o[comité social et économique] n' a pas été mis en place ou renouvelé , un procès-verbal de carence est établi par l' #o[employeur] . L' #o[employeur] porte à la connaissance des #o[salariés] par tout moyen permettant de donner date certaine à cette #o[information] , le procès-verbal dans l' #o[entreprise] et le transmet dans les quinze #o[jours] , par tout moyen permettant de conférer date certaine à l' agent de contrôle de l' #o[inspection du travail] mentionné à l' article L. 8112-1 . Ce dernier communique une copie du procès-verbal de carence aux organisations syndicales de salariés du département concerné
]


=== Analysis

See @supplement for entity clusters identified by our approach.

Among selected entities, we found a few false-positive. An important type of such false positives are dates ("jour" in the above example), dedicated expressions (like "cas échéant") and meta-language referring to the law ("présent titre").


= Discussion <discussion>

Our work is fundamentally different from ASKE, is that it commits to a discrete representation of entities, and does not try to cluster them into topics.

This has some immediate benefits. As the approach is very simple and use a global optimization approach, it can identify entities in the entire corpus very quickly. Once the heaviest part (dependency parsing) has been done, the construction of the polynomial and its optimization take less than 2 minutes for ~10k articles on a single GPU. It can handle deeply nested entities, and all the construction is inherently interpretable: Legal professionals can easily understand why specific entities were selected, making the system auditable.

Our current implementation is limited to extracting only subtrees in the sentence. This falls short for detecting concepts that are instantiated differently at each occurrence ("procès-verbal de [x]", "procès-verbal de [y]"). This is far from being a fundamental limitation. The approach could be extended to allow arbitrary subgraphs as entities instead. The relation $prec.eq$ would be different, but the polynomial approach would still work.

This explains partially why the baseline works better with the same number of total selected entities. Since it has access to every word (and not just leaves of the tree), it can identify nouns referring to attributes and relations, beyond just entities. Another theory is that for the same number of words, the baseline has a much larger representation space. It can combine arbitrary nouns, and the combination of nouns is much more informative than nouns taken individually.

The discrete approach that we used has more fundamental limitations. Since it does not use any vector representation, merging similar entities is not straight-forward. In #citet(<aske>), the ASKE approach uses local embeddings in order to compute a distance between entities vectors, and can apply standard clustering techniques when their similarity is under a given threshold. Developing a mathematical framework that would unify the information content view and the clustering view remains an open challenge, potentially requiring hybrid approaches that combine syntactic constraints with semantic similarity measures.


One major issue to create legal ontologies is the lack of labeled data. The main source is Eurovoc, a European project with manually edited topics and entities for the law. We did not have time to evaluate our method on this dataset.
ASKE used this exact dataset to evaluate this method, but it is questionable. The evaluation metric depends entirely on an embedding model.

The lack of gold-standard annotations for French legal entities remains a significant obstacle. The best source currently is Eurovoc, a European project with manually edited topics and entities for the law. ASKE used it to evaluate its approach, but the methodology is questionable: They use pseud-recall and pseudo-similarity metrics, that depends directly from an embedding model #footnote[We did not have time to test our method on the same benchmark]. To avoid relying on an embedding model for the evaluation, we developed an ABX benchmark using legal dictionaries. This only captures a subset of relevant entities, and does not measure exactly the quality of the extracted entities.


= Conclusion

In this work, we consider the task of legal entity recognition in nested noun phrases, inside the french law. We define legal entities as concepts that are self-contained, have a canonical representation in term of a noun phrase and are informative. We formalize this intuition using a metric inspired by information theory, and show its relation with cross-entropy. We show how this metric can be used with a very simple model to find entities that are particularly informative. We also propose a test dataset that can evaluate the quality of extracted entities. This work lays a foundation for ontology induction for law, without the need of annotated data.


The next logical step is to identify *attributes* that apply to entities, like properties and amounts. A similar task is to give each entity a *category*, like _institution_, _action_, _date_, _material_ ... We expect our evaluation dataset to still be relevant once the attributes are identified, because some legal terms can relate to common properties instead of entities.



#bibliography("biblio.bib")

#set page(columns: 1)

#appendix[
= Appendix


== Derivation of $H_m$ for subtrees <derivation-hm>

Let $D$ be the set of all grammatical trees in the corpus. Let $cal(E) subset cal(S)$ be the candidate set of entities.

$
H_m (cal(E)) = sum_(t in D) log_2(P(t \\ cal(E)) / P(t))
$

We define $cal(C) = {j in Omega | exists i in Omega, i prec.eq j "and" l_i in cal(E)}$. This set corresponds to all occurrences appearing in the subtrees of selected entities. Removing $cal(E)$ from the tree means removing all information from the elements in $cal(C)$

$
H_m (cal(E)) &= sum_(t in D) log_2((product_(i arrow j in t \ j in.not cal(C))P(w_j | w_i)P(a_j)) /  (product_(i arrow j in T) P(w_j | w_i)P(a_j))) \
&= sum_(t in D) -log_2(product_(i arrow j in t \ j in cal(C))P(w_j | w_i)P(a_j)) \
&= sum_(t in D) sum_(i arrow j in t \ j in cal(C)) -log_2(P(w_j | w_i)P(a_j)) \
&= sum_(t in D) sum_(i arrow j in t) -log_2(P(w_j | w_i)P(a_j)) bb(1)_cal(C)(j)
$

Finally, we can express $bb(1)_cal(c)(j)$ as $1-product_(i prec.eq j) x_l_i$, which gives the claimed result.


== Creation of the benchmark <benchmark-creation>

In order to create all triplets for the ABX task, we scrapped all definitions from `dictionnaire-juridique.com`, along with the french articles they cite.
On the 1447 term definitions and 5159 citations, we keep only the citations whose article are:
- located inside "Code du Travail"
- in the 300-2000 character range

After this step, the number of terms that have at least 2 citations is around 300.
We than construct our 200 triplets using this procedure:
- sample a term T uniformly
- sample (X, A) in the articles cited by T
- sample B uniformly, and check it is not cited by T


== Data sources and preprocessing


All results where obtained using the "Code du Travail", scrapped from the legifrance API.

The frequency analysis for the tree probability model was done using the Cold-law dataset @cold-french-law

We use a custom tokenization model based on regular expressions. The dependency parsing was done using the pre-trained french pipeline from spacy, based on the camemBERT model: https://github.com/explosion/spacy-models/releases/tag/fr_dep_news_trf-3.8.0

All code and datasets are accessible under the MIT licence at https://github.com/rambip/modeling-french-law


#pagebreak()


= Supplementary material <supplement>


// $gamma$ is a penalty, not a threshold, right? -Nils
Using a penality of $gamma=500$, we get 611 entities. We cluster them by article co-occurrence using the Louvain algorithm with a resolution of $20$.

#set text(size: 11pt)
#table(
  columns: (1fr),
  stroke: 1pt,
  inset: 5pt,
  [*Entities*],
  [
#w[transparence , à la lutte contre la corruption et à la modernisation de la vie économique (12)]
#w[garde des sceaux , ministre de la justice (18)]
#w[code de l' organisation judiciaire (13)]
#w[Conseil supérieur de la prud'homie (19)]
#w[Cour de cassation (21)]
#w[conseil de prud'hommes (214)]
#w[conseillers prud'hommes (88)]
#w[chambre (37)]
#w[audience (63)]
#w[vice-président (59)]
#w[jugement (142)]
#w[référé (45)]
#w[greffe (106)]
#w[prud'hommes (472)]  ],
  [
#w[groupe d' entreprises de dimension communautaire (41)]
#w[comité de la société européenne (44)]
#w[groupe spécial de négociation (125)]
#w[société coopérative européenne (55)]
#w[établissement concerné (41)]
#w[participation des salariés (34)]
#w[société européenne (119)]
#w[sociétés participantes (32)]
#w[élus (39)]
#w[filiale (95)]
#w[négociation (347)]
#w[membres (262)]  ],
  [
#w[Commission nationale de l' informatique et des libertés (27)]
#w[amende de 3 750 Euros (187)]
#w[contraventions de la cinquième classe (68)]
#w[procureur de la République (27)]
#w[Euros (344)]
#w[code pénal (122)]
#w[manquement (65)]
#w[amende de (119)]
#w[infraction (86)]
#w[internet (99)]
],
  [
#w[délégation du personnel du comité social et économique interentreprises (9)]
#w[plan d' épargne d' entreprise (51)]
#w[code monétaire et financier (47)]
#w[compte épargne temps (22)]
#w[retraite collectif (43)]
#w[épargne salariale (47)]
#w[plan (104)]
#w[placement (104)]
#w[épargne (158)]
#w[interentreprises (125)]
],
  [
#w[sécurité et de protection de la santé (24)]
#w[bâtiment ou de génie civil (35)]
#w[donneur d' ordre (63)]
#w[coordination (63)]
#w[amiante (43)]
#w[ouvrage (202)]
#w[bâtiment (48)]
#w[chantier (165)]  ],
  [
#w[nombre de votants (28)]
#w[bureau du vote (42)]
#w[opérations de vote (41)]
#w[sauvegarde (35)]
#w[scrutins (75)]
#w[vote (206)]
#w[électeurs (63)]
],
[
#w[commission des droits et de l' autonomie des personnes handicapées (15)]
#w[fonds de développement pour l' insertion professionnelle des handicapés (16)]
#w[bénéficiaires de l' obligation d' emploi (19)]
#w[situation de handicap (40)]
#w[fonction publique (35)]
#w[personnes handicapées (89)]
#w[handicap (103)]
]
)

Example of a very large "syntactic" entity:
#figure(
  placement: top,
  scope: "parent",
raw-render(```
digraph {
	graph [rankdir=LR]
	node [shape=box fontsize=20]
	edge [fontsize=10]
	33432 [label="informations mentionnées aux 7° à 12° et 14° de l' article R." fillcolor=red]
	33209 [label="mentionné au 1° de l' article R." fillcolor=red]
	33220 [label="organisme mentionné à l' article R." fillcolor=red]
	37883 [label="traitements mentionnés à l' article R." fillcolor=red]
	36415 [label="2° de l' article R." fillcolor=red]
	33124 [label="article R." fillcolor=red]
	46834 [label="valeurs d' exposition journalière définies à l' article R." fillcolor=red]
	34016 [label="définies aux articles R. 1233-34 et R." fillcolor=red]
	33497 [label="modalités prévues à l' article R." fillcolor=red]
	33123 [label="prévues à l' article R." fillcolor=red]
	33477 [label="alinéa de l' article R." fillcolor=red]
	33476 [label="dispositions du second alinéa de l' article R." fillcolor=red]
	38929 [label="II de l' article R." fillcolor=red]
	36021 [label="conditions fixées à l' article R." fillcolor=red]
	36022 [label="fixées à l' article R." fillcolor=red]
	35277 [label="I de l' article R." fillcolor=red]
	37170 [label="mentionnés au deuxième alinéa de l' article R." fillcolor=red]
	33122 [label="conditions prévues à l' article R." fillcolor=red]
	33270 [label="application de l' article R." fillcolor=red]
	33690 [label="dispositions de l' article R." fillcolor=red]
	33432 -> 33209 [label=419.78]
	33220 -> 33209 [label=461.91]
	37883 -> 33209 [label=473.99]
	36415 -> 33124 [label=491.41]
	46834 -> 34016 [label=498.84]
	33497 -> 33123 [label=535.01]
	33476 -> 33477 [label=590.89]
	38929 -> 33124 [label=652.75]
	36021 -> 36022 [label=779.92]
	35277 -> 33124 [label=782.39]
	37170 -> 33477 [label=1643.22]
	36022 -> 33124 [label=2027.74]
	34016 -> 33124 [label=2234.63]
	33477 -> 33124 [label=2340.91]
	33122 -> 33123 [label=2438.61]
	33270 -> 33124 [label=2642.89]
	33690 -> 33124 [label=3021.50]
	33209 -> 33124 [label=11248.55]
	33123 -> 33124 [label=11523.20]
}
```, width:100%),
) <figure-syntax-article>

]
