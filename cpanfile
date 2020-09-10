requires 'IPC::Run3';
requires 'Path::Tiny';

on 'test' => sub {
    requires 'List::Util';
    requires 'Test::More';
    requires 'Test::Deep';
    requires 'Test::Alien';
    requires 'FFI::Platypus';
};
