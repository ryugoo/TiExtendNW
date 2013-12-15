# TiExtendNW

[MKNetworkKit](https://github.com/MugunthKumar/MKNetworkKit) wrapper for Titanium 3.2 (iOS)

## Usage

See `example/app.js`

## Feature

* High performance HTTP client
* Auto parse JSON (responseJSON)
* `Ti.Network.HTTPClient` like interface

## Goal

* High compatible `Ti.Network.HTTPClient` API
* Provides the Titanium great features "MKNetworkKit"
* Tested

## Example

### JavaScript

```
var TiExtendNW = require('net.imthinker.ti.extendnw'),
    http = TiExtendNW.createHTTPClient();

http.open('GET', 'http://httpbin.org/get', {
    freezable: false,
    forceReload: false
});

http.onload = function (e) {
    Ti.API.debug('responseJSON');
    Ti.API.debug(http.responseJSON);
};

http.onerror = function (e) {
    Ti.API.error(e);
};

http.setRequestHeader('User-Agent', 'MKNetworkKit wrapper for Titanium (iOS) / Version 1.0');
http.setRequestHeader('X-ApplicationVersion', Ti.App.version);
http.send();
```

### Result

```
[DEBUG] responseJSON
[DEBUG] {
[DEBUG] args =     {
[DEBUG] };
[DEBUG] headers =     {
[DEBUG] "Accept-Language" = "ja, en, fr, de, zh-Hans, zh-Hant, nl, it, es, ko, pt, pt-PT, da, fi, nb, sv, ru, pl, tr, uk, ar, hr, cs, el, he, ro, sk, th, id, ms, en-GB, ca, hu, vi, en-us";
[DEBUG] Connection = close;
[DEBUG] Host = "httpbin.org";
[DEBUG] "User-Agent" = "MKNetworkKit wrapper for Titanium (iOS) / Version 1.0";
[DEBUG] "X-Applicationversion" = "1.0";
[DEBUG] };
[DEBUG] origin = "123.456.789.012";
[DEBUG] url = "http://httpbin.org/get";
[DEBUG] }
```

## License

The MIT License (MIT)

Copyright (c) 2013 Ryutaro Miyashita

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

==========

### MKNetworkKit

MKNetworkKit is licensed under MIT License Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.