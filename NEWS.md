# News

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
