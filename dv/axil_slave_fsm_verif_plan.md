# *axil_slave_fsm* verification plan

The current document describes a verification plan for
[axil_slave_fsm](../rtl/vga_axil_slave_fsm.sv) module. The plan is implemented in
[tb_axil_fsm](tb_axil_fsm.sv) module.

## Test suit

An *associative array* acts as the *slave*.

## List of tests

1.  ### Continuous

    [*n* number] of [sequential(non parallel) write] of sequentially incremented data values at
    sequentially incremented addresses. *Example*: 0: 0, 8: 8, 16: 16, ...

    Then

    Read in the same way starting from the first written address.

1.  ### Random

    [*n* number] of [independent(maybe parallel) read-write] [arbitrary delay] [random address-data]
    transactions.

1.  ### Reset

    One asynchronous reset in a middle of [random test](#random).
