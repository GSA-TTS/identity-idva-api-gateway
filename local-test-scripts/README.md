# Making an Authenticated Request

The generation of a digital signature can be handled by [this script](local-test-scripts\hmac-dig-sig.js). The following headers should be set:
- `Date : {{timestamp}}`
- `Authorization : hmac username="{{username}}", algorithm="hmac-sha256", headers="date request-line", signature="{{signature}}"`

The authorization header is in compliance with [Kong's Signature Authentication Scheme](https://docs.konghq.com/hub/kong-inc/hmac-auth/#signature-authentication-scheme).


Example HTTP request:
```
GET /give-ipp-idemia? HTTP/1.1
Host: give-dev.app.cloud.gov
Date: Wed, 30 Sep 2020 16:56:08 GMT
Authorization: hmac username="user", algorithm="hmac-sha256", headers="date request-line", signature="EtQAcABKkdXX/YdOd6/G+GdXTs7mVKi6sbfJjD7vBP8="
```