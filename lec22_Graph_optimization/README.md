# Graph Optimization

**Outline**

* What is a graph?
* Graph representations
* Implementing breadth-first search
* Graph compression/reordering

**What is a Graph?**

* Vertices model objects
* Edges model relationships between objects

* Edges can be directed
    * Relationship can go one way or both ways
* Edges can be weighted
    * Denotes "strength", distance, etc.
* Vertices and edges can have types and metadata

**Some Applications of Graphs**

* Knowledge graphs
* Social network queries
    * Finding all your friends who went to the same
    high school as you
    * Finding common friends with someone
    * Social networks recommending people whom
    you might know
    * Product recommendation
* Finding good clusters
    * Finding groups of vertices that are "well-
    connected" internally and "poorly-
    connected" externally
    * Finding people with similar interests
    * Detecting fraudulent websites
    * Document clustering
    * Unsupervised learning
* Connectomics
    * Study of the brain network structure
* Image Segmentation
    * Pixels correspond to vertices
    * Edges between neighboring pixels with weight
    corresponding to similarity

**Graph Representations**

Vertices labeled from 0 to n-1

* Adjacency matrix\
Value at (i, j) is "1" if edge exists, "0" otherwise
* Edge list\
(0,1) (1,2) (4,1) ...
* Adjacency list
    * Array of pointers (one per vertex)
    * Each vertex has an unordered list of its edges
* Compressed sparse row (CSR)
    * Two arrays: Offsets and Edges
    * Offsets[i] stores the offset of where vertex i's
    edges start in Edges

**Tradeoffs in Graph Representations**

* What is the cost of different operations?
```
____________________________________________________________________
                | Adjacency | Edge      | Adjacency     | Compressed|
                | matrix    | list      | list          | sparse row|
----------------|-----------|-----------|---------------|-----------|
Storage cost /  |           |           |               |           |
scanning        |   O(n^2)  |    O(m)   |   O(m+n)      |   O(m+n)  |
whole graph     |           |           |               |           |
----------------|-----------|-----------|---------------|-----------|
Add edge        |    O(1)   |    O(1)   | O(1)/O(deg(v))|   O(m+n)  |
----------------|-----------|-----------|---------------|-----------|
Delete edge     |           |           |               |           |
from vertex v   |    O(1)   |    O(m)   |   O(deg(v))   |   O(m+n)  |
----------------|-----------|-----------|---------------|-----------|
Finding all     |           |           |               |           |
neighbors of a  |    O(n)   |    O(m)   |   O(deg(v))   | O(deg(v)) |
vertex v        |           |           |               |           |
----------------|-----------|-----------|---------------|-----------|
Finding if w is |           |           |               |           |
a neighbor of v |    O(1)   |    O(m)   |   O(deg(v))   | O(deg(v)) |
________________|___________|___________|_______________|___________|
```

The algorithms in this lecture are best implemented with CSR.
* Sparse graphs
* Static algorithms - no updates to graph
* Need to scan over neighbors of a given set of vertices

**Properties of real-world graphs**

* They can be big (but not too big)
    * Twitter\
    41 M vertices, 1.5 B edges, 6.3 GB
    * Yahoo\
    1.4 B vertices, 6.6 B edges, 38 GB
    * Common Crawl\
    3.5 B vertices, 128 B edges, 540 GB
* Sparse (m much less than n^2)
* Degrees can be highly skewed

**Breadth-First Search (BFS)**

* Given a source vertex __s__, visit the
vertices in order of distance from __s__
* Possible outputs:
    * Vertices in the order they were visited
    * The distance from each vertex to __s__
    * A BFS tree, where each vertex has a
    parent to a neighbor in the previous level

**Serial BFS Algorithm**

```c
bfs(Graph, root):
    for each node n in Graph:
        n.distance = INF
        n.parent = NIL

    create empty queue Q

    root.distance = 0
    Q.enqueue(root)

    while Q is not empty:
        current = Q.dequeue()
        for each node n that is adjacent to current:
            if n.distance == INF:
                n.distance = current.distance + 1
                n.parent = current
                Q.enqueue(n)
```

