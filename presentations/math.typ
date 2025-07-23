#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge

$D$ is a set of documents. We will suppose each document has one single sentance for now.

Let $d$ be a document in $D$.

For $d$ is a set of sequence of tokens $(t_i)_(0 <= i < n)$

We associate embeddings $(u_i)_(0 <= i < n)$

And a tree structure represented by it's adjacency matrix $T$. $T_(i j)$ means that $i$ if the father of $j$ in the tree, according to dependency parsing.

Fome some tree $T$, we can multiply it by a diagonal matrix with boolean coefficients, $C$. We will refer to this matrix a the "cut".

We will use the following notation to describe this bilinear map:
$
  Phi(T, C) = T "diag"(C_1, C_2, ..., C_n)
$

For example, let's take the following document:


#diagram(
	node-stroke: .1em,
	spacing: 4em,
	node((0,0), `est`, radius: 2em, name: <est>),
	node((1,0), `mis`, radius: 2em, name: <mise>),
	node((2,0), `sur`, radius: 2em, name: <sur>),
	node((3,0), `le`, radius: 2em, name: <le>),
	node((4,0), `marché`, radius: 2em, name: <marche>),
	edge(<mise>, <marche>, `obl`, "-|>", bend: -40deg),
	edge(<mise>, <est>, `aux`, "-|>", bend: 0deg),
	edge(<marche>, <le>, `det`, "-|>", bend: 0deg),
	edge(<marche>, <sur>, `case`, "-|>", bend: 30deg),
)

This is more classically represented as:
#diagram(
  node-stroke: .1em,
	spacing: 4em,
	node((0,1), `est`, radius: 2em, name: <est>),
	node((1,0), `mis`, radius: 2em, name: <mise>),
	node((2,2), `sur`, radius: 2em, name: <sur>),
	node((3,2), `le`, radius: 2em, name: <le>),
	node((4,1), `marché`, radius: 2em, name: <marche>),
	edge(<mise>, <marche>, `obl`, "-|>", bend: 10deg),
	edge(<mise>, <est>, `aux`, "-|>", bend: 0deg),
	edge(<marche>, <le>, `det`, "-|>", bend: -10deg),
	edge(<marche>, <sur>, `case`, "-|>", bend: -20deg),
)

The associated matrix is

$
  T = mat(
    0, 0, 0, 0, 0;
    1, 0, 0, 0, 1;
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 1, 1, 0;
  )
$

Using the cut $C = mat(1; 1; 1; 1; 0)$, he have

$
  Phi(T, C) = mat(
    0, 0, 0, 0, 0;
    1, 0, 0, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 1, 1, 0;
  )
$


We get a new graph with the edge between the third word and its parent removed.

#diagram(
  node-stroke: .1em,
	spacing: 4em,
	node((0,1), `est`, radius: 2em, name: <est>),
	node((1,0), `mis`, radius: 2em, name: <mise>),
	node((2,2), `sur`, radius: 2em, name: <sur>),
	node((3,2), `le`, radius: 2em, name: <le>),
	node((4,1), `marché`, radius: 2em, name: <marche>),
	edge(<mise>, <marche>, `obl`, "--|>", bend: 10deg),
	edge(<mise>, <est>, `aux`, "-|>", bend: 0deg),
	edge(<marche>, <le>, `det`, "-|>", bend: -10deg),
	edge(<marche>, <sur>, `case`, "-|>", bend: -20deg),
)

We get 2 subtrees. In general, we get the new roots of the subtree by considering $"Ker"(T C)$

We not $"sub"(T)$ the matrix containing on each line $i$, the set of descendents of the node $i$
#footnote[
  There is a close form:

  $"sub"(T) = T^t + (T^2)&t + ... + (T^n)^t  \
    = (I_n - T^t)^(-1)
  $
]

We can then express one single subtree with $Phi(T, "sub"(T C)E_i)$

Let's consider some score $s: {0, 1}^(n^2) -> RR$

The reward of some cut over a tree is:
$R(T, C) = sum_(i=1)^n s(Phi(T, "sub"(T C)E_i))$

We define a parametric model over the cuts of a tree:

$pi_(theta)(T) = sum_(i=1)^n exp(w_theta dot u_i) / Z_(theta)$
