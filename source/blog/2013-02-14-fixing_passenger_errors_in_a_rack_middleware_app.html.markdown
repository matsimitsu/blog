---
title: Fixing Passenger errors in a Middleware app
date: 2013-02-14 22:44 +01:00
subtitle: 'Fix an annoying issue when using a Middleware in Passenger'
---

Every now and then i notice a "Cannot read response from backend process: Connection reset by peer (104)" exception in my Nginx error log. Time to fix that puppy!

READMORE

For an app i'm working on i had an issue with one of the middleware i used to authenticate users for an api. The middleware looks like this:


<script src="https://gist.github.com/matsimitsu/668c08a4e8552f7db2ef.js"></script>

Every time someone posted data to the app but wasn't allowed in i'd see the following error in my Nginx logs:

<script src="https://gist.github.com/matsimitsu/5614828f7b6facb55841.js"></script>

First i thought it was because i was returning a 401 and passenger was expecting some headers i didn't send. But even with the 'WWW-Authenticate' and 'Content-Length' headers it still raised the error.

Turns out that before you can return a response to passenger you need to get all the data passenger sends you. In this case the return came before i read the POST data from the request.

The solution is pretty simple, read the post data first before you return your own data.

<script src="https://gist.github.com/matsimitsu/c1beeea7de52cb176c2c.js"></script>

This way passenger will accept your response and doesn't trow any errors.
<script src="https://gist.github.com/matsimitsu/6f65157e15a86f64f25b.js"></script>
