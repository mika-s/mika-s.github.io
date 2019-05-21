---
layout: post
title:  "Generating normally distributed random numbers in Javascript"
date:   2019-05-15 12:00:00 +0100
categories: javascript random normal-distributed
---

Here I introduce a method that can be used to generate random numbers drawn from a normal
distribution. The code below uses the [Box-Muller transform][box–muller-transform] to make sure
the numbers are normally distributed.

```js
function boxMullerTransform() {
    const u1 = Math.random();
    const u2 = Math.random();
    
    const z0 = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
    const z1 = Math.sqrt(-2.0 * Math.log(u1)) * Math.sin(2.0 * Math.PI * u2);
    
    return { z0, z1 };
}

function getNormallyDistributedRandomNumber(mean, stddev) {
    const { z0, _ } = boxMullerTransform();
    
    return z0 * stddev + mean;
}
```

`z1` isn't used in this case, but I'll leave it in in case `boxMullerTransform()` is used another
place. This is how you can use `getNormallyDistributedRandomNumber()`:

```js
const generatedNumbers = []

const mean   = 30.0;
const stddev = 2.0;

for (let i = 0; i < 100000; i += 1) {
    generatedNumbers.push(getNormallyDistributedRandomNumber(mean, stddev))
}

const sum = generatedNumbers.reduce((acc, i) => acc += i);
const count = generatedNumbers.length;
const calculatedMean = sum/count;

console.log(calculatedMean);
```

`generatedNumbers` is an array that contains the numbers. To check that the mean really is what we
set it to be I calculate the mean and print it to the console. The output is 29.986221608852734,
which is close enough.

You can find a fiddle [here][jsfiddle].

[box–muller-transform]: https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
[jsfiddle]: https://jsfiddle.net/3rf4jL8n/2/
