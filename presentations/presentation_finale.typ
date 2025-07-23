#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge
#import "@preview/diagraph:0.3.3": raw-render
#import "@preview/algorithmic:1.0.0": *

//#set page(paper: "presentation-16-9", numbering: "1", number-align: right)

#show footnote.entry: set text(size: 12pt)
#set align(center+horizon)
#set text(size: 20pt)

#let title(x) = [
    #set align(center+top)
    #heading(x)
]

#[
#text(size: 50pt, "Legal Entity Recognition in the graph of French Law")

#text(size: 30pt, "Antonin PERONNET")
]

#pagebreak()

#title[Contexte: la loi en tant que structure de données]

#align(horizon)[
#image("../images/problem_law_two_way.svg", width: 70%)
]

#v(10pt)

#block([
#set align(left)
- Manque de contraintes
- Recherche difficile
])

#pagebreak()

#title[La solution: une ontologie]

#grid(
columns: (1fr, 1fr),
  image("../images/ontology_fr.excalidraw.svg"),
  block([
    #set align(left)
    - forme de compression
    - éditée / vérifiée
    - recherche par mots-clés
    - base de nombreuses autres methodes
  ])
)

#pagebreak()

#title[Des difficultés liées au domaine]

#grid(
  columns: (1fr, 1fr),
  inset: 20pt,
  stroke: (thickness: 1pt, dash: "dotted"),
  image("../images/no-highlighter-logo.png", width: 80pt),
  image("../images/term_source.excalidraw.png", height: 100pt),
  grid.cell(colspan: 2,
    $
    underbracket("Agence" "nationale" "de" underbracket("sécurité" "du" "médicament" "et" "des" overbracket("produits" "de" "santé", "entity 1"), "entity 2"), "entity 3")
    $,
  )
)

#pagebreak()
#title[Définition]

#table(
  columns: (3fr, 4fr, 3fr),
  inset: 20pt,
  stroke: (x, y) => if x == 1 {
      (
        left: 1pt + gray,
        right: 1pt + gray
      )
    },
  table.cell(colspan: 3)[
    une _Entité Légale_ est un concept:
  ],
  [*Précis*],
  [*Remplaçable*],
  [*Informatif*],
  [forme cannonique, \ sous forme de groupe nominal],
  [Par une autre entité, \ en gardant une phrase qui a du sens],
  [Permet a un juriste \ de retrouver facilement un article],
  [
    #set text(size: 15pt)
    #text(stroke: red, sym.crossmark) organisme concerné par \
    #text(stroke: green, sym.checkmark) organisme militaire
  ],
  [
    #set text(size: 15pt)
    $"Il est pris en chage par " cases("la famille", "le responsable")$
  ],
  [],
)

#pagebreak()
#title[Contribution 1: Formalisme]

#grid(
  columns: (1fr, 50pt, 1fr),
  inset: 10pt,
  stroke: (thickness: 1pt, dash: "dotted"),
  [texte $t$],
  [],
  [texte $t$ masqué],
  [#set text(size: 13pt)
    "Est français l'enfant dont au moins un parent est français"
  ],
  sym.arrow,
  [
    #set text(size: 13pt)
    "Est français l'enfant dont au moins un #box(fill: black, "parent") est #box(fill: black, "français")"
  ],
  $-log_2(P(t))$,
  [],
  $-log_2(P(t \\ "parent" "français"))$
)

Mesure de l'information contenue dans une collection d'entités:
$
  H_m (e_1, ..., e_n) = sum_(t in D) log_2((P (t \\ e_1, ..., e_n)) / (P (t)))
$

#pagebreak()
#title[Contribution 2: Algorithme]

#block(inset: -10pt, image("../images/articles_horizontal.svg", height: 15%))
#sym.arrow.b.stroked


#grid(
  columns: (1fr, 100pt),
  inset: -20pt,
  image("../images/candidate_trees.svg", height: 45%),
  [\+ Estimation des probabilités de chaque élément]
)

#sym.arrow.b.stroked

graphe de dépendances

#pagebreak()
#title[Contribution 2: Algorithme (cont.)]

#raw-render(```
digraph {
	graph [rankdir=LR]
	node [shape=box style=filled]
	edge [fontsize=8]
	3380 [label="recherche d' emploi" fillcolor=lightblue]
	3 [label=emploi fillcolor=lightblue]
	14615 [label="obligation d' emploi" fillcolor=none]

	11613 [label="entreprises , de la concurrence , de la consommation , du travail et de l' emploi" fillcolor=lightblue]
	29973 [label="relations sociales des plateformes d' emploi" fillcolor=none]
	29969 [label="plateformes d' emploi" fillcolor=none]
	6564 [label="demandeurs d' emploi" fillcolor=lightblue]
	3380 -> 3 [label=47336.42]
	14615 -> 3 [label=71518.26]
	11613 -> 3 [label=244524.04]
	29973 -> 29969 [label=330497.84]
	29969 -> 3 [label=525960.19]
	6564 -> 3 [label=579871.10]
}
```,
width:100%
)

#sym.arrow.b.stroked

$
  H_m (e_1, ..., e_n) = lambda_1 x_1 + lambda_12 x_1 x_2 + ... + lambda_n x_n
$

#sym.arrow.b.stroked

Recuit simulé

#pagebreak()
#title[Contribution 3: Benchmark et Evaluation]

#grid(
  columns: (1fr, 1fr),
  gutter: 20pt,
  image("../images/dict-juridique-def-ax.png"),
  image("../images/dict-juridique-def-b.png"),
  grid.cell(colspan: 2, inset: 5pt)[
    Cités ensemble #sym.arrow entités en commun (souvent)
  ]
)

#pagebreak()
#title[Contribution 3: Benchmark et Evaluation]

#image("../images/triple_abx.svg", height: 90%)

#pagebreak()
#title[Contribution 3: Benchmark et Evaluation (cont.)]

#grid(
  columns: (1fr, 1fr),
  image("../results/abx.svg", height: 90%),
  image("../results/abx_relative.svg", height: 90%),

)
#pagebreak()
#title[Conclusion]

#grid(
  columns: (1fr, 1fr),
  inset: 10pt,
  [*Limitations*], [*travaux futurs*],
  [#set align(left)
    - limité à des séquences de noms et d'adjectifs consécutifs: faux négatifs
    - modèle probabiliste simpliste
  ],
  [#set align(left)
    - catégoriser et fusionner les entités
    - extraire des attributs
    - annotations de qualité
  ]
)

#pagebreak()
#title[Bilan d'experience]

#block[
  #set align(left)
  + choisir la tâche en fonction des jeux de données disponibles
  + ne pas être trop ambitieux
  + explorer, formaliser, puis implémenter
  + ne pas complexifier l'approche tant qu'on ne sait pas l'évaluer
]

#pagebreak()

#title[Annexe: TF-IDF]

#image("../results/tfidf_citations.png")

#pagebreak()
#title[Annexe: Derivation for subtrees]

#[

#set text(size: 13pt)
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

]



#pagebreak()
#title[Annexe: entités]

#let w = word => {
 box(fill: luma(90%), inset: 5pt, word)
}
#set text(size: 10pt)
#table(
  columns: (1fr),
  stroke: 1pt,
  inset: 1pt,
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
