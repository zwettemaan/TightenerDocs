# getCapability

`getCapability(issuerGUID, productCode, issuerProductPassword)`

This is a function that returns the capability data that was provided for the product definition from the supplier.

This data is meant to be some crucial data that is needed by the licensed software before it can function.

This data could be simple (e.g. a date, a max. usage count,...) or complex (e.g. a crucial segment of code that
is needed by the software).

The data is carried from the supplier to the customer by way of the activation file - this file has multiple levels
of encryption. It is encrypted using the supplier's private key (so it is 'signed' by the supplier, and the customer's
computer can decrypt it using the supplier's public key, which is retrieved from the registry), and encrypted using the
customer's public key (so the supplier knows only the customer can decrypt it using their private key), and finally, 
it is also encrypted using the `issuerProductPassword` - so the data is only available to some code that knows the password.

