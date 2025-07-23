#align(center, [
#set text(size: 30pt)
Modeling the graph of french law

#set text(size: 25pt)
_State of the art_

#set text(size: 15pt)
PERONNET Antonin
])


#set page()
#set heading(numbering:"1.")
#set par(justify: true)

#set par(leading: 0.60em)

#show heading: it => {
v(10pt)
it
}

= Introduction

== The growing complexity of the law

Making the law easier to navigate and to edit is a major challenge, for experts as well as for the general public. Reports about the increasing complexity and volume of the law date back to @growth_law, and French law is no exception. Most legal experts only know a tiny fraction of all the law, thus there is no global vision of the law when it is written. As a consequence, law becomes harder to read, to navigate and to change. There are multiple factors making the law more or less easy to work with. The french government itself has written extensively on the topic @simplification_qualite_droit. Currently, the main points the french government focus on are:
- How texts are sorted and organised (*codification*).
- Whether they are in sync with the amendments made to them from other documents (*consolidation*).
- what actors are involved in the process of making the law, and what are their motivations while writing new laws (*law-making*).
- how the laws are written and verified (*standardisation*).

The number of different (and potentially conflicting) articles in the law make it harder to enforce, as it demands more time from legal experts to read and learn it. To solve this issue, one potential solution is to reduce the number of articles, and deliberately making the law less precise @degree_detail_law. But with computers, a new possibility emerges: translating the law to a standard format that can be efficiently treated by computers. This can allow a lot of tasks than are currently limited to human speed to be treated automatically: retrieving relevant documents, checking if a law is in sync with public information, checking for redundancy and obsolete norms.



== Representing the law


The question of how the law should be represented for a computer is a profound and difficult one, because the choice of the representation will influence which features of the law are relevant and which are not. This question first was studied in @concept_of_law, a foundational work is the field of Philosophy of Law.

All representations of the law are a trade-offs between 2 opposite visions of the law:
- a strict, *algorithmic* law. In this vision, the law is a process that decides if someone is guilty, and compute the judiciary decision. The law is then the source code of the algorithm.
- a flexible, *example-based* law. In this vision, the law is the collection of all past decisions, and they serve as jurisprudence to judge future cases.

The most strict vision of a law as a programming language has been used successfully in specific contexts. For example, the Catala language has been created specifically to translate law into code @catala. Legal programming languages are used especially for taxes, where checking if criteria are respected is easier and more valuable.


But as explained in @inadequacy_rule_based, the approach of a rule-based law is not satisfying because "No area of law is covered exclusively by statute". Law is full of guideline and vague concepts like "respect human dignity" that are used by judges in novel cases. These concepts can be represented using a formal language based on grammar. In that case, the representation of 2 texts with the same information content should be the same. Such representations exists for text in general and are called *meaning representations*. It is an active area of research, see @meaning_representations.

A more flexible way to represent legal knowledge (or any kind of knowledge about the word) is called an *ontology*. An ontology is a set of *entities* linked by *relations*, which can be of different types. In this view, law is a graph constituted by many legal categories interacting with each other. To use such an ontology, one must define the set of entity and relation types, what is called a *schema*. There have been multiple proposals to create such a schema, the first one being @functionnal_ontology. With time, legal documents have become very specialized depending on the domain they are in, leading to different ontologies. Ontologies schemas exist for multiple subfields of the legal domain @taking_stock, but unifying them is still an open problem @ontology_alignment_legal.


At the end of the spectrum, there is pure text. With advances in Natural Language Processing (NLP), this medium have been preferred for a wide variety of tasks because of it's flexibility. But note that this flexibility is also the reason why the way law is written is not standardized. Researcher in NLP often see the question of representing the law as a one-way problem, but it is really a two-way problem: at one end, lawmakers express what is allowed or not, and systems at the other end must use this knowledge in a consistent way.



= Existing solutions to treat legal information

Let's take a step back and review the history of how AI systems have treated information in the legal domain.


== Expert systems

The first algorithms that processed legal documents were very specific and rule-based @expert_system_law . One very important limitation of these systems was knowledge about the real world. 

