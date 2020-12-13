/// The `Slerver_io` library, is a class set that achieves the single goal of how to use a single phone in a wireless smartphone network to centralize data and send it to the server.

/// We have adopted a sockets-based approach to this problem, keeping in mind that the developer must be familiar with the proposed syntax, hence the routes.

/// The implementation of this solution uses 3 classes
/// * `SlerverIORoute`: as a basis for route knowledge.
/// * `SlerverIORouter`: here, being the switch between routes and actions.
/// * `SlerverIO`: the client that allows you to connect to the server and receive messages.
/// ### See also [Slerver](https://github.com/ChamplainLeCode/slever)
library slerver_io;

export 'src/slerver_io.dart';
export 'src/slerver_io_constants.dart';
export 'src/slerver_io_route.dart';
