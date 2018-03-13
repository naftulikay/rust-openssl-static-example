#[macro_use(lambda)]
extern crate crowbar;
#[macro_use]
extern crate cpython;
#[link(name="openssl", kind="static")]
extern crate openssl;

lambda!(|_event, _context| {
    Ok(openssl::init())
});