* Assume graph is given in compressed sparse row format
    * Two arrays: Offsets and Edges
    * n vertices and m edges (assume Offsets[n] = m)


```c
int* parent = (int*)malloc(sizeof(int)*n);
int* queue = (int*)malloc(sizeof(int)*n);

for (int i = 0; i < n; ++i) {
    parent[i] = -1; // initialization
}

queue[0] = source;
parent[source] = source;

int q_front = 0;
int q_back = 1;

// while queue not empty
while (q_front != q_back) {
    int current = queue[q_front++]; // dequeue
    int degree = Offsets[current + 1] - Offsets[current];
    for (int i = 0; i < degree; ++i) {
        int ngh = Edges[Offsets[current] + i];
        // check if neighbor has been visited
        if (parent[ngh] == -1) {
            parent[ngh] = current;
            // enqueue neighbor
            queue[q_back++] = ngh;
        }
    }
}
```

What is the most expensive part of the code?

* ```if (parent[ngh] == -1)``` - total of m random accesses
* Random accesses cost more than sequential accesses

**Analyzing the program**

(Approx.) analyze number of cache misses (cold cache;
cache size << n; 64 byte cache line size; 4 byte int)

* n/16 for initialization
* n/16 for dequeuing
* n for accessing ```Offsets``` array
* <= 2n + m/16 for accessing ```Edges``` array
* m for accessing parent array
* n/16 for enqueuing

Total <= (51/16)n + (17/16)m

What if we can fit a bitvector of size n in cache?

* Might reduce the number of cache misses
* More computation to do bit manipulation

**BFS with bitvector**

```c
int* parent = (int*)malloc(sizeof(int)*n);
int* queue = (int*)malloc(sizeof(int)*n);

int nv = 1+n/32;
int* visited = (int*)malloc(sizeof(int)*nv);

for (int i = 0; i < n; ++i) {
    parent[i] = -1; // initialization
}

for (int i = 0; i < nv; ++i) {
    visited[i] = 0;
}

queue[0] = source;
parent[source] = source;

visited[source/32] = (1 << (source % 32));

int q_front = 0;
int q_back = 1;

// while queue not empty
while (q_front != q_back) {
    int current = queue[q_front++]; // dequeue
    int degree = Offsets[current + 1] - Offsets[current];
    for (int i = 0; i < degree; ++i) {
        int ngh = Edges[Offsets[current] + i];
        // check if neighbor has been visited
        if (!((1 << ngh % 32) & visited[ngh/32])) {
            visited[ngh/32] |= (1 << (ngh % 32));
            parent[ngh] = current;
            // enqueue neighbor
            queue[q_back++] = ngh;
        }
    }
}
```

Bitvector version is faster for large enough values of m

**Parallel BFS Algorithm**

```c
BFS(Offsets, Edges, source) {
    parent, frontier, frontierNext, degrees are arrays
    cilk_for(int i = 0; i < n; ++i)
        parent[i] = -1;
    frontier[0] = source;
    frontierSize = 1;
    parent[source] = source;

    while (frontierSize > 0) {
        cilk_for(int i = 0; i < frontierSize; ++i)
            degrees[i] = Offsets[frontier[i] + 1] - Offsets[frontier[i]];
        perform prefix sum on degrees array
        cilk_for(int i = 0; i < frontierSize; ++i) {
            v = frontier[i];
            index = degrees[i];
            d = Offsets[v + 1] - Offsets[v];
            for (int j = 0; j < d; ++j) { // can be parallel
                ngh = Edges[Offsets[v] + j];
                if (parent[ngh] == -1 && compare-and-swap(&parent[ngh], -1, v)) {
                    frontierNext[index + j] = ngh;
                } else {
                    frontierNext[index + j] = -1;
                }
            }
        }
    }
}
```

**BFS Work-Span Analysis**

* Number of iterations <= diameter D of graph
* Each iteration takes Θ(log m) span for
cilk_for loops, prefix sum, and filter
(assuming inner loop is parallelized)

Span = Θ(D log m)

* Sum of frontier sizes = n
* Each edge traversed once -> m total visits
* Work of prefix sum on each iteration is
proportional to frontier size -> Θ(n) total
* Work of filter on each iteration is proportional
to number of edges traversed -> Θ(m) total