One of the first system that integrated knowledge about the real world (not only for legal tasks) for question answering was the Watson project @watson. The algorithms for extracting information were manually crafted by humans, to construct ontologies. The algorithms evolved with NELL @nell and openIE @openie, more statistical models that learned rules to extract informations. But with the rise of deep learning and Large Language Models (LLM), people realized it was easier to answer questions directly by memorizing or retrieving documents than to construct a knowledge base.


== Embedding knowledge in LLMs

Since GPT2 @gpt2, an increasing number of tasks in natural language processing is solved by pre-training large language models (LLMs) to predict text data, and then training then specifically on specific tasks. We will called this approach *expert LLMs*. This have been done for the law by training models directly on law corpus. The most recent model of this type is SauLM @saulm, trained on a large corpus of English law and discussions about the law.


As this approach does work to answer easy questions, this approach has a number of problems: the model always suffer from hallucinations, and facts cannot be edited (when a law changes for example). In addition, a lot of training data is required both to train the base model (to have a general understanding of the law) and for the specific problem being solved. In addition, the answers of the model are not easily explainable.


== Retrieval augmented generation

A more recent approach is Retrieval Augmented Generation (RAG). It is typically used to answer questions from a user using a specific corpus. The user makes a query in natural language, and a distance between this query and law articles is calculated using a given metric. Then, the $k$ nearest articles are given as inputs to a LLM, that is asked to generate an answer to the user. 

Since the knowledge is not only contained in the LLM, it is easier to update it.
But this approach is limited by the size of the context window (the number of words a LLM can read) and by the quality of the metric. This metric is often very sensitive to the style of the text for example. This does not allow for granularity (one part of an article might be very relevant but not all of it).

This approach and the previous one require a LLM trained on the language of the law being considered. Unfortunately, french LLMs are a lot less developed, with a few exceptions. @flaubert and @camembert use the BERT architecture on french documents, and @croissantllm is a decoder-only model trained on English and french.

There are currently no LLM for french legal texts specifically.


== Seeing the law as a graph

Beyond the LLM-based approaches, a lot of advancements have been made by viewing the law as a graph.

Some work use the citations between the articles to understand the relationship between the codes, as in @network_french_codes_1 and @network_french_codes_2. Unfortunately the analysis is restricted to the french codes, and the conclusions are not very surprising. In a similar way, @eu_law_citations use text similarity techniques to identify citations between cases in EU proceedings, and use the resulting graphs to compare types of cases.

Graph approaches have also been used to improve the performance of some tasks. @eu_law_classification shows the performance improvement of using the citations between law documents for legal classification, and @ljp_graphs uses graphs in the task of *legal judgement prediction* on a Chinese dataset.


In these approaches, using graphs helps to capture relations between law articles that would not be possible by using only text. Being able to manipulate directly the relations between law concepts could enable:
- creating a distance between articles that has good properties, in order to retrieve all laws that involve some particular concept.
- making explicit the complex dependencies and relations between law articles, in order to assist lawmakers to review it and make it evolve.
- automatically tagging a new law while it is written, which may help a lawmaker see what the law is interacting with.
- potentially detecting inconsistencies between laws.

More broadly, it would allow more approaches that combine the general knowledge of LLMs and the specific rules of expert systems. In particular, we focus on this goal: as a new law is written, being able to identify automatically what the relations with all the other existing laws are.


Unfortunately, the current approaches mainly use explicit or implicit citations between law articles as the edges of the graph. Indeed, such links are easily accessible, for example the official website for the french law Legifrance @legifrance allow to explore these links. But in practice, citation network is very limited compared to a complete ontology.


This motivates the question: is it possible to generate this graph representation from the text corpus directly ? How to *model the graph of french law* ?


More precisely, the task can be stated in this way (we will precise it below): how to extract an ontology from a legal corpus in an unsupervised or weakly supervised way ?


#pagebreak()

= Problem statement

== Definitions

=== Graph

A (homogeneous) graph is a set of vertices $V$ with a set of edges $E subset V times V$.

In a *heterogeneous graph*, there can be multiple types of edges $E_0, E_1 ... E_k in V times V$

=== Ontology induction

