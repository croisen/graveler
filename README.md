# Graveler (in Zig)

Seeing [ShoddyCast's](https://www.youtube.com/@ShoddyCast) take on the 
[Graveler Soft Lock Picking](https://www.youtube.com/watch?v=GgMl4PrdQeo&t) 
[here](https://www.youtube.com/watch?v=M8C8dHQE2Ro). Well it has a form to
submit code to see in a billion attempts of 231 dice roll of a four sided die
how many of those would be 1s.

## Compiling

```bash
git clone https://github.com/croisen/graveler.git
cd graveler
zig build
```

## Running

After compiling the zig code there will be four main files in the zig-out/bin
directory. Of course, the multi-threaded version is faster (well when I'd first
done it, it was slower than the single threaded version)

-   st-graveler-rewrite : Single threaded simulation of dice rolls (up to 1 billion)
-   st-graveler-prz-procs : Single threaded simulation of move paralysis (up to 1 billion)
-   mt-graveler-rewrite : Multi threaded simulation of dice rolls (up to 1 billion)
-   mt-graveler-prz-procs : Multi threaded simulation of move paralysis (up to 1 billion)

## Some of my laptop specs

IDK what to put here this is my first time participating in something like this

-   OS: Arch Linux 6.10.7-arch1-1

-   CPU: Intel(R) Pentium(R) Silver N5030 CPU @ 1.10GHz
-   Cores: 4
-   Sockets: 1

-   RAM: DIMM DDR4 Synchronous 2400 MHz
-   Size: 4GB

## Here is my zig rewrite results

![IDK.png](results/ST%20-%20Graveler%20Rewrite%20-%201.png)

## Zig rewrite with multithreading

Not that big of a time save that I was hoping for but an improvement nonetheless
![IDK.png](results/MT%20-%20Graveler%20Rewrite%20-%201.png)

## For the other goal of the video

Another program compiled here is how many straight paralysis procs can happen
in an attempt if the paralysis proc has a 25% chance to happen. Iterated over
1000000000 times
![IDK.png](results/ST%20-%20Straight%20PRZ%20Procs%20-%201.png)

## Trying the straight paralysis procs with multithreading

Pfft
![IDK.png](results/MT%20-%20Straight%20PRZ%20Procs%20-%201.png)
