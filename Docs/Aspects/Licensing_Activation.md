# Licensing and Activation

Tightener uses a privacy-centric, distributed licensing system based on **Capabilities**. Unlike traditional licensing servers that track "seats" directly against user data, the central registry manages anonymous capability slots and holds no identifiable user data — only GUIDs and public keys.

The "truth" about what a license entails (features, expiry, etc.) is embedded in an encrypted capability file held by the user, not the server. Software is installed independently of licensing (via a `.tpkg` package) and may run in a demo/unlicensed mode until a capability is activated, either through an integrated store purchase flow or a manual license request to the developer.