An ontology is a kind of heterogenous graph. It consists in a set of entities (the vertices) and a set of labeled relations between these entities (the edges). In addition, the ontology often has a *schema*, a kind of typing system which add constraints on the relations and which can be more or less complicated. As they are a lot of different approaches to express the constraints, we will not describe them here.


Ontology induction is the process of generating an ontology from unstructured data like text. It consists in 2 main tasks:
- *named entity recognition* (NER), finding the relevant entities in the text and identifying when they are the same.
- *relation extraction* (RE), finding the relations between these entities.

See @ontology_induction_survey for a survey.

=== Supervised, unsupervised, transfer learning

Depending on the way data is collected and used, machine learning methods can be of different types:

In *Supervised learning*, models are trained on labeled data $D = {(x_i, y_i) in X times Y}$, meaning the input data is paired with the correct output. The algorithm learns an approximation function $f: X -> Y$ to map inputs to the desired outputs by minimizing a loss function.

In *unsupervised learning*, the models use unlabeled data ${x_i in X}$. The algorithm learns a representation of data (see @representation), that can be used in tasks where labeled data is not easily available.

In *transfer learning*, a model is trained on labeled data on some distribution and is asked to generalize on cases $D' = {x'_i in X}$ that are very different from the original distribution. This is the same task, but in a different context. In the context of very general models like LLMs, the term "zero-shot learning" is also used when the model is tested on a completely novel task, without specific data @few_shot_learners.


Once a model have been trained to solve a task on a specific dataset $D_0$, people may want to adapt it to solve a novel task by using it on a new dataset $D_1$. This adaptation can be:
- *supervised*, by re-training the model on labeled data $D' = {(x', y')}$ (we will use the expression "weakly supervised" if the labeled data is a very small dataset)
- *unsupervised*, by retraining the model on unlabeled data $D' = {x'}$
- *transfered*, with no additional data.

#pagebreak()

=== Representations and embedings <representation>

A *representation* of a source text is a computer representation of the source text that:
- 1) is a compression of the text
- 2) allows to measure some kind of distance (or similarity) with another representation.

Representations are often used for words. There are two main types of representations:
- *discrete* or *categorical* representations, where a word $w_i$ is represented by a set of properties $S_i$
- *continuous* representations where a word $w_i$ is represented by a vector $v_i in RR^n$. They are often called *embeddings*

See @word_representation for more detail.



== Formalisation

Formally, our task is the following:
- input: 
    - our legal corpus: a set of texts $t_i$, each containing a sequence of words $w_(i, j)$
    - a set of seed entities $E_0$
    - a set of relations $R$
    - a set of seed relations ${(e_1, r, e_2)}$ with $e_1, e_2 in E$ and $r in R$
    - external legal knowledge: a set of texts $d_i$ containing knowledge *about the law*, like a dictionary of the law concepts.

- output:
    - a set of entities $E$
    - for each word $w_k, j$, an entity $e_(k, j) in E$ the words refers to
    - a set of relations between entities ${(e_1, r, e_2)}$ 


== Specificity of the task

Our problem is novel because of the following properties:
- the information extraction part is unsupervised 
- it relies on external legal knowledge as input. @aske is one of the only approach using external knowledge, see below.
- it is very granular, as each word is given a legal entity. This is different from article classification.
- the language used is french


Because of the novelty of the task, one important part of our work will be to *evaluate* our methods. This can be done by creating benchmarks or scores with good properties. Creating good evaluation is also useful to serve as baselines for subsequent works. See @eval for more details.


#pagebreak()

= Related work



== Ontology induction

Constructing an ontology of the law from text documents is an unsolved problem. One major difficulty is that understanding the law requires a lot of prerequisite knowledge, that is not written in the law: it is implicit knowledge.

Ontology induction in law is quite different from ontology induction in other domains, because law is both *descriptive* and *normative*. While most domains like medicine only give knowledge about the world (descriptive), law can additionally create definitions, apply them and express duties (normative). Most approaches in the literature focus on extracting descriptive information.

Another major challenge which we already mentioned is the choice of the ontology schema (@taking_stock). Many types of relations have been proposed and may be useful depending on the task, but choosing the best legal ontology schema for a given task is far from solved.


