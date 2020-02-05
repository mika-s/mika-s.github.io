---
layout: post
title:  "SoapUI snippets"
date:   2019-04-08 15:00:00 +0100
categories: soapui snippets
---

These are various SoapUI snippets I'm using that other might be interested in.

## Snippets

#### Generate random GUIDs

```java
${java.util.UUID.randomUUID()}
```

#### Random integer with two digits

```java
${=org.apache.commons.lang.RandomStringUtils.randomNumeric(2)}
```

#### Random string with two characters

```java
${=org.apache.commons.lang.RandomStringUtils.randomAlphabetic(2)}
```

#### Today's date in ISO format

```java
${=def now = new Date();now.format("yyyy-MM-dd")}
```

#### 200 days into the future

```java
${=def now = new Date();def future = now.plus(200);future.format("yyyy-MM-dd")}
```

#### Own IP address

```java
${=java.net.InetAddress.getLocalHost().getHostAddress()}
```

## Important links

- [Documentation for RandomStringUtils][RandomStringUtils-docs]

[RandomStringUtils-docs]: https://commons.apache.org/proper/commons-lang/apidocs/org/apache/commons/lang3/RandomStringUtils.html
