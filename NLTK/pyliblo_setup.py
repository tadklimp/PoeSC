# from __future__ import print_function
import liblo, sys

# send all messages to port 1234 on the local machine
try:
    target = liblo.Address(57120)
except liblo.AddressError as err:
    print(err)
    sys.exit()

# send message "/foo/message1" with int, float and string arguments
# liblo.send(target, "/msg", 123, 456.789)

# send double, int64 and char
# liblo.send(target, "/foo/message2", ('d', 3.1415), ('h', 2**42), ('c', 'x'))

# we can also build a message object first...
msg = liblo.Message("/msg")
# ... append arguments later...
msg.add(123, "foo")
msg.add(123, "foo")
msg.add(123, "foo")
# msg.add(1,2,3, "foo", [1])
msg.add([1,1,2])
# ... and then send it
liblo.send(target, msg)


fafa = ["try",1, ["tree",1,2], 'U', (1,2,"pool")]
for f in fafa:
    print(f.__class__)

# send a list of bytes as a blob
# blob = [0, 21, 15, 16, 23, 42]
# liblo.send(target, "/msg", blob)

# wrap a message in a bundle, to be dispatched after 2 seconds
# bundle = liblo.Bundle(liblo.time() + 2.0, liblo.Message("/blubb", 123))
# liblo.send(target, bundle)