Work = Θ(n + m)

**Dealing with nondeterminism**

compare-and-swap is not deterministic

```c
BFS(Offsets, Edges, source) {
    // omitted initialization code
    cilk_for(int i = 0; i < n; ++i)
        parent[i] = INF;

    while (frontierSize > 0) {
        compute degrees array and perform prefix sum on it
        cilk_for(int j = 0; j < d; ++j) { // phase 1
            v = frontier[i];
            index = degrees[i];
            d = Offsets[v + 1] - Offsets[v];
            for (int j = 0; j < d; ++j) { // can be parallel
                ngh = Edges[Offsets[v] + j];
                writeMin(&parent[ngh], v); // smallest value gets written
            }
        }
        cilk_for(int i = 0; i < frontierSize; ++i) { // phase 2
            v = frontier[i];
            index = degrees[i];
            d = Offsets[v + 1] - Offsets[v];
            for (int j = 0; j < d; ++j) { // can be parallel
                ngh = Edges[Offsets[v] + j];
                if (parent[ngh] == v) { // check if "won"
                    parent[ngh] = -v; // to avoid revisiting
                    frontierNext[index + j] = ngh;
                } else {
                    frontierNext[index + j] = -1;
                }
            }
        }
        filter out "-1" from frontierNext,
        store in frontier,
        and update frontierSize
    }
}

writeMin(addr, newval) {
    oldval = *addr;
    while (nweval < oldval) {
        if (CAS(addr, oldval, nweval))
            return;
        else
            oldval = *addr;
    }
}
```

**Direction-Optimizing BFS**

**Two ways to do BFS**

* Bottom-up is better when frontier is large
and many vertices have been visited
    * Reduces number of edges traversed

* Top-down is better when frontier is small

Threshold of frontier size > n/20 works well in practice

**Representing the frontier**

* Sparse integer array
    * [1, 4, 7]
* Dense byte array
    * [0, 1, 0, 0, 1, 0, 0, 1]
    * Can further compress this by using 1 bit per vertex
    and using bit-level operations to access it

* Sparse representation used for top-down
* Dense representation used for bottom-up
* Need to convert between representations
when switching methods

**Graph Compression and Reordering**

**Graph Compression on CSR**

```
Vertex IDs

Offsets     | 0 | 4 | 5 | 11| ...

Edges       | 2 | 7 | 9 | 16| 0 | 1 | 6 | 9 | 12| ...

Compressed  | 2 | 5 | 2 | 7 | -1| -1| 5 | 3 | 3 | ...
Edges
```

* For each vertex v:
    * First edge: difference is Edges[Offsets[v]] - v
    * i'th edge (i > 1): difference is Edges[Offsets[v] + i] - Edges[Offsets[v] + i - 1]
* Want to use fewer than 32 or 64 bits to store each value

**Variable-length codes**

* k-bit (variable-length) codes
    * Encode value in chunks of k bits
    * Use k-1 bits for data, and 1 bit as the "continue" bit
* Decoding is just encoding "backwards"
    * Read chunks until finding a chunk with a "0" continue bit
    * Shift data values left accordingly and sum together
* Branch mispredictions from checking continue bit

**Encoding optimization**

* Another idea: get rid of "continue" bits
* Increases space, but makes decoding cheaper
(no branch misprediction from checking "continue" bit)

**Decoding on-the-fly**

* Need to decode during the algorithm
    * If we decoded everything at the beginning
    we would not save any space.

All chunks can be decoded in parallel

**What is the cost of decoding on-the-fly?**

* In parallel, compressed can outperform uncompressed
    * These graph algorithms are memory-bound and memory
    subsystem is a bottleneck in parallel (contention for resources)
    * Spends less time on memory operations, but has to decode
* Decoding has good speedup so overall speedup is higher

**Graph Reordering**

* Reassign IDs to vertices to improve locality
    * Goal: Make vertex IDs close to their neighbors' IDs
    and neighbors' IDs close to each other
* Can improve compression rate due to smaller "differences"
* Can improve performance due to higher cache hit rate
* Various methods: BFS, DFS, METIS, by degree, etc.
