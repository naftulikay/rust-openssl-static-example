#[macro_use(lambda)]
extern crate crowbar;
#[macro_use]
extern crate cpython;
#[link(name="openssl", kind="static")]
extern crate openssl;
#[link(name="openssl", kind="static")]
extern crate openssl_sys;

lambda!(|_event, _context| {
    Ok(openssl::init())
});
