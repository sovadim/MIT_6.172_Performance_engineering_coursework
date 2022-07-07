# Domain Specific Languages and Autotuning

Saman Amarasinghe

**Domain Specific Languages**

* Capture the programer intent at a higher level of abstraction.
* Obtain many software engineering benefits
    * clarity, portability, maintainability, testability, etc.
* Provide the compiler more opportunities for higher performance
    * Can encode expert knowledge of domain specific transformations
    * Better view of the computation performed without heroic analysis
    * Less low-level decisions by the programmer that has to be undone

**Outline**

* GraphIt
* Halide
* OpenTuner

**GraphIt**

**PageRank Example in C++**

```c++
void pagerank(Graph &graph, double *new_rank, double *old_rank,
              int *out_degree, int max_iter)
{
    for (size_t i = 0; i < max_iter; ++i) {
        for (src: graph.vertices()) {
            for (dst: graph.getOutgoingNeighbors(node)) {
                new_rank[dst] += old_rank[src] / out_degree[src];
            }
        }
    }
    for (node: graph.vertices()) {
        new_rank[node] = base_score + damping * new_rank[node];
    }
    swap(old_rank, new_rank);
}
```

Slow

```c++
// Here was extremely big piece of optimized code
```

**Graph Algorithms**

* Topology-Driven Algorithms\
Work on all edges and vertices
* Data-Driven Algorithms\
Work on a subset of vertices and edges

**Graph Traversal**

* Different Traversal Orders have different performance characteristics

Push Traversal (from root to neighbor nodes)
* Incurs overhead with atomics
* Traverses no extra edges

Pull Traversal (from neighbor nodes to root)

Partitioning
* Improves locality
* Needs extra instructions to traverse two graphs

**Power-Low Graphs**

* Power-Law Degree Distribution, Small Diameter, Poor Locality
* World Wide Web
* Social Networks

**Bounded-Degree Graphs**

* Bounded Degree Distribution, Large Diameter, Excellent Locality
* Maps
* Engineering Meshes

**Optimization Tradeoff Space**

```
            Locality
                 / \
                / *Partitioning
               /     \
              /  * Pull
             /     * Push
            /___________\
Parallelism         Work-Efficiency
```

**GraphIt**

* Decouple algorithms from optimization for graph applications
* Algorithm: What to compute
    * High level: ignores all the optimization details
* Optimization (schedule): How to compute
    * Easy to use for users to try different combinations
    * Powerful enough to beat hand-optimized libraries by up to 4.8x

Algorithm Language

```c++
edges.apply(func)

edges.from(vertexset)
     .to(vertexset)
     .srcFilter(func)
     .dstFilter(func)
     .apply(func)
```

**PageRank Example**

```c++
func updateEdge(src: Vertex, dst: Vertex)
    new_rank[dst] += old_rank[src] / out_degree[src]
end

func updateVertex(v: Vertex)
    new_rank[v] = beta_score + damping * new_rank[v]
    old_rank[v] = new_rank[v]
    new_rank[v] = 0
end

func main()
    for i in 1:max iter
        #s1# edges.apply(updateEdge)
        vertices.apply(updateVertex)
    end
end
```

Scheduling Language

```c++
// Scheduling Function
schedule:
    program->configApplyDirection("s1", "SparsePush")

// Pseudo Generated Code
double *new_rank = new double[num_verts];
double *old_rank = new double[num_verts];
int *out_degree = new int[num_verts];
...
for (NideID src: vertices) {
    for (NodeID dst: G.getOutNgh(src)) {
        new_rank[dst] += old_rank[src] / out_degree[src];
    }
}
```

```c++
// Scheduling Function
schedule:
    program->configApplyDirection("s1", "SparsePush")
    program->configApplyDirection("s1", "dynamic-vertex-parallel")

// Pseudo Generated Code
double *new_rank = new double[num_verts];
double *old_rank = new double[num_verts];
int *out_degree = new int[num_verts];
...
parallel_for (NideID src: vertices) {
    for (NodeID dst: G.getOutNgh(src)) {
        atomic_add(new_rank[dst], old_rank[src] / out_degree[src]);
    }
}
```

**Many More Optimizations**

* Direction optimizations
    * SparsePush, DensePush, DensePull
