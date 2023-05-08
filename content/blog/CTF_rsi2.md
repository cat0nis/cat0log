+++
title = "CTF Writeup - RSI 2"
date = 2019-11-27
slug = "rsi2"
authors = ["Inryatt"]
+++
=== WIP ===

Prompt:

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/757a6b1e-5b7e-4412-be2a-5a6d213c337f/Untitled.png)

File:

[big_b.osr](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/04759051-70bc-4b97-a170-245091526779/big_b.osr)

Information on  .osr file: 

[.osr (file format)](https://osu.ppy.sh/wiki/en/Client/File_formats/Osr_%28file_format%29)

Loading the .osr file into Osu! will throw an error where Osu! complains it doesn’t have the beatmap corresponding to this replay. Luckily, we can get it fairly easily, thanks to this reddit post

[https://www.reddit.com/r/osugame/comments/9naogb/is_there_a_way_to_see_what_beatmap_a_replay_is/](https://www.reddit.com/r/osugame/comments/9naogb/is_there_a_way_to_see_what_beatmap_a_replay_is/)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/2cca76b2-a1a2-49fa-8495-b2e5a67c3b67/Untitled.png)

So, we see we need two things: An osu API key and the beatmap hash, which is included in the .osr file as we see below:

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/912600ba-7daa-4cda-8985-b3dfef28f609/Untitled.png)

we can easily see the player name, striker4250, so we grab the hash that comes directly before it:

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/b52f2b39-9b1a-4a68-9c58-82c847579633/Untitled.png)

<aside>
📌 2d687e5ee79f3862ad0c60651471cdcc

</aside>

The Osu! API key can be requested at [https://osu.ppy.sh/p/ap](https://osu.ppy.sh/p/api)i

By inserting this into the url we get from the reddit post, `[https://osu.ppy.sh/api/get_beatmaps?k=your_api_key&h=beatmap_hash](https://osu.ppy.sh/api/get_beatmaps?k=your_api_key&h=beatmap_hash)` , we get this JSON result back:

```json
[{
"beatmapset_id":"41823",
"beatmap_id":"131891",
"approved":"2",
"total_length":"139",
"hit_length":"112",
"version":"WHO'S AFRAID OF THE BIG BLACK",
"file_md5":"2d687e5ee79f3862ad0c60651471cdcc",
"diff_size":"4",
"diff_overall":"7",
"diff_approach":"10",
"diff_drain":"5",
"mode":"0",
"count_normal":"410",
"count_slider":"334",
"count_spinner":"2",
"submit_date":"2011-12-24 00:34:33",
"approved_date":"2012-02-19 05:51:54",
"last_update":"2012-02-19 05:05:41",
"artist":"The Quick Brown Fox",
"artist_unicode":null,
"title":"The Big Black",
"title_unicode":null,
"creator":"Blue Dragon",
"creator_id":"19048",
"bpm":"360.3",
"source":"",
"tags":"onosakihito speedcore renard lapfox",
"genre_id":"10",
"language_id":"2",
"favourite_count":"9166",
"rating":"9.30955",
"storyboard":"1",
"video":"0",
"download_unavailable":"0",
"audio_unavailable":"0",
"playcount":"31804980",
"passcount":"3035938",
"packs":"R129,R56,SA9",
"max_combo":"1337",
"diff_aim":"3.5275707244873047",
"diff_speed":"3.019768476486206",
"difficultyrating":"6.8468499183654785"
}]
```

From this we grab the beatmapset_id and insert it in `[https://osu.ppy.sh/s/beatmapset_id](https://osu.ppy.sh/s/beatmapset_id)` , which leads us to

[https://osu.ppy.sh/beatmapsets/41823#osu/131891](https://osu.ppy.sh/beatmapsets/41823#osu/131891)

 After downloading the beatmap and importing it into osu! we can finally watch the replay, where we can see the flag!

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/29fef28e-ba01-4fd0-871e-021d20be3cea/Untitled.png)

- So, the flag was:
    
    ```json
    UMDCTF{CL1CK_TO_THE_B3AT}
    ```