# Graveler (in Zig)

Seeing [ShoddyCast's](https://www.youtube.com/@ShoddyCast) code take on the 
[Graveler Soft Lock Picking](https://www.youtube.com/watch?v=GgMl4PrdQeo&t) 
[here](https://www.youtube.com/watch?v=M8C8dHQE2Ro). Well it has a form to
submit code to see in a billion attempts of 231 dice roll of a four sided die
how many of those would be 1s.

## Compiling

```bash
git clone https://github.com/croisen/graveler.git
cd graveler
zig build --release=fast
./zig-out/bin/graveler-rewrite
```

## Some of my laptop specs

IDK what to put here this is my first time participating in something like this

CPU: Intel(R) Pentium(R) Silver N5030 CPU @ 1.10GHz
Cores: 4
Sockets: 1

RAM: DIMM DDR4 Synchronous 2400 MHz
Size: 4GB

## Here is my zig rewrite results

Measured via perf stat if that is fine
![Zig Rewrite.png](results/Zig%20Rewrite.png)

## For the other goal of the video

Another program compiled here is how many straight paralysis procs can happen
in an attempt if the paralysis proc has a 25% chance to happen. Iterated over
1000000000 times
![Straight PRZ Procs.png](results/Straight%20PRZ%20Procs.png)
