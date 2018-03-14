# rust-openssl-static-example [![Build Status][travis.svg]][travis]

An example Rust project attempting to statically link OpenSSL into a shared library.

## Test Case

I have a shared library called `liblambda.so`. It must be a shared library because it is a Python C extension module
via the `cpython` crate and `crowbar`. The final result from compilation will be uploaded to AWS Lambda and run as a pseudo-Python Lambda function which
simply executes our Rust payload.

We use [a Docker container][docker] running the Lambda version of Amazon Linux for builds. This makes the execution
environment as close to the build environment as possible.

**The Problem:** AWS runs an old version of Amazon Linux without any software updates. However, in the Docker container
where I build my shared library, installing `openssl-devel` automatically upgrades OpenSSL from 1.0.1 to 1.0.2.
Therefore, it is not possible to build against the version of `openssl` which is present in the Amazon Linux image at
boot time; in the Docker image, simply by installing `openssl-devel` it is upgraded to 1.0.2, _which is not present
in the actual Amazon Linux runtime environment._ This causes the linker to panic as the shared library requires at least
1.0.2.

**The Attempted Solution:** By attempting to build OpenSSL statically into the shared library, we hope to work around
the issue by not linking against OpenSSL.

**Current Status:** **Not Working.** Despite following the instructions for the `openssl` crate and throwing in linker
configuration to the crate, the shared library is still linked against OpenSSL.

We have the following Cargo configuration:

```toml
[lib]
name = "lambda"
crate-type = ["cdylib"]

[dependencies]
cpython = { version = "0.1", default-features = false }
crowbar = { version = "0.2", default-features = false }
openssl = "0.10.5"
```

And finally, `lib.rs`:

```rust
#[macro_use(lambda)]
extern crate crowbar;
#[macro_use]
extern crate cpython;
#[link(name="openssl", kind="static")]
extern crate openssl;

lambda!(|_event, _context| {
    Ok(openssl::init())
});
```

Our test case:

```shell
cargo clean
OPENSSL_STATIC=1 cargo build --lib

if ldd target/debug/liblambda.so | grep -qiP 'ssl' ; then
  ldd target/debug/liblambda.so >&2
  echo "ERROR: Library is linked against OpenSSL." >&2
  exit 1
fi
```

The result:

```
Finished dev [unoptimized + debuginfo] target(s) in 0.0 secs
    linux-vdso.so.1 =>  (0x00007ffe10f1a000)
    libpython3.4m.so.1.0 => /usr/lib64/libpython3.4m.so.1.0 (0x00007fed9a0ff000)
    libssl.so.10 => /lib64/libssl.so.10 (0x00007fed99e8e000)
    libcrypto.so.10 => /lib64/libcrypto.so.10 (0x00007fed99a2f000)
    libdl.so.2 => /lib64/libdl.so.2 (0x00007fed9982b000)
    librt.so.1 => /lib64/librt.so.1 (0x00007fed99623000)
    libpthread.so.0 => /lib64/libpthread.so.0 (0x00007fed99406000)
    libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00007fed991f0000)
    libc.so.6 => /lib64/libc.so.6 (0x00007fed98e2c000)
    /lib64/ld-linux-x86-64.so.2 (0x00005573c3b0c000)
    libutil.so.1 => /lib64/libutil.so.1 (0x00007fed98c28000)
    libm.so.6 => /lib64/libm.so.6 (0x00007fed98926000)
    libgssapi_krb5.so.2 => /usr/lib64/libgssapi_krb5.so.2 (0x00007fed986d9000)
    libkrb5.so.3 => /usr/lib64/libkrb5.so.3 (0x00007fed983f0000)
    libcom_err.so.2 => /usr/lib64/libcom_err.so.2 (0x00007fed981ed000)
    libk5crypto.so.3 => /usr/lib64/libk5crypto.so.3 (0x00007fed97fba000)
    libz.so.1 => /lib64/libz.so.1 (0x00007fed97da3000)
    libkrb5support.so.0 => /usr/lib64/libkrb5support.so.0 (0x00007fed97b95000)
    libkeyutils.so.1 => /lib64/libkeyutils.so.1 (0x00007fed97991000)
    libresolv.so.2 => /lib64/libresolv.so.2 (0x00007fed97777000)
    libselinux.so.1 => /usr/lib64/libselinux.so.1 (0x00007fed97555000)
ERROR: Library is linked against OpenSSL.
```

## Executing Locally

Vagrant provides an all-in-one portable development environment in this workflow. `vagrant up` will provide a Vagrant
environment with Docker and Rust configured on the machine. Running `make clean build test` in Vagrant will clean
previous build data, spin up a Docker container for the build environment, build the project, and then report on
whether it was successful or not.

## License

Licensed at your discretion under either:

 - [MIT](./LICENSE-MIT)
 - [Apache License 2.0](./LICENSE-APACHE)

 [travis]: https://travis-ci.org/naftulikay/rust-openssl-static-example
 [travis.svg]: https://travis-ci.org/naftulikay/rust-openssl-static-example.svg?branch=master
 [docker]: https://hub.docker.com/r/naftulikay/circleci-amazonlinux-rust/
