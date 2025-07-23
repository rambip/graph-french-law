#set page(paper: "presentation-16-9")

#show footnote.entry: set text(size: 12pt)
#set align(center+horizon)

#let title(x) = [
    #set align(center+top)
    #heading(x)
]

#set text(size: 50pt)
Modeling the graph of French Law

#set text(size: 30pt)
Antonin PERONNET

#set text(size: 20pt)


#pagebreak()

#title[ Machine Learning for Law]


#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge

#diagram(
	spacing: (40pt, 30pt),
	node-stroke: luma(80%),
	node((0,0), width: 200pt, [ 💰 Tax calculation], name: <a>),
	node((0,1), width: 200pt, [⚖️ Legal Judgement prediction], name: <b>),
	node((0,2), width: 200pt, [✅Contract checking], name: <c>),
	node((0,3), width: 200pt, [...], name: <d>),

	node((2,1), name: <m>),
	node((3,1), [❔Question answering], name: <r>),


        edge(<m>, <r>, "->"),
	edge(<a.east>, <m>,  "-"),
	edge(<b.east>, <m>,  "-"),
	edge(<c.east>, <m>,  "-"),
	edge(<d.east>, <m>,  "-"),
)

#v(20pt)

*QA = retrieval + reasonning*



#grid(
    columns: (1fr, 1fr),
    [
    #image("../images/legalbench_results_big_sota_models.png", width: 90%)
    #footnote[LegalBench: A Collaboratively Built Benchmark for Measuring Legal Reasoning in Large Language Models (Guha et Al, 2024)]
    ],
    [
    == Limitations
        - hallucinations#footnote[Large Legal Fictions: Profiling Legal Hallucinations in Large Language Models (Dahl M et Al, 2024)]
        - not up to date
    ]
)



#pagebreak()

#title[The problem with the law]

#align(horizon)[
#image("../images/problem_law_two_way.svg", width: 70%)
]


#v(10pt)

#block([
#set align(left)
- Law evolves
- No standard
- Hard to retrieve
])



//}


#title[ Representing the law: Ontology]

#grid(columns: (3fr, 2fr),
[== What],
[== Why],
[
#image("../images/illustration_ontology_law.svg")
],
[
#set align(left)
- no hallucination
- can be edited
- better legal reasonning #footnote[Legal Judgment Prediction via Heterogeneous Graphs and Knowledge of Law Articles (Qian Dong and Shuzi Niu, 2021)]

And can help lawmakers !
]
)


#pagebreak()


#title[ Problem statement]

#image("../images/task_formulation.svg", height: 70%)

#v(10pt)

#grid(columns: (20%, 20%),
[
- unsupervised
],
[
- granular
]
)

#pagebreak()

#title[Ontology: Chosing the right one
#footnote[Taking stock of legal ontologies: a feature-based comparative analysis (Leone V., Di Caro L., Villata S., 2020)]
]


#let c_blue(x) = {
    set text(stroke: blue, size: 15pt)
    x
}

#grid(columns: (1fr, 1fr),
    gutter: 50pt,
diagram(
    spacing: (0pt, 12pt),
    node((0, -0), c_blue[References to \ other articles]),
    node((0, -1), c_blue[Topics]),
    node((0, -2), c_blue[Statutes]),
    node((0, -3), c_blue[Legal terms]),
    node((0, -4), c_blue[Every term]),
    node((0, -5), c_blue[Every word]),
    node((1, 1), name: <l>),
    node((1, -6), name: <r>),
    edge(<l>, <r>, "->"),
    node((1, -8), inset: -3em, [\#entities / document]),
),
[
#set align(left)
- For retrieval ?
- For Extraction ?
- For Manipulation ?
]
)




#pagebreak()

#title[ Locks]

#{
set align(horizon)

grid(columns: (1fr, 1fr, 1fr),
[
== fundamental
    - choice of the ontology
    - normative texts
],
[
== practical
    - specialized LLMs
    - annotated data
],
[
== evaluation
    - intrinsic
    - extrinsic
]
)
}

#pagebreak()

#title[ Added material ]

#image("../images/illustration_doctrine.png")
#image("../images/illustration_rag.png")


#pagebreak()

#title[ Representing the law: Code]

== Formal language

$
(exists p in "parents"(x); "Français"(p)) => "Français"(x)
$


== Programming language#footnote[Catala: a programming language for the law (Merigoux D., Chataing N., Protzenko J, 2021)]

#{
set text(size: 15pt)

```catala
declaration scope Child:
  input age content integer
  output is_eligible_article_3 condition

scope Child:
  rule is_eligible_article_3 under condition age < 18 consequence fulfilled
```
}

#image("../images/legal_tasks_classification.svg")
