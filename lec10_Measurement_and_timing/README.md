# Measurement and Timing

**Dynamic Frequency and Voltage Scaling**

__DVFS__ is a technique to reduce power by __adjusting__
the __clock frequency__ and __supply voltage__ to transistors.

* Reduce operating frequency if chip is too hot ot otherwise to
conserve (especially battery) power.

* Reduce voltage if frequency is reduced.

$$Power \propto CV^2f$$

C = dynamic capacitance ≈ roughly area * activity (how many bits toggle)\
V = supply voltage\
f = clock frequency

-> It hurts time measurements.

**Outline**

* Quiescing systems
* Tools for measuring software performance
* Performance modelling

**Sources of Variability**

* Daemons and background jobs
* Interrupts
* Code and data alignment
* Thread placement
* Runtime scheduler
* Hyperthreading
* Multitenancy
* DVFS
* Turbo Boost
* Network traffic

**Quiescing the System**

* Make sure no other jobs are running.
* Shut down daemons and cron jobs.
* Disconnect the network.
* Don't fiddle with the mouse.
* For serial jobs, don't run on core 0, where interrupt handlers are usually run.
* Turn hyperthreading off.
* Turn off DVFS.
* Turn off Turbo Boost.
* Use __taskset__ to pin Cilk workers to cores.
* Etc., etc.

**Code Alignment**

A small change to one place in the source code can
cause much of the generated machine code to change
locations. Performance can vary due to changes in
cache alignment and page alignment.

__Similar:__ Changing the order in which the ```*.o``` files appear on
the linker command line can have a larger effect than going between ```-O2``` to ```-O3```.

**LLVM Alignment Switches**

LLVM tends to cache-align functions, but it also
provides several compiler switches for controlling
alignment:

* ```-align-all-functions=<uint>```\
Force the alignment of all functions.

* ```-align-all-blocks=<uint>```\
Force the alignment of all blocks in the function.

