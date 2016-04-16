# RuledTrendy - Nobody knows that they saw it, but they did.

### What it does

If you haven't watched Fight Club yet, go watch it. If you have: This framework does to apps what Tyler Durden does to movies. It allows you to specify an image resource that is 
then downloaded at runtime and flashed for a short period of time randomly at a frequency you define. And yes, RuledTrendy is an anagram.

### Who this is for

You have decided to leave your shitty dayjob as an enterprise iOS developer? Great! Just make sure this ends up in your project somewhere.

### How to use
Build this framework & implement it in your project like so: 
```
import RuledTrendy
```

Instanciate the RuledTrendy class, provide a base64 encoded link to your image resource and define your frequency.
```
let trendy = RuledTrendy(key: "aHR0cDovL2FsbG1vdmllc3dhbGxwYXBlci5jb20vd3AtY29udGVudC91cGxvYWRzLzIwMTYvMDMvdHlsZXItZHVyZGVuLTMuanBn")
trendy.frequency = .Default
```
Do nothing.



