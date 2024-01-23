# encrypt

`encrypt(string, aesKey[ , aesIV ])`

This function encrypts a Base64-encoded string that can be decrypted by the [`decrypt`](decrypt.md) function.

The encryption algorithm is AES, and the function accepts a key string and an initial vector (IV) string.

The aesIV can be omitted in which case the function will generate and IV from the aesKey.