=== In general

As we mentioned, the default paradigm to process textual information today is RAG, despite its limitations. Thus, work in the domain of ontology induction is a lot less investigated. Still, there are some successful approaches that uses state of the art LLMs:

- @instructuie uses a pre-trained language model to do NER and RE in a pure text format. It is trained on a large inter-disciplinary corpus of data.

- @genie uses constrained text-generation for RE in a similar way.

Unfortunately, theses approaches are all supervised. They use a lot of training data from the specific domains of the texts, with ontologies manually constructed by humans as training data. Similar datasets have not been made for legal law articles, in particular in french. In addition, knowing how to extract information for one domain (for example medical) will not transfer to knowing what is relevant in a legal text: transfer learning often fail.

- @llms4ol uses a lot less training data, but the performances vary a lot with the domain (medical, geography ...)


=== In the legal domain

@construction_legal_kb_llm is the most advanced attempt to construct a legal ontology from a legal corpus. It uses find-tuning techniques to improve the legal knowledge of a LLM in Chinese's criminal law, and uses it to extract entities and relations from text. The paper manually annotated 460 criminal offenses in the Criminal Code according to a fixed ontology schema, and showed strong results on the test evaluation.

@aske used a different approach to extract entities from a legal corpus. It uses an existing LLM and an external dictionary of word definitions. The ontology is very simple, since it contains only hierarchical entities and no relations. It is more similar to a text annotation task than a ontology induction task.


== Topic modelling and text annotation

A weaker form of ontology induction is *topic modelling*, or *text annotation*. Given a set of documents, the goal is to induce categories (or topics) the documents are related to. The categories can mix entities and relation aspects, which make it harder to build a knowledge graph from it.

@classifying_legal_norms tries to create a hierarchy of law types by making expert interacting with an algorithm.

@topic_modelling_legal_bert introduces a methodology for legal topic modelling using a model trained on legal data, so that it can be used as baseline.

@structure_us_federal_law tries to predicts aspects of the US federal law dynamics using classical topic modelling techniques.

@renumbering_tax uses Word2Vec, a classical word embedding model, to compute a distance between law articles. It is specific to tax law and the task is very precise: renumbering the sections of the document.



A very important question in topic modelling is whether to use *bag of words* or *text embeddings* to represent categories.
- in *bag of words*, the categories exactly correspond to a set of words appearing in the text. It is a *discrete* representation. It is easily interpretable, but it is very limited as it cannot capture relationships between words or words used in different meanings
- in *text embeddings*, parts of the text are directly transformed into vectors, and the categories exist in this vector space. It is a *continuous* representation. This approach can lead to more overfitting and less explainability. For example, it might be sensitive to the style of the articles, which is not relevant.

There are hybrid methods that use discrete and continuous representations at different stages.

One of the most recent technique to extract concepts from a language model is sparse auto-encoders.  It was used in @scaling_monosemanticity to identify concepts in a text model in an unsupervised way.

== Evaluation <eval>

There are 2 main ways to evaluate the quality of the ontology extraction: *intrinsic* and *extrinsic* evaluations. An important part of the research project will be to come up with such evaluation, to measure how successful our approach is.

=== Intrinsic

An intrinsic evaluation measures the quality of the ontology in itself. This requires to know which properties the ontology should have. For example, an evaluation could measure how much our algorithm detects 2 opposite concepts in the same paragraph, which indicates a form of inconsistency.

This type of evaluation is better because it measures the quality directly, but it can be very hard to implement. In the case of legal ontologies, a "good classification" depends a lot on human preferences and standards, which is costly to collect.

For example, researchers in @llm_for_legal_experts generated decision trees from legal sentences and evaluated the result using ratings by human evaluators.

=== Extrinsic

An extrinsic evaluation measures how useful the ontology is for different downstream tasks. For example, how well it can help to predict the charges that apply in various contexts.

It is easier to come up with an extrinsic evaluation, but they are heavier to setup and may be misleading. An ontology may be very useful for certain tasks, but useless for others.

Such evaluations could include legal question-answering @legal_question_rag and detecting similarities between articles @similarity_prediction.

#pagebreak()

#bibliography("papers.bib")