* ```-align-all-nofallthru-blocks=<uint>```\
Force the alignment of all blocks that have no fall-through predecessors
(i.e. don't add nops that are executed).

Aligned code is more likely to avoid performance anomalies,
but it can also sometimes be slower.

**Data Alignment**

A program's name can affect its speed.

* The executable's name ends up in an environment variable.

* Environment variables end up on the call stack.

* The length of the name affects the stack alignment.

* Data access slows when crossing page boundaries.

**Tools for Measuring Software Performance**

**Ways to Measure a Program**

* Measure the program externally.
```bash
$ time
```

* Instrument the program.
    * Include timing calls in the program.
    * E.g., ```gettimeofday()```, ```clock_gettime()```, ```rdtsc()```.
    * By hand, or with compiler support.

* Interrupt the program.
    * Stop the program, and look at its internal state.
    * E.g., ```gdb```, Poor Man's Profiler, ```gprof```.

* Exploit hardware and operating systems support.
    * Run the program with counters maintained by the hardware and OS, e.g., ```perf```.

* Simulate the program.
    * E.g., ```cachegrind```.

**The ```time``` command**

The ```time``` command can measure elapsed time, user time, and system time for an entire program.

What does that mean?

* ```real``` is wall-clock time.
* ```user``` is the amount of processor time spent in user-mode code (outside the kernel) within the processor.
* ```sys``` is the amount of processor time spent in the kernel within the process.

**clock_gettime(CLOCK_MONOTONIC, ...)**

```c
#include <time.h>

struct timespec start, end;

clock_gettime(CLOCK_MONOTONIC, &start);
function_to_measure();
clock_gettime(CLOCK_MONOTONIC, &end);

double tdiff = (end.tv_sec - start.tv_sec) + 1e-9 * (end.tv_nsec - start.ev_nsec);
```

* Faster than a system call.
* Guarantees never to run backwards.

**```rdtsc()```**

x86 processors provide a __time-stamp counter__ (TSC) in hardware.
You can read TSC as follows:
```c
static __inline__ unsigned long long rdtsc(void) {
    unsigned hi, lo;
    __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
    return ( ((unsigned long long)lo)
           | (((unsigned long long)hi)<<32));
}
```

* The time returned is "clock cycles since boot"
* ```rdtsc()``` runs in about 32ns.

**Don't Use Lousy Timers!**

* ```rdtsc()``` may give different answers on different cores on the same machine.
* TSC sometimes runs backwards.
* The counter may not progress at a constant speed.
* Converting clock cycles to seconds can be tricky.
* Don't use ```rdtsc()```!
* Don't use ```gettimeofday()```, either, because it has similar problems!

**Interrupting**

* IDEA: Run your program under ```gdb```, and type ctrl-C at random intervals.
* Look at the stack each time to determine which functions are usually being executed.
* Who needs a fancy profiler?
* Some people call this strategy the "Poor Man's Profiler".
* ```pmprof``` and ```gprof``` automate this strategy to provide profile information for all your functions.
* Neither is accurate if you don't obtain enough samples. (```gprof``` samples only 100 times per second.)

**Hardware Counters**

* ```libpfm4``` virtualizes all the hardware counters.
* Modern kernels make it possible for libraries such as ```libpfm4``` to measure
all the provided hardware event counters on a per-process basis.
* ```perf stat``` employs ```libpfm4```.
* There are many esoteric hardware counters.
Good luck figuring out what they all measure.
* Watch out: You probably cannot measure more than 4 or 5 counters at a time
without paying a penalty in performance or accuracy.

**Simulation**

* Simulators, such as ```cachegrind``` usually run much slower than real time.
* But they can deliver accurate and repeatable performance numbers.
* If you want a particular statistic, you can go in and collect it without perturbing the simulator.

**Problem**

Suppose that you measure the performance of a
deterministic program 100 times on a computer with
some interfering background noise. What statistic
best represents the raw performance of the software?

- [ ] arithmetic mean
- [ ] geometric mean
- [ ] median
- [ ] maximum
- [x] minimum

Minimum does the best at noise rejection, because
we expect that any measurements higher than the
minimum are due to noise.

**Selecting Among Summary Statistics**

**Service as many requests as possible**
* Arithmetic mean
* CPU utilization

**All tasks are completed within 10 ms**
* Arithmetic mean
* Wall-clock time

**Most service requests are satisfied within 100 ms**
* 90th percentile
* Wall-clock time

**Meet a customer service-level agreement (SLA)**
* Some weighted combination

**Fit into a machine with 100 MB of memory**
* Maximum
* Memory use

**Least cost possible**
* Arithmetic mean
* Energy use or CPU utilization

**Fastest/biggest/best solution**
* Arithmetic mean
* Speedup of wall-clock time

**Summarizing Ratios**

```
Trial   | Program A | Program B |   A/B
----------------------------------------
1       |     9     |     3     |   3.00
2       |     8     |     2     |   4.00
3       |     2     |    20     |   0.10
4       |    10     |     2     |   5.00
----------------------------------------
Mean    |   8.25    |   4.75    |   3.13
```

Conclusion\
~~Program B is > 3 times better than A.~~

**Turn the Comparison Upside-Down**

```
Trial   | Program A | Program B |   A/B  |    B/A
--------------------------------------------------
1       |     9     |     3     |   3.00 |   0.33
2       |     8     |     2     |   4.00 |   0.25
3       |     2     |    20     |   0.10 |  10.00
4       |    10     |     2     |   5.00 |   0.20
--------------------------------------------------
Mean    |   8.25    |   4.75    |   3.13 |   2.70
```

The ratio of the means is NOT the mean of the ratios.

The ratio of the means IS the mean of the ratios.

**Comparing Two Programs**

The strategy:

Perform __n__ head-to-head comparisons between A and B,
and suppose A wins more frequently.
Consider the null hypothesis that B beats A, and calculate
the __P-value__: "if B beats A, what is the probability
that we'd observe that A beats B more often than we did?".
If the P-value is low, we can accept that A beats B.

NOTE: With a lot of noise, we need lots of trials.

**Fitting to a Model**

// Suppose we collected some statistics of running time, instructions and cache misses.

Want to infer how long it takes to run an
instruction and how long to take a cache miss.

Guess that the runtime T can be modelled as:
```
T = a*I + b*C
```

where
* __I__ is the number of instructions,
* __C__ is the number of cache misses.

**Least-Squares Regression**

A __least-squares regression__ can fit the data to the model
```
T = a*I + b*C
```
yielding
* a = 0.2002 ns
* b = 18.00 ns

with R^2 = 0.9997, which means that 99.97% of the
data is explained by the model.

**Issues with Modelling**

Adding more basis functions to the model improves
the fit, but how do I know whether I'm overfitting?

* Removing a basis function doesn't affect the quality much.

Is the model predictive?

* Pick half of the data at random.
* Use that data to find the coefficients.
* Using those coefficients, find out how well the model predicts the other half of the data.

How can I tell whether I'm fooling myself?

* Triangulate.
* Check that different ways of measuring tell a consistent story.
* Analogously to a spreadsheet, make sure the sum of the row
sums adds up to the sum of the column sums.
