# News

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
