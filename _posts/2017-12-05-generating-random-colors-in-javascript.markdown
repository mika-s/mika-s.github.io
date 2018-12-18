---
layout: post
title:  "Generating random HSL colors in Javascript"
date:   2017-12-05 12:00:00 +0100
categories: javascript colors hsl
---

Sometimes we need to generate a range of random colors. This can, for example, be when creating graphs where
every curve should have a different color in order to distinguish the curves from each other. A decent first
attempt at creating a random-color generator could be a function like this:

```javascript
function randomRgbaString (alpha) {
  let r = Math.floor(Math.random() * 255)
  let g = Math.floor(Math.random() * 255)
  let b = Math.floor(Math.random() * 255)
  let a = alpha
  return `rgba(${r},${g},${b},${a})`
}
```

that is run like this:

```javascript
let colors = [];
for (let i = 0; i < 10; i++) colors.push(randomRgbaString(1));
```

This generates [rgba strings][mdn-color] that represents colors in CSS. `alpha` is the alpha-channel, which
represents transparency. It's not important here and is simply set to 1 (no transparency). The color
values in the string are random values between 0 and 255, e.g.

```javascript
rgba(127,2,241,1)
rgba(128,54,180,1)
...
rgba(77,149,200,1)
```

A problem quickly arises when we, for example, generate 10 random colors:

<table style="text-align: center">
  <tr>
    <td style="padding-top: 0; background-color: rgba(210, 191, 156, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba( 89, 187,  20, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba(151,  76,  57, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba(132, 157, 204, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba(211,  19, 210, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba(  0, 144, 101, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba( 95, 195,  63, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba( 24,  97, 229, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba( 56, 154,  66, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: rgba(227, 247, 211, 1)">&nbsp;</td>
  </tr>
</table>

Several of the colors look similar, making it hard to distinguish them from each other. So we don't really
want the colors completely random, we want them spread apart from each other. This is easily done with HSL
colors.

### HSL

Hue-Saturation-Lightness (HSL) is an alternative to the RGB color model. Rather than having three values
that represents red, green and blue, we now have three values representing hue, saturation and lightness.

HSL has a cylindrical geometry, as seen in the image below.

![HSL cylinder]({{ "/assets/generating-random-colors-in-javascript/HSL_color_solid_cylinder.png" | absolute_url }}){: style="width: 70%; display: block; margin: auto;" }


<sub><sup>Made by [SharkD][wikipedia-user-sharkd], under [CC BY-SA 3.0][cc-by-sa-3.0].</sup></sub>

**Hue:**

Hue is the perceived color, for example red, green, blue or yellow. The unit of hue is degrees, because the
HSL model is represented as a cylinder with hue being the circular coordinate. Red is 0°, green is 120° and
blue is 240°.

<table style="text-align: center">
  <tr>
    <td style="padding: 0">  0°</td>
    <td style="padding: 0"> 40°</td>
    <td style="padding: 0"> 80°</td>
    <td style="padding: 0">120°</td>
    <td style="padding: 0">160°</td>
    <td style="padding: 0">200°</td>
    <td style="padding: 0">240°</td>
    <td style="padding: 0">280°</td>
    <td style="padding: 0">320°</td>
  </tr>
  <tr>
    <td style="padding-top: 0; background-color: hsla(  0, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla( 40, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla( 80, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(160, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(200, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(280, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(320, 100%, 50%, 1)">&nbsp;</td>
  </tr>
</table>

The colors above all have constant saturation and lightness.

**Saturation:**

Saturation represents how "colorful" the color is. It has a value between 0 and 100%. 0% is unsaturated
(gray), while 100% is full saturation.

The table below shows various hues with different values of saturation. The saturation
increases the further right you go in the table. The lightness is 50% for all the colors.

<table style="text-align: center">
  <tr>
    <td style="padding: 0">Hue / Sat</td>
    <td style="padding: 0">0%</td>
    <td style="padding: 0">10%</td>
    <td style="padding: 0">20%</td>
    <td style="padding: 0">30%</td>
    <td style="padding: 0">40%</td>
    <td style="padding: 0">50%</td>
    <td style="padding: 0">60%</td>
    <td style="padding: 0">70%</td>
    <td style="padding: 0">80%</td>
    <td style="padding: 0">90%</td>
    <td style="padding: 0">100%</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">0°</td>
    <td style="padding-top: 0; background-color: hsla(0,   0%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  10%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  20%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  30%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  40%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  50%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  60%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  70%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  80%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0,  90%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%, 50%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">60°</td>
    <td style="padding-top: 0; background-color: hsla(60,   0%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  10%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  20%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  30%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  40%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  50%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  60%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  70%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  80%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60,  90%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%, 50%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">120°</td>
    <td style="padding-top: 0; background-color: hsla(120,   0%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  10%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  20%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  30%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  40%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  50%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  60%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  70%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  80%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120,  90%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%, 50%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">180°</td>
    <td style="padding-top: 0; background-color: hsla(180,   0%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  10%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  20%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  30%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  40%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  50%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  60%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  70%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  80%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180,  90%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%, 50%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">240°</td>
    <td style="padding-top: 0; background-color: hsla(240,   0%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  10%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  20%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  30%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  40%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  50%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  60%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  70%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  80%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240,  90%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%, 50%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">300°</td>
    <td style="padding-top: 0; background-color: hsla(300,   0%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  10%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  20%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  30%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  40%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  50%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  60%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  70%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  80%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300,  90%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%, 50%, 1)">&nbsp;</td>
  </tr>
</table>

**Lightness:**

Lightness is simply the brightness of the color. It has a value between 0 and 100%. 0% lightness is
black, while 100% lightness is white. 50% is "normal" colors.

