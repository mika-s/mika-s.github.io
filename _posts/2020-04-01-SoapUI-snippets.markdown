---
layout: post
title:  "SoapUI snippets"
date:   2020-04-01 15:00:00 +0100
categories: soapui snippets
---

# SoapUI snippets

## Snippets

| Description                       | Code                                                                |
| Generate random GUIDs             | `${java.util.UUID.randomUUID()}`                                    |
| Random integer with two digits    | `${=org.apache.commons.lang.RandomStringUtils.randomNumeric(2)}`    |
| Random string with two characters | `${=org.apache.commons.lang.RandomStringUtils.randomAlphabetic(2)}` |
| Today's date in ISO format        | `${=def now = new Date();now.format("yyyy-MM-dd")}`                 |

## Important links

- [Documentation for RandomStringUtils][RandomStringUtils-docs]

[RandomStringUtils-docs]: https://commons.apache.org/proper/commons-lang/apidocs/org/apache/commons/lang3/RandomStringUtils.html
