# News

## [0.10.3](https://github.com/stencila/rasta/compare/v0.10.2...v0.10.3) (2021-10-11)


### Bug Fixes

* **Codec:** Return Stencila entities ([1e1adfc](https://github.com/stencila/rasta/commit/1e1adfceaec5120abce1a35d1176e0663677913d))

## [0.10.2](https://github.com/stencila/rasta/compare/v0.10.1...v0.10.2) (2021-02-02)


### Bug Fixes

* **Deps:** Update Stencila Schema ([6d44bd6](https://github.com/stencila/rasta/commit/6d44bd6a7473d3bf143f6d6d6bbf3e872d010a52))

## [0.10.1](https://github.com/stencila/rasta/compare/v0.10.0...v0.10.1) (2021-02-02)


### Bug Fixes

* **Encoding:** Handle errors and supress warnings when decoding outputs ([90a1b9a](https://github.com/stencila/rasta/commit/90a1b9a5c137a39b6abfb983b61db4af4181fa3b)), closes [#6](https://github.com/stencila/rasta/issues/6)
* **Server:** Call own log ([46a29ee](https://github.com/stencila/rasta/commit/46a29eea54a56b6fb665591f54c6a1f1951b4a1e))

# [0.10.0](https://github.com/stencila/rasta/compare/v0.9.0...v0.10.0) (2020-12-23)


### Bug Fixes

* **Codec:** Skip some data.frame column types ([48eb94b](https://github.com/stencila/rasta/commit/48eb94baaafad8aed5c73d46b1049ee39e19a382))


### Features

* **Codec:** Add row names as a new column ([6fbab53](https://github.com/stencila/rasta/commit/6fbab53cc58a64d352ffb5d741203beadf243f2e))

# [0.9.0](https://github.com/stencila/rasta/compare/v0.8.1...v0.9.0) (2020-10-01)


### Bug Fixes

* **Deps:** Upgrade Schema version ([d4f4e5b](https://github.com/stencila/rasta/commit/d4f4e5b9650ad35e85d57110bd5a546ad1fb6ab0))
* **Server:** Reduce the size of debug log entries ([fff41d8](https://github.com/stencila/rasta/commit/fff41d88899bd8412373d532fe1b286503ac4a05))


### Features

* **Logging:** Allow stack to be passed to error method ([c375752](https://github.com/stencila/rasta/commit/c375752e7fd9ecc19e3b063169190ace99581ef4))

## [0.8.1](https://github.com/stencila/rasta/compare/v0.8.0...v0.8.1) (2020-09-10)


### Bug Fixes

* **Interpreter:** Group recordedplot outputs ([0fe994d](https://github.com/stencila/rasta/commit/0fe994d4be238a44a748b5b7adb0089d4f06aca8)), closes [#3](https://github.com/stencila/rasta/issues/3)

# [0.8.0](https://github.com/stencila/rasta/compare/v0.7.1...v0.8.0) (2020-09-10)


### Features

* **PipeServer:** Remove unused server class ([5001f4c](https://github.com/stencila/rasta/commit/5001f4c6950126d53fa04405d2c838541218d597))

## [0.7.1](https://github.com/stencila/rasta/compare/v0.7.0...v0.7.1) (2020-08-14)


### Bug Fixes

* Improve serialization to/from JSON ([3f148d3](https://github.com/stencila/rasta/commit/3f148d35f29a6e4b242bf086147e42a3e5064209))

# [0.7.0](https://github.com/stencila/rasta/compare/v0.6.0...v0.7.0) (2020-08-13)


### Features

* **Interpreter:** Allow setting of chunk options using comments ([a53b19f](https://github.com/stencila/rasta/commit/a53b19f403fcad71b6c1df222104a5f27500dc89))

# [0.6.0](https://github.com/stencila/rasta/compare/v0.5.2...v0.6.0) (2020-08-11)


### Bug Fixes

* **Messages:** Send other messages to the log. ([a91fe32](https://github.com/stencila/rasta/commit/a91fe32d43adca2a6cc6976035e4e237b31725c5))
* **Warnings:** Send code chunk warning messages to log instead of output ([dc4b19e](https://github.com/stencila/rasta/commit/dc4b19e2e9e2b5cc49d193d839a3c710956e30db))


### Features

* **Interpreter:** Handle fig.width and fig.height options ([f721587](https://github.com/stencila/rasta/commit/f7215871f8223650117f2f9911d005ac5c8eaca2))

## [0.5.2](https://github.com/stencila/rasta/compare/v0.5.1...v0.5.2) (2020-05-17)


### Bug Fixes

* **Logger:** Fix spelling mistake in assignment of fallback ([4095d67](https://github.com/stencila/rasta/commit/4095d674b1a28a534ae6ea748218433125fcad1b))

## [0.5.1](https://github.com/stencila/rasta/compare/v0.5.0...v0.5.1) (2020-03-13)


### Bug Fixes

* **Dependencies:** Upgrade and pin to Schema 0.42.0 ([f6decf7](https://github.com/stencila/rasta/commit/f6decf7c39591cebee655bc7ff599884d782c734))

# [0.5.0](https://github.com/stencila/rasta/compare/v0.4.1...v0.5.0) (2020-02-07)


### Bug Fixes

* **JSON:** Suppress warning in toJSON ([c3cfc33](https://github.com/stencila/rasta/commit/c3cfc33a0f778e37cc68f350da0d0890223447e5))


### Features

* **Codec:** Add support for decoding more R types ([f3ef158](https://github.com/stencila/rasta/commit/f3ef1580b85edea7e801899879921c0afd672122))
* **Decode:** Add handling of table values. ([35013a0](https://github.com/stencila/rasta/commit/35013a05991a2268b7df38f4dfd49c5660708ca0))
* **Logger:** Allow get / set of log handler ([b8f3a6a](https://github.com/stencila/rasta/commit/b8f3a6abf3d6eaf0869d4338132f2aa6a9385328))

## [0.4.1](https://github.com/stencila/rasta/compare/v0.4.0...v0.4.1) (2020-02-06)


### Bug Fixes

* **Decode:** Remove incorrect use of graphics::replayPlot ([ccbae8f](https://github.com/stencila/rasta/commit/ccbae8f72b207d40d2ac902f5a84fb9d118ecae6)), closes [#1](https://github.com/stencila/rasta/issues/1)

# [0.4.0](https://github.com/stencila/rasta/compare/v0.3.0...v0.4.0) (2020-02-05)


### Bug Fixes

* **Interpreter:** Upgrade to new schema API ([1304994](https://github.com/stencila/rasta/commit/13049946f2a4be0cc3e502e5f87e83ffce2aaebb))
* **Interpreter:** Use stencilaschema types ([411c83b](https://github.com/stencila/rasta/commit/411c83b8ab461334f5f30c11755d4ba52d4489ac))
* **Package:** Add necessary imports ([c24b1a3](https://github.com/stencila/rasta/commit/c24b1a30a02792116fcff88601a889e4902557dc))
* **Server:** Add more logging ([9ab15a0](https://github.com/stencila/rasta/commit/9ab15a09b523b21ed90fc272b1d32eaecb8a6f4d))


### Features

* **Decoding:** Add module for decoding R objects to nodes ([c38f99c](https://github.com/stencila/rasta/commit/c38f99c3dfc1ccab1c5830ba1556e15e68bb46e8))

# [0.3.0](https://github.com/stencila/rasta/compare/v0.2.0...v0.3.0) (2020-01-08)


### Bug Fixes

* **RCpp:** Do not gitignore Rccp exports ([b564a96](https://github.com/stencila/rasta/commit/b564a968970ac8b33d304ce4ce84c1e4a95393a0)), closes [/travis-ci.org/stencila/rasta/jobs/633566076#L807](https://github.com//travis-ci.org/stencila/rasta/jobs/633566076/issues/L807)


### Features

* **Message streams:** Allow incoming stream to be non-blocking ([e732df3](https://github.com/stencila/rasta/commit/e732df3056fb846cc3f3efb6d9f95b45915b9ded))
* **Message streams:** C++ implementation of length-prefixed message streams ([c25cd97](https://github.com/stencila/rasta/commit/c25cd974235f303618a3369134c89471a3177924))
* **PipeServer:** Add server using names pipes ([5603a69](https://github.com/stencila/rasta/commit/5603a69240ae8905bff7dcd5dbfe2dad7d010c1c))
* **tmp_dir:** Add function to return OS-specific temporary directory ([d77d7e1](https://github.com/stencila/rasta/commit/d77d7e179e91082db1518bced9e672a9f6320701))

# [0.2.0](https://github.com/stencila/rasta/compare/v0.1.2...v0.2.0) (2020-01-05)


### Bug Fixes

* **StreamServer:** Open error file on start() and  close on stop() ([5db990a](https://github.com/stencila/rasta/commit/5db990a731d9259bf4247002584f10dc3607d359))


### Features

* **Server and Interpreter:** Allow for receive and dispatch methods to be async ([19f0c99](https://github.com/stencila/rasta/commit/19f0c9904146afccede71a286f405371794b57dd))
* **Session state:** Persist environment across calls to execute ([56fc7f5](https://github.com/stencila/rasta/commit/56fc7f552669d16f7a363d284cc42d8b63632405))


## [0.1.2](https://github.com/stencila/rasta/compare/v0.1.1...v0.1.2) (2020-01-03)


### Bug Fixes

* **Releases:** Configure committing of NEWS.md and DESCRIPTION. ([40f2121](https://github.com/stencila/rasta/commit/40f21217ebae800f3380829448a54a19c8ee915d))
