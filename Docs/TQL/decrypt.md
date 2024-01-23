# decrypt

`decrypt(string, aesKey[ , aesIV ])`

This function decrypts an encrypted string that was returned by the [`encrypt`](encrypt.md) function.

The encryption algorithm is AES, and the function accepts a key string and an initial vector (IV) string.

The aesIV can be omitted in which case the function will generate and IV from the aesKey.