The table below shows various hues with different values of lightness. The lightness increases the
further right you go in the table. The saturation is 100% for all the colors.

<table style="text-align: center">
  <tr>
    <td style="padding: 0">Hue / Lig</td>
    <td style="padding: 0">0%</td>
    <td style="padding: 0">10%</td>
    <td style="padding: 0">20%</td>
    <td style="padding: 0">30%</td>
    <td style="padding: 0">40%</td>
    <td style="padding: 0">50%</td>
    <td style="padding: 0">60%</td>
    <td style="padding: 0">70%</td>
    <td style="padding: 0">80%</td>
    <td style="padding: 0">90%</td>
    <td style="padding: 0">100%</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">0°</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,   0%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  10%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  20%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  30%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  40%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  60%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  70%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  80%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%,  90%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(0, 100%, 100%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">60°</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,   0%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  10%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  20%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  30%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  40%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  60%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  70%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  80%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%,  90%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(60, 100%, 100%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">120°</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,   0%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  10%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  20%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  30%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  40%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  60%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  70%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  80%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%,  90%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%, 100%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">180°</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,   0%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  10%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  20%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  30%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  40%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  60%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  70%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  80%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%,  90%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(180, 100%, 100%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">240°</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,   0%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  10%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  20%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  30%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  40%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  60%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  70%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  80%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%,  90%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%, 100%, 1)">&nbsp;</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">300°</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,   0%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  10%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  20%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  30%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  40%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  60%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  70%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  80%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%,  90%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(300, 100%, 100%, 1)">&nbsp;</td>
  </tr>
</table>

### Code

Using this information we can create a function that generates colors as `hsla()` strings, which are also
supported by CSS. The strings should be returned in an array and the colors should not be similar to each
other.

The perceived color is basically the hue, which means we can keep the saturation and lightness constant. The
number of colors we want to generate is `amount`. By dividing 360° by `amount` we get the difference between
the hues of the returned colors.

E.g. `amount = 2` gives the hues 0° and 180°. `amount = 3` gives the hues 0°, 120° and 240°.

Saturation and lightness are in percent, while alpha is between 0 and 1.

```javascript
function generateHslaColors (saturation, lightness, alpha, amount) {
  let colors = []
  let huedelta = Math.trunc(360 / amount)

  for (let i = 0; i < amount; i++) {
    let hue = i * huedelta
    colors.push(`hsla(${hue},${saturation}%,${lightness}%,${alpha})`)
  }

  return colors
}
```

### Examples

```javascript
let c = generateHslaColors(50, 100, 1.0, 3)
```

<table style="text-align: center">
  <tr>
    <td style="padding: 0">c[0]</td>
    <td style="padding: 0">c[1]</td>
    <td style="padding: 0">c[2]</td>
  </tr>
  <tr>
    <td style="padding-top: 0; background-color: hsla(  0, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%, 50%, 1)">&nbsp;</td>
  </tr>
</table>
<br>

```javascript
let c = generateHslaColors(50, 100, 1.0, 5)
```

<table style="text-align: center">
  <tr>
    <td style="padding: 0">c[0]</td>
    <td style="padding: 0">c[1]</td>
    <td style="padding: 0">c[2]</td>
    <td style="padding: 0">c[3]</td>
    <td style="padding: 0">c[4]</td>
  </tr>
  <tr>
    <td style="padding-top: 0; background-color: hsla(  0, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla( 72, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(144, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(216, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(288, 100%, 50%, 1)">&nbsp;</td>
  </tr>
</table>
<br>


```javascript
let c = generateHslaColors(50, 100, 1.0, 7)
```

<table style="text-align: center">
  <tr>
    <td style="padding: 0">c[0]</td>
    <td style="padding: 0">c[1]</td>
    <td style="padding: 0">c[2]</td>
    <td style="padding: 0">c[3]</td>
    <td style="padding: 0">c[4]</td>
    <td style="padding: 0">c[5]</td>
    <td style="padding: 0">c[6]</td>
  </tr>
  <tr>
    <td style="padding-top: 0; background-color: hsla(  0, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla( 51, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(102, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(154, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(205, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(257, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(308, 100%, 50%, 1)">&nbsp;</td>
  </tr>
</table>
<br>


```javascript
let c = generateHslaColors(50, 100, 1.0, 9)
```

<table style="text-align: center">
  <tr>
    <td style="padding: 0">c[0]</td>
    <td style="padding: 0">c[1]</td>
    <td style="padding: 0">c[2]</td>
    <td style="padding: 0">c[3]</td>
    <td style="padding: 0">c[4]</td>
    <td style="padding: 0">c[5]</td>
    <td style="padding: 0">c[6]</td>
    <td style="padding: 0">c[7]</td>
    <td style="padding: 0">c[8]</td>
  </tr>
  <tr>
    <td style="padding-top: 0; background-color: hsla(  0, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla( 40, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla( 80, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(120, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(160, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(200, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(240, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(280, 100%, 50%, 1)">&nbsp;</td>
    <td style="padding-top: 0; background-color: hsla(320, 100%, 50%, 1)">&nbsp;</td>
  </tr>
</table>
<br>

We can see that we get colors spread all over the color spectrum, rather than having several colors
that look similar. The function won't work very well when we are asking for a large amount of colors.
If we ask for 36 colors, for instance, we only have a hue delta of 10°. The colors are then barely
distinguishable. For cases like that the saturation and lightness also have to vary.

[mdn-color]: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value
[wikipedia-user-SharkD]: https://commons.wikimedia.org/wiki/User:SharkD
[cc-by-sa-3.0]: https://creativecommons.org/licenses/by-sa/3.0/deed.en
