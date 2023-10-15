# *axil_slave_fsm* verification plan

The current document describes a verification plan for
[axil_slave_fsm](../rtl/vga_axil_slave_fsm.sv) module. The plan is implemented in
[tb_axil_fsm](tb_axil_fsm.sv) module.

***[TOC]***
1.  [test suit](#test-suit)
1.  [list of tests](#list-of-tests)
    1.  [continuous test](#continuous)
    1.  [parallel test](#parallel)
    1.  [random test](#random)
    1.  [reset test](#reset)

## Test suit

An *associative array* acts as the *slave*.

## List of tests

1.  ### Continuous

    [*n* number] of [continuous(non parallel) write] of continuously incremented data values at
    continuously incremented addresses. *Example*: 0: 0, 8: 8, 16: 16, ...

    Then

    Read in the same way starting from the first written address.

    **Purpose**:

    Простая и предсказуемая схема формирования адреса и данных позволяет верифицировать даже
    по временным диаграммам без особых трудностей. Таким образом осуществляется начальная
    верификация дизайна, и ошибка, если она есть, выявляется на изи.

1.  ### Parallel

    [1 number] of [parallel read-write] [random address-data]
    transactions.

    The read packet is prewritten in the slave.

    **Purpose**:

    Этот тест проверяет на способность параллельной работы каналов чтения-записи. Да помогут нам
    ассерты.

1.  ### Random

    [*n* number] of [independent(maybe parallel) read-write] [arbitrary delay] [random address-data]
    transactions.

    Reading is performed from the written address pool.

    **Purpose**:

    Стандартный верификационный тест. Уповаем на удачу, что ошибка сама себя обнаружит.

1.  ### Reset

    One asynchronous reset in a middle of [random test](#random).

    **Purpose**:

    Стандартный верификационный тест.