* Parallelization strategies
    * serial, dynamic-vertex-parallel, static-vertexparallel,
    edge-aware-dynamic-vertex-parallel, edge-parallel
* Cache
    * fixed-vertex-count, edge-aware-vertexcount
* NUMA
    * serial, static-parallel, dynamic-parallel
* AoS, SoA
* Vertexset data layout
    * bitvector, boolean array

**Halide**

* A new language and compiler
    * Originally developed for image processing
    * Focuses on stencils on regular girds
    * Complex pipelines of stencil kernels
    * Support other operations like reductions and scans
* Primary goal
    * Match or exceed hand optimized performance on each architecture
    * Reduce the rote programming burden of highly optimized code
    * Increase the portability without loss of performance

**Example: 3x3 Blur**

```c++
void box_filter_3x3(const Image &in, Image &blury) {
    Image blurx(in.width(), in.height()); // allocate blurx array

    for (int y = 0; y < in.height(); ++y) {
        for (int x = 0; x < in.height(); ++x) {
            blurx(x, y) = (in(x - 1, y) + in(x, y) + in(x + 1, y)) / 3;
        }
    }

    for (int x = 0; x < in.width(); ++x) {
        for (int y = 0; y < in.height(); ++y) {
            blury(x, y) = (blurx(x, y - 1) + blurx(x, y) + blurx(x, y + 1)) / 3;
        }
    }
}
```

Slow

```c++
// Here was extremely big piece of optimized code
```

Halide x2 faster than Adobe implementation of Laplace Filter

**Decouple Algorithm From Schedule**

* Algorithm: what is computed
    * The algorithm defines pipelines as pure functions
    * Pipeline stages are functions from coordinates to values
    * Execution order and storage are unspecified
* Schedule: where and when it's computed
    * Architecture specific
    * Single, unified model for all schedules
    * Simple enough to search, expose to user\
    Powerful enough to beat expert-tuned code

Stencil Pipelines Require Tradeoffs Determined By Organization Of Computation

```
redundant     locality
work ---------
    \        /
     \      /
      \    /
       \  /
        \/
        parallelism
```

**Parallelism**

* Need parallelism to keep multicores, vector units,
clusters and GPUs busy
    * Too much parallelism is at best useless but can
    even be detrimental

**Locality**

* Ones a data is touched, how quickly is it reused
* Faster reuse means better cache locality
* Locality at multiple levels: registers, L1, L2, LLC

**Redundant Work**

* Sometimes cannot get both locality and parallelism
* A little redundant computation can facilitate both
* Extra cost should be amortizable by the wins

**OpenTuner**

* Performance Engineering is all about finding the right:
    * block size in matrix multiply (voodoo parameters)
    * strategy in the dynamic memory allocation
    * flags in calling GCC to optimize the program
    * schedule in Halide
    * schedule in GraphIt

How to find the right value

1. Model-Based
2. Heuristic-Based
3. Exhaustive Search
4. Autotuned (OpenTuner)

**Model Based**

Come-up with a comprehensive model
* In this case, a model for the memory system and data reuse

Pros:
* Can explain exactly why we chose a given tile size
* "Optimal"

Cons:
* Hard to build models
* Cannot model everything
* Our model may miss an important component

**Heuristic Based**

Works most of the time
* In this case, small two-to-the-power tile sized works most of the time
* Hard-code constants

Pros:
* Simple and easy to do
* Works most of the time

Cons
* Simplistic
* Always suboptimal performance
* In some cases may be really bad

**Exhaustive Search**

Empirically evaluate all the possible values
* All possible integers for some constant

Pros:
* Will find the "optimal" value

Cons:
* Only for the inputs evaluated
* Can take a long time

**Autotuning**

1. Define a space of acceptable values
2. Choose a value at random from that space
3. Evaluate the performance given that value
4. If satisfied with the performance or time limit exceeded -> finish
5. Choose a new value from the feedback
6. Goto 3

**Ensembles of technique**

* Nelder-Mead Simplex
* Differential Evolution
* Particle Swarm Optimization
* Model Driven Optimization

* Many different techniques
* Each best suited to solve different problems
* Hard to write a single autotuner that performs well
in different domains
* Can we make these techniques work together?

* Meta-technique divides testing budget between sub-techniques
* Results are shared between all techniques
