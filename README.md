# SlerverIO

This plugin provides client way to interconnect flutter app.<br>
##### Learn more at [Bixterprise.com](http://flutter.bixterprise.com)
## Usage

Lets take a look at how to use `SlerverIO` to connect two Flutter app for data sharing on both Android and iOS.

Create the client that we will use to connect.
``` Dart
SlerverIO client;
```
Initilialize response from flutter Server App.
``` Dart
initClient ( ) async {
 client = await SlerverIO.connect('10.42.0.241', 9000, autoReconnect: true);
}
```
Now we add response triggers by using  `SlerverIORedirectRoute` from `SlerverIO`
``` Dart
onResponse ( ) {
 var io = client.router;
  io
   ..on('/name', (Map<String, dynamic> params) {
    print(params['message']);
   })
   ..on('/surname', (List params) {
    print('${params.first} => ${params.last}');
   })
   ..on('connect', () {
    print('Connected successfully');
   });
}
```

Now lets define function uses to send data to server

``` Dart
writeSomething() {
    client
      ..send({
         'path': '/register',
         'params': {'name': 'Bakop', 'surname': 'Champlain'}
      })
      ..send({
         'path': '/findAll',
         'params': ['Champlain', 'Manuel', 'Cabrel', 'Jordan']
      });
}
```
