+++
title = "CTF Writeup - RSI 1"
date = 2019-11-27
slug = "rsi1"
authors = ["Inryatt"]
+++
=== WIP ===
Prompt:

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a1a1c2ca-5e74-4178-ad61-3330b04b712b/Untitled.png)

The file given:

[tutorial.osr](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/42191d52-3868-4e46-884f-185dd9eaab1e/tutorial.osr)

This .osr file is a Replay for the Rhythm game OSU! 

More information about .osr: 

[https://osu.ppy.sh/wiki/en/Client/File_formats/Osr_(file_format)](https://osu.ppy.sh/wiki/en/Client/File_formats/Osr_%28file_format%29)

For this challenge, the most relevant part is

> The remaining data contains information about mouse movement and key presses in an [LZMA](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Markov_chain_algorithm)
 stream.
> 

This LZMA stream can be quickly found via **binwalk**.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/0f767f33-e75b-4076-8abe-5224c0765bb2/Untitled.png)

after extracting with 

```bash
binwalk -e tutorial.osr
```

we end up with 

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/87d55d69-2e98-4239-8117-4da9f5bd2e5f/Untitled.png)

and inside 7F we can find the flag:

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a55f3c07-f41d-4cd4-be68-2b6f4304a6cc/Untitled.png)

```bash
UMDCTF{wE1c0m3_t0_o5u!}
```